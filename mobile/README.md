# ❄️ Solo Leveling Winter Arc — Flutter Mobile App

> Native Flutter & Dart mobile application for the 4-Month Winter Arc Protocol (September 1 to December 31) featuring animated Solo Leveling "System" holographic UI, Smartwatch Health Auto-Sync, Built-in Offline Native Alarms/Notifications, and real-time Supabase PostgreSQL integration.

---

## 📱 How to Download & Install the APK on Your Android Phone

### ⚡ Option 1: 1-Click Cloud Download from GitHub (Recommended)
1. Visit your repository's [GitHub Actions tab](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/actions) on your phone or PC.
2. Select the latest build and tap **`Winter-Arc-Solo-Leveling-App`** under **Artifacts** to download the `.zip`.
3. Extract and tap **`app-release.apk`** to install on your Android device!

### 💻 Option 2: Build Locally on Your PC
```powershell
cd mobile
flutter pub get
flutter build apk --release
```
The APK is generated at:
`mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔔 Built-In Offline Native Notifications

The app does **not require any 3rd party apps**. It schedules native OS alarms with Android `AlarmManager`:
- **07:00 AM IST:** `⚡ [ SYSTEM NOTIFICATION : DAILY QUEST ISSUED ]`
- **06:30 PM IST:** `⚔️ [ SYSTEM QUEST : PLACEMENT & DSA SHIFT ]`
- **10:30 PM IST:** `⚠️ [ CAUTION : PENALTY QUEST WARNING ]`

---

## ⚡ Running in Development Mode

```powershell
flutter run -d chrome    # Web preview with hot reload
flutter run -d windows   # Windows desktop app
flutter run              # Plugged-in Android/iOS device
```
