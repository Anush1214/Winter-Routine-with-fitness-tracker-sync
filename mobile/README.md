# ❄️ Solo Leveling Winter Arc — Flutter Mobile App

> Native Flutter & Dart mobile application for the 4-Month Winter Arc Protocol (September 1 to December 31) featuring animated Solo Leveling "System" holographic UI, Smartwatch Health Auto-Sync, Built-in Offline Native Alarms/Notifications, and real-time Supabase PostgreSQL integration.

---

## 📱 How to Download & Install the Mobile APK on Your Android Phone

### ⚡ Step-by-Step APK Download Guide (GitHub Actions):

1. **Open GitHub Actions on Your Phone or PC**:  
   👉 **[GitHub Actions Workflows](https://github.com/Anush1214/Winter-Routine-with-fitness-tracker-sync/actions)**

2. **Select the Latest Successful Run**:  
   Tap on the top workflow run that has a **green checkmark (✅)**.

3. **Download the APK Artifact**:  
   Scroll down to the **Artifacts** section at the bottom:  
   👉 Tap **`Winter-Arc-Solo-Leveling-App`** to download the `.zip`.

4. **Install on Your Phone**:
   - Extract the `.zip` file in your Downloads folder.
   - Tap on **`app-release.apk`** $\rightarrow$ Tap **Install**.
   - If prompted with *"Install from unknown sources"*, tap **Settings $\rightarrow$ Allow from this source**.
   - If Google Play Protect shows a prompt, tap **Install anyway**.

5. **Open the App**:
   - Open the **Winter Arc Protocol** app and allow notifications to receive daily quest alerts!

---

## 💻 Building the APK Locally on Your PC

```powershell
cd mobile
flutter pub get
flutter build apk --release --no-tree-shake-icons
```
The compiled APK is generated at:  
📁 `mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔔 Built-In Offline Native Notifications

The app does **not require any 3rd party apps**. It schedules native OS alarms directly with Android `AlarmManager`:
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
