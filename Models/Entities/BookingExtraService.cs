namespace marriage_hall_backend.Models.Entities
{
    public class BookingExtraService
    {
        public int Id { get; set; }

        public int BookingId { get; set; }
        public Booking Booking { get; set; } = null!;

        public int ExtraServiceId { get; set; }
        public ExtraService ExtraService { get; set; } = null!;

        // Snapshot of the price at the time of booking, in case the hall later changes it.
        public decimal Price { get; set; }
    }
}
