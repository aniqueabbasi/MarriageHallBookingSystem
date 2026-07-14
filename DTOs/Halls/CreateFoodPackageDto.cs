using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Halls
{
    public class CreateFoodPackageDto
    {
        [Required, MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Description { get; set; } = string.Empty;

        [Range(0, double.MaxValue)]
        public decimal PricePerHead { get; set; }
    }
}
