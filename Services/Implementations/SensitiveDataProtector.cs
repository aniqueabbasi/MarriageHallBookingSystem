using System.Security.Cryptography;
using System.Text;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.DataProtection;

namespace marriage_hall_backend.Services.Implementations
{
    /// Reversible encryption (ASP.NET Core Data Protection) plus a
    /// deterministic HMAC-SHA256 lookup hash for sensitive fields like CNIC
    /// numbers. The encrypted value can be decrypted for display/verification;
    /// the hash exists purely so duplicates can be detected without ever
    /// decrypting or storing the plaintext.
    public class SensitiveDataProtector : ISensitiveDataProtector
    {
        private const string Purpose = "marriage_hall_backend.SensitiveData.v1";

        private readonly IDataProtector _protector;
        private readonly string _hmacKey;

        public SensitiveDataProtector(IDataProtectionProvider dataProtectionProvider, IConfiguration configuration)
        {
            _protector = dataProtectionProvider.CreateProtector(Purpose);

            _hmacKey = configuration["SensitiveData:HmacKey"]
                ?? throw new InvalidOperationException(
                    "SensitiveData:HmacKey is not configured. Set it with " +
                    "'dotnet user-secrets set \"SensitiveData:HmacKey\" \"<a long random value>\"' in development, " +
                    "or via an environment variable / secret store in production. Never commit it to appsettings.json.");
        }

        public string Protect(string plaintext) => _protector.Protect(plaintext);

        public string Unprotect(string protectedValue) => _protector.Unprotect(protectedValue);

        public string ComputeLookupHash(string normalizedValue)
        {
            var hash = HMACSHA256.HashData(Encoding.UTF8.GetBytes(_hmacKey), Encoding.UTF8.GetBytes(normalizedValue));
            return Convert.ToHexString(hash);
        }
    }
}
