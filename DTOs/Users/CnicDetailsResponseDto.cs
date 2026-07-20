namespace marriage_hall_backend.DTOs.Users
{
    /// Confirmation response for `PUT /api/users/me/cnic`. Never carries the
    /// encrypted value, the lookup hash, or the full CNIC — only a masked
    /// display value derived from the stored last-4 digits.
    public class CnicDetailsResponseDto
    {
        public string MaskedCnicNumber { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? FatherOrHusbandName { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public DateOnly? DateOfIssue { get; set; }
        public DateOnly? DateOfExpiry { get; set; }
        public string? Gender { get; set; }
        public string VerificationStatus { get; set; } = string.Empty;
    }
}
