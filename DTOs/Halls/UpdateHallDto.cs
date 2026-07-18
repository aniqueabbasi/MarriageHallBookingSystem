using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;

namespace marriage_hall_backend.DTOs.Halls
{
    public class UpdateHallDto
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

        public bool IsActive { get; set; } = true;

        /// <summary>New images to append (existing images are kept, none of these become primary).</summary>
        public List<IFormFile> Images { get; set; } = new();

        /// <summary>JSON-encoded array; full replace of the hall's food packages, e.g. [{"name":"Gold","description":"...","pricePerHead":500}]</summary>
        public string? FoodPackages { get; set; }

        /// <summary>JSON-encoded array; full replace of the hall's extra services, e.g. [{"name":"DJ","description":"...","price":10000}]</summary>
        public string? ExtraServices { get; set; }
    }
}
