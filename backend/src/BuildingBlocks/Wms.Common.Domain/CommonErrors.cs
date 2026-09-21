namespace Wms.Common.Domain;

/// <summary>Errors shared by every module.</summary>
public static class CommonErrors
{
    public static Error NotFound(string entity, object id) =>
        new("NOT_FOUND", $"{entity} '{id}' was not found.", 404);

    public static Error Validation(IReadOnlyDictionary<string, string[]> details) =>
        new("VALIDATION_FAILED", "One or more validation errors occurred.", 400, details);

    public static Error Conflict(string code, string message) => new(code, message, 409);

    public static Error Unprocessable(string code, string message) => new(code, message, 422);

    public static Error Forbidden(string permission) =>
        new("FORBIDDEN", $"Missing permission '{permission}'.", 403);

    public static Error StaleVersion() =>
        new("STALE_VERSION", "The record was modified by another user. Reload and retry.", 409);

    public static Error TenantRequired() =>
        new("TENANT_REQUIRED", "The access token does not carry a tenant_id claim.", 401);
}
