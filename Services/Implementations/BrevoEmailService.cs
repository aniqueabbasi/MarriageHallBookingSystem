using System.Net.Http.Headers;
using System.Net.Http.Json;
using marriage_hall_backend.Services.Interfaces;

namespace marriage_hall_backend.Services.Implementations
{
    public class BrevoEmailService : IEmailService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public BrevoEmailService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        public async Task SendPasswordResetOtpAsync(string email, string otp)
        {
            var brevoSection = _configuration.GetSection("Brevo");
            var apiKey = brevoSection["ApiKey"];
            var senderEmail = brevoSection["SenderEmail"];
            var senderName = brevoSection["SenderName"];

            if (string.IsNullOrWhiteSpace(apiKey))
                throw new InvalidOperationException("Brevo:ApiKey is not configured.");

            var request = new HttpRequestMessage(HttpMethod.Post, "https://api.brevo.com/v3/smtp/email");
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            request.Headers.Add("api-key", apiKey);

            request.Content = JsonContent.Create(new
            {
                sender = new { name = senderName, email = senderEmail },
                to = new[] { new { email } },
                subject = "Your Hallfest password reset code",
                htmlContent = BuildHtmlBody(otp)
            });

            var response = await _httpClient.SendAsync(request);
            if (!response.IsSuccessStatusCode)
            {
                var body = await response.Content.ReadAsStringAsync();
                throw new InvalidOperationException($"Failed to send password reset email via Brevo ({(int)response.StatusCode}): {body}");
            }
        }

        private static string BuildHtmlBody(string otp) => $$"""
            <!DOCTYPE html>
            <html>
              <body style="margin:0;padding:0;background-color:#f4f4f7;font-family:Segoe UI,Roboto,Helvetica,Arial,sans-serif;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="padding:32px 0;">
                  <tr>
                    <td align="center">
                      <table role="presentation" width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,0.08);">
                        <tr>
                          <td style="background:#6366f1;padding:24px 32px;">
                            <span style="color:#ffffff;font-size:20px;font-weight:600;">Hallfest</span>
                          </td>
                        </tr>
                        <tr>
                          <td style="padding:32px;">
                            <h1 style="margin:0 0 16px;font-size:18px;color:#111827;">Reset your password</h1>
                            <p style="margin:0 0 24px;font-size:14px;color:#4b5563;line-height:1.5;">
                              Use the code below to reset your Hallfest account password. This code expires in 10 minutes.
                            </p>
                            <div style="text-align:center;margin:0 0 24px;">
                              <span style="display:inline-block;padding:12px 28px;font-size:28px;font-weight:700;letter-spacing:8px;color:#111827;background:#f4f4f7;border-radius:6px;">{{otp}}</span>
                            </div>
                            <p style="margin:0;font-size:13px;color:#9ca3af;line-height:1.5;">
                              If you did not request a password reset, you can safely ignore this email — your password will not be changed.
                            </p>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </body>
            </html>
            """;
    }
}
