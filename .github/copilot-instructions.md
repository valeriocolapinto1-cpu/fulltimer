# Copilot instructions for this repo

## Commands

- Get packages: `flutter pub get`
- Analyze: `flutter analyze`
- Run all tests: `flutter test`
- Run one test file: `flutter test test/widgets/timer_display_test.dart`
- Run one named test: `flutter test test/providers/timer_provider_test.dart --plain-name "does not trigger haptics when vibration disabled"`
- Run the app with Flutter defaults: `flutter run`
- Launch with the repo’s debug args from `.vscode/launch.json` when Supabase/WCA config is needed.

## Architecture

- `lib/main.dart` is the startup point. It locks portrait orientation, initializes Supabase, then creates `StorageService`, `SettingsProvider`, `SessionProvider`, and `L10n` before calling `runApp`.
- `lib/app.dart` builds the `MaterialApp` and the shell navigation. The main flow is timer, times, stats, and battle; the menu opens algorithms, online competition, profile, and settings.
- `SessionProvider` is the core app state for sessions, solves, active event, custom events, and current scramble. It persists through `StorageService` and uses `ScrambleService` for immediate + async scrambles.
- `TimerProvider` is a pointer-driven state machine for hold/start/inspection/running/stopped states. `TimerScreen` wires pointer events to it and pushes completed solves back into `SessionProvider`.
- `StorageService` uses `SharedPreferences` for local session/event/settings persistence. `SupabaseService` handles auth and online competition data. `WcaAuthService` provides optional WCA OAuth.
- `ScrambleService` tries local tnoodle first, then falls back to internal scramblers or `cuber` for 3x3/OH.

## Conventions

- Use `provider` patterns already in the code: `context.watch<T>()` for UI reads and `context.read<T>()` for actions.
- Keep event IDs aligned with `EventType.defaults` plus custom events stored in `SessionProvider`.
- `SolveTime` is the canonical model for formatting and result handling. `SolveResult` uses `ok`, `plusTwo`, and `dnf`.
- Averages follow the repo’s conventions: `Session.averageOf(n)` returns `null` when there are too few solves and `-1` for invalid averages.
- Custom event names and emoji are sanitized in `SessionProvider`; comments are trimmed and capped before saving.
- `SettingsProvider` owns UI/timer preferences, including `TimerDisplayMode` (`hidden`, `withDecimals`, `withoutDecimals`) and the scramble preview toggle.
- `TimerScreen` has a manual-input mode, so changes to timer UI should respect both timer and manual entry paths.
- When changing event/session selection, make sure the active session/event IDs and stored scramble refresh together.
- Share text should come from `SessionProvider.buildShareText()` and `buildSolveShareText()` so exported formatting stays consistent.
- Keep screenshots, icons, and previews using the existing WCA color/event mapping helpers in `widgets/cube_icon.dart` and `widgets/scramble_preview.dart`.
