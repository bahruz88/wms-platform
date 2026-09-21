using Wms.Common.Application.Abstractions;

namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>
/// Per-request holder for the resolved <c>iam</c> record. <see cref="ICurrentUser"/> is synchronous, so the
/// (possibly remote) lookup happens once in <see cref="PrincipalResolutionMiddleware"/> and everything
/// downstream reads the result from here.
/// </summary>
public sealed class PrincipalContext
{
    public PrincipalSnapshot? Snapshot { get; private set; }

    /// <summary>True once the middleware ran, whether or not it found a row.</summary>
    public bool Resolved { get; private set; }

    public void Set(PrincipalSnapshot? snapshot)
    {
        Snapshot = snapshot;
        Resolved = true;
    }
}
