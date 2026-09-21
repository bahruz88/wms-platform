using System.Reflection;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.Messaging;

namespace Wms.Common.Application.DependencyInjection;

public static class HandlerRegistrationExtensions
{
    /// <summary>Registers every <see cref="ICommandHandler{TCommand,TResponse}"/>, <see cref="IQueryHandler{TQuery,TResponse}"/> and FluentValidation validator in the assembly.</summary>
    public static IServiceCollection AddWmsHandlersFromAssembly(this IServiceCollection services, Assembly assembly)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(assembly);

        foreach (var type in assembly.GetTypes())
        {
            if (type.IsAbstract || type.IsInterface || type.IsGenericTypeDefinition)
            {
                continue;
            }

            foreach (var contract in type.GetInterfaces())
            {
                if (!contract.IsGenericType)
                {
                    continue;
                }

                var definition = contract.GetGenericTypeDefinition();
                if (definition == typeof(ICommandHandler<,>) || definition == typeof(IQueryHandler<,>))
                {
                    services.AddScoped(contract, type);
                }
            }
        }

        services.AddValidatorsFromAssembly(assembly, includeInternalTypes: true);
        return services;
    }
}
