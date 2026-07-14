using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Halls
{
    public class CreateHallImageDto
    {
        [Required, MaxLength(500)]
        public string ImageUrl { get; set; } = string.Empty;

        public bool IsPrimary { get; set; }
    }
}
