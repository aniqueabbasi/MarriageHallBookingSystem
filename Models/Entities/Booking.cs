using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.Models.Entities
{
    public class Booking
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public User User { get; set; } = null!;

        public int HallId { get; set; }
        public Hall Hall { get; set; } = null!;

        public int? FoodPackageId { get; set; }
        public FoodPackage? FoodPackage { get; set; }

        public DateOnly EventDate { get; set; }
        public TimeOnly StartTime { get; set; }
        public TimeOnly EndTime { get; set; }
        public int GuestCount { get; set; }

        public BookingStatus Status { get; set; } = BookingStatus.Pending;
        public decimal TotalAmount { get; set; }
        public decimal AdvanceAmount { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<BookingExtraService> ExtraServices { get; set; } = new List<BookingExtraService>();
        public ICollection<Payment> Payments { get; set; } = new List<Payment>();
        public Review? Review { get; set; }
    }
}
