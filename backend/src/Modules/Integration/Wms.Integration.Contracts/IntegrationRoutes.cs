namespace Wms.Integration.Contracts;

/// <summary>Integration (1C adapter, outbox consumer) depends only on Contracts (spec §5).</summary>
public static class IntegrationRoutes
{
    public const string ModuleName = "Integration";
    public const string Prefix = "/api/v1/integration";
}
