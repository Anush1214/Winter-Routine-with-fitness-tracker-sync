# ❄️ SOLO LEVELING // WINTER ARC PROTOCOL 2026

> Strict 4-Month Transformation System Protocol (September 1 to December 31) with **Native Flutter Mobile Companion App (Android & iOS)**, **Nothing X / CMF Watch Pro 2 Health Auto-Sync**, **Firebase Multi-User Authentication**, and **Built-in Offline Native System Push Notifications** powered 24/7 by Supabase PostgreSQL.

---

## 📥 Direct Downloads & Quick Links

[![Download APK](https://img.shields.io/badge/📲_Direct_Download-Android_Solo_Leveling_APK-00F0FF?style=for-the-badge&logo=android&logoColor=02050E)](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/releases/latest/download/app-release.apk)
[![PWA iOS App](https://img.shields.io/badge/🍎_iOS_Instant_App-PWA_Safari_Install-FF0055?style=for-the-badge&logo=apple&logoColor=white)](https://your-winter-arc-app.vercel.app)

* **Direct 1-Tap APK Download Link (Android):**  
  👉 **[https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/releases/latest/download/app-release.apk](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/releases/latest/download/app-release.apk)**

* **GitHub Actions Builds & Artifacts:**  
  👉 **[https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/actions](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/actions)**

---

## 📱 How to Install the App on Android

1. **Download the APK**: Tap the [Direct APK Download Link](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/releases/latest/download/app-release.apk) on your phone.
2. **Install**: Open your **Downloads** folder $\rightarrow$ Tap **`app-release.apk`** $\rightarrow$ Tap **Install**.
   - *If prompted with "Install unknown apps", tap **Settings $\rightarrow$ Allow from this source** $\rightarrow$ Tap **Install**.*
   - *If Google Play Protect shows a notice, tap **Install anyway**.*
3. **Awaken Your Hunter**: Open **Winter Arc Protocol**, sign in or tap **`CONTINUE AS GUEST SHADOW HUNTER`**, and allow notification permissions!

---

## 🍎 How to Install the App on iPhone (iOS)

### ⚡ Method 1: Instant 1-Tap PWA Install (No Mac or Xcode Required)
1. Open the hosted web app link in **Safari** on your iPhone.
2. Tap the **Share Button** (square with upward arrow) at the bottom of Safari.
3. Scroll down and tap **"Add to Home Screen"** $\rightarrow$ tap **Add**.
4. The **Winter Arc Protocol** icon will appear on your home screen and run full-screen as a native iOS app!

### 💻 Method 2: Native iOS Runner (Using Mac & Xcode)
```bash
cd mobile
flutter pub get
cd ios && pod install && cd ..
flutter run -d ios
```

---

## ⌚ How to Connect with Nothing X (CMF Watch Pro 2)

Your CMF Watch Pro 2 connects to the **Nothing X** app, which automatically syncs your steps, sleep, and workouts with **Google Health Connect** (Android) and **Apple Health** (iOS):

1. **In Nothing X App**:
   - Open the **Nothing X** (or CMF Watch) app on your phone.
   - Go to **Profile / Settings** $\rightarrow$ **Third-Party Services**.
   - Enable **Google Health Connect** (Android) or **Apple Health** (iOS).
2. **In Winter Arc Mobile App**:
   - Tap **Watch Sync** in the top bar.
   - Tap **`FETCH LIVE METRICS FROM NOTHING X`**.
   - Tap **`PUSH TELEMETRY & AUTO-CHECK QUESTS`** to automatically complete your 10,000 steps, 7-8h sleep, and gym workout quests!

---

## 🔥 Firebase Multi-User Authentication & Data Isolation

The app includes a dedicated Solo Leveling **Hunter Awakening Portal**:
- **Multi-User Isolation**: Each user has their own isolated routine tasks, 122-day progress heatmap, and hydration logs.
- **Sign In & Registration**: Authenticate using your email & password.
- **Guest Shadow Hunter Mode**: Tap **`CONTINUE AS GUEST SHADOW HUNTER`** for 1-tap instant offline access without typing credentials.

---

## 🔔 Standalone Offline Native Notifications

The app schedules native OS alarms with Android `AlarmManager` and iOS notification center:
- **🌅 07:00 AM IST:** `⚡ [ SYSTEM NOTIFICATION : DAILY QUEST ISSUED ]` (Morning Protocol)
- **⚔️ 06:30 PM IST:** `⚔️ [ SYSTEM QUEST : PLACEMENT & DSA SHIFT ]` (DSA & Japanese Practice)
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
├── mobile/                       # Native Flutter & Dart Mobile Companion App (Android & iOS)
│   ├── lib/
│   │   ├── main.dart             # App entry point with AuthService gating & dark theme
│   │   ├── services/
│   │   │   ├── auth_service.dart         # Firebase Auth + Guest session management
│   │   │   ├── notification_service.dart # Native on-device offline alarms & notifications
│   │   │   ├── health_service.dart       # Nothing X / Health Connect / HealthKit sync
│   │   │   └── supabase_service.dart     # Per-user isolated state manager & API sync
│   │   └── presentation/         # Animated Solo Leveling HUD frames, AuthScreen & quest views
│   ├── android/                  # Android Runner (SDK 36, desugaring enabled)
│   ├── ios/                      # iOS Runner (HealthKit permissions, iOS 14+ Podfile)
│   └── pubspec.yaml              # Mobile dependencies & assets
│
├── backend/                      # Services, Prisma Database, Smartwatch Sync, Automations
│   ├── prisma/                   # Supabase PostgreSQL models (Task, HealthLog, UserSettings)
│   ├── services/                 # Tasks, Health Sync, Hydration, Notifications & Stats
│   └── automation/               # GitHub Actions workflows & Smartwatch shortcuts
│
└── src/app/api/                  # Next.js App Router API endpoints with CORS & User Isolation
```

---

## ⚡ Quick Start (Web Development)

```bash
npm install
npm run prisma:generate
npm run prisma:push
npm run prisma:seed
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) in your browser.
