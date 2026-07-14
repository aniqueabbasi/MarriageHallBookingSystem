using System.Security.Claims;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.Helpers
{
    public static class ClaimsPrincipalExtensions
    {
        public static int GetUserId(this ClaimsPrincipal principal)
        {
            var value = principal.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedException("Missing user identity.");
            return int.Parse(value);
        }

        public static UserRole GetRole(this ClaimsPrincipal principal)
        {
            var value = principal.FindFirstValue(ClaimTypes.Role)
                ?? throw new UnauthorizedException("Missing role claim.");
            return Enum.Parse<UserRole>(value);
        }
    }
}
