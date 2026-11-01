# Vani — Live Accessibility Captions

> **Tagline:** Every word, within reach.  
> **Mission:** Enable deaf and hard-of-hearing individuals to open their phone and read live spoken conversation in real time with zero friction, zero account creation, and 100% on-device privacy.

---

## 1. Product Principle

**"Open Vani. Read the conversation. Nothing should get in the way."**

- **Direct Launch:** Opens directly into the live captioning interface without landing dashboards or sign-in walls.
- **Multilingual Code-Switching:** Built for Indian multilingual contexts (e.g., *"आज की meeting में we need to finalize the deployment before शाम को"*).
- **Dual-Signaled Accessibility:** Meets WCAG AAA contrast guidelines; statuses and turns never rely solely on color.
- **Local-First & Private:** Speech is transcribed directly via on-device neural speech recognizers; no personal conversation audio is uploaded or stored on remote servers.

---

## 2. Design System & Stitch Integration

This project is paired with the Google Stitch project:
- **Stitch Project:** [Vani Live Accessibility Captions (ID: 17288222240461821434)](https://stitch.withgoogle.com/projects/17288222240461821434?pli=1)
- **Theme:** *Editorial Accessibility* & *Obsidian Edition*
- **Typography:**
  - Headings / Display: `Noto Serif` (Editorial print authority, literary cadence)
  - Transcripts / Controls: `Noto Sans` (Open apertures, tall x-height, cross-script Latin & Devanagari disambiguation)
- **Core Color Tokens:**
  - Base Paper Canvas: `#FBF9F5` (prevents visual glare during extended reading sessions)
  - Surface Paper Layer: `#F4EFEB`
  - Primary Accent: `#184E3F` / `#00362A` (Deep Forest Emerald, contrast ratio > 7:1)
  - Text Primary: `#191C1B` (Deep Charcoal, 14.8:1 contrast ratio)
  - Secondary Slate: `#5A625E` (Timestamps and metadata, >4.5:1 contrast)
  - Hairline Border: `#DCE3DE` (Sage structure without cognitive clutter)
  - Obsidian Dark Mode: `#0D0E13` Canvas, `#3B82F6` Electric Cobalt, `#F8FAFC` Bone White text
  - High-Contrast Mode: Pure Black `#000000`, Pure White `#FFFFFF`, Yellow `#FFFF00` (>18:1 contrast)

---

## 3. Architecture & Codebase Structure

```
lib/
├── controllers/
│   ├── caption_controller.dart          # Manages live caption state, bounded memory, mic gain, auto-scroll
│   └── quick_responses_controller.dart  # Manages quick responses, selection, 180° flip state, custom phrases
├── models/
│   ├── app_settings.dart               # User preferences (text scale, theme mode, haptics, wakelock)
│   ├── quick_phrase.dart               # Structured quick response phrases with Hindi translations
│   └── transcript_segment.dart         # Discrete speech utterances, partial/final state, acoustic events
├── screens/
│   ├── live_caption_screen.dart        # Primary live teleprompter & caption surface
│   ├── quick_responses_screen.dart     # Hero billboard card + essential response phrases
│   └── settings_screen.dart            # Typography scaling, theme modes, accessibility, privacy guarantee
├── services/
│   ├── fake_speech_service.dart        # Deterministic test harness for hermetic tests (never used in prod)
│   ├── native_speech_service.dart      # Real on-device Android & iOS speech recognition with silence restart
│   ├── settings_service.dart           # Local persistence via SharedPreferences
│   └── speech_service.dart             # Replaceable, typed speech recognition interface & lifecycle
├── theme/
│   ├── vani_colors.dart                # Stitch color tokens
│   ├── vani_theme.dart                 # Material 3 ThemeData (Light, Dark Obsidian, High Contrast)
│   └── vani_typography.dart            # Noto Serif & Noto Sans typographic scales
└── widgets/
    ├── fullscreen_billboard_dialog.dart# High-contrast fullscreen billboard with 180° flip for across-table viewing
    ├── jump_to_latest_button.dart      # Accessible floating return-to-latest indicator
    ├── status_pill.dart                # Dual-signaled animated listening/paused/error badge
    ├── tactile_mic_meter.dart          # 3-bar non-color microphone level meter
    └── transcript_turn_card.dart       # Speaker cards with S1/S2 badges, acoustic events, interim live ticker
```

---

## 4. Key Architectural Decisions

See [ADR 0001: Speech Recognition Engine & Backend Architecture](file:///c:/code/personal/vani/docs/adr/0001-speech-recognition-and-backend.md).

1. **Replaceable Speech Recognition Interface (`SpeechRecognitionService`)**:
   - Decouples UI from underlying speech provider.
   - Lifecycle states: `idle`, `requestingPermission`, `initializing`, `listening`, `processing`, `paused`, `unavailable`, `error`, `disposed`.
   - Continuous listening session manager with automatic bounded backoff to recover from Android silence timeouts seamlessly without endless loops or crashing.
2. **Backend Decision (Rust vs. Client-Only)**:
   - Evaluated against Section 7 requirements: A backend is justified *only* if server-side API mediation, remote audio transcoding, or user accounts are required.
   - Because Vani is built as a zero-account, local-first accessibility tool that runs speech recognition directly on-device, **no custom backend is implemented at this stage**, eliminating privacy exposure and cloud costs.
3. **Memory Bounded Retention**:
   - `CaptionController` caps active in-memory turns at a configurable bound (`maxSegments = 200`), preventing unbounded memory accumulation during all-day conversations while preserving recent conversation context.

---

## 5. Verification & Testing

All unit tests, widget tests, and static analysis pass cleanly:

```bash
# Run unit and widget tests
flutter test

# Verify static analysis (0 errors, 0 warnings)
flutter analyze

# Verify code formatting
dart format --output=none --set-exit-if-changed lib test
```

### Test Coverage Highlights:
- **Transcript Turn Lifecycle:** Partial interim hypothesis streaming, final segment commitment, duplicate prevention.
- **Continuous Listening:** Pause, resume, auto-scroll detection, memory bounds trimming.
- **Quick Responses:** Hero billboard presentation, selection, 180° flip rotation for counter viewing, custom phrase persistence.
- **Accessibility & Settings:** Text scaling (100%–160%), theme switching, haptic preferences.

---

## 6. How to Run Locally

### Prerequisites
- Flutter SDK 3.47+ & Dart 3.13+
- Android Studio / Android SDK 34+ (for Android emulator or device)
- Google Chrome / Edge (for desktop web inspection)

### Run Command
```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```
