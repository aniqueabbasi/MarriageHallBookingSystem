using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Halls
{
    public class CreateExtraServiceDto
    {
        [Required, MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Description { get; set; } = string.Empty;

        [Range(0, double.MaxValue)]
        public decimal Price { get; set; }
    }
}
