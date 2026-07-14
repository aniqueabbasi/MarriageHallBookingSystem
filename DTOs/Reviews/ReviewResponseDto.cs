namespace marriage_hall_backend.DTOs.Reviews
{
    public class ReviewResponseDto
    {
        public int Id { get; set; }
        public int HallId { get; set; }
        public int UserId { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
