# Flutter Project Structure

Understanding the Flutter folder structure is essential for organizing code, managing assets, and maintaining scalability. Flutter automatically generates a unified project environment that supports cross-platform development (Android, iOS, Web, etc.).

## Folder Structure Overview

Below is an overview of the key directories and files generated when creating a Flutter project, along with their roles:

| Folder / File | Purpose & Role |
| --- | --- |
| **`lib/`** | The core logic folder. Contains all your Dart code (screens, widgets, services, models). `main.dart` is the entry point. |
| **`android/`** | Contains Native Android configurations (Manifest, Gradle scripts). Used to build the Android version of the app. |
| **`ios/`** | Contains Native iOS configurations (Xcode workspace, Info.plist). Used to build the iOS version of the app. |
| **`web/`** | Contains HTML/CSS/JS configurations required to compile the Flutter app for the browser. |
| **`assets/`** | A manually created folder used to store static resources like images, fonts, and JSON data. Must be declared in `pubspec.yaml`. |
| **`test/`** | Contains automated tests (unit, widget, integration). Ensures app reliability and prevents regressions (`widget_test.dart`). |
| **`pubspec.yaml`** | The most critical setup file. Manages dependencies (packages), asset declarations, fonts, and the Flutter SDK version. |
| **`build/`** | Auto-generated during compilation. Contains compiled output files (APKs, IPAs). Do not modify this folder manually. |
| **`.gitignore`** | Specifies files/directories that Git should not track (e.g., `build/`, `.dart_tool/`, environment secrets). |
| **`README.md`** | Default markdown file for project documentation. |

## Folder Hierarchy

A typical, scalable Flutter project is organized internally within the `lib/` folder:

```text
your_flutter_app/
 ┣ android/
 ┣ assets/
 ┃ ┣ fonts/
 ┃ ┗ images/
 ┣ ios/
 ┣ lib/
 ┃ ┣ models/           # Data definitions (e.g., User, Route)
 ┃ ┣ screens/          # UI visual pages
 ┃ ┣ services/         # External interactions (Firebase, APIs, DB)
 ┃ ┣ widgets/          # Small reusable UI components
 ┃ ┗ main.dart         # Dart entry point
 ┣ test/
 ┃ ┗ widget_test.dart
 ┣ pubspec.yaml
 ┗ README.md
```

## Reflection on Scalability & Teamwork

**Why is understanding each folder's purpose important?**
Because Flutter compiles to multiple platforms from a single codebase, you need to understand where the Native code lives (`android/`, `ios/`) versus the unified Dart code (`lib/`). Keeping business logic inside `lib/` and knowing exactly where to insert dependencies (`pubspec.yaml`) ensures you don't break platform-specific builds.

**How does a well-organized structure improve teamwork and development speed?**
By adopting a modular architecture inside the `lib/` folder (such as separating `screens/`, `services/`, and `models/`), multiple developers can work simultaneously without running into constant merge conflicts. A team member can build UI in `screens/` while another constructs backend queries in `services/`. This highly cohesive, loosely coupled approach guarantees that when the project grows from 10 files to 100 files, it remains predictable and easy to debug.
