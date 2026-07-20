using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Auth
{
    public class ForgotPasswordDto
    {
        [Required, EmailAddress]
        public string Email { get; set; } = string.Empty;
    }
}
