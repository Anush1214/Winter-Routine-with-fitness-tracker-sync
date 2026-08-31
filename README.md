# ❄️ WINTER ARC 2026 // 4-Month Personal Productivity Protocol

> Strict 4-Month Daily Transformation PWA (September 1 to December 31) with Smartwatch Health Auto-Sync, Dynamic Routine Management, and Zero-Cost Native Mobile Push Notifications powered 24/7 by Supabase PostgreSQL.

---

## 📁 Project Architecture & Clean Folder Separation

The project is cleanly separated into `frontend` and `backend`:

```
├── frontend/                     # Client Components, UI, Audio Synthesizer, Utilities & Styles
│   ├── components/               # Header, DateCarousel, DailyProgressCard, RoutineSection, 
│   │                             # TaskItem, HabitCounters, ConsistencyHeatmap, TaskModal,
│   │                             # NotificationSettingsModal, SmartwatchSyncModal
│   ├── lib/
│   │   ├── audio.ts              # Web Audio API synthesized sounds (clicks, water, fanfare)
│   │   └── utils.ts              # Timeline, categories, date helpers
│   └── styles/
│       └── globals.css           # Winter Arc cyber-frost theme & neon glow styling
│
├── backend/                      # Services, Prisma Database, Smartwatch Sync, Automations
│   ├── prisma/
│   │   ├── schema.prisma         # Supabase PostgreSQL models (Task, HealthLog, UserSettings)
│   │   └── seed.ts               # Seeding script for all 122 days (Sept 1 - Dec 31)
│   ├── services/
│   │   ├── tasksService.ts       # Task CRUD & scope propagation engine
│   │   ├── healthSyncService.ts  # Smartwatch auto-metric ingest & auto-checking
│   │   ├── waterService.ts       # Hydration tracking & 4L auto-check
│   │   ├── notificationService.ts# Dynamic push notification compiler
│   │   ├── settingsService.ts    # User notification schedules & goal preferences
│   │   └── statsService.ts       # 4-month heatmap & streak statistics
│   ├── lib/
│   │   ├── prisma.ts             # Resilient Prisma client with Supabase pooling & local fallback
│   │   └── notifications.ts      # ntfy.sh REST API Markdown push client
│   └── automation/
│       ├── daily-alerts.yml      # GitHub Actions scheduled workflow (01:30, 13:00, 17:00 UTC)
│       └── smartwatch-shortcuts.json # Apple Health & Tasker setup payload
│
├── public/                       # PWA Manifest, Service Worker & Icons
├── src/app/api/                  # Next.js App Router API endpoints linking to backend/services
└── .env.example                  # Environment template for Supabase, ntfy & cron secrets
```

---

## ⚡ Quick Start (Local Development)

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Generate Prisma Client:**
   ```bash
   npm run prisma:generate
   ```

3. **Start the Next.js development server:**
   ```bash
   npm run dev
   ```
   Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🗄️ Database Setup with Supabase (Free Tier PostgreSQL)

1. Create a free project on [Supabase](https://supabase.com).
2. Go to **Project Settings** > **Database** > **Connection Pooling**.
3. Copy the **Transaction Mode (port 6543)** string to `DATABASE_URL` in `.env.local`.
4. Copy the **Session/Direct Mode (port 5432)** string to `DIRECT_URL` in `.env.local`.
5. Push the schema and seed all 122 days:
   ```bash
   npm run prisma:push
   npm run prisma:seed
   ```

---

## 📱 Mobile Push Notifications (ntfy.sh - 100% Free)

1. Install the free **ntfy app** from the App Store (iOS) or Play Store (Android).
2. Open the **Alerts Hub** inside the Winter Arc app.
3. Set your private topic name (e.g., `winter-arc-yourname`).
4. Click the link or scan the QR code to subscribe on your phone in 1 click!
5. Test your notifications instantly using the **Send Test Alert** button in the app.

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

- **Steps >= 10,000** automatically marks `10k steps` task as complete.
- **Sleep >= 420 mins (7 hrs)** automatically marks `7-8hr Sleep` task as complete.
- **Gym Workout Done = true** automatically marks `From sept 5th gym 6-7` task as complete.
- **Water >= 4000ml** automatically marks `4-5l water` task as complete.

---

## ⏰ Automated Cron Alerts (GitHub Actions)

Scheduled in `.github/workflows/daily-alerts.yml` at:
- `30 1 * * *` (07:00 AM IST) -> Morning Briefing
- `0 13 * * *` (06:30 PM IST) -> Evening DSA & Placement Prep Shift
- `0 17 * * *` (10:30 PM IST) -> Nightly Wrap-up & Sleep 11 PM Prep

Add `CRON_SECRET` and `NEXT_PUBLIC_APP_URL` to your GitHub Repository Secrets.
