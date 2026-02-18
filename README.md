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

### What Was Implemented

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

The current MVP proves:

- Successful Firebase connectivity  
- Real-time Firestore updates  
- Reactive Flutter UI behavior  

Screenshots and video walkthrough are provided below for verification.

---

## Reflection

Firebase significantly reduces backend complexity by providing authentication, real-time database capabilities, and scalable infrastructure out of the box. This allows SafeStride to focus on delivering a responsive, community-powered routing experience while maintaining a production-ready foundation.