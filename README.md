# 🚀 Acadyk Native Admin Panel (Flutter / Dart)

This directory contains the complete source code, assets, and build artifacts for the **Acadyk Native Admin Panel**, built with Flutter & Dart using the application's central design system, state management, and routing architecture.

---

## 📂 Directory Structure

### lib/admin/ — Admin Feature Core
- **data/**
  - dmin_models.dart: Data models for accounts, dashboard metrics, users, content, logs, and settings.
  - dmin_mock_data.dart: Offline & development mock data store.
  - dmin_service.dart: Service layer for API operations and CRUD actions.
- **providers/**
  - dmin_auth_provider.dart: Authentication & role-based access control (SUPER_ADMIN, EDITOR, VIEWER).
  - dmin_dashboard_provider.dart: Metrics counters & recent activity feeds.
  - dmin_users_provider.dart: User search, filtering, and suspension controls.
  - dmin_content_provider.dart: Content moderation, post approval & deletion.
  - dmin_settings_provider.dart: App configuration, maintenance mode, and feature flags.
- **screens/**
  - dmin_root_screen.dart: Master admin controller managing authentication & active tabs.
  - dmin_login_screen.dart: Admin sign-in screen with form validation.
  - dmin_dashboard_screen.dart: Responsive dashboard with 2x2 stat grid & activity feed.
  - dmin_users_screen.dart: User management (Table on Desktop, Cards on Mobile).
  - dmin_content_screen.dart: Moderation queue & reports review.
  - dmin_analytics_screen.dart: Metrics breakdown & visual engagement charts.
  - dmin_activity_screen.dart: Audit log stream with relative timestamps.
  - dmin_settings_screen.dart: App settings & feature flag toggles.
  - dmin_pages_screen.dart: Dynamic route directory.
  - dmin_media_screen.dart: Media asset library.
- **widgets/**
  - dmin_responsive.dart: Responsive breakpoint utilities (AdminBreakpoints, AdminResponsiveGrid).
  - dmin_scaffold.dart: Adaptive layout shell (Sidebar on Desktop, Drawer + Bottom Nav on Mobile).
  - dmin_stat_card.dart: Metric card with responsive sizing.
  - dmin_data_table.dart: Responsive data viewer (Table on Desktop, Cards on Mobile).
  - dmin_search_bar.dart: Search input with category chips.
  - dmin_form_field.dart: Responsive form layouts.
  - dmin_empty_state.dart: State placeholders.

---

### lib/app/ — Routing & Theme Integration
- pp/router/app_router.dart: GoRouter routes for /admin/*
- pp/router/route_names.dart: Admin route constants
- pp/router/route_guards.dart: Route authorization guard
- pp/theme/app_colors.dart: Monochrome black & white design tokens
- pp/bootstrap.dart: Provider dependency injection
- pp/app.dart: Main MaterialApp.router

---

### ssets/ — Brand Assets
- ssets/images/lagacy.png: Brand logo asset
- ssets/images/: Supporting platform images and banners

---

### uild/web/ — Compiled Web Target
- Contains the production-ready compiled Flutter Web release bundle.

---

## 🔑 Default Admin Credentials
- **Super Admin:** admin@acadyk.edu / SuperAdmin2026!
- **Editor:** editor@acadyk.edu / Editor2026!
- **Viewer:** viewer@acadyk.edu / Viewer2026!