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

## 📚 Case Study: Syncly - The To-Do App That Wouldn't Sync

### Challenge Analysis
The Syncly team faced issues with real-time updates, image uploads, and secure sessions. Users experienced delays in data synchronization, and the team lacked a scalable backend infrastructure.

### Solution with Firebase
By integrating Firebase, we addressed these challenges effectively:

1.  **Authentication (Firebase Auth):**
    -   **Problem:** Need for secure user sessions without building a custom auth server.
    -   **Solution:** We implemented Firebase Authentication to handle sign-up, sign-in, and session management. This ensures that only authenticated users can access their tasks, providing security and personalization out of the box.

2.  **Real-Time Data Sync (Cloud Firestore):**
    -   **Problem:** Updates weren't syncing in real-time; changes took minutes to appear.
    -   **Solution:** We utilized Cloud Firestore's real-time capabilities. By using `StreamBuilder` in Flutter to listen to Firestore snapshots, any change made to the database (add/update/delete) is *instantly* pushed to all connected client devices. This eliminates the need for manual refresh or polling, solving the synchronization delay.

3.  **Scalable Storage (Firebase Storage):**
    -   **Problem:** Difficulty handling file uploads and storage scalability.
    -   **Solution:** Firebase Storage provides a robust and scalable way to store user-generated content like images/files. It handles the complexity of file hosting, security rules, and scaling storage needs as the user base grows. *(Note: While the current demo focuses on Auth and Firestore, Storage is the designated solution for this requirement)*.

### Enhancing Scalability, Real-Time Experience, and Reliability
-   **Scalability:** Firebase is a serverless platform that automatically scales with your app's usage. We don't need to provision servers or worry about traffic spikes; Firebase handles the infrastructure.
-   **Real-Time Experience:** Firestore's listener-based model ensures that the UI is always a reflection of the latest server state. This creates a seamless and responsive user experience where collaboration happens instantly.
-   **Reliability:** Google's infrastructure backs Firebase, ensuring high availability and uptime. SDKs also handle offline persistence, allowing the app to work even with intermittent network connectivity and sync when back online.

---

## Assignment 3.10: Firebase Integration

This section documents the integration of Firebase Authentication and Cloud Firestore into SafeStride.

### 1. Setup Instructions
- Ensure you have the FlutterFire CLI installed: `dart pub global activate flutterfire_cli`
- Run `flutterfire configure` to generate `firebase_options.dart` targeting your Firebase project.
- Use `fvm flutter pub get` to download dependencies.
- Ensure an iOS simulator or Android emulator is running, then execute `fvm flutter run`.

### 2. Code Snippets Implementation
Authentication is handled via `AuthService` wrapping `FirebaseAuth.instance`.
```dart
// Core logic for Auth State mapping
StreamBuilder<User?>(
  stream: AuthService().authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
    return snapshot.hasData ? RouteDashboardScreen() : LoginScreen();
  }
)
```

Firestore operations are modularized in `FirestoreService`.
```dart
// Real-time synchronization stream
StreamBuilder<QuerySnapshot>(
  stream: FirestoreService().getRoutesStream(),
  builder: (context, snapshot) {
    // Renders dynamic list that mutates instantly on Firestore updates
    return ListView.builder(...);
  }
)
```

### 4. Reflection
**Challenges:** Ensuring the Flutter lifecycle was correctly initialized via `WidgetsFlutterBinding` before communicating with native Firebase channels. Handing async exceptions efficiently without polluting the UI layer required strict try/catch blocks in the service layer, keeping in mind to prevent using `BuildContext` across async gaps.
**Benefits of Firebase:** Eliminates the need for a custom REST API and WebSocket server. The `StreamBuilder` architecture natively observes Firestore's internal cache, providing instant UI updates and seamless offline support inherently.

--

## 📱 Responsive Layout Design (Assignment 3.17)

This screen demonstrates a responsive Flutter layout using Container, Row, Column, Expanded, and MediaQuery.

---

### 🔧 Layout Strategy

- Used **Column** for vertical structure
- Used **Row** for horizontal layout on large screens
- Used **Container** for styled sections
- Used **Expanded** for flexible sizing
- Used **MediaQuery** to switch layout based on screen width

---

## 🧠 Reflection

Responsive design ensures the app looks good on different screen sizes and orientations. The main challenge was maintaining balanced proportions across devices. Using MediaQuery and Expanded helped create a flexible layout that adapts smoothly between phone and tablet views.
