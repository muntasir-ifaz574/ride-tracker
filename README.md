# Live Ride Tracker

A ride tracking mobile app built with Flutter. Watch your driver move on the map, see their ETA count down, and get a clean summary of your fare — all in a sleek dark UI.

---

## Download the App

> Click the button below to download the APK directly to your Android phone.

[![Download APK](https://img.shields.io/badge/Download%20APK-Google%20Drive-blue?style=for-the-badge&logo=google-drive)](https://drive.google.com/drive/folders/1ijqvHDO6sBYhSLuciSsnd8nXtFPXXGmC?usp=sharing)

> **Note:** On your phone, you may need to allow "Install from unknown sources" in your settings since this is a direct APK (not from the Play Store).

---

## Watch the Demo

> Click the thumbnail below to watch the full app demo on Google Drive.

[![Watch Demo Video](https://img.shields.io/badge/Watch%20Demo-Google%20Drive-red?style=for-the-badge&logo=google-drive)](https://drive.google.com/YOUR_VIDEO_LINK_HERE)

---

## What the App Does

When you open the app, you'll see a splash screen with the RiseUp Labs logo, followed by the main tracking screen. Here's what you get:

- **Live car marker on the map** — the car icon glides smoothly along the real road route fetched from Google Maps. No jumpy teleporting.
- **3D driving camera view** — the camera locks onto the car and tilts at an angle, rotating as the car turns, just like a navigation app.
- **Real-time ETA countdown** — shows you exactly how many minutes are left until arrival, calculated from the actual Google Directions API.
- **Driver details card** — driver name, vehicle plate, and star rating shown at the bottom.
- **Estimated fare display** — shows the total ride fare with taxes included.
- **Live badge** — a pulsing red dot next to "Live" shows the ride is actively tracked.
- **Draggable bottom sheet** — you can swipe the info card up or down without leaving the map view.

---

## How It's Built

The app follows **Clean Architecture**, meaning the code is organized into three clear layers that don't mix responsibilities:

```
lib/
├── data/               ← talks to APIs and manages raw data
│   ├── datasources/    ← Google Directions API calls
│   ├── models/         ← JSON parsing (Driver, Fare)
│   └── repositories/   ← combines data sources into usable results
│
├── domain/             ← the core business logic (no Flutter dependencies)
│   ├── entities/       ← plain Dart objects (Driver, Fare)
│   ├── repositories/   ← abstract contracts for data access
│   └── state/          ← Riverpod state notifier and state model
│
└── presentation/       ← everything the user sees
    ├── screens/        ← SplashScreen, LiveRideTrackingScreen
    ├── widgets/        ← LiveMapView, RideBottomSheet, BlinkingDot
    └── theme/          ← colors and design tokens
```

### Tech Stack

| What | Tool |
|---|---|
| Framework | Flutter 3.x |
| State Management | Riverpod 3 |
| Maps | Google Maps Flutter |
| Route Polylines | Google Directions API |
| SVG Rendering | flutter_svg |
| Environment Config | flutter_dotenv |

---

## API Key Setup

The app loads the Google Maps API key securely from a local `.env` file. This file is **not committed to git** for security.

To run the app yourself:

1. Create a `.env` file in the project root:
   ```
   MAPS_API_KEY=your_google_maps_api_key_here
   ```
2. For Android, add your key to `android/local.properties`:
   ```
   MAPS_API_KEY=your_google_maps_api_key_here
   ```
3. For iOS, add your key to `ios/Flutter/Config.xcconfig`:
   ```
   MAPS_API_KEY=your_google_maps_api_key_here
   ```

---

## Running Locally

Make sure you have Flutter installed, then:

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## Performance Notes

A few things were done specifically to keep the map animation at 60 fps without any lag:

- The car marker is updated using raw bytes cached once at startup — no file I/O during animation.
- Camera and marker updates are throttled to ~30 fps to avoid flooding the platform bridge.
- The car rotation smoothly interpolates to avoid snapping when turning corners.
- Only the marker layer re-renders on each frame — the rest of the UI is untouched.

---

## Project Structure At a Glance

```
ridetracker/
├── assets/
│   ├── icons/car.png          ← car marker icon on the map
│   └── logo/riseuplabs.svg    ← splash screen logo
├── lib/                       ← all Dart source code
├── android/                   ← Android platform config
├── ios/                       ← iOS platform config
├── test/                      ← widget tests
└── .env                       ← secret API key (not in git)
```

---

## Security

- The Google Maps API key is **never hardcoded** in Dart source files.
- `.env`, `local.properties`, and `Config.xcconfig` are all listed in `.gitignore`.
- The app will throw a clear error if the key is missing, rather than silently using a fallback.

---

## Built by

**Muntasir Efaz**
