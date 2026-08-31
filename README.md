# ❄️ SOLO LEVELING // WINTER ARC PROTOCOL 2026

> Strict 4-Month Transformation System Protocol (September 1 to December 31) with **Native Flutter Mobile Companion App**, **Smartwatch Health Auto-Sync**, **Dynamic Routine Management**, and **Built-in Offline Native System Push Notifications** powered 24/7 by Supabase PostgreSQL.

---

## 📱 How to Download & Install the Mobile APK on Your Android Phone

You can download and install the ready-to-use Android APK directly onto your phone in **under 1 minute** without installing Flutter or Android Studio on your PC!

---

### ⚡ Step-by-Step APK Download Guide (GitHub Actions):

1. **Open the GitHub Actions Tab on Your Phone or PC**:  
   👉 **[Click Here to Open GitHub Actions Artifacts](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/actions)**

2. **Select the Latest Successful Run**:  
   Tap on the top workflow run that has a **green checkmark (✅)** (e.g., `fix(android): bump compileSdk to 36...`).

3. **Download the APK Artifact**:  
   Scroll down to the bottom of the page to the **Artifacts** section:  
   👉 Click **`Winter-Arc-Solo-Leveling-App`** to download the `.zip` file.

4. **Install on Your Phone**:
   - Open your phone's **Files** or **Downloads** app.
   - Extract the downloaded `.zip` file $\rightarrow$ Tap on **`app-release.apk`**.
   - If Android prompts with *"For your security, your phone is not allowed to install unknown apps from this source"*:
     - Tap **Settings** $\rightarrow$ Toggle **Allow from this source** to **ON** $\rightarrow$ Tap **Install**.
   - If Google Play Protect shows a popup, tap **Install anyway**.

5. **Launch the Solo Leveling System**:
   - Open the **Winter Arc Protocol** app from your app drawer.
   - Allow the notification permission prompt when asked to enable daily quest alerts!

---

### 💻 Alternative: Building the APK Locally on Your PC

If you have Flutter installed on your laptop and want to build manually:

```powershell
# 1. Navigate to mobile directory
cd mobile

# 2. Get dependencies
flutter pub get

# 3. Build release APK
flutter build apk --release --no-tree-shake-icons
```

Your compiled APK will be located at:  
📁 `mobile/build/app/outputs/flutter-apk/app-release.apk`  
*(Transfer this file to your phone via USB cable, WhatsApp, Telegram, or Google Drive and tap to install).*

---

### 🔔 Built-In Offline Native Notifications (No Extra Apps Needed!)

The mobile app includes a **Native On-Device Alarm & Notification Engine** (`flutter_local_notifications` + Android `AlarmManager`):
- **100% Offline & Standalone**: System alarms trigger reliably even if the app is closed, phone is locked, or there is no internet connection.
- **Smartwatch Wrist Vibration**: All native Android alerts automatically mirror and vibrate on your **CMF Watch Pro 2** (via the CMF Watch / Nothing X companion app).
- **Daily Automated Schedule**:
  - **🌅 07:00 AM IST:** `⚡ [ SYSTEM NOTIFICATION : DAILY QUEST ISSUED ]` (Morning Awakening Protocol)
  - **⚔️ 06:30 PM IST:** `⚔️ [ SYSTEM QUEST : PLACEMENT & DSA SHIFT ]` (DSA & Japanese Practice)
  - **⚠️ 10:30 PM IST:** `⚠️ [ CAUTION : PENALTY QUEST WARNING ]` (Night Protocol & Penalty Alert)
- **Instant Testing**: Open the app $\rightarrow$ Tap **Alerts** in the top bar $\rightarrow$ Tap **`TEST NATIVE NOTIFICATION NOW`** to test instant vibration.

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
