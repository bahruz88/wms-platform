namespace Wms.Common.Application.Messaging;

/// <summary>Marker for anything the <see cref="IDispatcher"/> can route.</summary>
public interface IBaseRequest
{
}

/// <summary>State-changing request. Exactly one handler; validated by FluentValidation before handling.</summary>
public interface ICommand<TResponse> : IBaseRequest
{
}

/// <summary>Read-only request. Handlers must use <c>AsNoTracking()</c> (spec Əlavə A).</summary>
public interface IQuery<TResponse> : IBaseRequest
{
}
