# ❄️ Solo Leveling Winter Arc — Flutter Mobile App

> Native Flutter & Dart mobile application for the 4-Month Winter Arc Protocol (September 1 to December 31) featuring animated Solo Leveling "System" holographic UI, Smartwatch Health Auto-Sync, and real-time Supabase PostgreSQL integration.

---

## 📁 Architecture & Clean Structure

```
winter_arc_mobile/
├── pubspec.yaml                  # Flutter dependencies (supabase_flutter, provider, health, audioplayers)
├── README.md                     # Setup and running guide
└── lib/
    ├── main.dart                 # Application entry point with dark holographic theme
    ├── core/
    │   ├── theme/
    │   │   ├── solo_colors.dart  # Obsidian #02050E, Neon Cyan #00F0FF, Mana Blue, Penalty Crimson
    │   │   └── solo_typography.dart # Futuristic Google Fonts typography
    │   ├── utils/
    │   │   └── timeline_utils.dart # 122-Day math (Sept 1 — Dec 31)
    │   └── audio/
    │       └── sound_service.dart  # Procedural haptics & audio triggers
    ├── models/
    │   ├── task_model.dart       # Quest objective schema
    │   └── health_log_model.dart # Steps, Sleep, Water, Gym logs
    ├── services/
    │   ├── supabase_service.dart # Real-time state manager & REST API sync
    │   └── health_service.dart   # Apple Health & Android Health Connect auto-sync
    └── presentation/
        ├── widgets/
        │   ├── holographic_frame.dart   # CustomPainter glowing corner brackets & scanlines
        │   ├── mana_circular_ring.dart  # Animated sweeping circular mana gauge
        │   ├── hydration_wave_card.dart # Vitality water chamber with quick-log buttons
        │   ├── quest_objective_tile.dart# Holographic quest tile with electric checkmark
        │   ├── hunter_rank_badge.dart   # Dynamic E-Rank to S-Rank Monarch emblem
        │   ├── penalty_warning_banner.dart # Pulsating crimson penalty alert
        │   └── expedition_matrix.dart   # 122-Day 4-month animated grid matrix
        └── screens/
            ├── home_quest_screen.dart   # Main dashboard screen
            ├── quest_editor_modal.dart  # Modal to add/edit routine objectives
            └── smartwatch_sync_sheet.dart # Health sync bottom sheet
```

---

## ⚡ Getting Started (Running the App)

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run on Android / iOS Simulator / Real Device:**
   ```bash
   flutter run
   ```

3. **Connect to your live backend:**
   Open `lib/services/supabase_service.dart` and set `_baseUrl` to your hosted Vercel URL (e.g. `https://your-app.vercel.app`).
