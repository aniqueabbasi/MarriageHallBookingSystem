using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.DTOs.Users;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class UserService : IUserService
    {
        private readonly AppDbContext _db;
        private readonly ISensitiveDataProtector _sensitiveDataProtector;

        public UserService(AppDbContext db, ISensitiveDataProtector sensitiveDataProtector)
        {
            _db = db;
            _sensitiveDataProtector = sensitiveDataProtector;
        }

        public async Task<UserDto> GetMeAsync(int userId)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Id == userId)
                ?? throw new NotFoundException("User not found.");

            return MapToDto(user);
        }

        public async Task<UserDto> UpdateMeAsync(int userId, UpdateProfileDto dto)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Id == userId)
                ?? throw new NotFoundException("User not found.");

            var emailTaken = await _db.Users.AnyAsync(u => u.Email == dto.Email && u.Id != userId);
            if (emailTaken)
                throw new ConflictException("A user with this email already exists.");

            user.FullName = dto.FullName;
            user.Email = dto.Email;
            user.PhoneNumber = dto.PhoneNumber;
            user.City = dto.City;
            user.UpdatedAt = DateTime.UtcNow;

            await _db.SaveChangesAsync();

            return MapToDto(user);
        }

        private static UserDto MapToDto(Models.Entities.User user) => new()
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            City = user.City,
            Role = user.Role
        };

        public async Task<CnicDetailsResponseDto> SaveCnicDetailsAsync(int userId, CnicDetailsDto dto)
        {
            var userExists = await _db.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
                throw new NotFoundException("User not found.");

            var normalizedCnic = CnicNormalizer.Normalize(dto.CnicNumber);
            var cnicHash = _sensitiveDataProtector.ComputeLookupHash(normalizedCnic);

            var belongsToAnotherUser = await _db.UserCnicDetails
                .AnyAsync(c => c.CnicNumberHash == cnicHash && c.UserId != userId);
            if (belongsToAnotherUser)
                throw new ConflictException("This CNIC is already associated with another account.");

            var details = await _db.UserCnicDetails.SingleOrDefaultAsync(c => c.UserId == userId);
            var now = DateTime.UtcNow;

            if (details is null)
            {
                details = new UserCnicDetails { UserId = userId, CreatedAtUtc = now };
                _db.UserCnicDetails.Add(details);
            }

            details.CnicNumberEncrypted = _sensitiveDataProtector.Protect(normalizedCnic);
            details.CnicNumberHash = cnicHash;
            details.CnicLast4 = CnicNormalizer.ExtractLast4(normalizedCnic);
            details.FullName = dto.FullName;
            details.FatherOrHusbandName = dto.FatherOrHusbandName;
            details.DateOfBirth = dto.DateOfBirth;
            details.DateOfIssue = dto.DateOfIssue;
            details.DateOfExpiry = dto.DateOfExpiry;
            details.Gender = dto.Gender;
            details.UpdatedAtUtc = now;
            // VerificationStatus is intentionally left untouched here — OCR-assisted
            // entry is never sufficient to mark a CNIC as Verified on its own.

            await _db.SaveChangesAsync();

            return new CnicDetailsResponseDto
            {
                MaskedCnicNumber = MaskCnicNumber(details.CnicLast4),
                FullName = details.FullName,
                FatherOrHusbandName = details.FatherOrHusbandName,
                DateOfBirth = details.DateOfBirth,
                DateOfIssue = details.DateOfIssue,
                DateOfExpiry = details.DateOfExpiry,
                Gender = details.Gender,
                VerificationStatus = details.VerificationStatus
            };
        }

        /// "5671" -> "*****-*******-5671" — never echo the full number back
        /// once it's been saved; only the last 4 digits are ever displayed.
        private static string MaskCnicNumber(string cnicLast4) => $"*****-*******-{cnicLast4}";
    }
}
