# 14: Navigation

## Purpose
To map the application's routing mechanism.

## Overview
MoneyLens uses `go_router` for declarative navigation. This provides a clean way to handle deep-linking and authentication guards.

## Route Map
![Navigation Map](diagrams/navigation.mmd)

- `/` (Splash)
- `/onboarding` (Onboarding)
- `/auth/pin` (PIN setup or unlock)
- `/dashboard` (Main layout shell)
  - `/dashboard/transactions`
  - `/dashboard/analytics`
  - `/dashboard/inbox`
  - `/dashboard/settings`

## Authentication Guard
An interceptor monitors the `authProvider`. If a user attempts to route to `/dashboard` while the app is locked, `go_router` transparently redirects them to `/auth/pin`.

## Best Practices
- Always use `context.go()` instead of `context.push()` for top-level shell navigation to prevent memory leaks from stacked routes.
- Abstract route paths into a constants file.
