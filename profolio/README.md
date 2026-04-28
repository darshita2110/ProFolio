# ProFolio

> A polished, Firebase-powered professional portfolio app built with Flutter.

ProFolio lets users create and manage a personal professional profile — capturing their skills, work experience, education, and interests — through a beautifully animated mobile UI with full dark/light theme support.

---

## Screenshots

| Auth | Onboarding | Profile |
|------|------------|---------|
| Animated sign-in / sign-up with glassmorphism card | 4-step guided onboarding flow | Sliver hero header with stats bar |

---

## Features

- **Authentication** — Email/password sign-up, sign-in, and password reset via Firebase Auth
- **Guided Onboarding** — 4-step flow to capture personal info, skills, experience, and interests
- **Profile View** — Collapsible hero header, stats bar, and richly styled section cards
- **Profile Edit** — Inline editing for all profile fields with bottom-sheet dialogs for structured data
- **Dark / Light Theme** — Toggleable at any time, persisted via Riverpod state; consistent brand palette across both modes
- **Real-time Sync** — Profile data streamed live from Firestore; changes reflect instantly
- **Responsive Routing** — GoRouter with redirect guards ensuring unauthenticated users never reach protected screens

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x (Dart 3.6+) |
| State Management | Riverpod 2.x (`StateNotifier`, `StreamProvider`, `family`) |
| Backend | Firebase Auth + Cloud Firestore |
| Routing | GoRouter 13.x |
| Fonts | Google Fonts — DM Serif Display + DM Sans |

---

## Architecture

The project follows a **feature-first clean architecture**:

```
lib/
├── core/
│   ├── config/          # Firebase initialisation
│   ├── constants/       # Firestore collection & field names
│   ├── providers/       # Global Riverpod providers (auth, firestore)
│   ├── routing/         # GoRouter config & route constants
│   ├── services/        # IAuthService / IFirestoreService abstractions + implementations
│   └── theme/           # AppTheme (dark & light) + ThemeModeNotifier
├── features/
│   ├── auth/
│   │   ├── application/ # AuthController (StateNotifier), AuthState
│   │   ├── domain/      # IAuthRepository + AuthRepository
│   │   └── presentation/# AuthScreen
│   ├── onboarding/
│   │   ├── application/ # OnboardingController, OnboardingState
│   │   └── presentation/# OnboardingScreen (4-step wizard)
│   └── profile/
│       ├── application/ # ProfileController, userProfileProvider (StreamProvider)
│       └── presentation/# ProfileScreen (view + edit)
└── models/              # UserProfile, Experience, Education (with toJson / fromJson)
```

Key design decisions:

- **Interface-first services** — `IAuthService` and `IFirestoreService` are abstract classes, making the Firebase implementations swappable and unit-testable without touching feature code.
- **Firestore constants** — All collection names and field keys live in `FirestoreConstants`, eliminating magic strings.
- **Context-aware theme getters** — `AppTheme.bgCardOf(context)` and friends resolve the correct colour for the active theme, keeping widget code clean.

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.6.2`
- A Firebase project with **Authentication** (Email/Password) and **Firestore** enabled
- `flutterfire` CLI (recommended for setup)

### Setup

1. **Clone the repository**

```bash
git clone https://github.com/your-username/profolio.git
cd profolio
```

2. **Configure Firebase**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) — both are gitignored.

3. **Install dependencies**

```bash
flutter pub get
```

4. **Run code generation** (Riverpod annotations)

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. **Run the app**

```bash
flutter run
```

---

## Firestore Data Model

### `users/{uid}`

```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "skills": ["string"],
  "experience": [
    {
      "role": "string",
      "company": "string",
      "duration": "string",
      "description": "string | null"
    }
  ],
  "education": [
    {
      "degree": "string",
      "institution": "string",
      "year": "string",
      "grade": "string | null"
    }
  ],
  "interests": ["string"],
  "createdAt": "ISO 8601 string",
  "updatedAt": "ISO 8601 string"
}
```

---

## Routing

| Route | Screen | Guard |
|-------|--------|-------|
| `/auth` | AuthScreen | Redirects to `/profile` if authenticated |
| `/onboarding` | OnboardingScreen | Requires authenticated user |
| `/profile` | ProfileScreen (view) | Redirects to `/onboarding` if no profile doc |
| `/edit-profile` | ProfileScreen (edit) | Same as `/profile` |

---

## Theme

The app ships a warm, minimal design system built around two brand colours:

| Token | Value | Usage |
|-------|-------|-------|
| `primary` | `#E8A838` | CTAs, accents, avatar background |
| `accent` | `#4ECDC4` | Education badges, interest chips |
| `success` | `#6BCB77` | GPA badges, success toasts |
| `error` | `#EF6461` | Validation, delete actions |

Both dark and light palettes are fully specified — no colour is hardcoded in widget files.

---

## Roadmap

- [ ] Profile photo upload (Firebase Storage)
- [ ] Public shareable profile link
- [ ] PDF export of portfolio
- [ ] Social sign-in (Google, Apple)
- [ ] Unit & widget test coverage
- [ ] Firestore `Timestamp` migration for date fields
