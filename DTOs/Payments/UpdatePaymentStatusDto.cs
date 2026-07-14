using System.ComponentModel.DataAnnotations;
using marriage_hall_backend.Models.Enums;

namespace marriage_hall_backend.DTOs.Payments
{
    public class UpdatePaymentStatusDto
    {
        [Required]
        public PaymentStatus Status { get; set; }
    }
}
