using marriage_hall_backend.Data;
using marriage_hall_backend.DTOs.Notifications;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Models.Entities;
using marriage_hall_backend.Models.Enums;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace marriage_hall_backend.Services.Implementations
{
    public class NotificationService : INotificationService
    {
        private readonly AppDbContext _db;

        public NotificationService(AppDbContext db)
        {
            _db = db;
        }

        public async Task CreateAsync(int userId, NotificationType type, string title, string message)
        {
            _db.Notifications.Add(new Notification { UserId = userId, Type = type, Title = title, Message = message });
            await _db.SaveChangesAsync();
        }

        public async Task<List<NotificationResponseDto>> GetForUserAsync(int userId)
        {
            return await _db.Notifications
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.CreatedAt)
                .Select(n => new NotificationResponseDto
                {
                    Id = n.Id,
                    Type = n.Type,
                    Title = n.Title,
                    Message = n.Message,
                    IsRead = n.IsRead,
                    CreatedAt = n.CreatedAt
                })
                .ToListAsync();
        }

        public async Task MarkAsReadAsync(int notificationId, int userId)
        {
            var notification = await _db.Notifications.SingleOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId)
                ?? throw new NotFoundException("Notification not found.");

            notification.IsRead = true;
            await _db.SaveChangesAsync();
        }

        public async Task MarkAllAsReadAsync(int userId)
        {
            await _db.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ExecuteUpdateAsync(setters => setters.SetProperty(n => n.IsRead, true));
        }
    }
}
