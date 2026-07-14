using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Bookings
{
    public class CreateBookingDto
    {
        [Required]
        public int HallId { get; set; }

        public int? FoodPackageId { get; set; }

        [Required]
        public DateOnly EventDate { get; set; }

        [Required]
        public TimeOnly StartTime { get; set; }

        [Required]
        public TimeOnly EndTime { get; set; }

        [Range(1, int.MaxValue)]
        public int GuestCount { get; set; }

        public List<int> ExtraServiceIds { get; set; } = new();
    }
}
