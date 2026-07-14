using marriage_hall_backend.DTOs.Notifications;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.Services.Interfaces
{
    public interface INotificationService
    {
        Task CreateAsync(int userId, NotificationType type, string title, string message);
        Task<List<NotificationResponseDto>> GetForUserAsync(int userId);
        Task MarkAsReadAsync(int notificationId, int userId);
        Task MarkAllAsReadAsync(int userId);
    }
}
