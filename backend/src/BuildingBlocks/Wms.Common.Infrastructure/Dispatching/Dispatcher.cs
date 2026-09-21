using System.Collections.Concurrent;
using System.Reflection;
using FluentValidation;
using FluentValidation.Results;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;

namespace Wms.Common.Infrastructure.Dispatching;

/// <summary>DI-based dispatcher: runs all FluentValidation validators for the request, then its single handler.</summary>
public sealed class Dispatcher(IServiceProvider serviceProvider) : IDispatcher
{
    private static readonly ConcurrentDictionary<(Type Request, Type Response, Type Definition), (Type HandlerType, MethodInfo Handle)> Cache = new();

    public Task<Result<TResponse>> SendAsync<TResponse>(ICommand<TResponse> command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        return DispatchAsync<TResponse>(command, typeof(ICommandHandler<,>), cancellationToken);
    }

    public Task<Result<TResponse>> QueryAsync<TResponse>(IQuery<TResponse> query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return DispatchAsync<TResponse>(query, typeof(IQueryHandler<,>), cancellationToken);
    }

    private async Task<Result<TResponse>> DispatchAsync<TResponse>(IBaseRequest request, Type handlerDefinition, CancellationToken cancellationToken)
    {
        var requestType = request.GetType();
        var validationError = await ValidateAsync(request, requestType, cancellationToken).ConfigureAwait(false);
        if (validationError is not null)
        {
            return Result<TResponse>.Failure(validationError);
        }

        var (handlerType, handle) = Cache.GetOrAdd((requestType, typeof(TResponse), handlerDefinition), static key =>
        {
            var type = key.Definition.MakeGenericType(key.Request, key.Response);
            var method = type.GetMethod("HandleAsync", BindingFlags.Public | BindingFlags.Instance)
                ?? throw new InvalidOperationException($"{type.Name} has no HandleAsync method.");
            return (type, method);
        });

        var handler = serviceProvider.GetService(handlerType)
            ?? throw new InvalidOperationException($"No handler is registered for request '{requestType.FullName}'.");

        var task = (Task<Result<TResponse>>)handle.Invoke(handler, [request, cancellationToken])!;
        return await task.ConfigureAwait(false);
    }

    private async Task<Error?> ValidateAsync(object request, Type requestType, CancellationToken cancellationToken)
    {
        var validatorsType = typeof(IEnumerable<>).MakeGenericType(typeof(IValidator<>).MakeGenericType(requestType));
        var validators = serviceProvider.GetService(validatorsType) as IEnumerable<IValidator> ?? [];

        var context = new ValidationContext<object>(request);
        var failures = new List<ValidationFailure>();
        foreach (var validator in validators)
        {
            var result = await validator.ValidateAsync(context, cancellationToken).ConfigureAwait(false);
            if (!result.IsValid)
            {
                failures.AddRange(result.Errors);
            }
        }

        if (failures.Count == 0)
        {
            return null;
        }

        var details = failures
            .GroupBy(f => f.PropertyName, StringComparer.Ordinal)
            .ToDictionary(g => g.Key, g => g.Select(f => f.ErrorMessage).ToArray(), StringComparer.Ordinal);

        return CommonErrors.Validation(details);
    }
}
