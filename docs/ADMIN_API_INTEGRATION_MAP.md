# Acadyk Admin API Integration Map

This document establishes the end-to-end integration architecture across the Admin Panel, Spring Boot Backend, PostgreSQL Database, and Flutter User Panel.

---

## Complete Feature Matrix

| # | Feature | Status | Notes |
|---|---|---|---|
| 1 | Authentication & RBAC | **NEEDS CONNECTION** | Backend JWT & Firebase Auth filter exist; Admin Panel login needs connection to real backend session/token. |
| 2 | Event Management | **EXISTS / NEEDS CONNECTION** | Backend CRUD & registration exist in `EventController`/`EventService`; Admin UI needs full connection. |
| 3 | Student Management | **PARTIALLY EXISTS** | DB supports `users` + `profiles` + institutional fields; Admin needs `/admin/users` query & update endpoints. |
| 4 | Faculty Management | **PARTIALLY EXISTS** | Supported by `users(role='FACULTY')` and `ProfileEntity`; Admin user filters need backend query endpoint. |
| 5 | Account Suspension | **PARTIALLY EXISTS** | `AccountStatus.SUSPENDED` exists in `UserEntity`; Backend filter enforcement & Admin action need hookup. |
| 6 | Campus Clubs | **EXISTS / NEEDS CONNECTION** | `ClubController`, `ClubService`, `clubs`, `club_members` exist; Admin UI needs connection to real API. |
| 7 | Teams & Societies | **PARTIALLY EXISTS** | Modeled in DB as `communities` or `clubs` with subcategories; Admin UI needs API connection. |
| 8 | Organizations | **EXISTS / NEEDS CONNECTION** | `CommunityController` & `ClubController` exist; mapped to Admin Organizations screen. |
| 9 | Content & Moderation | **PARTIALLY EXISTS** | `PostController` exists; Admin moderation endpoints (`/admin/posts`) need backend controller connection. |
| 10 | Academic Notices | **PARTIALLY EXISTS** | Backend can serve notices via `posts` with announcement type or dedicated notice entity; Admin needs hookup. |
| 11 | Results Management | **MISSING** | Academic semester grade tables not yet in primary DB; can be linked via `users(enrollment_number)`. |
| 12 | Notifications | **EXISTS** | `NotificationController` and `fcmService` exist; Admin broadcast notification endpoint can be connected. |
| 13 | Dashboard Statistics | **PARTIALLY EXISTS** | Individual entity tables exist; aggregated `/admin/dashboard/stats` query endpoint needed in backend. |

---

## Detailed End-to-End Traces

### 1. Authentication & RBAC
- **Status**: `NEEDS CONNECTION`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_login_screen.dart`
  - **ADMIN SERVICE**: `AdminService.authenticate()` in `lib/admin/data/admin_service.dart`
  - **API ENDPOINT**: `POST /api/v1/auth/login` or `POST /api/v1/auth/verify-token`
  - **SPRING BOOT SERVICE**: `AuthService.login()` / `FirebaseTokenVerifier.verifyToken()`
  - **DATABASE**: `users`, `profiles`, `auth_audit_logs`
  - **USER API**: `GET /api/v1/auth/session` / `GET /api/v1/users/me`
  - **USER PANEL**: `apps/mobile/lib/features/auth`

---

### 2. Event Management (Phase 6 Priority Flow)
- **Status**: `EXISTS / NEEDS CONNECTION`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_events_screen.dart`
  - **ADMIN SERVICE**: `AdminEventsProvider` -> `AdminService.createEvent()` / `AdminService.getEvents()`
  - **API ENDPOINT**:
    - List: `GET /api/v1/events`
    - View: `GET /api/v1/events/{id}`
    - Create: `POST /api/v1/events`
    - Update: `PUT /api/v1/events/{id}`
    - Delete: `DELETE /api/v1/events/{id}`
    - Register: `POST /api/v1/events/{id}/register`
  - **SPRING BOOT SERVICE**: `EventService.kt` (`getEvents()`, `getEventById()`, `createEvent()`, `registerForEvent()`)
  - **DATABASE**: `events`, `event_registrations`, `profiles`
  - **USER API**: `GET /api/v1/events`, `POST /api/v1/events/{id}/register`
  - **USER PANEL**: `apps/mobile/lib/features/events/presentation/providers/event_provider.dart`

