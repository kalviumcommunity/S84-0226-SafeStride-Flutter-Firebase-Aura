# SafeStride

## Overview

SafeStride is a mobile-first platform designed to help runners and cyclists in busy urban environments discover safe, reliable, and community-validated routes.

In many cities, fitness enthusiasts struggle to identify routes that are not only efficient but also safe and well-reviewed by real users. Existing map solutions often optimize for distance or speed, but rarely for on-ground safety and community trust.

SafeStride addresses this gap by combining Flutter’s cross-platform UI capabilities with Firebase’s real-time backend to surface routes backed by real user experiences.

---

## Problem Statement

Runners and cyclists in busy cities lack access to safe, well-reviewed routes or community-endorsed paths. This often leads to unsafe route choices, poor user confidence, and fragmented fitness experiences.

---

## Our Solution

SafeStride enables users to:

- Discover routes recommended by real runners and cyclists  
- View community-backed route data in real time  
- Contribute new route insights to help other users  
- Access continuously synced data powered by Firebase  

The current MVP demonstrates real-time data synchronization using Cloud Firestore, forming the foundation for a community-driven route intelligence platform.

---

## Current MVP Scope

The present implementation focuses on:

- Firebase integration with Flutter  
- Real-time data updates using Cloud Firestore  
- Reactive UI using StreamBuilder  
- Scalable backend foundation for future route intelligence features  

Future iterations will expand into route safety scoring, user reviews, and personalized route recommendations.

---

## Tech Stack

- Flutter  
- Dart  
- Firebase Core  
- Cloud Firestore  
- Firebase Authentication

---

## Firebase Integration (Assignment Scope)

This sprint focuses on integrating Firebase as the backend for SafeStride’s mobile experience. The goal is to demonstrate real-time data synchronization and a scalable cloud-connected architecture using Flutter and Firebase.

### What will be Implemented

- Firebase project setup and app registration  
- FlutterFire configuration  
- Firebase initialization in the Flutter app  
- Cloud Firestore integration  
- Real-time UI updates using StreamBuilder  

---

## Real-Time Data Flow

The application uses Cloud Firestore’s snapshot streams to keep the UI in sync with the database.

Flow:

1. User taps the add button  
2. A new document is written to Firestore  
3. Firestore emits a real-time update  
4. StreamBuilder rebuilds the affected UI  
5. Updated data appears instantly without refresh  

This demonstrates the reactive and real-time capabilities required for SafeStride’s future community-driven features.

---

## Demo

![alt text](image.png)

---

## Reflection

Firebase significantly reduces backend complexity by providing authentication, real-time database capabilities, and scalable infrastructure out of the box. This allows SafeStride to focus on delivering a responsive, community-powered routing experience while maintaining a production-ready foundation.

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── screens/
       ├──welcome_screen.dart 
├── widgets/
       ├──custom_button.dart
├── models/
├── services/
```

---

## 🧩 Purpose of Each Directory

- **main.dart** — Entry point of the app and root configuration  
- **screens/** — Full UI pages (each file = one screen)  
- **widgets/** — Reusable UI components  
- **models/** — Data structures and JSON mapping  
- **services/** — Firebase/API interaction layer  
- **utils/** — Helper functions, constants, and validators  

---

## 🏗️ How This Supports Modular Design

This structure separates UI, data, and service logic into independent layers.  
It improves readability, enables code reuse, and makes the app easier to scale and maintain as new features are added.

---

## 🧷 Naming Conventions

- **Files:** `snake_case.dart` → `welcome_screen.dart`  
- **Classes:** `PascalCase` → `WelcomeScreen`  
- **Variables/Functions:** `camelCase` → `isLoading`, `fetchRoutes()`  
- **Widgets:** Screens end with `Screen`; reusable widgets have descriptive names.

---

## 🎯 Why This Matters

A consistent structure and naming convention keeps the codebase clean, scalable, and team-friendly for future development.

---

## 📚 Documentation

For additional documentation, see the [docs](./docs) folder:

- [Flutter Fundamentals README](./docs/flutter_fundamentals_README.md) - Flutter widget tree and reactive UI concepts
- [Stateless vs Stateful Widgets](./docs/STATELESS_STATEFUL_WIDGETS.md) - Understanding widget types with practical implementation
- [Project Structure](./docs/PROJECT_STRUCTURE.md) - Project structure overview
- [Navigation Implementation](./docs/NAVIGATION_IMPLEMENTATION.md) - Navigation setup guide
- [Landing Page Setup](./docs/LANDING_PAGE_SETUP.md) - Landing page configuration
- [Quick Reference](./docs/QUICK_REFERENCE.md) - Quick reference guide

---
# To run using .env
```bash 
flutter run -d chrome --dart-define-from-file=.env
```