# Backend API Changes — Frontend Integration Guide

This document covers every backend API change made in the recent update round. Give this to whoever is integrating the Flutter frontend against these endpoints.

---

## 1. Auth changes

### Access tokens now last 7 days
`accessToken` returned from login/register is now valid for **7 days** instead of 1 hour. `expiresAt` in the response reflects this.

### Refresh tokens removed entirely
`POST /api/auth/refresh` and `POST /api/auth/revoke` **no longer exist** (404 if called). The refresh-token flow is gone from the backend completely.

**`TokenResponseDto` — the `refreshToken` field is gone:**
```json
{
  "accessToken": "eyJ...",
  "expiresAt": "2026-07-24T12:00:00Z",
  "user": { "id": 1, "fullName": "...", "email": "...", "phoneNumber": "...", "role": "Customer" }
}
```
**Frontend action required:** remove any code that stores, sends, or refreshes using a `refreshToken`. When the access token expires (after 7 days), the user simply has to log in again — there is no silent refresh anymore.

---

## 2. Hall creation — `POST /api/halls`

**Content-Type changed from `application/json` to `multipart/form-data`.** JSON bodies are no longer accepted (415 Unsupported Media Type).

This single call now creates the hall, its images, its food packages, and its extra services all at once. **There is no longer a way to add these after creation** — food packages/extra services/images can only be set here or via the update endpoint below (see §3). To add a new food package to an existing hall, you must send an update.

### Form fields

| Field | Type | Required | Notes |
|---|---|---|---|
| `Name` | string | yes | max 150 chars |
| `Description` | string | yes | |
| `Address` | string | yes | max 250 chars |
| `City` | string | yes | max 100 chars |
| `Capacity` | int | yes | > 0 |
| `PricePerDay` | decimal | yes | >= 0 |
| `Images` | file(s) | **yes, at least 1** | repeat the field name for multiple files: `Images=file1.jpg`, `Images=file2.jpg`, etc. JPEG/PNG/WEBP only, 5MB max each. **First image uploaded becomes the primary image.** |
| `FoodPackages` | string | no | **JSON array as a string** — see format below |
| `ExtraServices` | string | no | **JSON array as a string** — see format below |

### FoodPackages / ExtraServices format

These are **not** repeated indexed fields — send one form field containing a JSON array as plain text.

`FoodPackages` value:
```json
[{"name":"Gold","description":"Premium package","pricePerHead":1500}]
```

`ExtraServices` value (note: `price`, not `pricePerHead`):
```json
[{"name":"DJ","description":"Music setup","price":10000}]
```

Multiple items — just add more objects to the array:
```json
[{"name":"Gold","description":"...","pricePerHead":1500},{"name":"Silver","description":"...","pricePerHead":900}]
```

Leave the field empty (or omit it) if there are no food packages/extra services to add.

**⚠️ Common mistake:** sending a bare object `{"name":"Gold",...}` instead of an array `[{"name":"Gold",...}]` — even for a single item, it must be wrapped in `[ ]`. A bare object (or any invalid JSON) returns:
```json
{ "message": "FoodPackages must be a valid JSON array, e.g. [{\"name\":\"...\"}]." }
```

### Response — `200 OK`, `HallDetailDto`
```json
{
  "id": 12,
  "ownerId": 5,
  "ownerName": "Jane Doe",
  "name": "Grand Palace",
  "description": "...",
  "address": "...",
  "city": "Lahore",
  "capacity": 300,
  "pricePerDay": 90000,
  "isActive": true,
  "averageRating": 0,
  "reviewCount": 0,
  "images": [
    { "id": 1, "imageUrl": "/uploads/halls/abc123.jpg", "isPrimary": true },
    { "id": 2, "imageUrl": "/uploads/halls/def456.jpg", "isPrimary": false }
  ],
  "virtualTours": [],
  "foodPackages": [
    { "id": 7, "name": "Gold", "description": "...", "pricePerHead": 1500 }
  ],
  "extraServices": [
    { "id": 4, "name": "DJ", "description": "...", "price": 10000 }
  ]
}
```
`imageUrl` is a relative path — prepend your API base URL to display it (e.g. `http://your-api-host{imageUrl}`).

### Error responses
| Status | Cause |
|---|---|
| 400 | No images provided, an image too large/wrong type, malformed FoodPackages/ExtraServices JSON, or a validation failure inside one of those entries |
| 415 | Content-Type isn't `multipart/form-data` |
| 401/403 | Missing/invalid token, or role isn't HallOwner/Admin |

