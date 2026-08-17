# Acadyk Admin & User Panel Integration Audit

**Document Version:** 1.0.0  
**Generated Date:** 2026-08-17  
**Projects Audited:**
1. **User Panel & Backend:** `https://github.com/somraj-dev/Acadyk` (Kotlin Spring Boot + PostgreSQL + Flutter Mobile)
2. **Admin Panel:** `https://github.com/sudhanshupatel517-collab/adminacadyk` (Flutter Web)

---

## 1. Executive Summary & Existing Architecture

The Acadyk ecosystem is divided into three primary components:
1. **Spring Boot Backend (`acadyk-api`)**:
   - **Language/Framework**: Kotlin 1.9+, Spring Boot 3.2+, Spring Security 6+, Spring Data JPA, Hibernate, Flyway.
   - **Persistence/Infrastructure**: PostgreSQL (relational), Redis (distributed locks, caching), AWS S3 (media storage), Apache Kafka (domain event streaming), Firebase Admin SDK (identity verification).
   - **Deployment/Base URL**: `http://15.252.182.118:8080/api/v1` (Active remote staging instance).
2. **User Panel (`apps/mobile`)**:
   - **Framework**: Flutter / Dart with Riverpod state management.
   - **Focus**: Student community, events feed, campus clubs, startup hub, direct chat, networking, opportunities.
3. **Admin Panel (`adminacadyk` / `admin ui`)**:
   - **Framework**: Flutter Web / Dart with Provider state management.
   - **Focus**: Administrative governance, user & faculty management, role assignment, account suspension, event approvals/creation, organization/club oversight, post moderation, exam notices, and system analytics.

---

## 2. Existing Authentication & Authorization Architecture

### A. Authentication System
- **User Panel / Mobile**: Authenticates primarily via Firebase Google Sign-In, obtaining a Firebase ID Token. The mobile client sends `Authorization: Bearer <token>` to `POST /api/v1/auth/verify-token` or in HTTP headers.
- **Backend Filter (`FirebaseAuthFilter.kt`)**: Intercepts requests with `Authorization: Bearer <token>`.
  - Production mode: Verifies ID token with `FirebaseAuth.getInstance().verifyIdToken(token)`.
  - Fallback / Dev mode: Supports HMAC JWT tokens or test bearer tokens (`test-token-<uid>`) for local development without active Firebase credentials.
  - Automatically provisions user in PostgreSQL `users` and `profiles` tables if not present upon first sign-in.
- **Admin Panel Authentication**:
  - Currently contains client-side mock credentials (`admin@acadyk.edu`, `SuperAdmin2026!`) in `AdminMockData.dart`.
  - `admin_service.dart` falls back to `AdminMockData` when calls to `/admin/*` fail.

### B. Authorization & Role-Based Access Control (RBAC)
- Defined in `com.acadyk.security.Role.kt`:
  - `STUDENT` (`ROLE_STUDENT`)
  - `FACULTY` (`ROLE_FACULTY`)
  - `COLLEGE_ADMIN` (`ROLE_COLLEGE_ADMIN`)
  - `COMPANY` (`ROLE_COMPANY`)
  - `MODERATOR` (`ROLE_MODERATOR`)
  - `SUPER_ADMIN` (`ROLE_SUPER_ADMIN`)
- Backend `SecurityConfig.kt` enables `@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)`.
- Backend enforces role verification using Spring Security `UserPrincipal` and `@PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN')")`.

---

## 3. Existing Database Schema & Entity Inventory (PostgreSQL / Flyway)

The PostgreSQL database contains 14 Flyway migrations (`V1` to `V14`):

