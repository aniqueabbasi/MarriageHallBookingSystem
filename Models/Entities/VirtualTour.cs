namespace marriage_hall_backend.Models.Entities
{
    public class VirtualTour
    {
        public int Id { get; set; }
        public int HallId { get; set; }
        public Hall Hall { get; set; } = null!;

        public string Title { get; set; } = string.Empty;
        public string TourUrl { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
