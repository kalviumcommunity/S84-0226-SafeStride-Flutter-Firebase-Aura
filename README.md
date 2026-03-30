# SafeStride

SafeStride is a Flutter + Firebase application for runners and cyclists to discover, evaluate, and share safer routes.

## What This Project Includes

- Firebase Authentication (email/password + Google sign-in)
- Cloud Firestore-backed user data and route data
- Responsive Flutter UI for web and mobile
- Google Maps integration
- Route/safety-oriented screens and services

## Tech Stack

- Flutter (Dart)
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Provider state management
- Google Maps Flutter

## Current Project Structure

```text
lib/
       main.dart
       firebase_options.dart
       config/
       constants/
       components/
       controllers/
       models/
       providers/
       screens/
       services/
       widgets/
docs/
       GOOGLE_SIGNIN_SETUP.md
       GOOGLE_SIGNIN_IMPLEMENTATION.md
       PROJECT_STRUCTURE.md
       QUICK_REFERENCE.md
       ...
```

## Prerequisites

- Flutter SDK installed and on PATH
- Android Studio / Android SDK (for Android run)
- Chrome (for web run)
- Firebase project configured

## Environment Configuration

This project loads variables from `.env`.

Required keys:

```env
MAPS_API_KEY=YOUR_MAPS_API_KEY
GOOGLE_ANDROID_CLIENT_ID=YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com
GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

Notes:

- Do not put OAuth client secret in Flutter frontend code.
- `.env` is included as a Flutter asset via `pubspec.yaml`.

## Firebase Configuration

The app is currently wired to Firebase project:

- `projectId`: `safestride-ed8a1`
- Config source: `lib/firebase_options.dart`

If you use another project, regenerate `firebase_options.dart` with FlutterFire CLI.

## Google Sign-In Setup

### Firebase Console

In Firebase project `safestride-ed8a1`:

1. Go to Authentication -> Sign-in method.
2. Enable Google provider.
3. Set support email and save.
4. In Authentication -> Settings -> Authorized domains, ensure:
        - `localhost`
        - `127.0.0.1` (recommended)

### Google Cloud Console (Web OAuth)

Create OAuth Client ID of type Web application and add:

- Authorized JavaScript origins:
       - `http://localhost:59562`
       - `http://127.0.0.1:59562`
- Authorized redirect URIs (if required by your setup):
       - `http://localhost:59562`
       - `http://localhost:59562/`
       - `http://127.0.0.1:59562`
       - `http://127.0.0.1:59562/`

Use the resulting Web client ID in `GOOGLE_WEB_CLIENT_ID`.

## Run Commands

### Install dependencies

```bash
flutter pub get
```

### Run on Web (fixed port for OAuth stability)

```bash
flutter run -d chrome --web-port 59562
```

### Run on Android emulator/device

```bash
flutter run -d emulator-5554
```

If no Android devices are shown:

```bash
flutter emulators --launch Medium_Phone_API_36.1
flutter devices
```

## Troubleshooting

### Error: Google sign-in is not enabled in Firebase Authentication

Enable Google provider in Firebase Authentication for the exact project in `lib/firebase_options.dart`.

### Error: redirect_uri_mismatch

- Run web on fixed port `59562`.
- Ensure origins/redirects in Google Console match that port.

### Error: unauthorized-domain

Add `localhost` under Firebase Authentication authorized domains.

## Development Notes

- Main app entrypoint: `lib/main.dart`
- Auth logic: `lib/services/auth_service.dart`
- Login screen: `lib/screens/login/login_screen.dart`
- Signup screen: `lib/screens/signup_screen.dart`

## Additional Documentation

See `docs/` for detailed guides:

- `docs/GOOGLE_SIGNIN_SETUP.md`
- `docs/GOOGLE_SIGNIN_IMPLEMENTATION.md`
- `docs/PROJECT_STRUCTURE.md`
- `docs/QUICK_REFERENCE.md`

## License

Internal / coursework project (update as needed).