| Table | Migration | Entity (`com.acadyk`) | Purpose & Key Relationships |
|---|---|---|---|
| `users` | `V2`, `V14` | `UserEntity` | Core user credentials, `firebase_uid`, `college_email`, `enrollment_number`, `degree`, `branch`, `joining_year`, `role`, `account_status` (`ACTIVE`, `PENDING_VERIFICATION`, `SUSPENDED`, `INACTIVE`), `is_active`. |
| `profiles` | `V2` | `ProfileEntity` | Public student/faculty identity, `username`, `full_name`, `bio`, `college_name`, `major`, `profile_photo_url`, `followers_count`, `connections_count`. FK -> `users(id)`. |
| `educations` | `V3` | `EducationEntity` | Student degree history, institutions, grades. FK -> `profiles(id)`. |
| `experiences` | `V3` | `ExperienceEntity` | Work/internship history, role, company. FK -> `profiles(id)`. |
| `certificates` | `V3` | `CertificateEntity` | Student credentials & licenses. FK -> `profiles(id)`. |
| `resumes` | `V3` | `ResumeEntity` | Uploaded resumes, PDF URLs, default resume flags. FK -> `profiles(id)`. |
| `posts` | `V4` | `PostEntity` | Campus feed posts, text/media, `author_id` (FK -> `profiles`), `like_count`, `comment_count`. |
| `comments` | `V4` | `CommentEntity` | Post comments & threaded discussions. FK -> `posts`, `profiles`. |
| `post_reactions` | `V4` | `PostReactionEntity` | Likes, reactions, bookmarks on posts. |
| `connections` | `V5` | `ConnectionEntity` | Student connection network, status (`PENDING`, `ACCEPTED`, `REJECTED`, `BLOCKED`). |
| `follows` | `V5` | `FollowEntity` | Student-to-student and student-to-faculty follow graph. |
| `communities` | `V6` | `CommunityEntity` | Academic departments & interest communities. FK -> `profiles(id)`. |
| `community_members` | `V6` | `CommunityMemberEntity` | Membership & roles in communities. |
| `clubs` | `V6` | `ClubEntity` | Campus clubs, student societies, technical chapters. |
| `club_members` | `V6` | `ClubMemberEntity` | Club membership and leadership positions. |
| `events` | `V7` | `EventEntity` | Hackathons, workshops, guest lectures, webinars, meetups. `organizer_id` (FK -> `profiles`), `start_time`, `end_time`, `venue`, `is_virtual`, `banner_url`, `max_attendees`, `registrations_count`. |
| `event_registrations` | `V7` | `EventRegistrationEntity` | User event registrations & attendance status. FK -> `events(id)`, `profiles(id)`. |
| `opportunities` | `V7` | `OpportunityEntity` | Job postings, internships, research fellowships, scholarships. FK -> `profiles(id)`. |
| `opportunity_applications` | `V7` | `OpportunityApplicationEntity` | Student job applications, attached resume, application status. |
| `startups` | `V8` | `StartupEntity` | Student startups & ventures. FK -> `profiles(id)`. |
| `conversations` | `V9` | `ConversationEntity` | 1-on-1 direct messaging and group chats. |
| `messages` | `V9` | `MessageEntity` | Chat messages, timestamps, read receipts. |
| `notifications` | `V10` | `NotificationEntity` | In-app user notifications. |
| `notification_preferences` | `V10` | `NotificationPreferenceEntity` | Push/email notification preferences per user. |
| `leaderboards` | `V11` | `LeaderboardEntity` | Student activity scores, points, badges, rankings. |
| `auth_audit_logs` | `V14` | `AuthAuditLogEntity` | Authentication audit trail: `ip_address`, `device_info`, `event_type`, `success`, `failure_reason`. |

---

## 4. Existing API Endpoints Inventory

### Public & User Endpoints (`/api/v1`)
- **Authentication**:
  - `POST /api/v1/auth/verify-token` — Firebase ID Token verification & session creation.
  - `POST /api/v1/auth/login` — Direct email/password or dev login.
  - `POST /api/v1/auth/register` — Initial user registration.
  - `POST /api/v1/auth/reset-password` — Password reset.
  - `GET /api/v1/auth/session` — Get authenticated user session info.
  - `DELETE /api/v1/auth/delete-account` — Soft-delete account.
- **Users & Profiles**:
  - `GET /api/v1/users/me` — Authenticated profile.
  - `GET /api/v1/users/identity` — Detailed institutional identity (enrollment number, degree, branch, year, status).
  - `GET /api/v1/profiles/{id}` — Public profile by ID.
  - `PUT /api/v1/me/profile` — Update self profile.
  - `GET /api/v1/profiles/{id}/education` — Education history.
  - `POST /api/v1/me/education` — Add education record.
  - `GET /api/v1/profiles/{id}/experiences` — Experiences list.
  - `POST /api/v1/me/experiences` — Add experience.
  - `GET /api/v1/profiles/{id}/certificates` — Certificates list.
  - `POST /api/v1/me/certificates` — Add certificate.
  - `GET /api/v1/profiles/{id}/resumes` — Resumes list.
  - `POST /api/v1/me/resumes` — Upload resume.
  - `GET /api/v1/search/profiles?q={query}` — Search student/faculty profiles.
