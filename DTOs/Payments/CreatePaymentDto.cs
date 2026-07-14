using System.ComponentModel.DataAnnotations;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.DTOs.Payments
{
    public class CreatePaymentDto
    {
        [Required]
        public int BookingId { get; set; }

        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        [Required]
        public PaymentMethod Method { get; set; }

        [MaxLength(100)]
        public string? TransactionId { get; set; }
    }
}
