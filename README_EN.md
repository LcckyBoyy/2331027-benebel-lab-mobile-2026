# 📰 NewsApp — Flutter

A Flutter application that fetches top headlines from [NewsAPI](https://newsapi.org), built with a focus on clean architecture, offline readiness, and consistent code structure.

---

## ✨ Features

- Browse top headlines from NewsAPI
- Search articles by keyword
- Filter by category (Technology, Sports, Business, Health, Entertainment)
- Shimmer loading effect for smooth UX
- Offline mode — automatically displays cached data when no internet connection is available
- User-friendly error UI with retry button

---

## 📁 Folder Structure

```
lib/
├── models/         # Data models (Article)
├── services/       # API calls & caching logic
├── providers/      # State management (Provider)
├── views/          # Screens (Home, Search, Detail)
├── widgets/        # Reusable UI components
└── main.dart
```

### Why this structure?

| Folder | Purpose |
|---|---|
| `models/` | Defines the data shape. `Article.fromJson()` handles JSON parsing so the rest of the app doesn't need to care about the API response format. |
| `services/` | All network requests and cache read/write logic live here. UI files never call the API directly. |
| `providers/` | Manages app state (loading, data, error). Sits between `services/` and `views/`. |
| `views/` | Pure UI. Screens only read from providers and display data — no business logic here. |
| `widgets/` | Reusable components (`ArticleCard`, `LoadingShimmer`) used consistently across all screens. |

This separation ensures that changes in one layer (e.g., swapping the API) don't break other layers.

---

## 🔧 State Management — Why Provider?

This project uses **Provider** as the state management solution. Here's the reasoning:

- **Simple and readable** — Provider follows a straightforward pattern that's easy to trace and debug. The data flow is explicit: `Service → Provider → View`.
- **Official recommendation** — Provider is recommended by the Flutter team for projects of this scale.
- **Right-sized** — Solutions like BLoC or Riverpod add boilerplate that isn't necessary for a single-feature app like this. GetX, while convenient, abstracts too much and makes the architecture harder to explain and maintain.
- **Easy to test** — Because business logic is isolated in the Provider layer, each part can be tested independently.

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  provider: ^6.1.2
  shared_preferences: ^2.2.3
  shimmer: ^3.0.0
  url_launcher: ^6.3.0
```

---

## 🚀 Getting Started

### Quick Test (No Setup Needed)

A pre-built APK is available in the `apk/` folder. Transfer `apk/news_app.apk` to an Android device and install it directly.

### Build From Source

**Prerequisites:** Flutter SDK ≥ 3.7.0, Android SDK, JDK 17

1. Clone this repository
   ```bash
   git clone <repository-url>
   cd news_app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Add your NewsAPI key

   Copy `.env.example` to `.env` and paste your API key:
   ```bash
   cp .env.example .env
   ```
   ```
   NEWS_API_KEY=your_actual_api_key_here
   ```
   Get a free API key at [newsapi.org/register](https://newsapi.org/register)

4. Run on a physical device or emulator
   ```bash
   flutter run
   ```

> **Note:** NewsAPI's free tier does not support browser-based requests (CORS). Run on an Android/iOS device or emulator for best results.

---

## 📱 Screens

| Screen | Description |
|---|---|
| Home | Article list with shimmer loading, category filter, offline banner, and error state |
| Search | Keyword search using `async/await` + `FutureBuilder` |
| Detail | Full article view with source info and open-in-browser button |

---

## 🗂️ Offline Mode

When there is no internet connection, the app automatically loads the last successfully fetched data from local cache (`shared_preferences`) and displays an **"Offline Mode"** banner to inform the user.

---

*Built for UTS — Lab Pengembangan Aplikasi Mobile, Sistem Informasi 2025/2026*