- **Events**:
  - `GET /api/v1/events` — Paginated list of events (filter by `eventType`).
  - `GET /api/v1/events/{id}` — Get single event with registration state.
  - `POST /api/v1/events` — Create event (organizer authenticated).
  - `POST /api/v1/events/{id}/register` — Register for event with distributed lock capacity checks.
- **Posts & Feed**:
  - `GET /api/v1/posts` — Paginated community posts feed.
  - `GET /api/v1/posts/{id}` — Get single post.
  - `POST /api/v1/posts` — Create post.
  - `DELETE /api/v1/posts/{id}` — Delete post (author).
  - `GET /api/v1/posts/{postId}/comments` — Comments list.
  - `POST /api/v1/posts/{postId}/comments` — Add comment.
  - `POST /api/v1/posts/{postId}/reactions` — Toggle reaction (like, etc.).
  - `POST /api/v1/posts/{postId}/bookmark` — Bookmark post.
- **Clubs & Communities**:
  - `GET /api/v1/clubs` — List campus clubs.
  - `GET /api/v1/clubs/{id}` — Club details.
  - `POST /api/v1/clubs` — Create club.
  - `POST /api/v1/clubs/{id}/join` — Join/leave club.
  - `GET /api/v1/communities` — List academic communities.
  - `GET /api/v1/communities/{id}` — Community details.
  - `POST /api/v1/communities` — Create community.
  - `POST /api/v1/communities/{id}/join` — Join/leave community.
- **Opportunities & Startups**:
  - `GET /api/v1/opportunities` — List opportunities (internships, jobs, scholarships).
  - `GET /api/v1/opportunities/{id}` — Opportunity details.
  - `POST /api/v1/opportunities` — Post opportunity.
  - `POST /api/v1/opportunities/{id}/apply` — Submit application.
  - `GET /api/v1/startups` — List startups.
  - `GET /api/v1/startups/{id}` — Startup details.
  - `POST /api/v1/startups` — Register startup.
- **Files & Storage**:
  - `POST /api/v1/files/upload` — Direct multipart file upload (S3).
  - `POST /api/v1/files/presigned-upload-url` — S3 presigned upload URL.
- **Notifications & Chat**:
  - `GET /api/v1/notifications` — In-app notification list.
  - `GET /api/v1/notifications/unread-count` — Unread badge count.
  - `POST /api/v1/notifications/{id}/read` — Mark notification read.
  - `POST /api/v1/notifications/read-all` — Mark all read.
  - `POST /api/v1/notifications/fcm-token` — Register FCM device token.
  - `GET /api/v1/conversations` — Conversation list.
  - `POST /api/v1/conversations` — Start DM.
  - `GET /api/v1/conversations/{id}/messages` — Messages in conversation.
  - `POST /api/v1/conversations/{id}/messages` — Send message.

---

## 5. Admin Panel Architecture & Audit

### A. Navigation, Screens & State Management
- **State Management**: Uses `Provider` package (`ChangeNotifier`).
- **Screen Inventory**:
  1. `admin_login_screen.dart` — Admin login with role display.
  2. `admin_root_screen.dart` — Layout shell with responsive sidebar and top navigation.
  3. `admin_dashboard_screen.dart` — System KPIs, active counts, pending approvals, quick actions.
  4. `admin_users_screen.dart` — Student & Faculty list with multi-facet filters (Role, Branch, Course, Status, Department, Club, Team).
  5. `admin_user_detail_screen.dart` — Complete institutional profile, academic record, suspension modal, audit logs.
  6. `admin_events_screen.dart` — Event directory, Create/Edit event dialog, publish/draft toggle, registration count monitor.
  7. `admin_organizations_screen.dart` — Clubs & Teams management, faculty advisors, member management.
  8. `admin_content_screen.dart` — Feed post moderation, flagged post triage, post approval/removal.
  9. `admin_notices_screen.dart` — Academic notices, priority levels (normal, important, urgent), exam schedules.
  10. `admin_analytics_screen.dart` — Engagement graphs, registration trends.
  11. `admin_activity_screen.dart` — Administrative audit trail.
  12. `admin_media_screen.dart` — Media & banner manager.
  13. `admin_settings_screen.dart` — Application settings, maintenance mode toggles.

