using System.Text.Json;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Consumption.Application;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Commands.SalesImports;
using Wms.Consumption.Application.Queries;
using Wms.Consumption.Contracts;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Endpoints;

/// <summary>
/// Operations <c>listSalesImports</c>, <c>createSalesImport</c>, <c>uploadSalesCsv</c>, <c>getSalesImport</c>,
/// <c>updateSalesImport</c>, <c>submitSalesImport</c>.
/// </summary>
public static class SalesImportEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/sales-imports", ListAsync)
            .RequirePermission(ConsumptionPermissions.SalesImport)
            .WithName("listSalesImports");

        group.MapPost("/sales-imports", CreateAsync)
            .RequirePermission(ConsumptionPermissions.SalesImport)
            .RequireIdempotencyKey()
            .WithName("createSalesImport");

        group.MapPost("/sales-imports/upload-csv", UploadCsvAsync)
            .RequirePermission(ConsumptionPermissions.SalesImport)
            .RequireIdempotencyKey()
            .DisableAntiforgery()
            .WithName("uploadSalesCsv");

        group.MapGet("/sales-imports/{id:long}", GetAsync)
            .RequirePermission(ConsumptionPermissions.SalesImport)
            .WithName("getSalesImport");

        group.MapPut("/sales-imports/{id:long}", UpdateAsync)
            .RequirePermission(ConsumptionPermissions.SalesImport)
            .WithName("updateSalesImport");

        group.MapPost("/sales-imports/{id:long}/submit", SubmitAsync)
            .RequirePermission(ConsumptionPermissions.SalesImport)
            .RequireIdempotencyKey()
            .WithName("submitSalesImport");
    }

    private static async Task<IResult> ListAsync(
        [AsParameters] SalesImportsRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var query = new GetSalesImportsQuery(
            request.LocationId, request.DateFrom, request.DateTo, request.Status, request.Source,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateAsync(
        SalesImportCreateRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new CreateSalesImportCommand(
            request.LocationId,
            request.BusinessDate,
            request.Source,
            request.ExternalRef,
            (request.Lines ?? []).Select(l => l.ToInput()).ToList());
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ConsumptionRoutes.Prefix}/sales-imports/{dto.Id}", dto));
    }

    /// <summary>
    /// <c>multipart/form-data</c>: <c>locationId</c>, <c>businessDate</c>, optional <c>externalRef</c> and
    /// <c>columnMapping</c> (a JSON object), plus the <c>file</c> part. Above 5 MB the upload is refused with
    /// <c>422 FILE_TOO_LARGE</c> before the body is read into memory.
    /// </summary>
    private static async Task<IResult> UploadCsvAsync(HttpRequest httpRequest, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(httpRequest);
        if (!httpRequest.HasFormContentType)
        {
            return new Error("VALIDATION_FAILED", "The endpoint expects multipart/form-data with a 'file' part.", 400).ToProblem();
        }

        var form = await httpRequest.ReadFormAsync(cancellationToken).ConfigureAwait(false);
        var file = form.Files["file"] ?? form.Files.FirstOrDefault();
        if (file is null || file.Length == 0)
        {
            return new Error("VALIDATION_FAILED", "The 'file' part is missing or empty.", 400).ToProblem();
        }

        if (file.Length > SalesCsvLimits.MaxBytes)
        {
            return ConsumptionErrors.FileTooLarge(file.Length, SalesCsvLimits.MaxBytes).ToProblem();
        }

        if (!uint.TryParse(form["locationId"], out var locationId) || locationId == 0)
        {
            return new Error("VALIDATION_FAILED", "'locationId' is required.", 400).ToProblem();
        }

        if (!DateOnly.TryParse(form["businessDate"], System.Globalization.CultureInfo.InvariantCulture, out var businessDate))
        {
            return new Error("VALIDATION_FAILED", "'businessDate' is required in yyyy-MM-dd format.", 400).ToProblem();
        }

        SalesCsvColumnMapping? mapping = null;
        var rawMapping = form["columnMapping"].ToString();
        if (!string.IsNullOrWhiteSpace(rawMapping))
        {
            try
            {
                mapping = JsonSerializer.Deserialize<SalesCsvColumnMapping>(rawMapping, JsonOptions);
            }
            catch (JsonException ex)
            {
                return new Error("VALIDATION_FAILED", $"'columnMapping' is not valid JSON: {ex.Message}", 400).ToProblem();
            }
        }

        using var buffer = new MemoryStream();
        await using (var stream = file.OpenReadStream())
        {
            await stream.CopyToAsync(buffer, cancellationToken).ConfigureAwait(false);
        }

        var externalRef = form["externalRef"].ToString();
        var command = new UploadSalesCsvCommand(
            locationId,
            businessDate,
            string.IsNullOrWhiteSpace(externalRef) ? null : externalRef,
            mapping,
            buffer.ToArray());

        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ConsumptionRoutes.Prefix}/sales-imports/{dto.SalesImport.Id}", dto));
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetSalesImportQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> UpdateAsync(
        long id,
        SalesImportUpdateRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var command = new UpdateSalesImportCommand(id, request.RowVersion, (request.Lines ?? []).Select(l => l.ToInput()).ToList());
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> SubmitAsync(
        long id,
        VersionedActionRequest? request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var result = await dispatcher.SendAsync(new SubmitSalesImportCommand(id, request?.RowVersion), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    /// <summary>Kept to make the enum reachable from the OpenAPI document even when no import exists yet.</summary>
    internal static SalesSource DefaultSource => SalesSource.Manual;
}
