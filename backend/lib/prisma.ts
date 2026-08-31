import { PrismaClient } from "@prisma/client";

declare global {
  // eslint-disable-next-line no-var
  var prisma: PrismaClient | undefined;
}

export interface InMemoryTask {
  id: string;
  title: string;
  category: string;
  targetDate: string; // YYYY-MM-DD
  startTime: string | null;
  isCompleted: boolean;
  autoMetric: string | null;
  createdAt: string;
}

export interface InMemoryHealthLog {
  logDate: string; // YYYY-MM-DD
  steps: number;
  sleepMinutes: number;
  waterIntakeMl: number;
  gymWorkoutDone: boolean;
  syncedAt: string;
}

export interface InMemoryUserSettings {
  id: string;
  ntfyTopic: string;
  ntfyServer: string;
  morningTime: string;
  morningEnabled: boolean;
  eveningTime: string;
  eveningEnabled: boolean;
  nightTime: string;
  nightEnabled: boolean;
  waterGoalMl: number;
  stepsGoal: number;
  sleepGoalMinutes: number;
  customSlots: string | null;
  updatedAt: string;
}

const BASE_DAILY_TASKS = [
  { title: "Wake Up & Morning Protocol", category: "routine", startTime: "07:00", autoMetric: null },
  { title: "Hydration Goal: 4-5L Water", category: "health", startTime: null, autoMetric: "water_4l" },
  { title: "Sleep Recovery: 7-8 Hours", category: "health", startTime: null, autoMetric: "sleep_7h" },
  { title: "Daily Movement: 10,000 Steps", category: "fitness", startTime: null, autoMetric: "steps_10k" },
  { title: "Office Work Shift", category: "routine", startTime: "09:00", autoMetric: null },
  { title: "Self-Study & Revision (If Time Permits)", category: "study", startTime: null, autoMetric: null },
  { title: "Evening Fresh Up & Transition", category: "routine", startTime: "18:30", autoMetric: null },
  { title: "DSA & Placement Preparation Shift", category: "career", startTime: "19:00", autoMetric: null },
  { title: "DSA Practice & Japanese Language", category: "career", startTime: null, autoMetric: null },
  { title: "Major Project Development", category: "career", startTime: null, autoMetric: null },
  { title: "Night Protocol & Sleep by 11:00 PM", category: "routine", startTime: "23:00", autoMetric: null },
];

const GYM_TASK = {
  title: "Gym Workout Session (06:00 - 07:00)",
  category: "fitness",
  startTime: "06:00",
  autoMetric: "gym_workout",
};

class LocalDataStore {
  private tasks: Map<string, InMemoryTask> = new Map();
  private healthLogs: Map<string, InMemoryHealthLog> = new Map();
  private settings: InMemoryUserSettings = {
    id: "default",
    ntfyTopic: "winter-arc-routine",
    ntfyServer: "https://ntfy.sh",
    morningTime: "07:00",
    morningEnabled: true,
    eveningTime: "18:30",
    eveningEnabled: true,
    nightTime: "22:30",
    nightEnabled: true,
    waterGoalMl: 4500,
    stepsGoal: 10000,
    sleepGoalMinutes: 420,
    customSlots: JSON.stringify([
      { id: "midday_sync", name: "Midday Hydration & Step Check", time: "13:30", enabled: true }
    ]),
    updatedAt: new Date().toISOString(),
  };

  private initialized = false;

  public init() {
    if (this.initialized) return;
    this.initialized = true;

    const year = new Date().getFullYear();
    const startDate = new Date(Date.UTC(year, 8, 1)); // Sept 1
    const endDate = new Date(Date.UTC(year, 11, 31)); // Dec 31
    const gymStartDate = new Date(Date.UTC(year, 8, 5)); // Sept 5

    const current = new Date(startDate);
    while (current <= endDate) {
      const dateKey = current.toISOString().split("T")[0];

      BASE_DAILY_TASKS.forEach((t, index) => {
        const id = `${dateKey}-task-${index}`;
        this.tasks.set(id, {
          id,
          title: t.title,
          category: t.category,
          targetDate: dateKey,
          startTime: t.startTime,
          isCompleted: false,
          autoMetric: t.autoMetric,
          createdAt: new Date().toISOString(),
        });
      });

      if (current >= gymStartDate) {
        const gymId = `${dateKey}-task-gym`;
        this.tasks.set(gymId, {
          id: gymId,
          title: GYM_TASK.title,
          category: GYM_TASK.category,
          targetDate: dateKey,
          startTime: GYM_TASK.startTime,
          isCompleted: false,
          autoMetric: GYM_TASK.autoMetric,
          createdAt: new Date().toISOString(),
        });
      }

      this.healthLogs.set(dateKey, {
        logDate: dateKey,
        steps: 0,
        sleepMinutes: 0,
        waterIntakeMl: 0,
        gymWorkoutDone: false,
        syncedAt: new Date().toISOString(),
      });

      current.setUTCDate(current.getUTCDate() + 1);
    }
  }

