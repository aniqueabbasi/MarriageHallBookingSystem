using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Users
{
    public class UpdateProfileDto
    {
        [Required, MaxLength(150)]
        public string FullName { get; set; } = string.Empty;

        [Required, EmailAddress, MaxLength(200)]
        public string Email { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? PhoneNumber { get; set; }

        [MaxLength(100)]
        public string? City { get; set; }
    }
}
