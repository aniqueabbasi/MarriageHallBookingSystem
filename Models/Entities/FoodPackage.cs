namespace marriage_hall_backend.Models.Entities
{
    public class FoodPackage
    {
        public int Id { get; set; }
        public int HallId { get; set; }
        public Hall Hall { get; set; } = null!;

        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal PricePerHead { get; set; }

        public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    }
}
