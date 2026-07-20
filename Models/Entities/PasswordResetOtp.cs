namespace marriage_hall_backend.Models.Entities
{
    public class PasswordResetOtp
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public User User { get; set; } = null!;

        public string OtpHash { get; set; } = string.Empty;
        public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
        public DateTime ExpiresAtUtc { get; set; }
        public bool IsUsed { get; set; }
        public int FailedAttempts { get; set; }
    }
}
