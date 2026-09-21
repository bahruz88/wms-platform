using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using Wms.Documents.Infrastructure.Antivirus;
using Wms.Documents.Infrastructure.Storage;

namespace Wms.Documents.UnitTests;

/// <summary>clamd answers one NUL-terminated line; anything that is not a verdict must fail closed.</summary>
public sealed class ClamAvResponseTests
{
    [Theory]
    [InlineData("stream: OK\0")]
    [InlineData("stream: OK")]
    [InlineData("  stream: OK  ")]
    public void A_clean_stream_is_clean(string response)
    {
        var result = ClamAvResponse.Parse(response);

        Assert.True(result.IsSuccess);
        Assert.True(result.Value.IsClean);
        Assert.Equal("CLEAN", result.Value.ToScanResult(scannerEnabled: true));
    }

    [Theory]
    [InlineData("stream: Eicar-Test-Signature FOUND\0", "Eicar-Test-Signature")]
    [InlineData("stream: Win.Test.EICAR_HDB-1 FOUND", "Win.Test.EICAR_HDB-1")]
    public void An_infected_stream_carries_the_signature(string response, string signature)
    {
        var result = ClamAvResponse.Parse(response);

        Assert.True(result.IsSuccess);
        Assert.False(result.Value.IsClean);
        Assert.Equal(signature, result.Value.Signature);
        Assert.Equal($"INFECTED:{signature}", result.Value.ToScanResult(scannerEnabled: true));
    }

    [Theory]
    [InlineData("")]
    [InlineData("\0")]
    [InlineData("INSTREAM size limit exceeded. ERROR\0")]
    [InlineData("UNKNOWN COMMAND\0")]
    public void Anything_else_fails_closed(string response)
    {
        var result = ClamAvResponse.Parse(response);

        Assert.True(result.IsFailure);
        Assert.Equal("VIRUS_SCAN_UNAVAILABLE", result.Error.Code);
        Assert.Equal(503, result.Error.Status);
    }

    [Fact]
    public async Task The_disabled_scanner_reports_clean_and_SKIPPED()
    {
        var scanner = new DisabledVirusScanner();

        var result = await scanner.ScanAsync(Stream.Null, TestCancellation.Token);

        Assert.False(scanner.IsEnabled);
        Assert.True(result.IsSuccess);
        Assert.Equal("SKIPPED", result.Value.ToScanResult(scannerEnabled: false));
    }

    [Fact]
    public async Task A_disabled_clamav_scanner_does_not_open_a_socket()
    {
        var options = Options.Create(new AntivirusOptions { Enabled = false, Host = "no-such-host.invalid" });
        var scanner = new ClamAvVirusScanner(options, NullLogger<ClamAvVirusScanner>.Instance);

        var result = await scanner.ScanAsync(new MemoryStream([1, 2, 3]), TestCancellation.Token);

        Assert.False(scanner.IsEnabled);
        Assert.True(result.IsSuccess);
    }

    [Fact]
    public void The_default_clamd_port_is_3310()
    {
        var options = new AntivirusOptions();

        Assert.Equal(3310, options.Port);
        Assert.False(options.Enabled);
        Assert.Equal(TimeSpan.FromSeconds(30), options.Timeout);
    }
}

/// <summary>
/// <c>Minio__PublicEndpoint</c> exists because a presigned URL is bound to the host it was signed for:
/// inside compose the API talks to <c>minio:9000</c>, but the browser can only reach <c>localhost:9000</c>.
/// </summary>
public sealed class MinioOptionsTests
{
    [Theory]
    [InlineData("minio:9000", "minio", 9000, false)]
    [InlineData("localhost:9000", "localhost", 9000, false)]
    [InlineData("http://localhost:9000", "localhost", 9000, false)]
    [InlineData("https://s3.example.com", "s3.example.com", 443, true)]
    [InlineData("https://s3.example.com:9443", "s3.example.com", 9443, true)]
    [InlineData("storage.internal", "storage.internal", 80, false)]
    public void An_endpoint_is_parsed_into_host_port_and_scheme(string value, string host, int port, bool ssl)
    {
        var endpoint = MinioEndpoint.Parse(value, defaultUseSsl: false);

        Assert.Equal(host, endpoint.Host);
        Assert.Equal(port, endpoint.Port);
        Assert.Equal(ssl, endpoint.UseSsl);
    }

    [Fact]
    public void The_signing_endpoint_falls_back_to_the_internal_one()
    {
        Assert.Equal("minio:9000", new MinioOptions { Endpoint = "minio:9000" }.SigningEndpoint);
        Assert.Equal("minio:9000", new MinioOptions { Endpoint = "minio:9000", PublicEndpoint = "   " }.SigningEndpoint);
        Assert.Equal(
            "localhost:9000",
            new MinioOptions { Endpoint = "minio:9000", PublicEndpoint = "localhost:9000" }.SigningEndpoint);
    }

    [Fact]
    public void The_default_link_lifetimes_match_the_contract()
    {
        var options = new MinioOptions();

        Assert.Equal(TimeSpan.FromMinutes(15), options.UploadUrlLifetime);
        Assert.Equal(TimeSpan.FromMinutes(5), options.DownloadUrlLifetime);
        Assert.Equal("wms-attachments", options.Bucket);
    }

    [Theory]
    [InlineData(false, "attachment")]
    [InlineData(true, "inline")]
    public void The_download_disposition_follows_the_inline_flag(bool inline, string expected)
    {
        var disposition = MinioObjectStorage.ContentDisposition("qaimə.pdf", inline);

        Assert.StartsWith(expected + "; filename=\"", disposition, StringComparison.Ordinal);
        Assert.Contains("filename*=UTF-8''", disposition, StringComparison.Ordinal);
    }

    [Fact]
    public void A_file_name_cannot_break_out_of_the_content_disposition_header()
    {
        var disposition = MinioObjectStorage.ContentDisposition("evil\";\r\nX-Injected: 1\".pdf", inline: false);

        Assert.DoesNotContain("\r", disposition, StringComparison.Ordinal);
        Assert.DoesNotContain("\n", disposition, StringComparison.Ordinal);
        Assert.Equal(2, disposition.Count(c => c == '"'));
    }
}
