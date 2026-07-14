using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.DTOs.Notifications
{
    public class NotificationResponseDto
    {
        public int Id { get; set; }
        public NotificationType Type { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
