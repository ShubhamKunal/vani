# Architecture Decision Record (ADR) 0001: Speech Recognition Engine & Backend Architecture

## Context & Problem Statement
Vani is a real-time speech-to-text mobile application designed for deaf and hard-of-hearing individuals. The core user experience requires:
1. Opening the app and immediately reading speech with minimal latency.
2. Handling bilingual / multilingual speech common in India (Hindi, Indian English, and conversational code-switching such as: *"आज की meeting में we need to finalize the deployment before शाम को"*).
3. Zero mandatory account creation, zero transmission of sensitive personal speech/audio to unneeded cloud databases by default, and continuous listening reliability.
4. Clean separation of presentation from speech recognition through an extensible, testable abstraction layer.

## Decision 1: Speech Recognition Engine Strategy

### Evaluated Alternatives
1. **Cloud Remote Streaming Service (e.g., Google Cloud Speech-to-Text v2 / Whisper Streaming / Conformer)**:
   - *Pros*: Excellent multilingual code-switching transcription on server clusters.
   - *Cons*: Requires active Internet connectivity, ongoing operational server/API costs, latency overhead, and transmits private conversations over the wire (medical, legal, or intimate conversations). Violates the local-first zero-account privacy expectation unless strictly needed.
2. **On-Device Native Speech APIs (Android SpeechRecognizer & iOS SFSpeechRecognizer via `speech_to_text`)**:
   - *Pros*: Completely local and on-device on supported models (Google Speech Services / Apple On-Device Dictation). Zero server operational cost. Latency is minimal (sub-100ms partial token streaming). Works without account creation. Supports Indian English (`en-IN`) and Hindi (`hi-IN`). On Android 13+ (API 33+), Android SpeechRecognizer natively supports language switching and multiple languages.
   - *Cons*: Built-in session timeouts on prolonged silence requiring an intelligent continuous-session lifecycle manager; varied OEM support for simultaneous code-switching within a single utterance.
3. **Pluggable Architecture (Replaceable Speech Interface `SpeechRecognitionService`)**:
   - Define a pure, typed Dart interface `SpeechRecognitionService` decoupling the Flutter UI from any specific engine.
   - Provide a native implementation `NativeSpeechRecognitionService` utilizing on-device speech recognition with automatic session restart on silence, sound level telemetry, and error resilience.
   - Provide a deterministic fake implementation `FakeSpeechRecognitionService` for hermetic unit, widget, and integration testing with simulated partial hypotheses, final segments, acoustic events, and simulated network/engine errors.

### Outcome
We adopt **Approach 3 (Pluggable Architecture)** with **Native Speech Recognition** as the default production engine:
- Local-first, zero audio recorded or uploaded by default.
- Privacy-preserving: all processing occurs on the user's device via system speech engines.
- Continuous listening session manager with automatic recovery from silence timeouts and audio interruptions.
- Extensible design allowing future remote streaming backends (e.g., custom streaming server) to be plugged in simply by implementing `SpeechRecognitionService`.

---

## Decision 2: Backend Justification (Rust vs. Client-Only)

### Criteria for Introducing a Rust Backend (per Section 7)
A backend is justified **only** if:
- Secure mediation of remote streaming speech API keys is required.
- Centralized user accounts, billing, or cross-device database synchronization is required.
- Remote audio stream transcoding or custom ML model inference is hosted.

### Analysis for Current Scope
- Vani is designed as an immediate, friction-free accessibility utility: **"Open Vani. Read the conversation. Nothing should get in the way."**
- Account creation and cloud synchronization directly introduce friction, privacy risk, and latency.
- The on-device speech recognition engine operates entirely on the mobile device without external API keys or server proxies.
- Adding a server or database would add deployment complexity, server costs, and security attack surface without providing tangible value to a deaf or hard-of-hearing user reading live speech across a counter or meeting room.

### Outcome
**No custom backend is implemented at this stage.** The application is built as an autonomous, local-first Flutter application.
The `SpeechRecognitionService` interface is strictly decoupled so that if a remote streaming service (Rust WebSocket gateway) is added in the future for cloud-based code-switching transcription, it can be integrated with zero UI refactoring.

