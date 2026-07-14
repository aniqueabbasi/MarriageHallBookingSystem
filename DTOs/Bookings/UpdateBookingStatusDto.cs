using System.ComponentModel.DataAnnotations;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.DTOs.Bookings
{
    public class UpdateBookingStatusDto
    {
        [Required]
        public BookingStatus Status { get; set; }

        // Required only when confirming a booking (Status == Confirmed).
        public decimal? AdvanceAmount { get; set; }
    }
}
