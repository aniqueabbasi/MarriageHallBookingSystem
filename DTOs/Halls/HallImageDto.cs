namespace marriage_hall_backend.DTOs.Halls
{
    public class HallImageDto
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public bool IsPrimary { get; set; }
    }
}
