using marriage_hall_backend.DTOs.Bookings;
using marriage_hall_backend.Helpers;
using marriage_hall_backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace marriage_hall_backend.Controllers
{
    [ApiController]
    [Route("api/bookings")]
    [Authorize]
    public class BookingsController : ControllerBase
    {
        private readonly IBookingService _bookingService;

        public BookingsController(IBookingService bookingService)
        {
            _bookingService = bookingService;
        }

        [HttpPost]
        [Authorize(Roles = "Customer")]
        public async Task<ActionResult<BookingResponseDto>> Create(CreateBookingDto dto)
            => Ok(await _bookingService.CreateAsync(User.GetUserId(), dto));

        [HttpGet("{id:int}")]
        public async Task<ActionResult<BookingResponseDto>> GetById(int id)
            => Ok(await _bookingService.GetByIdAsync(id, User.GetUserId(), User.GetRole()));

        [HttpGet("mine")]
        [Authorize(Roles = "Customer")]
        public async Task<ActionResult<List<BookingResponseDto>>> GetMine()
            => Ok(await _bookingService.GetForCustomerAsync(User.GetUserId()));

        [HttpGet("for-my-halls")]
        [Authorize(Roles = "HallOwner")]
        public async Task<ActionResult<List<BookingResponseDto>>> GetForMyHalls()
            => Ok(await _bookingService.GetForHallOwnerAsync(User.GetUserId()));

        [HttpPatch("{id:int}/status")]
        public async Task<ActionResult<BookingResponseDto>> UpdateStatus(int id, UpdateBookingStatusDto dto)
            => Ok(await _bookingService.UpdateStatusAsync(id, User.GetUserId(), User.GetRole(), dto));
    }
}
