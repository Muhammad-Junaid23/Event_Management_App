![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-orange?logo=firebase)
![Riverpod](https://img.shields.io/badge/Riverpod-2.6-purple)
![License](https://img.shields.io/badge/license-MIT-green)

# Event Management System

Flutter event management app with Firebase backend.

## Stack

- Flutter (Riverpod, GoRouter)
- Firebase Auth, Firestore, Cloud Messaging
- Cloudinary for image storage

## Setup

1. `flutter pub get`
2. `flutter run -d chrome` (or a connected device)

Firebase is pre-configured via `firebase_options.dart`.

## Features

- Auth: email/password, Google, password reset, email verification
- Events: CRUD, filters, search, RSVP, favorites, calendar view
- Community: multi-group, polls with atomic voting
- Notifications: in-app + FCM push
- Profile: name, avatar, dark mode

## Architecture

- Feature-first folder structure
- Repository pattern — screens → providers → repositories → Firebase
- No Firebase calls outside `lib/core/repositories/`

## Known limitations

- Auto-send push notifications require Cloud Functions (Blaze plan)
- Group selector is per-user, in-memory + SharedPreferences
