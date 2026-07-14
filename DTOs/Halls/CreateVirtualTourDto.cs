using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Halls
{
    public class CreateVirtualTourDto
    {
        [Required, MaxLength(150)]
        public string Title { get; set; } = string.Empty;

        [Required, MaxLength(500)]
        public string TourUrl { get; set; } = string.Empty;
    }
}
