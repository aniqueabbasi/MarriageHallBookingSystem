using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.DTOs.Bookings
{
    public class BookingResponseDto
    {
        public int Id { get; set; }
        public int HallId { get; set; }
        public string HallName { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public DateOnly EventDate { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }
        public int GuestCount { get; set; }
        public BookingStatus Status { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal AdvanceAmount { get; set; }
        public decimal AmountPaid { get; set; }
        public string? FoodPackageName { get; set; }
        public List<string> ExtraServiceNames { get; set; } = new();
        public DateTime CreatedAt { get; set; }
    }
}
