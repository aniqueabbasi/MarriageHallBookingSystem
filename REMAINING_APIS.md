# Remaining Backend APIs — Integration Specs

19 endpoints not yet wired into the frontend, grouped by domain. Each section is a self-contained spec you can hand to whoever integrates it.

All endpoints require `Authorization: Bearer {accessToken}` unless marked otherwise. `BookingStatus`, `PaymentStatus`, `PaymentMethod`, `NotificationType`, `UserRole` are all serialized as **strings** (e.g. `"Pending"`, not `0`).

---

## 1. Bookings (4 endpoints) — ⚠️ highest priority, lifecycle is incomplete without these

### `GET /api/bookings/{id}`
Fetch a single booking's detail.

- **Auth:** any authenticated user, but only the booking's customer, the hall's owner, or an Admin can view it — others get 403.
- **Response `200`:** `BookingResponseDto`
```json
{
  "id": 5,
  "hallId": 1,
  "hallName": "Grand Palace",
  "userId": 3,
  "customerName": "Ali Khan",
  "eventDate": "2027-01-01",
  "startTime": "10:00:00",
  "endTime": "14:00:00",
  "guestCount": 200,
  "status": "Pending",
  "totalAmount": 65000.00,
  "advanceAmount": 0,
  "amountPaid": 0,
  "foodPackageName": "Gold",
  "extraServiceNames": ["DJ"],
  "createdAt": "2026-07-16T15:32:26Z"
}
```
- **Errors:** `404` booking doesn't exist, `403` not your booking/hall.

### `GET /api/bookings/mine`
**Customer's "My Bookings" list.** Role: `Customer` only.

- **Response `200`:** `List<BookingResponseDto>` — every booking made by the logged-in customer, same shape as above, unfiltered by status (show Pending/Confirmed/Completed/Cancelled/Rejected all together; let the UI group/filter by `status`).

### `GET /api/bookings/for-my-halls`
**Hall owner's incoming booking requests — this is the screen that lets an owner confirm/reject a booking.** Role: `HallOwner` only.

- **Response `200`:** `List<BookingResponseDto>` — every booking made against any hall this owner owns, across all halls, all statuses.
- Frontend should show `status == "Pending"` bookings prominently (these are new requests awaiting action) and let the owner drill into a booking to change its status via the endpoint below.

### `PATCH /api/bookings/{id}/status`
**The confirm/reject/cancel/complete action.** This is the one endpoint that makes the whole booking flow functional beyond initial creation.

- **Auth:** depends on the target status:
  - `Cancelled` → the booking's own customer, OR the hall's owner, OR Admin
  - `Confirmed` / `Rejected` / `Completed` → only the hall's owner or Admin
- **Request body:**
```json
{
  "status": "Confirmed",
  "advanceAmount": 20000
}
```
  - `status` — required, one of `Confirmed`, `Rejected`, `Completed`, `Cancelled` (`Pending` is the initial state, never set via this endpoint)
  - `advanceAmount` — **required only when `status` is `Confirmed`**; must be > 0 and <= the booking's `totalAmount`. Omit/null for all other status values.
- **Allowed transitions (anything else returns 400):**
  - `Pending` → `Confirmed`, `Rejected`, `Cancelled`
  - `Confirmed` → `Completed`, `Cancelled`
  - `Completed`, `Cancelled`, `Rejected` → terminal, no further transitions
- **Response `200`:** updated `BookingResponseDto`
- **Side effect:** triggers a notification to the customer (or owner, for cancellation) — see §5 Notifications, which is why wiring that up alongside this is worth doing together.
- **Errors:** `400` invalid transition or missing/invalid `advanceAmount` when confirming, `403` wrong role for the target status, `404` booking not found.

---

## 2. Payments (3 endpoints)

### `POST /api/payments`
Customer submits a payment against their own booking (e.g. paying the advance). Role: `Customer` only.

- **Request body:**
```json
{
  "bookingId": 5,
  "amount": 20000,
  "method": "JazzCash",
  "transactionId": "TXN123456"
}
```
  - `method` — one of `Cash`, `CreditCard`, `DebitCard`, `BankTransfer`, `JazzCash`, `EasyPaisa`
  - `transactionId` — optional, max 100 chars
- **Response `200`:** `PaymentResponseDto`
```json
{
  "id": 1,
  "bookingId": 5,
  "amount": 20000,
  "method": "JazzCash",
  "status": "Pending",
  "transactionId": "TXN123456",
  "paidAt": null,
  "createdAt": "2026-07-18T10:00:00Z"
}
```
- Payment is always created as `Pending` — it needs to be verified (see next endpoint) before it counts. Notifies the hall owner to verify it.
- **Errors:** `404` booking not found, `403` not your booking, `400` booking is `Cancelled`/`Rejected`.

### `GET /api/payments/booking/{bookingId}`
Payment history for a booking — use this to show "amount paid so far" / a payment timeline.

- **Auth:** the booking's customer, the hall's owner, or Admin.
- **Response `200`:** `List<PaymentResponseDto>`
- **Errors:** `404`, `403`.

### `PATCH /api/payments/{id}/status`
Hall owner/Admin verifies a payment (marks it completed, failed, or refunded). Role: `HallOwner` or `Admin`.

- **Request body:**
```json
{ "status": "Completed" }
```
  - one of `Pending`, `Completed`, `Failed`, `Refunded`
