using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Application.Commands.SalesImports;

/// <summary>
/// <c>POST /api/v1/consumption/sales-imports/upload-csv</c> (operationId <c>uploadSalesCsv</c>).
/// Parses the POS export and creates the DRAFT document. Rows that cannot be read come back in
/// <c>parseErrors</c>; the rest are written (contract). A file above 5 MB is rejected with
/// <c>422 FILE_TOO_LARGE</c>.
/// </summary>
public sealed record UploadSalesCsvCommand(
    uint LocationId,
    DateOnly BusinessDate,
    string? ExternalRef,
    SalesCsvColumnMapping? ColumnMapping,
    byte[] Content) : ICommand<SalesImportParseResultDto>;

public sealed class UploadSalesCsvCommandValidator : AbstractValidator<UploadSalesCsvCommand>
{
    public UploadSalesCsvCommandValidator()
    {
        RuleFor(c => c.LocationId).GreaterThan(0u);
        RuleFor(c => c.Content).NotNull();
    }
}

public sealed class UploadSalesCsvCommandHandler(
    ISalesCsvParser parser,
    IDispatcher dispatcher,
    IConsumptionQueries queries) : ICommandHandler<UploadSalesCsvCommand, SalesImportParseResultDto>
{
    public async Task<Result<SalesImportParseResultDto>> HandleAsync(UploadSalesCsvCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);

        if (command.Content.LongLength > SalesCsvLimits.MaxBytes)
        {
            return ConsumptionErrors.FileTooLarge(command.Content.LongLength, SalesCsvLimits.MaxBytes);
        }

        var parsed = parser.Parse(command.Content, command.ColumnMapping);
        if (parsed.Rows.Count == 0 && parsed.Errors.Count == 0)
        {
            return ConsumptionErrors.CsvParseFailed("The file contains no data rows.");
        }

        if (parsed.Rows.Count == 0)
        {
            return ConsumptionErrors.CsvParseFailed(
                $"No row of the file could be read ({parsed.Errors.Count} error(s)); the first one is: {parsed.Errors[0].Message}");
        }

        // Identical POS codes are summed: a POS export often lists one row per shift.
        var lines = parsed.Rows
            .GroupBy(r => r.PosCode, StringComparer.OrdinalIgnoreCase)
            .Select(g => new SalesLineInput(null, g.Key, g.Sum(r => r.QtySold), g.Any(r => r.GrossAmount is not null) ? g.Sum(r => r.GrossAmount ?? 0m) : null))
            .ToList();

        var created = await dispatcher
            .SendAsync(new CreateSalesImportCommand(command.LocationId, command.BusinessDate, SalesSource.Csv, command.ExternalRef, lines), cancellationToken)
            .ConfigureAwait(false);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var detail = await queries.GetSalesImportAsync(created.Value.Id, command.BusinessDate, cancellationToken).ConfigureAwait(false);
        if (detail is null)
        {
            return ConsumptionErrors.SalesImportNotFound(created.Value.Id);
        }

        var errors = parsed.Errors.Select(e => new CsvParseErrorDto(e.RowNumber, e.RawLine, e.Message)).ToList();
        return new SalesImportParseResultDto(detail, parsed.Rows.Count, errors);
    }
}
