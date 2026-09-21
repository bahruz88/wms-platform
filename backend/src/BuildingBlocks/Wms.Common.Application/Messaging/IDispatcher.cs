using Wms.Common.Domain;

namespace Wms.Common.Application.Messaging;

/// <summary>Simple DI-based mediator (spec §3: no MediatR). Runs validators, then the single handler.</summary>
public interface IDispatcher
{
    Task<Result<TResponse>> SendAsync<TResponse>(ICommand<TResponse> command, CancellationToken cancellationToken);

    Task<Result<TResponse>> QueryAsync<TResponse>(IQuery<TResponse> query, CancellationToken cancellationToken);
}
