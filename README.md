# ❄️ SOLO LEVELING // WINTER ARC PROTOCOL 2026

> Strict 4-Month Transformation System Protocol (September 1 to December 31) with **Native Flutter Mobile Companion App**, **Smartwatch Health Auto-Sync**, **Dynamic Routine Management**, and **Built-in Offline Native System Push Notifications** powered 24/7 by Supabase PostgreSQL.

---

## 📱 Mobile APK Installation & Testing Guide (Android)

You can download and install the native Android APK directly onto your phone without needing any local Flutter or Android SDK setup!

### ⚡ Method 1: Download from GitHub Actions (Easiest - 1 Click)

1. Open your GitHub Repository on your phone's browser or laptop:  
   🔗 **[GitHub Actions Workflows](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/actions)**
2. Click on the latest workflow run (e.g. `ci: add GitHub Actions workflow to auto-build and release Flutter APK`).
3. Scroll down to the **Artifacts** section and tap **`Winter-Arc-Solo-Leveling-App`** to download the `.zip` containing the `app-release.apk`.
4. Extract the zip and tap **`app-release.apk`** to install on your phone.
   - *If prompted with "Install from unknown sources", tap **Settings $\rightarrow$ Allow from this source**.*
5. Open the **Winter Arc Protocol** app!

---

### 💻 Method 2: Build APK Locally via Laptop Terminal

If you want to compile the APK directly on your machine:

1. **Install Android Command-line Tools / Android Studio**:
   - Download [Android Studio](https://developer.android.com/studio).
   - In Android Studio $\rightarrow$ **Settings / SDK Manager** $\rightarrow$ **SDK Tools** $\rightarrow$ Check **"Android SDK Command-line Tools"** and click **Apply**.
   - Accept licenses in terminal:
     ```powershell
     flutter doctor --android-licenses
     ```
2. **Build Release APK**:
   ```powershell
   cd mobile
   flutter pub get
   flutter build apk --release
   ```
3. Your compiled `.apk` will be generated at:  
   📁 `mobile/build/app/outputs/flutter-apk/app-release.apk`
4. Send this file to your phone via Google Drive, WhatsApp, Telegram, or USB cable and tap **Install**.

---

### 🔔 Standalone Native Notifications (NO 3rd party apps needed!)

The Flutter app includes a **Native On-Device Notification & Alarm Engine** (`flutter_local_notifications` + Android `AlarmManager`):
- **100% Offline**: Fires system alerts even if the app is closed, phone is locked, or there is no internet.
- **Smartwatch Vibration**: Native notifications automatically mirror to your **CMF Watch Pro 2** (or any Bluetooth smartwatch via the companion watch app).
- **Daily Built-in Schedule**:
  - **🌅 07:00 AM IST:** `⚡ [ SYSTEM NOTIFICATION : DAILY QUEST ISSUED ]` (Morning Protocol)
  - **⚔️ 06:30 PM IST:** `⚔️ [ SYSTEM QUEST : PLACEMENT & DSA SHIFT ]` (DSA & Japanese)
  - **⚠️ 10:30 PM IST:** `⚠️ [ CAUTION : PENALTY QUEST WARNING ]` (Night Warning)

---

## 📁 Project Architecture & Clean Folder Separation

```
├── frontend/                     # Next.js React Client, Holographic Solo Leveling UI & Procedural Audio
│   ├── components/               # Header, DateCarousel, DailyProgressCard, RoutineSection, 
│   │                             # HabitCounters, ConsistencyHeatmap, TaskModal, SmartwatchSyncModal
│   ├── lib/                      # Procedural Web Audio API sound synthesizer & utilities
│   └── styles/globals.css        # Solo Leveling obsidian glassmorphism & HUD neon styles
│
├── mobile/                       # Native Flutter & Dart Mobile Companion App
│   ├── lib/
│   │   ├── main.dart             # App entry point with dark holographic theme & Provider
│   │   ├── core/theme/           # Obsidian Void #02050E, Neon Cyan #00F0FF, Mana Blue
│   │   ├── services/
│   │   │   ├── notification_service.dart # Native on-device offline alarms & notifications
│   │   │   ├── health_service.dart       # HealthKit / Health Connect sync
│   │   │   └── supabase_service.dart     # Real-time state manager & API sync
│   │   └── presentation/         # Animated Solo Leveling HUD frames, gauges & 4 quest sections
│   └── pubspec.yaml              # Mobile dependencies & assets
│
├── backend/                      # Services, Prisma Database, Smartwatch Sync, Automations
│   ├── prisma/
│   │   ├── schema.prisma         # Supabase PostgreSQL models (Task, HealthLog, UserSettings)
│   │   └── seed.ts               # Seeding script for all 122 days (Sept 1 - Dec 31)
│   ├── services/                 # Tasks, Health Sync, Hydration, Notifications & Stats
│   └── automation/               # GitHub Actions workflows & Smartwatch shortcuts
│
└── src/app/api/                  # Next.js App Router API endpoints with CORS enabled
```

---

## ⚡ Quick Start (Web Development)

1. **Install dependencies:**
   ```bash
   npm install
   ```
2. **Push database schema to Supabase:**
   ```bash
   npm run prisma:generate
   npm run prisma:push
   npm run prisma:seed
   ```
3. **Start local dev server:**
   ```bash
   npm run dev
   ```
   Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 📱 Quick Start (Flutter Mobile App)

```bash
cd mobile
flutter pub get
flutter run -d chrome      # Preview in browser with live reload
flutter run -d windows     # Run native desktop app
flutter run                # Run on connected Android / iOS device
```

---

## ⌚ CMF Watch Pro 2 & Smartwatch Auto-Sync

The tracker accepts POST requests to `/api/sync-health`:

```bash
curl -X POST https://your-winter-arc-app.vercel.app/api/sync-health \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2026-09-01",
    "steps": 10450,
    "sleepMinutes": 450,
    "gymWorkoutDone": true,
    "waterIntakeMl": 4200
  }'
```

- **Steps >= 10,000** $\rightarrow$ Auto-completes `Daily Movement: 10,000 Steps`.
- **Sleep >= 420 mins (7 hrs)** $\rightarrow$ Auto-completes `Sleep Recovery: 7-8 Hours`.
- **Gym Workout Done = true** $\rightarrow$ Auto-completes `Gym Workout Session (06:00 - 07:00)`.
- **Water >= 4000ml** $\rightarrow$ Auto-completes `Hydration Goal: 4-5L Water`.
