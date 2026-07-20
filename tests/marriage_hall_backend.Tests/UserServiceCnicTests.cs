using System.Security.Cryptography;
using System.Text;
using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Users;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Implementations;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace marriage_hall_backend.Tests
{
    public class UserServiceCnicTests
    {
        private static AppDbContext CreateDb() =>
            new(new DbContextOptionsBuilder<AppDbContext>()
                .UseInMemoryDatabase(Guid.NewGuid().ToString())
                .Options);

        private static async Task<int> SeedUserAsync(AppDbContext db, string email)
        {
            var user = new User { FullName = "Test User", Email = email, PasswordHash = "x", Role = UserRole.Customer };
            db.Users.Add(user);
            await db.SaveChangesAsync();
            return user.Id;
        }

        private static CnicDetailsDto ValidDto(string cnicNumber = "12345-1234567-1") => new()
        {
            CnicNumber = cnicNumber,
            FullName = "Ali Raza",
            FatherOrHusbandName = "Muhammad Raza",
            DateOfBirth = new DateOnly(2000, 4, 5),
            DateOfIssue = new DateOnly(2020, 1, 1),
            DateOfExpiry = new DateOnly(2030, 1, 1),
            Gender = "Male"
        };

        private static ISensitiveDataProtector CreateRealProtector()
        {
            var services = new ServiceCollection();
            services.AddDataProtection().UseEphemeralDataProtectionProvider();
            var dataProtectionProvider = services.BuildServiceProvider().GetRequiredService<IDataProtectionProvider>();
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?> { ["SensitiveData:HmacKey"] = "test-hmac-key" })
                .Build();

            return new SensitiveDataProtector(dataProtectionProvider, configuration);
        }

        [Fact]
        public async Task SaveCnicDetailsAsync_NewSubmission_DoesNotStorePlainCnicInDatabase()
        {
            // Uses the real protector here (not the fake below) — this test is only
            // meaningful against genuine encryption, not a transparent test double.
            await using var db = CreateDb();
            var userId = await SeedUserAsync(db, "user1@test.com");
            var service = new UserService(db, CreateRealProtector());

            await service.SaveCnicDetailsAsync(userId, ValidDto());

            var stored = await db.UserCnicDetails.SingleAsync(c => c.UserId == userId);
            Assert.DoesNotContain("12345-1234567-1", stored.CnicNumberEncrypted);
            Assert.DoesNotContain("1234512345671", stored.CnicNumberEncrypted);
            Assert.DoesNotContain("12345", stored.CnicNumberHash);
        }

        [Fact]
        public async Task SaveCnicDetailsAsync_NewSubmission_DefaultsVerificationStatusToPending()
        {
            await using var db = CreateDb();
            var userId = await SeedUserAsync(db, "user1@test.com");
            var service = new UserService(db, new FakeSensitiveDataProtector());

            var response = await service.SaveCnicDetailsAsync(userId, ValidDto());

            Assert.Equal("Pending", response.VerificationStatus);
            var stored = await db.UserCnicDetails.SingleAsync(c => c.UserId == userId);
            Assert.Equal("Pending", stored.VerificationStatus);
        }

        [Fact]
        public async Task SaveCnicDetailsAsync_Response_ContainsOnlyMaskedCnicNumber()
        {
            await using var db = CreateDb();
            var userId = await SeedUserAsync(db, "user1@test.com");
            var service = new UserService(db, new FakeSensitiveDataProtector());

            var response = await service.SaveCnicDetailsAsync(userId, ValidDto());

            Assert.Equal("*****-*******-5671", response.MaskedCnicNumber);
            Assert.DoesNotContain("12345", response.MaskedCnicNumber);
        }

        [Fact]
        public void CnicDetailsResponseDto_HasNoEncryptedOrHashProperty()
        {
            var properties = typeof(CnicDetailsResponseDto).GetProperties().Select(p => p.Name);

            Assert.DoesNotContain(properties, name => name.Contains("Encrypted", StringComparison.OrdinalIgnoreCase));
            Assert.DoesNotContain(properties, name => name.Contains("Hash", StringComparison.OrdinalIgnoreCase));
            Assert.DoesNotContain(properties, name => name is "CnicNumber");
        }

        [Fact]
        public async Task SaveCnicDetailsAsync_CnicAlreadyBelongsToAnotherUser_ThrowsConflictWithNeutralMessage()
        {
            await using var db = CreateDb();
            var protector = new FakeSensitiveDataProtector();
            var user1 = await SeedUserAsync(db, "user1@test.com");
            var user2 = await SeedUserAsync(db, "user2@test.com");

            await new UserService(db, protector).SaveCnicDetailsAsync(user1, ValidDto("12345-1234567-1"));

            var ex = await Assert.ThrowsAsync<ConflictException>(
                () => new UserService(db, protector).SaveCnicDetailsAsync(user2, ValidDto("12345-1234567-1")));

            Assert.Equal("This CNIC is already associated with another account.", ex.Message);
            Assert.DoesNotContain("user1@test.com", ex.Message);
        }

        [Fact]
        public async Task SaveCnicDetailsAsync_SameUserResubmitsOwnCnic_UpdatesExistingRecordInsteadOfThrowing()
        {
            await using var db = CreateDb();
            var protector = new FakeSensitiveDataProtector();
            var userId = await SeedUserAsync(db, "user1@test.com");
            var service = new UserService(db, protector);

            await service.SaveCnicDetailsAsync(userId, ValidDto("12345-1234567-1"));
            var response = await service.SaveCnicDetailsAsync(userId, ValidDto("12345-1234567-1"));

            Assert.Equal("*****-*******-5671", response.MaskedCnicNumber);
            Assert.Equal(1, await db.UserCnicDetails.CountAsync(c => c.UserId == userId));
        }

        private sealed class FakeSensitiveDataProtector : ISensitiveDataProtector
        {
            public string Protect(string plaintext) => $"enc:{plaintext}";

            public string Unprotect(string protectedValue) => protectedValue["enc:".Length..];

            public string ComputeLookupHash(string normalizedValue) =>
                Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(normalizedValue)));
        }
    }
}
