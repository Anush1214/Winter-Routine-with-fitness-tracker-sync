# ❄️ Solo Leveling Winter Arc — Flutter Mobile App

> Native Flutter & Dart mobile application for the 4-Month Winter Arc Protocol (September 1 to December 31) featuring animated Solo Leveling "System" holographic UI, Smartwatch Health Auto-Sync, Built-in Offline Native Alarms/Notifications, and real-time Supabase PostgreSQL integration.

---

## 📥 Direct APK Download for Android

[![Download APK](https://img.shields.io/badge/📲_Direct_Download-Solo_Leveling_APK-00F0FF?style=for-the-badge&logo=android&logoColor=02050E)](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/releases/latest/download/app-release.apk)

* **Direct 1-Tap APK Download Link:**  
  👉 **[https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/releases/latest/download/app-release.apk](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/releases/latest/download/app-release.apk)**

* **Alternative (GitHub Actions Artifacts):**  
  👉 **[https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/actions](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/actions)**

---

## 📱 How to Install the APK on Your Android Phone

1. **Download the File**: Tap the [Direct APK Download Link](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/releases/latest/download/app-release.apk) on your phone.
2. **Install**: Tap `app-release.apk` in your Downloads folder $\rightarrow$ Tap **Install**.
   - *If prompted with "Install unknown apps", tap **Settings $\rightarrow$ Allow from this source** $\rightarrow$ Tap **Install**.*
   - *If Google Play Protect shows a notice, tap **Install anyway**.*
3. **Launch & Authorize**: Open **Winter Arc Protocol** and allow notifications to receive daily quest alerts and smartwatch vibrations!

---

## 🔔 Built-In Offline Native Notifications

The app does **not require any 3rd party apps**. It schedules native OS alarms directly with Android `AlarmManager`:
- **07:00 AM IST:** `⚡ [ SYSTEM NOTIFICATION : DAILY QUEST ISSUED ]`
- **06:30 PM IST:** `⚔️ [ SYSTEM QUEST : PLACEMENT & DSA SHIFT ]`
- **10:30 PM IST:** `⚠️ [ CAUTION : PENALTY QUEST WARNING ]`

---

## 💻 Building the APK Locally on Your PC

```powershell
cd mobile
flutter pub get
flutter build apk --release --no-tree-shake-icons
```
Output: `mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## ⚡ Running in Development Mode

```powershell
flutter run -d chrome    # Web preview with hot reload
flutter run -d windows   # Windows desktop app
flutter run              # Plugged-in Android/iOS device
```
