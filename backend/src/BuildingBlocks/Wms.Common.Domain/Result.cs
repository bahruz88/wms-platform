namespace Wms.Common.Domain;

/// <summary>Result pattern (spec Əlavə A): business failures are values, not exceptions.</summary>
public class Result
{
    protected Result(bool isSuccess, Error error)
    {
        if (isSuccess && error != Error.None)
        {
            throw new ArgumentException("A successful result cannot carry an error.", nameof(error));
        }

        if (!isSuccess && error == Error.None)
        {
            throw new ArgumentException("A failed result must carry an error.", nameof(error));
        }

        IsSuccess = isSuccess;
        Error = error;
    }

    public bool IsSuccess { get; }

    public bool IsFailure => !IsSuccess;

    public Error Error { get; }

    public static Result Success() => new(true, Error.None);

    public static Result Failure(Error error) => new(false, error);

    public static Result<TValue> Success<TValue>(TValue value) => Result<TValue>.Success(value);

    public static Result<TValue> Failure<TValue>(Error error) => Result<TValue>.Failure(error);

    public static implicit operator Result(Error error) => Failure(error);

    public static Result FromError(Error error) => Failure(error);
}

/// <summary>Result carrying a value on success.</summary>
public sealed class Result<TValue> : Result
{
    private readonly TValue? _value;

    private Result(bool isSuccess, Error error, TValue? value)
        : base(isSuccess, error)
    {
        _value = value;
    }

    public TValue Value => IsSuccess
        ? _value!
        : throw new InvalidOperationException($"Cannot read the value of a failed result ({Error.Code}).");

    public static Result<TValue> Success(TValue value) => new(true, Error.None, value);

    public static new Result<TValue> Failure(Error error) => new(false, error, default);

    public static implicit operator Result<TValue>(TValue value) => Success(value);

    public static implicit operator Result<TValue>(Error error) => Failure(error);

    public static Result<TValue> FromValue(TValue value) => Success(value);

    public static new Result<TValue> FromError(Error error) => Failure(error);

    public Result<TOut> Map<TOut>(Func<TValue, TOut> map)
    {
        ArgumentNullException.ThrowIfNull(map);
        return IsSuccess ? Result<TOut>.Success(map(Value)) : Result<TOut>.Failure(Error);
    }
}
