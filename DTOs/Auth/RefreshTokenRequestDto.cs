using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Auth
{
    public class RefreshTokenRequestDto
    {
        [Required]
        public string RefreshToken { get; set; } = string.Empty;
    }
}
