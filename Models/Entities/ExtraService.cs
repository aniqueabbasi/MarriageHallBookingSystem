namespace marriage_hall_backend.Models.Entities
{
    public class ExtraService
    {
        public int Id { get; set; }
        public int HallId { get; set; }
        public Hall Hall { get; set; } = null!;

        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }

        public ICollection<BookingExtraService> BookingExtraServices { get; set; } = new List<BookingExtraService>();
    }
}
