namespace Wms.Common.Infrastructure.Modules;

/// <summary>Response of every module's <c>GET /ping</c> endpoint.</summary>
public sealed record ModulePing(string Module, uint TenantId, string User, DateTimeOffset ServerTimeUtc);
