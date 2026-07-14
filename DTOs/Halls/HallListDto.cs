namespace marriage_hall_backend.DTOs.Halls
{
    public class HallListDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public int Capacity { get; set; }
        public decimal PricePerDay { get; set; }
        public bool IsActive { get; set; }
        public string? PrimaryImageUrl { get; set; }
        public double AverageRating { get; set; }
        public int ReviewCount { get; set; }
    }
}