### Removed endpoints
These no longer exist — remove any calls to them:
- ~~`POST /api/halls/{id}/images`~~
- ~~`POST /api/halls/{id}/food-packages`~~
- ~~`POST /api/halls/{id}/extra-services`~~

---

## 3. Hall update — `PUT /api/halls/{id}`

**Also changed to `multipart/form-data`.** This is where you now add food packages/extra services/images to an *existing* hall.

### Form fields

| Field | Type | Required | Notes |
|---|---|---|---|
| `Name` | string | yes | |
| `Description` | string | yes | |
| `Address` | string | yes | |
| `City` | string | yes | |
| `Capacity` | int | yes | > 0 |
| `PricePerDay` | decimal | yes | >= 0 |
| `IsActive` | bool | yes | toggle hall visibility in search |
| `Images` | file(s) | no | **Additive** — any images sent here are *added* to the hall's existing images. None of them become primary (the original primary stays). Omit entirely to leave images untouched. |
| `FoodPackages` | string | no | JSON array, same format as create. **⚠️ Full replace, not additive** — see below |
| `ExtraServices` | string | no | JSON array, same format as create. **⚠️ Full replace, not additive** |

### ⚠️ Important: FoodPackages/ExtraServices are a full replace on update
Whatever you send in `FoodPackages`/`ExtraServices` **becomes the hall's complete set** — it does not append to what's already there.

- To **add** a food package to a hall that already has one: send the existing one(s) *and* the new one together in the array.
- To **keep** the existing food packages unchanged: omit the field entirely (send nothing/empty), and the current ones stay untouched — sending an empty array `[]` will clear all of them.
- If you send the field at all with different content than what currently exists, the old ones are removed (soft-deleted) and the new ones take their place.

This is asymmetric with `Images` (which is additive) — worth flagging clearly in the UI/form logic so a hall owner doesn't accidentally wipe their food packages by only sending the ones they're adding.

### Response
Same `HallDetailDto` shape as create (§2).

### Errors
Same shape as create, plus:
| Status | Cause |
|---|---|
| 403 | Caller doesn't own this hall (and isn't Admin) |
| 404 | Hall doesn't exist |

---

## 4. New delete endpoints (soft delete)

All three return `204 No Content` on success, are Hall Owner/Admin only, enforce ownership (403) and that the item belongs to the given hall (404).

| Endpoint | Deletes |
|---|---|
| `DELETE /api/halls/{hallId}/food-packages/{packageId}` | A food package |
| `DELETE /api/halls/{hallId}/extra-services/{serviceId}` | An extra service |
| `DELETE /api/halls/{hallId}/virtual-tours/{tourId}` | A virtual tour |

These are **soft deletes** — the row stays in the database (so historical bookings still resolve their name correctly), but it's filtered out of `GET /api/halls/{id}`'s `foodPackages[]`/`extraServices[]`/`virtualTours[]` arrays from that point on, and can no longer be selected when creating a new booking.

`POST /api/halls/{id}/virtual-tours` (add a virtual tour) is unchanged — still JSON, still works as before.

---

## 5. Booking creation — new error messages for stale/deleted items

If a customer's app has a cached food package or extra service id that the hall owner has since deleted (soft-deleted, per §4), `POST /api/bookings` now returns a **distinct, actionable error** instead of a generic "doesn't belong to this hall" message:

| Scenario | Message |
|---|---|
| Food package id belongs to a different hall | `"Selected food package does not belong to this hall."` |
| Food package id is valid for this hall but was deleted | `"This food package is no longer offered. Please refresh and select again."` |
| Extra service id belongs to a different hall | `"One or more selected extra services do not belong to this hall."` |
| Extra service id is valid for this hall but was deleted | `"This extra service is no longer offered. Please refresh and select again."` |

**Frontend action required:** when either of the "no longer offered" messages comes back, the booking screen should refresh the hall detail (re-fetch `GET /api/halls/{id}`) so the user re-picks from the current list, rather than just showing a generic error — this is specifically a stale-cache case, not a bug.

---

## Quick checklist for frontend integration

- [ ] Remove all refresh-token storage/logic; handle 401 by sending the user to login again
- [ ] Update hall creation to send `multipart/form-data` with repeated `Images` file fields and JSON-string `FoodPackages`/`ExtraServices`
- [ ] Update hall edit screen to use `multipart/form-data` too, and warn/handle the fact that `FoodPackages`/`ExtraServices` are full-replace, not additive
- [ ] Add delete buttons/actions for food packages, extra services, and virtual tours on the owner's hall management screen
- [ ] Handle the two new booking error messages by refreshing hall detail and prompting re-selection
- [ ] Prepend your API base URL to every `imageUrl` returned in `images[]`
