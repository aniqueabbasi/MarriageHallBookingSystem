namespace marriage_hall_backend.Models.Entities
{
    public class HallImage
    {
        public int Id { get; set; }
        public int HallId { get; set; }
        public Hall Hall { get; set; } = null!;

        public string ImageUrl { get; set; } = string.Empty;
        public bool IsPrimary { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
