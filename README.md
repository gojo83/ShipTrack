# ShipTrack 🚚

A full-stack courier tracking mobile application built with **Flutter** and **Firebase**. ShipTrack allows users to create shipments, track deliveries in real time, and receive instant status notifications — with a built-in admin panel to manage all shipments across the platform.

---

## Features

- **Authentication** — Secure email/password login and registration via Firebase Auth
- **Shipment Creation** — Create shipments with receiver verification by email + phone
- **Cost Estimation** — Automatic shipping cost and ETA calculation based on weight and delivery type
- **Live Tracking** — Real-time status stepper with 5 delivery stages
- **Map View** — Pickup and delivery locations displayed on an OpenStreetMap map
- **Shipment History** — Full history for both senders and receivers
- **Real-Time Notifications** — Instant in-app alerts for both sender and receiver on every status change
- **Admin Dashboard** — Search, view, and update the status of any shipment across all users
- **Help & Support** — FAQ accordion and contact links
- **Profile Screen** — Account info and sign-out

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.41.7 (Dart) |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| State Management | Provider |
| Maps | flutter_map + OpenStreetMap |
| Notifications | Firestore streams (in-app) |
| Build | Gradle (Kotlin DSL) |

---

## Prerequisites

Before running this project make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.41.0 or higher)
- [Android Studio](https://developer.android.com/studio) with Android SDK
- [Node.js](https://nodejs.org) (for Firebase CLI)
- [Firebase CLI](https://firebase.google.com/docs/cli) — install with `npm install -g firebase-tools`
- A Firebase project with **Authentication** and **Firestore** enabled

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/ShipTrack.git
cd ShipTrack
```

### 2. Set up Firebase

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and create a new project
2. Enable **Authentication → Email/Password**
3. Enable **Firestore Database** (start in test mode)
4. Register an Android app with package name `com.proj.shiptrack`
5. Download `google-services.json` and place it in `android/app/`

### 3. Configure FlutterFire

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This generates `lib/firebase_options.dart` automatically.

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Run the app

```bash
flutter run
```

Select your connected Android device or emulator when prompted.

---

## Firestore Setup

### Required Collections

Create the following collections in your Firestore database:

**`users`** — auto-populated on registration, no manual setup needed

**`shipments`** — auto-populated when shipments are created, no manual setup needed

**`notifications`** — auto-populated when admin updates status, no manual setup needed

**`admins`** — you need to create this manually:

1. In Firebase Console → Firestore → create collection named `admins`
2. Add a document where the **Document ID = your Firebase Auth UID**
3. Add any field e.g. `role : "admin"`
4. Log in with that account — you will be routed to the admin dashboard automatically

### Required Composite Indexes

Go to **Firestore → Indexes → Composite** and create these:

| Collection | Field 1 | Field 2 |
|---|---|---|
| `shipments` | `userId` (Ascending) | `createdAt` (Descending) |
| `shipments` | `receiverUserId` (Ascending) | `createdAt` (Descending) |
| `notifications` | `userId` (Ascending) | `createdAt` (Descending) |

> Firestore will also prompt you with a direct link to create missing indexes the first time a query runs — just click the link in the debug console.

---

## How to Use the App

### As a Regular User (Sender)

1. **Register** with your name, email, phone, and password
2. **Log in** to reach the home dashboard
3. Tap **Ship** in the bottom nav to create a new shipment
4. Enter the sender address, receiver address, and the **receiver's exact registered email and phone**
5. Select package type, weight, and delivery type — the cost and ETA are calculated automatically
6. Tap **Confirm Shipment** — a tracking ID is generated
7. Tap any shipment on the home screen to open the **tracking view** with live status and map
8. Check the **Alerts** tab for real-time status notifications

### As a Receiver

1. Log in to your account
2. Go to **History** — shipments addressed to your email + phone will appear here
3. Check the **Alerts** tab for notifications when your package status changes

### As an Admin

1. Log in with the account whose UID is in the `admins` collection
2. You are automatically routed to the **Admin Dashboard**
3. Browse all shipments or use the search bar to find one by tracking ID
4. Tap any status chip on a shipment card to update it — a confirmation dialog appears
5. On confirmation, both the sender and receiver receive an instant notification

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_model.dart
│   └── shipment_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── geocoding_service.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── create_shipment_screen.dart
│   │   ├── history_screen.dart
│   │   ├── tracking_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── profile_screen.dart
│   │   └── help_screen.dart
│   └── admin/
│       └── admin_screen.dart
├── widgets/
│   └── custom_text_field.dart
└── utils/
    ├── app_theme.dart
    └── constants.dart
```

---

## Shipping Cost Formula

| Delivery Type | Base Price | Per kg |
|---|---|---|
| Standard | ৳ 80 | ৳ 50 |
| Express | ৳ 150 | ৳ 50 |

**Example:** 3kg Express = 150 + (3 × 50) = **৳ 300**

---

## Delivery Status Stages

```
Order Placed → Package Picked Up → In Transit → Out for Delivery → Delivered
```

Status updates are made by the admin and propagate instantly to all users via Firestore streams.

---

## Common Issues

**`flutter` not recognised in terminal**
Add Flutter to your PATH: `$env:PATH += ";C:\path\to\flutter\bin"` (Windows PowerShell)

**`flutterfire` not recognised**
Add the Pub cache bin to PATH: `$env:PATH += ";C:\Users\YOUR_NAME\AppData\Local\Pub\Cache\bin"`

**Build fails with desugaring error**
In `android/app/build.gradle.kts` add inside `compileOptions`:
```kotlin
isCoreLibraryDesugaringEnabled = true
```
And in `dependencies`:
```kotlin
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
```

**Firestore query fails at runtime**
Create the required composite indexes listed above — Firestore will also print a direct link to create them in your debug console.

**Device not detected by `flutter devices`**
Enable USB Debugging in Developer Options on your Android device, then run `adb devices` to verify the connection.

---

## Built With

- [Flutter](https://flutter.dev)
- [Firebase](https://firebase.google.com)
- [OpenStreetMap](https://www.openstreetmap.org) via [flutter_map](https://pub.dev/packages/flutter_map)
- [Provider](https://pub.dev/packages/provider)

---

## Author

**Ibtisum Jaman** — ID: 24141204
CSE489: Android App Development
