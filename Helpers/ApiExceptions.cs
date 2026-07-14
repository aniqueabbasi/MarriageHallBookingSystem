using Microsoft.AspNetCore.Http;

namespace marriage_hall_backend.Helpers
{
    public abstract class ApiException : Exception
    {
        protected ApiException(string message, int statusCode) : base(message)
        {
            StatusCode = statusCode;
        }

        public int StatusCode { get; }
    }

    public class NotFoundException : ApiException
    {
        public NotFoundException(string message) : base(message, StatusCodes.Status404NotFound) { }
    }

    public class ForbiddenException : ApiException
    {
        public ForbiddenException(string message) : base(message, StatusCodes.Status403Forbidden) { }
    }

    public class BadRequestException : ApiException
    {
        public BadRequestException(string message) : base(message, StatusCodes.Status400BadRequest) { }
    }

    public class ConflictException : ApiException
    {
        public ConflictException(string message) : base(message, StatusCodes.Status409Conflict) { }
    }

    public class UnauthorizedException : ApiException
    {
        public UnauthorizedException(string message) : base(message, StatusCodes.Status401Unauthorized) { }
    }
}
