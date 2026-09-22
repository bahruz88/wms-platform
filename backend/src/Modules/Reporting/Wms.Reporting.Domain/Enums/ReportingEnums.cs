namespace Wms.Reporting.Domain.Enums;

/// <summary><c>ReportCategory</c> of reporting.v1.yaml — how the catalogue is grouped in the UI.</summary>
public enum ReportCategory
{
    Stock,
    Movement,
    Quality,
    Procurement,
    Finance,
    Audit,
}

/// <summary><c>ParamType</c> of reporting.v1.yaml — the client builds the form from it.</summary>
public enum ReportParamType
{
    Date,
    DateRange,
    Location,
    Locations,
    Product,
    Products,
    Category,
    Supplier,
    Enum,
    Boolean,
    Int,
    Decimal,
    Text,
}

/// <summary>
/// <c>ColumnType</c> of reporting.v1.yaml. <c>Datetime</c> is deliberately spelled with a lower-case <c>t</c>:
/// the platform serialises enums with <see cref="System.Text.Json.JsonNamingPolicy.SnakeCaseUpper"/>
/// (README §8.10) and the contract's value is <c>DATETIME</c>, not <c>DATE_TIME</c>.
/// </summary>
public enum ReportColumnType
{
    String,
    Int,
    Decimal,
    Percent,
    Money,
    Date,
    Datetime,
    Boolean,
    Enum,
    Link,
}

/// <summary><c>ReportColumn.align</c> of reporting.v1.yaml.</summary>
public enum ColumnAlign
{
    Left,
    Right,
    Center,
}

/// <summary><c>ExportFormat</c> of reporting.v1.yaml.</summary>
public enum ExportFormat
{
    Xlsx,
    Csv,
    Pdf,
}

/// <summary><c>ExportStatus</c> of reporting.v1.yaml.</summary>
public enum ExportStatus
{
    Queued,
    Running,
    Completed,
    Failed,
    Cancelled,
}
