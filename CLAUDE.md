# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile app for "Tesla Rayos X & Control Biológico" — a service appointment booking system. Users request appointments, view their requests, and authenticate via email or Google. Admins approve/reject all requests. Backend is Supabase (PostgreSQL + Auth + Realtime).

## Common Commands

```bash
# Run app
flutter run

# Build Android APK
flutter build apk

# Regenerate code after modifying Riverpod @riverpod providers (if added)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze/lint
flutter analyze

# Tests
flutter test
```

## Architecture

Feature-based clean architecture under `lib/`:

```
lib/
├── main.dart            # Flutter binding, .env load, Supabase PKCE setup, ProviderScope
├── app.dart             # MaterialApp.router + theme
├── core/theme/          # AppColors (Material 3 palette), AppTheme (Manrope font)
├── features/
│   ├── auth/            # Email + Google OAuth via Supabase
│   ├── nueva_cita/      # Appointment booking form
│   ├── mis_solicitudes/ # Real-time list of user's own requests
│   ├── profile/         # Profile screen, ProfileModel, profileProvider
│   └── admin/           # Admin panel — approve/reject all requests (role-gated)
└── shared/routing/      # GoRouter with auth-based redirect
```

Each feature follows `domain/data/presentation` separation:
- **domain/** — plain Dart models with manual `fromJson`/`toJson` (no Freezed)
- **data/** — repository classes (Supabase CRUD / streams)
- **presentation/** — screens + widgets + Riverpod providers

## State Management

- **Riverpod** throughout: `StateNotifier` for auth, `StreamProvider` for real-time requests
- Auth state uses sealed classes: `AuthInitial | AuthLoading | AuthAuthenticated | AuthError | AuthUnauthenticated`
- GoRouter reads `authNotifierProvider` and calls `router.refresh()` on every auth change — redirect logic lives in the router, not in widgets
- `_HomeShell` in `app_router.dart` is the post-login shell: hosts bottom nav + `IndexedStack` for the three tabs

## Role System

- `profiles.role` column: `'client'` (default) or `'admin'`
- `ProfileModel.isAdmin` getter drives tab visibility and `allRequestsStreamProvider` access
- Admin tab only rendered when `profileProvider` resolves `isAdmin == true`
- Admin can update any request status; regular users can only CRUD their own (enforced by RLS)

## Key Patterns

- **Form validation** is manual: `Map<String, bool> _errors` tracks field errors, cleared on input change
- All UI strings are in **Spanish**
- `ConsumerWidget` / `ConsumerStatefulWidget` for Riverpod integration in UI
- `build_runner` only needed if `@riverpod` annotation generators are added — current providers are hand-written `StateNotifierProvider` / `StreamProvider`

## Environment & Backend

- Supabase credentials live in `assets/.env` (gitignored): `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- Schema in `supabase_migrations.sql` — run in Supabase Dashboard > SQL Editor
- Tables: `profiles` (auto-created via trigger on signup) and `requests` (appointments)
- Request statuses: `Pendiente | Aprobado | Rechazado` (CHECK constraint in DB)
- RLS: users see only their own requests; admin bypass requires a separate permissive policy or service role
- Real-time updates use Supabase `.stream()` in `solicitudesStreamProvider` and `allRequestsStreamProvider`