---

### 3. Students Management
- **Status**: `PARTIALLY EXISTS`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_users_screen.dart` & `admin_user_detail_screen.dart`
  - **ADMIN SERVICE**: `AdminUsersProvider` -> `AdminService.getUsers(roleFilter: 'STUDENT')`
  - **API ENDPOINT**: `GET /api/v1/admin/users?role=STUDENT&search=...`
  - **SPRING BOOT SERVICE**: `UserService` / `AdminUserService`
  - **DATABASE**: `users` (`enrollment_number`, `degree`, `branch`, `joining_year`, `account_status`), `profiles`
  - **USER API**: `GET /api/v1/users/identity`, `GET /api/v1/profiles/{id}`
  - **USER PANEL**: `apps/mobile/lib/features/profile`

---

### 4. Faculty Management
- **Status**: `PARTIALLY EXISTS`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_users_screen.dart` (Faculty Tab)
  - **ADMIN SERVICE**: `AdminUsersProvider` -> `AdminService.getUsers(roleFilter: 'FACULTY')`
  - **API ENDPOINT**: `GET /api/v1/admin/users?role=FACULTY`
  - **SPRING BOOT SERVICE**: `UserService` / `AdminUserService`
  - **DATABASE**: `users(role='FACULTY')`, `profiles`
  - **USER API**: `GET /api/v1/search/profiles?q=...`
  - **USER PANEL**: `apps/mobile/lib/features/profile`

---

### 5. Account Suspension
- **Status**: `PARTIALLY EXISTS`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_user_detail_screen.dart` (Suspend Button & Modal)
  - **ADMIN SERVICE**: `AdminUsersProvider` -> `AdminService.updateUserStatus(userId, 'suspended')`
  - **API ENDPOINT**: `PATCH /api/v1/admin/users/{userId}/suspend`
  - **SPRING BOOT SERVICE**: `AdminUserService.suspendUser(userId, reason)`
  - **DATABASE**: `users.account_status = 'SUSPENDED'`, `auth_audit_logs`
  - **USER API**: `FirebaseAuthFilter` checks `user.accountStatus == AccountStatus.SUSPENDED` -> Returns `403 FORBIDDEN`
  - **USER PANEL**: Mobile App intercepts `403` and displays Suspension Notice screen.

---

### 6. Clubs Management
- **Status**: `EXISTS / NEEDS CONNECTION`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_organizations_screen.dart` (Clubs Tab)
  - **ADMIN SERVICE**: `AdminOrganizationsProvider` -> `AdminService.getOrganizations()`
  - **API ENDPOINT**: `GET /api/v1/clubs`, `POST /api/v1/clubs`, `GET /api/v1/clubs/{id}`
  - **SPRING BOOT SERVICE**: `ClubService.kt`
  - **DATABASE**: `clubs`, `club_members`, `profiles`
  - **USER API**: `GET /api/v1/clubs`, `POST /api/v1/clubs/{id}/join`
  - **USER PANEL**: `apps/mobile/lib/features/clubs`

---

### 7. Teams & Communities
- **Status**: `EXISTS / NEEDS CONNECTION`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_organizations_screen.dart` (Teams Tab)
  - **ADMIN SERVICE**: `AdminOrganizationsProvider` -> `AdminService.getOrganizations()`
  - **API ENDPOINT**: `GET /api/v1/communities`, `POST /api/v1/communities`
  - **SPRING BOOT SERVICE**: `CommunityService.kt`
  - **DATABASE**: `communities`, `community_members`, `profiles`
  - **USER API**: `GET /api/v1/communities`, `POST /api/v1/communities/{id}/join`
  - **USER PANEL**: `apps/mobile/lib/features/community`

---

### 8. Organizations
- **Status**: `EXISTS / NEEDS CONNECTION`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_organizations_screen.dart`
  - **ADMIN SERVICE**: `AdminOrganizationsProvider`
  - **API ENDPOINT**: `GET /api/v1/clubs` + `GET /api/v1/communities`
  - **SPRING BOOT SERVICE**: `ClubService` + `CommunityService`
  - **DATABASE**: `clubs`, `communities`
  - **USER API**: `GET /api/v1/clubs`, `GET /api/v1/communities`
  - **USER PANEL**: `apps/mobile/lib/features/clubs`, `features/community`

