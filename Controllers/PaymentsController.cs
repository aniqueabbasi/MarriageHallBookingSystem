using marriage_hall_backend.DTOs.Payments;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace marriage_hall_backend.Controllers
{
    [ApiController]
    [Route("api/payments")]
    [Authorize]
    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentsController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpPost]
        [Authorize(Roles = "Customer")]
        public async Task<ActionResult<PaymentResponseDto>> Create(CreatePaymentDto dto)
            => Ok(await _paymentService.CreateAsync(User.GetUserId(), dto));

        [HttpGet("booking/{bookingId:int}")]
        public async Task<ActionResult<List<PaymentResponseDto>>> GetForBooking(int bookingId)
            => Ok(await _paymentService.GetForBookingAsync(bookingId, User.GetUserId(), User.GetRole()));

        [HttpPatch("{id:int}/status")]
        [Authorize(Roles = "HallOwner,Admin")]
        public async Task<ActionResult<PaymentResponseDto>> UpdateStatus(int id, UpdatePaymentStatusDto dto)
            => Ok(await _paymentService.UpdateStatusAsync(id, User.GetUserId(), User.GetRole(), dto));
    }
}
