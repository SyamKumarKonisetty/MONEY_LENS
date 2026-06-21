# 15: Settings

## Purpose
To detail the configuration options available to the user.

## Overview
The Settings screen provides control over application-wide behaviors and data management.

## Features
- **Theme Selection**: Toggle between Light, Dark, and System Default. State is managed by a `ThemeNotifier` and persisted via `SharedPreferences`.
- **Security**: Allows users to change their PIN and update their recovery question.
- **Data Management**:
  - **Export Data**: Triggers the Export Engine (CSV/PDF).
  - **Factory Reset**: A highly destructive action that wipes the Drift Database and SharedPreferences. It requires PIN verification and a confirmation dialog wrapped in a `DangerButton`.

## Future Improvements
- Cloud backup toggles.
- Currency formatting overrides.
