namespace marriage_hall_backend.Services.Interfaces
{
    public interface IEmailService
    {
        Task SendPasswordResetOtpAsync(string email, string otp);
    }
}
