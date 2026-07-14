using System.ComponentModel.DataAnnotations;

namespace marriage_hall_backend.DTOs.Reviews
{
    public class CreateReviewDto
    {
        [Required]
        public int BookingId { get; set; }

        [Range(1, 5)]
        public int Rating { get; set; }

        [MaxLength(1000)]
        public string? Comment { get; set; }
    }
}
