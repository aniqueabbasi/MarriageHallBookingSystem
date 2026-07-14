namespace marriage_hall_backend.DTOs.Favorites
{
    public class FavoriteResponseDto
    {
        public int Id { get; set; }
        public int HallId { get; set; }
        public string HallName { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public decimal PricePerDay { get; set; }
        public string? PrimaryImageUrl { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
