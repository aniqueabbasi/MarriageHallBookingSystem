namespace marriage_hall_backend.Models.Entities
{
    public sealed class UserCnicDetails
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public string CnicNumberEncrypted { get; set; } = string.Empty;

        public string CnicNumberHash { get; set; } = string.Empty;

        public string CnicLast4 { get; set; } = string.Empty;

        public string FullName { get; set; } = string.Empty;

        public string? FatherOrHusbandName { get; set; }

        public DateOnly? DateOfBirth { get; set; }

        public DateOnly? DateOfIssue { get; set; }

        public DateOnly? DateOfExpiry { get; set; }

        public string? Gender { get; set; }

        public string VerificationStatus { get; set; } = "Pending";

        public DateTime CreatedAtUtc { get; set; }

        public DateTime UpdatedAtUtc { get; set; }

        public User User { get; set; } = null!;
    }
}
