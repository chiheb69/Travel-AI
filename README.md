# Travel AI 🌍✈️

**Travel AI** is a next-generation travel planning application built with **Flutter** and powered by **Google's Gemini 1.5 Flash**. It combines reliable travel booking features with an intelligent AI assistant to help users discover, plan, and organize their dream trips.

![Travel AI Banner](assets/images/ic_launcher.png)

---

## ✨ Key Features

### 🤖 Intelligent AI Assistant
-   **Powered by Gemini 1.5 Flash**: Lightning-fast responses for travel tips, itinerary planning, and destination insights.
-   **Context-Aware**: Remembers your preference context during the session.
-   **Real-time Assistance**: Chat floating action button always available on the dashboard.

### 🛡️ Powerful Admin Dashboard
-   **User Management**: View real-time list of all registered users.
-   **Deep Insights**: Inspect user profiles, including their **Cloud-Synced Bio**, **Favorites**, and **Bookings**.
-   **CRUD Operations**: Edit user details or delete accounts with one tap.
-   **Exclusive Access**: Secured route accessible only to specific admin credentials.

### ☁️ Cloud Sync & Persistence
-   **Cross-Device Sync**: User data (Favorites, Bookings, Bio) is stored in **Cloud Firestore**.
-   **Persistent Bio**: Users can write a custom "About Me" bio that is instantly visible to the Admin.
-   **Default Avatar System**: A premium, platform-wide fallback image for users who haven't set a profile picture.

### 🔐 Robust Authentication
-   **Multi-Method Login**:
    -   Google Sign-In (Web & Android).
    -   Email/Password Registration.
-   **Smart Routing**: Automatic redirection to `Dashboard` or `AdminPanel` based on user role.
-   **Auto-Bootstrap**: Admin account auto-creation if missing.

### 🎨 Premium UI/UX
-   **Modern Design**: Built with **Glassmorphism**, smooth gradients, and **`animate_do`** animations.
-   **Dynamic Theming**: Custom dark theme with a "Deep Slate" and "Vibrant Cyan" color palette.
-   **Responsive**: Optimized layouts for both Mobile and Web.

---

## 🛠️ Tech Stack

-   **Frontend**: Flutter 3.x (Dart)
-   **State Management**: `flutter_bloc` (BLoC Pattern)
-   **Backend Features**: Firebase Auth, Cloud Firestore
-   **AI Model**: `google_generative_ai` (Gemini 1.5 Flash)
-   **Animations**: `animate_do`, `lottie`
-   **Networking**: `http`, `cloud_firestore`

---

## 🚀 Getting Started

### Prerequisites
-   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
-   A Firebase Project with **Auth** (Google & Email) and **Firestore** enabled.
-   A [Google AI Studio](https://makersuite.google.com/) API Key for Gemini.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/travel_ai.git
    cd travel_ai
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure Environment**:
    -   Update `lib/core/config.dart` with your **Gemini API Key**.
    -   Ensure Firebase is initialized (standard `firebase_options.dart` or manual platform files).

4.  **Run the App**:
    ```bash
    # For Web (Chrome)
    flutter run -d chrome

    # For Android
    flutter run -d android
    ```

---

## 📱 Mobile Configuration (Android)

To enable **Google Sign-In on Android**, you must register your app's SHA-1 fingerprint.

1.  **Generate SHA-1 Key** (Windows):
    ```powershell
    keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
    ```

2.  **Add to Firebase**:
    -   Go to [Firebase Console](https://console.firebase.google.com/).
    -   Project Settings -> Your Apps -> Android.
    -   Add the **SHA-1** fingerprint.
    -   Download the updated `google-services.json` and place it in `android/app/`.

---

## 🔑 Admin Credentials (Demo)

Use these credentials to access the Admin Dashboard:

| Role | Email | Password |
| :--- | :--- | :--- |
| **Admin** | `admin@app.tn` | `chiheb2011` |

---

## 📂 Architecture Overview

The project follows a **Feature-First** & **Repository Pattern** architecture:

```
lib/
├── core/                # App-wide configurations, theme, utils
├── features/
│   ├── admin/           # Admin Dashboard & User Management
│   ├── auth/            # Authentication BLoC & Screens
│   ├── chat/            # AI Chat Logic
│   ├── discovery/       # Main User Dashboard
│   └── profile/         # User Profile & Bio editing
├── models/              # Data Models (AppUser, Destination, etc.)
├── repositories/        # Data Fetching Layer (Firebase, Auth)
└── app.dart             # Main App Widget & Routing
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Made with ❤️ and 🤖 by Travel AI Team.*
