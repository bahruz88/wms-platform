using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Wms.Common.Domain;

namespace Wms.Common.Infrastructure.Http;

/// <summary>Maps <see cref="Result"/> to Minimal API <c>TypedResults</c>; failures become RFC 7807 problems with a <c>code</c> extension (spec §13.3).</summary>
public static class ResultExtensions
{
    public const string ErrorTypeBase = "https://wms/errors/";

    public static ProblemDetails ToProblemDetails(this Error error)
    {
        ArgumentNullException.ThrowIfNull(error);
        var problem = new ProblemDetails
        {
            Type = ErrorTypeBase + error.Code.ToLowerInvariant().Replace('_', '-'),
            Title = error.Code,
            Status = error.Status,
            Detail = error.Message,
        };
        problem.Extensions["code"] = error.Code;
        if (error.Details is not null)
        {
            problem.Extensions["errors"] = error.Details;
        }

        return problem;
    }

    public static ProblemHttpResult ToProblem(this Error error) => TypedResults.Problem(error.ToProblemDetails());

    public static IResult ToHttpResult<T>(this Result<T> result, Func<T, IResult> onSuccess)
    {
        ArgumentNullException.ThrowIfNull(result);
        ArgumentNullException.ThrowIfNull(onSuccess);
        return result.IsSuccess ? onSuccess(result.Value) : result.Error.ToProblem();
    }

    public static IResult ToOk<T>(this Result<T> result) => result.ToHttpResult(value => TypedResults.Ok(value));

    public static IResult ToCreated<T>(this Result<T> result, Func<T, string> location)
    {
        ArgumentNullException.ThrowIfNull(location);
        return result.ToHttpResult(value => TypedResults.Created(location(value), value));
    }

    public static IResult ToNoContent(this Result result)
    {
        ArgumentNullException.ThrowIfNull(result);
        return result.IsSuccess ? TypedResults.NoContent() : result.Error.ToProblem();
    }
}
