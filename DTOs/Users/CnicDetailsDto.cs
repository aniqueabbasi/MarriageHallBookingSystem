using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Users
{
    /// Request body for `PUT /api/users/me/cnic`. The client is expected to
    /// have already OCR-scanned and let the user confirm/edit every field —
    /// this DTO only re-validates the shape server-side.
    public class CnicDetailsDto
    {
        [Required, RegularExpression(@"^[0-9]{5}-[0-9]{7}-[0-9]$",
            ErrorMessage = "CNIC number must be in the format XXXXX-XXXXXXX-X.")]
        public string CnicNumber { get; set; } = string.Empty;

        [Required, MaxLength(150)]
        public string FullName { get; set; } = string.Empty;

        [Required, MaxLength(150)]
        public string FatherOrHusbandName { get; set; } = string.Empty;

        [Required]
        public DateOnly DateOfBirth { get; set; }

        [Required]
        public DateOnly DateOfIssue { get; set; }

        [Required]
        public DateOnly DateOfExpiry { get; set; }

        [MaxLength(20)]
        public string? Gender { get; set; }
    }
}
