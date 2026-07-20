using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using marriage_hall_backend.Services.Implementations;
using marriage_hall_backend.Services.Interfaces;

namespace marriage_hall_backend.Tests
{
    public class SensitiveDataProtectorTests
    {
        private static ISensitiveDataProtector CreateProtector(string? hmacKey = "test-hmac-key-please-ignore")
        {
            var services = new ServiceCollection();
            services.AddDataProtection().UseEphemeralDataProtectionProvider();
            var dataProtectionProvider = services.BuildServiceProvider().GetRequiredService<IDataProtectionProvider>();

            var configData = hmacKey is null
                ? new Dictionary<string, string?>()
                : new Dictionary<string, string?> { ["SensitiveData:HmacKey"] = hmacKey };
            var configuration = new ConfigurationBuilder().AddInMemoryCollection(configData).Build();

            return new SensitiveDataProtector(dataProtectionProvider, configuration);
        }

        [Fact]
        public void Protect_ThenUnprotect_ReturnsOriginalPlaintext()
        {
            var protector = CreateProtector();
            const string plaintext = "12345-1234567-1";

            var protectedValue = protector.Protect(plaintext);
            var result = protector.Unprotect(protectedValue);

            Assert.Equal(plaintext, result);
            Assert.NotEqual(plaintext, protectedValue);
        }

        [Fact]
        public void ComputeLookupHash_SameInput_ProducesSameHash()
        {
            var protector = CreateProtector();

            var hash1 = protector.ComputeLookupHash("12345-1234567-1");
            var hash2 = protector.ComputeLookupHash("12345-1234567-1");

            Assert.Equal(hash1, hash2);
        }

        [Fact]
        public void ComputeLookupHash_DifferentInput_ProducesDifferentHash()
        {
            var protector = CreateProtector();

            var hash1 = protector.ComputeLookupHash("12345-1234567-1");
            var hash2 = protector.ComputeLookupHash("12345-1234567-2");

            Assert.NotEqual(hash1, hash2);
        }

        [Fact]
        public void Constructor_MissingHmacKey_ThrowsClearConfigurationError()
        {
            var services = new ServiceCollection();
            services.AddDataProtection().UseEphemeralDataProtectionProvider();
            var dataProtectionProvider = services.BuildServiceProvider().GetRequiredService<IDataProtectionProvider>();
            var configuration = new ConfigurationBuilder().Build();

            var ex = Assert.Throws<InvalidOperationException>(() => new SensitiveDataProtector(dataProtectionProvider, configuration));

            Assert.Contains("SensitiveData:HmacKey", ex.Message);
            Assert.DoesNotContain("System.NullReferenceException", ex.Message);
        }
    }
}