---

### 9. Posts & Content Moderation
- **Status**: `PARTIALLY EXISTS`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_content_screen.dart`
  - **ADMIN SERVICE**: `AdminContentProvider` -> `AdminService.getContent()`, `AdminService.updateContentStatus()`
  - **API ENDPOINT**: `GET /api/v1/posts`, `DELETE /api/v1/posts/{id}`, `PATCH /api/v1/admin/posts/{id}/status`
  - **SPRING BOOT SERVICE**: `PostService.kt`
  - **DATABASE**: `posts`, `post_reactions`, `comments`, `profiles`
  - **USER API**: `GET /api/v1/posts`, `POST /api/v1/posts`
  - **USER PANEL**: `apps/mobile/lib/features/feed`

---

### 10. Academic Notices
- **Status**: `PARTIALLY EXISTS`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_notices_screen.dart`
  - **ADMIN SERVICE**: `AdminNoticesProvider` -> `AdminService.getNotices()`, `AdminService.createNotice()`
  - **API ENDPOINT**: `GET /api/v1/posts?type=announcement` or `GET /api/v1/admin/notices`
  - **SPRING BOOT SERVICE**: `PostService` / `NoticeService`
  - **DATABASE**: `posts` or `notices`
  - **USER API**: `GET /api/v1/posts`
  - **USER PANEL**: `apps/mobile/lib/features/feed` / `features/notifications`

---

### 11. Academic Results
- **Status**: `MISSING`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_user_detail_screen.dart` (Academic Record Tab)
  - **ADMIN SERVICE**: `AdminService.getStudentResult(enrollmentNumber)`
  - **API ENDPOINT**: `GET /api/v1/admin/results/{enrollmentNumber}`
  - **SPRING BOOT SERVICE**: `ResultService` (Compact schema extension)
  - **DATABASE**: Linked via `users.enrollment_number`
  - **USER API**: `GET /api/v1/users/results`
  - **USER PANEL**: `apps/mobile/lib/features/profile`

---

### 12. Notifications
- **Status**: `EXISTS`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_dashboard_screen.dart` & `admin_activity_screen.dart`
  - **ADMIN SERVICE**: `AdminService`
  - **API ENDPOINT**: `GET /api/v1/notifications`, `POST /api/v1/notifications/fcm-token`
  - **SPRING BOOT SERVICE**: `NotificationService.kt`, `FcmService.kt`
  - **DATABASE**: `notifications`, `notification_preferences`
  - **USER API**: `GET /api/v1/notifications`, `POST /api/v1/notifications/{id}/read`
  - **USER PANEL**: `apps/mobile/lib/features/notifications`

---

### 13. Dashboard Statistics
- **Status**: `PARTIALLY EXISTS`
- **Trace**:
  - **ADMIN UI**: `lib/admin/screens/admin_dashboard_screen.dart`
  - **ADMIN SERVICE**: `AdminDashboardProvider` -> `AdminService.getDashboardStats()`
  - **API ENDPOINT**: `GET /api/v1/admin/dashboard/stats`
  - **SPRING BOOT SERVICE**: `AdminDashboardService` (aggregating `userRepository`, `eventRepository`, `clubRepository`, `postRepository`)
  - **DATABASE**: `users`, `events`, `clubs`, `posts`, `communities`
  - **USER API**: N/A (Admin only)
  - **USER PANEL**: N/A