  public getTasksByDate(dateKey: string): InMemoryTask[] {
    this.init();
    return Array.from(this.tasks.values()).filter((t) => t.targetDate === dateKey);
  }

  public getAllTasks(): InMemoryTask[] {
    this.init();
    return Array.from(this.tasks.values());
  }

  public getTaskById(id: string): InMemoryTask | undefined {
    this.init();
    return this.tasks.get(id);
  }

  public createTask(data: Omit<InMemoryTask, "id" | "createdAt">): InMemoryTask {
    this.init();
    const id = `task-${Date.now()}-${Math.random().toString(36).substring(2, 6)}`;
    const task: InMemoryTask = {
      ...data,
      id,
      createdAt: new Date().toISOString(),
    };
    this.tasks.set(id, task);
    return task;
  }

  public updateTask(id: string, updates: Partial<InMemoryTask>): InMemoryTask | null {
    this.init();
    const existing = this.tasks.get(id);
    if (!existing) return null;
    const updated = { ...existing, ...updates };
    this.tasks.set(id, updated);
    return updated;
  }

  public deleteTask(id: string): boolean {
    this.init();
    return this.tasks.delete(id);
  }

  public deleteTasksByTitle(title: string, fromDate?: string): number {
    this.init();
    let count = 0;
    this.tasks.forEach((task, id) => {
      if (task.title.toLowerCase() === title.toLowerCase()) {
        if (!fromDate || task.targetDate >= fromDate) {
          this.tasks.delete(id);
          count++;
        }
      }
    });
    return count;
  }

  public getHealthLog(dateKey: string): InMemoryHealthLog {
    this.init();
    let log = this.healthLogs.get(dateKey);
    if (!log) {
      log = {
        logDate: dateKey,
        steps: 0,
        sleepMinutes: 0,
        waterIntakeMl: 0,
        gymWorkoutDone: false,
        syncedAt: new Date().toISOString(),
      };
      this.healthLogs.set(dateKey, log);
    }
    return log;
  }

  public getAllHealthLogs(): InMemoryHealthLog[] {
    this.init();
    return Array.from(this.healthLogs.values());
  }

  public upsertHealthLog(dateKey: string, updates: Partial<InMemoryHealthLog>): InMemoryHealthLog {
    this.init();
    const existing = this.getHealthLog(dateKey);
    const updated = {
      ...existing,
      ...updates,
      syncedAt: new Date().toISOString(),
    };
    this.healthLogs.set(dateKey, updated);
    return updated;
  }

  public getSettings(): InMemoryUserSettings {
    return this.settings;
  }

  public updateSettings(updates: Partial<InMemoryUserSettings>): InMemoryUserSettings {
    this.settings = {
      ...this.settings,
      ...updates,
      updatedAt: new Date().toISOString(),
    };
    return this.settings;
  }
}

export const localStore = new LocalDataStore();

const hasDbUrl = Boolean(
  process.env.DATABASE_URL &&
  !process.env.DATABASE_URL.includes("placeholder") &&
  (process.env.DATABASE_URL.startsWith("postgresql://") || process.env.DATABASE_URL.startsWith("postgres://"))
);

export const prisma: PrismaClient | null = hasDbUrl
  ? global.prisma || new PrismaClient({ log: ["error"] })
  : null;

if (process.env.NODE_ENV !== "production" && prisma) {
  global.prisma = prisma;
}

export const isDbConnected = Boolean(prisma);
