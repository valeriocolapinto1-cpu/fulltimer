# Session Log — 28 Mag 2026

## Riassunto

### Completato
- **Supabase config** Hardcoded in `app_config.dart` (URL + anon key), app parte senza `--dart-define`
- **`.vscode/launch.json`** Creato con 3 configurazioni (Windows, Android, Chrome) con Supabase preconfigurato
- **Scramble preview fixato:**
  - `4×4–7×7` ora simulano le mosse (`_NxNSimPainter`) — supporta wide (Rw, Lw...) e block (3Rw, 3Lw...)
  - Rimosso text overlay che causava RenderFlex overflow
  - Fixato crash `FormatException: int.parse('4x4')` → `eventId.substring(0, 1)`

### Problemi aperti
- Emulator `sdk gphone64 x86 64` si è disconnesso. Disponibile `Pixel_6` — va lanciato con `flutter emulators --launch Pixel_6`
- L'utente ha riportato "forme sbagliate" per preview di pyra, sq1, mega, clock — da verificare dopo fix crash
- `flutter run -d windows` non funziona (manca toolchain Visual Studio)
- Android SDK richiede Build-Tools 35 + Platform 36

### `flutter analyze`: 0 errori/warnings, `flutter test`: 5/5 pass
