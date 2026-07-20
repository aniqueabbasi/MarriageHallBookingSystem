namespace marriage_hall_backend.DTOs.Auth
{
    public class VerifyResetOtpResponseDto
    {
        public string ResetToken { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
    }
}