### B. Networking Layer (`lib/core/network/api_client.dart`)
- Uses `dio` HTTP client.
- Base URL currently configured as `http://localhost:8080/api` (needs centralized adjustment to `http://15.252.182.118:8080/api/v1` or configurable via environment).
- Includes Bearer token injection (`Authorization: Bearer <token>`).

### C. Mock Data Audit (`admin_mock_data.dart`)
- Currently contains:
  - Mock admin credentials (`adminAccounts`, `adminPasswords`).
  - 14 mock users (11 students with enrollment numbers like `BTAM25O1062`, 3 faculty members with employee IDs like `EMP1001`).
  - 7 mock feed posts.
  - 5 mock events (e.g. `CodeFest 2026`, `TechTalk: AI in Healthcare`).
  - 7 mock organizations (4 clubs, 3 teams).
  - 4 mock notices (exam date-sheets, placement drives).
  - Mock semester academic results (SGPA, subject credit tables).
  - 14 mock audit log entries.

---

## 6. Missing Backend APIs for Complete Admin Capabilities

While the backend currently supports complete User Panel operations and public event creation, the following dedicated Administrative controllers and endpoints need to be connected or implemented in the Spring Boot backend:

1. **Admin Dashboard Stats**:
   - `GET /api/v1/admin/dashboard/stats` — Aggregate counts: total users, active students, faculty, total clubs, published events, pending moderation reports.
2. **Admin User Management & Suspension**:
   - `GET /api/v1/admin/users` — Paginated user query with filters (`role`, `status`, `department`, `branch`, `course`, `search`).
   - `GET /api/v1/admin/users/{id}` — Full user detail including account status and institutional data.
   - `PATCH /api/v1/admin/users/{id}/suspend` — Suspend user account with reason and audit log entry.
   - `PATCH /api/v1/admin/users/{id}/activate` — Restore suspended user account.
   - `DELETE /api/v1/admin/users/{id}` — Soft delete user.
3. **Admin Event Management**:
   - `PUT /api/v1/events/{id}` or `PUT /api/v1/admin/events/{id}` — Update event details (venue, description, timings, organizer, banner).
   - `PATCH /api/v1/events/{id}/status` or `PATCH /api/v1/admin/events/{id}/status` — Update event status (`DRAFT`, `PUBLISHED`, `CANCELLED`, `COMPLETED`).
   - `DELETE /api/v1/events/{id}` — Delete/cancel event.
4. **Admin Content Moderation**:
   - `GET /api/v1/admin/posts` — Get all posts including flagged items.
   - `PATCH /api/v1/admin/posts/{id}/status` — Moderate post status (`PUBLISHED`, `FLAGGED`, `REMOVED`).
5. **Admin Academic Notices**:
   - Backend support for institutional notices (`notices` entity or leveraging `posts` / `announcements`).
6. **Admin Academic Results**:
   - Read-only student semester grade records mapped to `enrollment_number`.

---

## 7. Security, Conflict & Deployment Considerations

1. **Security & Authorization**:
   - Administrative endpoints must require `@PreAuthorize("hasRole('SUPER_ADMIN') or hasRole('COLLEGE_ADMIN')")`.
   - Admin authentication must issue real JWT tokens or authenticate securely against backend credentials.
2. **Account Suspension Enforcement**:
   - When a user's `account_status` is set to `SUSPENDED`, `FirebaseAuthFilter` and Spring Security must reject incoming requests from that user with `403 Forbidden` (`AccountSuspendedException`).
   - User data is preserved; only access is blocked.
3. **CORS & Remote Host Configuration**:
   - Backend `SecurityConfig.kt` already supports `allowedOriginPatterns = listOf("*")` and handles `CORS_ALLOWED_ORIGINS`.
   - Admin Panel Flutter Web must point to `http://15.252.182.118:8080/api/v1` for remote integration and support switching to local environments seamlessly.
