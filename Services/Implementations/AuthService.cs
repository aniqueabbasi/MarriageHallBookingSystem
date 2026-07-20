using System.Security.Cryptography;
using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Auth;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private const int OtpExpiryMinutes = 10;
        private const int OtpResendCooldownSeconds = 60;
        private const int MaxOtpAttempts = 5;

        private readonly AppDbContext _db;
        private readonly JwtHelper _jwtHelper;
        private readonly IEmailService _emailService;

        public AuthService(AppDbContext db, JwtHelper jwtHelper, IEmailService emailService)
        {
            _db = db;
            _jwtHelper = jwtHelper;
            _emailService = emailService;
        }

        public async Task<TokenResponseDto> RegisterAsync(RegisterDto dto)
        {
            if (dto.Role == UserRole.Admin)
                throw new ForbiddenException("Admin accounts cannot be self-registered.");

            var emailExists = await _db.Users.AnyAsync(u => u.Email == dto.Email);
            if (emailExists)
                throw new ConflictException("A user with this email already exists.");

            var user = new User
            {
                FullName = dto.FullName,
                Email = dto.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                PhoneNumber = dto.PhoneNumber,
                Role = dto.Role
            };

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            return await IssueTokensAsync(user);
        }

        public async Task<TokenResponseDto> LoginAsync(LoginDto dto)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Email == dto.Email);
            if (user is null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                throw new UnauthorizedException("Invalid email or password.");

            return await IssueTokensAsync(user);
        }

        public async Task ForgotPasswordAsync(ForgotPasswordDto dto)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Email == dto.Email);
            if (user is null)
                return; // don't reveal whether the account exists

            var mostRecentOtp = await _db.PasswordResetOtps
                .Where(o => o.UserId == user.Id)
                .OrderByDescending(o => o.CreatedAtUtc)
                .FirstOrDefaultAsync();

            if (mostRecentOtp is not null && mostRecentOtp.CreatedAtUtc.AddSeconds(OtpResendCooldownSeconds) > DateTime.UtcNow)
                return; // within resend cooldown; silently no-op so the response stays identical either way

            var previousUnused = await _db.PasswordResetOtps
                .Where(o => o.UserId == user.Id && !o.IsUsed)
                .ToListAsync();
            foreach (var old in previousUnused)
                old.IsUsed = true;

            var otp = GenerateOtp();
            _db.PasswordResetOtps.Add(new PasswordResetOtp
            {
                UserId = user.Id,
                OtpHash = BCrypt.Net.BCrypt.HashPassword(otp),
                CreatedAtUtc = DateTime.UtcNow,
                ExpiresAtUtc = DateTime.UtcNow.AddMinutes(OtpExpiryMinutes),
                IsUsed = false,
                FailedAttempts = 0
            });
            await _db.SaveChangesAsync();

            await _emailService.SendPasswordResetOtpAsync(user.Email, otp);
        }

        public async Task<VerifyResetOtpResponseDto> VerifyResetOtpAsync(VerifyResetOtpDto dto)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Email == dto.Email)
                ?? throw new UnauthorizedException("Invalid or expired OTP.");

            var otpEntity = await _db.PasswordResetOtps
                .Where(o => o.UserId == user.Id && !o.IsUsed)
                .OrderByDescending(o => o.CreatedAtUtc)
                .FirstOrDefaultAsync()
                ?? throw new UnauthorizedException("Invalid or expired OTP.");

            if (otpEntity.FailedAttempts >= MaxOtpAttempts)
                throw new UnauthorizedException("Too many failed attempts. Please request a new OTP.");

            if (otpEntity.ExpiresAtUtc < DateTime.UtcNow)
                throw new UnauthorizedException("Invalid or expired OTP.");

            if (!BCrypt.Net.BCrypt.Verify(dto.Otp, otpEntity.OtpHash))
            {
                otpEntity.FailedAttempts++;
                await _db.SaveChangesAsync();
                throw new UnauthorizedException("Invalid or expired OTP.");
            }

            var (resetToken, expiresAt) = _jwtHelper.GeneratePasswordResetToken(user.Id, otpEntity.Id);

            return new VerifyResetOtpResponseDto { ResetToken = resetToken, ExpiresAt = expiresAt };
        }

        public async Task ResetPasswordAsync(ResetPasswordDto dto)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Email == dto.Email)
                ?? throw new UnauthorizedException("Invalid or expired reset token.");

            var claims = _jwtHelper.ValidatePasswordResetToken(dto.ResetToken)
                ?? throw new UnauthorizedException("Invalid or expired reset token.");

            if (claims.UserId != user.Id)
                throw new UnauthorizedException("Invalid or expired reset token.");

            var otpEntity = await _db.PasswordResetOtps.SingleOrDefaultAsync(o => o.Id == claims.OtpId && o.UserId == user.Id)
                ?? throw new UnauthorizedException("Invalid or expired reset token.");

            if (otpEntity.IsUsed)
                throw new UnauthorizedException("This reset token has already been used.");

            if (otpEntity.ExpiresAtUtc < DateTime.UtcNow)
                throw new UnauthorizedException("Invalid or expired reset token.");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;
            otpEntity.IsUsed = true;

            await _db.SaveChangesAsync();
        }

        private static string GenerateOtp() => RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");

        private async Task<TokenResponseDto> IssueTokensAsync(User user)
        {
            var (accessToken, expiresAt) = _jwtHelper.GenerateAccessToken(user);

            return new TokenResponseDto
            {
                AccessToken = accessToken,
                ExpiresAt = expiresAt,
                User = new UserDto
                {
                    Id = user.Id,
                    FullName = user.FullName,
                    Email = user.Email,
                    PhoneNumber = user.PhoneNumber,
                    City = user.City,
                    Role = user.Role
                }
            };
        }
    }
}
