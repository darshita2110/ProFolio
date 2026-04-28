<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.6+-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=for-the-badge" />

# ProFolio

**A polished, Firebase-powered professional portfolio app built with Flutter.**

ProFolio lets you build and manage a personal professional profile — capturing your skills, work experience, education, and interests — through a beautifully animated mobile UI with full dark/light theme support.

[Features](#features) · [Screenshots](#screenshots) · [Tech Stack](#tech-stack) · [Architecture](#architecture) · [Getting Started](#getting-started) · [Roadmap](#roadmap)

</div>

---

## Features

| | Feature | Details |
|---|---|---|
| 🔐 | **Authentication** | Email/password sign-up, sign-in, and password reset via Firebase Auth |
| 🧭 | **Guided Onboarding** | 4-step wizard to capture personal info, skills, experience, and interests |
| 🪪 | **Profile View** | Collapsible sliver hero header, stats bar, and richly styled section cards |
| ✏️ | **Profile Edit** | Inline editing for all fields; bottom-sheet dialogs for structured data |
| 🌗 | **Dark / Light Theme** | Togglable at any time, persisted via Riverpod; consistent brand palette across both modes |
| ⚡ | **Real-time Sync** | Profile data streamed live from Firestore — changes reflect instantly |
| 🔒 | **Route Guards** | GoRouter redirect guards ensure unauthenticated users never reach protected screens |
| 🔑 | **Password Strength** | Live strength indicator with per-requirement checklist during sign-up |

---

## Screenshots

| Auth | Onboarding | Profile |
|:---:|:---:|:---:|
| Animated sign-in / sign-up with glassmorphism card | 4-step guided onboarding flow | Sliver hero header with stats bar |

---

## Tech Stack

| Layer | Technology |
|---|---|
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

### Key Design Decisions

- **Interface-first services** — `IAuthService` and `IFirestoreService` are abstract classes, making Firebase implementations swappable and unit-testable without touching feature code.
- **Firestore constants** — All collection names and field keys live in `FirestoreConstants`, eliminating magic strings.
- **Context-aware theme getters** — `AppTheme.bgCardOf(context)` and friends resolve the correct colour for the active theme, keeping widget code clean.

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.6.2`
- A Firebase project with **Authentication** (Email/Password) and **Firestore** enabled
- [`flutterfire` CLI](https://firebase.flutter.dev/docs/cli/) (recommended for setup)

### Setup

**1. Clone the repository**

```bash
git clone https://github.com/your-username/profolio.git
cd profolio
```

**2. Configure Firebase**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) — both are gitignored.

**3. Install dependencies**

```bash
flutter pub get
```

**4. Run code generation** (Riverpod annotations)

```bash
dart run build_runner build --delete-conflicting-outputs
```

**5. Run the app**

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
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp"
}
```

---

## Routing

| Route | Screen | Guard |
|---|---|---|
| `/auth` | AuthScreen | Redirects to `/profile` if already authenticated |
| `/onboarding` | OnboardingScreen | Requires authenticated user |
| `/profile` | ProfileScreen (view) | Redirects to `/onboarding` if no profile doc exists |
| `/edit-profile` | ProfileScreen (edit) | Same as `/profile` |

---

## Theme

A warm, minimal design system built around two brand colours, with fully specified dark and light palettes — no colour is hardcoded in widget files.

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#E8A838` | CTAs, accents, avatar background |
| `accent` | `#4ECDC4` | Education badges, interest chips |
| `success` | `#6BCB77` | GPA badges, success toasts |
| `error` | `#EF6461` | Validation errors, delete actions |

---

## Roadmap

- [ ] Profile photo upload (Firebase Storage)
- [ ] Public shareable profile link
- [ ] PDF export of portfolio
- [ ] Social sign-in (Google, Apple)
- [ ] Unit & widget test coverage
- [ ] Firestore `Timestamp` migration for all date fields

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

## License

[MIT](LICENSE)