- **Response `200`:** updated `PaymentResponseDto` (`paidAt` gets set automatically when status becomes `Completed`)
- Notifies the customer of the new status.
- **Errors:** `404` payment not found, `403` not this hall's owner.
- Note: `BookingResponseDto.amountPaid` (used everywhere bookings are shown) only sums payments with `status == "Completed"` — a `Pending` payment doesn't count toward it yet, so the UI should make clear a submitted payment is awaiting verification.

---

## 3. Reviews (2 endpoints)

### `POST /api/reviews`
Customer reviews a completed booking. Role: `Customer` only.

- **Request body:**
```json
{
  "bookingId": 5,
  "rating": 5,
  "comment": "Great venue, highly recommend!"
}
```
  - `rating` — required, 1-5
  - `comment` — optional, max 1000 chars
- **Response `200`:** `ReviewResponseDto`
```json
{
  "id": 1,
  "hallId": 1,
  "userId": 3,
  "customerName": "Ali Khan",
  "rating": 5,
  "comment": "Great venue, highly recommend!",
  "createdAt": "2026-07-18T10:00:00Z"
}
```
- **Business rules:**
  - Only reviewable if the booking's `status == "Completed"` — otherwise `400`
  - Only the booking's own customer can review it — otherwise `403`
  - One review per booking — a second attempt returns `409` "You have already reviewed this booking."
- **Frontend action:** show a "Leave a review" prompt on completed bookings in the My Bookings list that don't have a review yet (there's no endpoint to check "has this booking been reviewed" directly — either track it client-side after a successful review or call `GET /api/reviews/hall/{hallId}` and check if the booking's customer already appears against this hall).

### `GET /api/reviews/hall/{hallId}` — public, no auth needed
The actual review list for a hall's detail page.

- **Response `200`:** `List<ReviewResponseDto>` for that hall.
- Note: `GET /api/halls/{id}` already returns `averageRating`/`reviewCount` as aggregate numbers — this endpoint is what supplies the actual review text/list to render below that.

---

## 4. Favorites (3 endpoints)

All require `Customer` role.

### `GET /api/favorites`
- **Response `200`:** `List<FavoriteResponseDto>`
```json
[{
  "id": 1,
  "hallId": 1,
  "hallName": "Grand Palace",
  "city": "Lahore",
  "pricePerDay": 90000,
  "primaryImageUrl": "/uploads/halls/abc.jpg",
  "createdAt": "2026-07-18T10:00:00Z"
}]
```

### `POST /api/favorites/{hallId}`
- **Response `200`:** `FavoriteResponseDto` (same shape as above)
- **Errors:** `404` hall doesn't exist, `409` already favorited.

### `DELETE /api/favorites/{hallId}`
- **Response:** `204 No Content`
- **Errors:** `404` — not currently favorited (note: keyed by `hallId`, not the favorite's own `id`).

**Frontend action:** replace the local-only favorite toggle with these three, and hydrate the favorited state from `GET /api/favorites` on load rather than a client-side default.

---

## 5. Notifications (3 endpoints)

Notifications are **already being generated server-side** — booking creation and every status change (confirm/reject/cancel/complete, payment verification) fires one automatically. Nothing to change backend-side; this is purely "go read what's already there."

### `GET /api/notifications`
- **Response `200`:** `List<NotificationResponseDto>`, newest first
```json
[{
  "id": 1,
  "type": "BookingConfirmed",
  "title": "Booking Confirmed",
  "message": "Your booking for \"Grand Palace\" on 2027-01-01 is now Confirmed.",
  "isRead": false,
  "createdAt": "2026-07-18T10:00:00Z"
}]
```
  - `type` is one of `BookingRequested`, `BookingConfirmed`, `BookingRejected`, `BookingCancelled`, `PaymentReceived`, `ReviewReminder`, `General` — useful for picking an icon per notification type.

### `PATCH /api/notifications/{id}/read`
Mark a single notification read.
- **Response:** `204 No Content`. **Errors:** `404` (not found, or not yours — same message either way).

### `PATCH /api/notifications/read-all`
Mark every unread notification for the current user as read in one call.
- **Response:** `204 No Content`, no body, no per-item confirmation.

---

## 6. Admin (4 endpoints) — likely out of scope for the Flutter app

All require `Admin` role. These back the standalone HTML admin panel built earlier in this project (`wwwroot/admin/`), not the customer/owner-facing Flutter app. Listed here for completeness in case an in-app admin surface is ever planned — otherwise skip.

| Endpoint | Response |
|---|---|
| `GET /api/admin/users` | `List<UserDto>` — every registered user |
| `PATCH /api/admin/users/{id}/role` | body: raw JSON string `"Admin"` / `"HallOwner"` / `"Customer"` → returns updated `UserDto` |
| `GET /api/admin/halls` | `List<HallListDto>` — every hall regardless of `isActive` |
| `GET /api/admin/bookings` | `List<BookingResponseDto>` — every booking across the whole platform |

---

## Suggested integration order

1. **Bookings §1** first — without `for-my-halls` + `UpdateStatus`, hall owners have no way to act on bookings at all, which is a bigger functional gap than any of the "dummy data" screens.
2. **Notifications §5** alongside it — the two are tightly coupled (every status change in §1 fires a notification), and the backend work for notifications is already done.
3. **Payments §2** next, to close the loop on advance payment collection/verification.
4. **Reviews §3** and **Favorites §4** — independent, lower-priority, can be done in either order.
5. **Admin §6** — only if/when an in-app admin view is actually planned.
