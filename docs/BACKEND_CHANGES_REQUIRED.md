# Backend Changes Required

> **IMPORTANT:**
> The Admin Panel is now connected to the real backend at `http://15.252.182.118:8080/api/v1`.
> **Event listing (GET)** and **event creation (POST)** work with the existing backend.
> **Event update (PUT)** and **event delete (DELETE)** require the backend changes below.

## What Works Now (No Backend Changes Needed)

| Admin Action | Backend Endpoint | Status |
|---|---|---|
| List Events | `GET /api/v1/events` | ✅ Working |
| Create Event | `POST /api/v1/events` | ✅ Working |
| Dashboard Stats | `GET /api/v1/events?size=1` (count) | ✅ Working |

## What Needs Backend Changes

| Admin Action | Required Endpoint | Status |
|---|---|---|
| Update Event | `PUT /api/v1/events/{id}` | ❌ Not implemented |
| Delete Event | `DELETE /api/v1/events/{id}` | ❌ Not implemented |
| Admin Login | `POST /api/v1/auth/login` | ⚠️ Needs email+password flow |

---

## 1. Add to `EventDtos.kt`

```kotlin
data class UpdateEventRequest(
    val title: String? = null,
    val description: String? = null,
    val eventType: String? = null,
    val location: String? = null,
    val isVirtual: Boolean? = null,
    val meetingLink: String? = null,
    val startTime: Instant? = null,
    val endTime: Instant? = null,
    val bannerUrl: String? = null,
    val maxAttendees: Int? = null
)
```

## 2. Add to `EventService.kt`

```kotlin
@Transactional
fun updateEvent(eventId: String, request: UpdateEventRequest, userId: String): EventResponse {
    val event = eventRepository.findByIdAndDeletedAtIsNull(eventId)
        .orElseThrow { ResourceNotFoundException("Event not found: $eventId") }

    request.title?.let { event.title = it; event.slug = it.lowercase().replace(" ", "-") }
    request.description?.let { event.description = it }
    request.eventType?.let { event.eventType = it }
    request.location?.let { event.location = it }
    request.isVirtual?.let { event.isVirtual = it }
    request.meetingLink?.let { event.meetingLink = it }
    request.startTime?.let { event.startTime = it }
    request.endTime?.let { event.endTime = it }
    request.bannerUrl?.let { event.bannerUrl = it }
    request.maxAttendees?.let { event.maxAttendees = it }
    event.updatedAt = Instant.now()

    val saved = eventRepository.save(event)
    return eventMapper.toResponse(saved)
}

@Transactional
fun deleteEvent(eventId: String, userId: String) {
    val event = eventRepository.findByIdAndDeletedAtIsNull(eventId)
        .orElseThrow { ResourceNotFoundException("Event not found: $eventId") }

    event.deletedAt = Instant.now()
    event.updatedAt = Instant.now()
    eventRepository.save(event)
}
```

## 3. Add to `EventController.kt`

```kotlin
@PutMapping("/{id}")
fun updateEvent(
    @PathVariable id: String,
    @RequestBody request: UpdateEventRequest,
    @AuthenticationPrincipal principal: UserPrincipal
): ResponseEntity<ApiResponse<EventResponse>> {
    val updated = eventService.updateEvent(id, request, principal.id)
    return ResponseEntity.ok(ApiResponse.success(updated, "Event updated"))
}

@DeleteMapping("/{id}")
fun deleteEvent(
    @PathVariable id: String,
    @AuthenticationPrincipal principal: UserPrincipal
): ResponseEntity<ApiResponse<Nothing>> {
    eventService.deleteEvent(id, principal.id)
    return ResponseEntity.ok(ApiResponse.success(null, "Event deleted"))
}
```

## 4. Flyway Migration (if `deleted_at` column missing)

Create `V15__add_deleted_at_to_events.sql`:
```sql
ALTER TABLE events ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;
```

---

## How the Admin Panel Falls Back

1. **Backend reachable** → Real data from PostgreSQL via API
2. **Backend unreachable** → Falls back to in-memory mock data seamlessly
3. **Endpoint missing (404/405)** → Falls back to mock data for that operation
