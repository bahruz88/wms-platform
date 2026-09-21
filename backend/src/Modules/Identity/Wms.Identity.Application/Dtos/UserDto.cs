namespace Wms.Identity.Application.Dtos;

public sealed record UserDto(
    uint Id,
    string Username,
    string FullName,
    string? Email,
    string? Phone,
    bool IsActive,
    IReadOnlyList<string> Roles,
    IReadOnlyList<uint> LocationIds);
