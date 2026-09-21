using System.Buffers;
using System.Buffers.Binary;
using System.Net.Sockets;
using System.Text;
using Microsoft.Extensions.Options;
using Wms.Common.Domain;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Domain;

namespace Wms.Documents.Infrastructure.Antivirus;

/// <summary>
/// clamd <c>INSTREAM</c> over plain TCP (spec §11). The protocol is tiny, so it is written by hand rather
/// than pulling in another package: send <c>zINSTREAM\0</c>, then length-prefixed chunks (4-byte big-endian),
/// then a zero-length chunk, then read the NUL-terminated verdict.
/// Fails closed — if clamd cannot be reached the upload is not completed.
/// </summary>
public sealed class ClamAvVirusScanner(IOptions<AntivirusOptions> options, ILogger<ClamAvVirusScanner> logger) : IVirusScanner
{
    private const int ChunkSize = 32 * 1024;
    private const int MaxResponseBytes = 4096;
    private static readonly byte[] InStreamCommand = Encoding.ASCII.GetBytes("zINSTREAM\0");

    private readonly AntivirusOptions _options = options?.Value ?? throw new ArgumentNullException(nameof(options));

    public bool IsEnabled => _options.Enabled;

    public async Task<Result<ScanVerdict>> ScanAsync(Stream content, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(content);
        if (!_options.Enabled)
        {
            return Result.Success(ScanVerdict.Clean);
        }

        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        timeout.CancelAfter(_options.Timeout);

        try
        {
            var response = await ExchangeAsync(content, timeout.Token).ConfigureAwait(false);
            return ClamAvResponse.Parse(response);
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            logger.LogError(
                "clamd at {Host}:{Port} did not answer within {Timeout}",
                _options.Host,
                _options.Port,
                _options.Timeout);
            return DocumentsErrors.VirusScanUnavailable();
        }
        catch (SocketException ex)
        {
            logger.LogError(ex, "clamd at {Host}:{Port} is unreachable", _options.Host, _options.Port);
            return DocumentsErrors.VirusScanUnavailable();
        }
        catch (IOException ex)
        {
            logger.LogError(ex, "The clamd INSTREAM exchange with {Host}:{Port} failed", _options.Host, _options.Port);
            return DocumentsErrors.VirusScanUnavailable();
        }
    }

    private async Task<string> ExchangeAsync(Stream content, CancellationToken cancellationToken)
    {
        using var client = new TcpClient();
        await client.ConnectAsync(_options.Host, _options.Port, cancellationToken).ConfigureAwait(false);

        await using var network = client.GetStream();
        await network.WriteAsync(InStreamCommand, cancellationToken).ConfigureAwait(false);

        var buffer = ArrayPool<byte>.Shared.Rent(ChunkSize);
        try
        {
            var length = new byte[4];
            int read;
            while ((read = await content.ReadAsync(buffer.AsMemory(0, ChunkSize), cancellationToken).ConfigureAwait(false)) > 0)
            {
                BinaryPrimitives.WriteInt32BigEndian(length, read);
                await network.WriteAsync(length, cancellationToken).ConfigureAwait(false);
                await network.WriteAsync(buffer.AsMemory(0, read), cancellationToken).ConfigureAwait(false);
            }

            BinaryPrimitives.WriteInt32BigEndian(length, 0);
            await network.WriteAsync(length, cancellationToken).ConfigureAwait(false);
            await network.FlushAsync(cancellationToken).ConfigureAwait(false);
        }
        finally
        {
            ArrayPool<byte>.Shared.Return(buffer);
        }

        return await ReadResponseAsync(network, cancellationToken).ConfigureAwait(false);
    }

    private static async Task<string> ReadResponseAsync(Stream network, CancellationToken cancellationToken)
    {
        var response = new byte[MaxResponseBytes];
        var total = 0;
        while (total < MaxResponseBytes)
        {
            var read = await network.ReadAsync(response.AsMemory(total, MaxResponseBytes - total), cancellationToken).ConfigureAwait(false);
            if (read == 0)
            {
                break;
            }

            total += read;
            if (Array.IndexOf(response, (byte)0, 0, total) >= 0)
            {
                break;
            }
        }

        return Encoding.ASCII.GetString(response, 0, total);
    }
}

/// <summary>Parses the single line clamd answers an <c>INSTREAM</c> with.</summary>
public static class ClamAvResponse
{
    /// <summary>
    /// <c>stream: OK</c> → clean, <c>stream: &lt;signature&gt; FOUND</c> → infected,
    /// anything else (including <c>… ERROR</c> and an empty answer) → the scanner could not give a verdict.
    /// </summary>
    public static Result<ScanVerdict> Parse(string? response)
    {
        var line = (response ?? string.Empty).Replace("\0", string.Empty, StringComparison.Ordinal).Trim();
        if (line.Length == 0)
        {
            return DocumentsErrors.VirusScanUnavailable();
        }

        if (line.EndsWith("OK", StringComparison.Ordinal) && !line.Contains("FOUND", StringComparison.Ordinal))
        {
            return Result.Success(ScanVerdict.Clean);
        }

        if (line.EndsWith("FOUND", StringComparison.Ordinal))
        {
            return Result.Success(ScanVerdict.Infected(ExtractSignature(line)));
        }

        return DocumentsErrors.VirusScanUnavailable();
    }

    private static string ExtractSignature(string line)
    {
        var body = line[..^"FOUND".Length].TrimEnd();
        var colon = body.IndexOf(':', StringComparison.Ordinal);
        var signature = (colon >= 0 ? body[(colon + 1)..] : body).Trim();
        return signature.Length == 0 ? "unknown" : signature;
    }
}

/// <summary>Used when <c>Antivirus__Enabled=false</c>: every object is reported clean and marked <c>SKIPPED</c>.</summary>
public sealed class DisabledVirusScanner : IVirusScanner
{
    public bool IsEnabled => false;

    public Task<Result<ScanVerdict>> ScanAsync(Stream content, CancellationToken cancellationToken) =>
        Task.FromResult(Result.Success(ScanVerdict.Clean));
}
