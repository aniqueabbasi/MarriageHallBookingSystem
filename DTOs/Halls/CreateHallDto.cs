using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Halls
{
    public class CreateHallDto
    {
        [Required, MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Description { get; set; } = string.Empty;

        [Required, MaxLength(250)]
        public string Address { get; set; } = string.Empty;

        [Required, MaxLength(100)]
        public string City { get; set; } = string.Empty;

        [Range(1, int.MaxValue)]
        public int Capacity { get; set; }

        [Range(0, double.MaxValue)]
        public decimal PricePerDay { get; set; }
    }
}
