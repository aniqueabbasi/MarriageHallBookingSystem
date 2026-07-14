using System.ComponentModel.DataAnnotations;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.DTOs.Auth
{
    public class RegisterDto
    {
        [Required, MaxLength(150)]
        public string FullName { get; set; } = string.Empty;

        [Required, EmailAddress, MaxLength(200)]
        public string Email { get; set; } = string.Empty;

        [Required, MinLength(8)]
        public string Password { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? PhoneNumber { get; set; }

        [Required]
        public UserRole Role { get; set; } = UserRole.Customer;
    }
}
