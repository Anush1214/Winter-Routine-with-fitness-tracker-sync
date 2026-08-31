import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Category styling config for Winter Arc
export const CATEGORY_CONFIG: Record<
  string,
  { label: string; color: string; bg: string; border: string; glow: string; icon: string }
> = {
  routine: {
    label: "Routine",
    color: "text-sky-400",
    bg: "bg-sky-500/10",
    border: "border-sky-500/30",
    glow: "shadow-[0_0_12px_rgba(56,189,248,0.15)]",
    icon: "Clock",
  },
  fitness: {
    label: "Fitness",
    color: "text-emerald-400",
    bg: "bg-emerald-500/10",
    border: "border-emerald-500/30",
    glow: "shadow-[0_0_12px_rgba(16,185,129,0.15)]",
    icon: "Dumbbell",
  },
  career: {
    label: "Career",
    color: "text-violet-400",
    bg: "bg-violet-500/10",
    border: "border-violet-500/30",
    glow: "shadow-[0_0_12px_rgba(139,92,246,0.15)]",
    icon: "Briefcase",
  },
  health: {
    label: "Health",
    color: "text-cyan-400",
    bg: "bg-cyan-500/10",
    border: "border-cyan-500/30",
    glow: "shadow-[0_0_12px_rgba(6,182,212,0.15)]",
    icon: "HeartPulse",
  },
  study: {
    label: "Study",
    color: "text-amber-400",
    bg: "bg-amber-500/10",
    border: "border-amber-500/30",
    glow: "shadow-[0_0_12px_rgba(245,158,11,0.15)]",
    icon: "BookOpen",
  },
  custom: {
    label: "Custom",
    color: "text-pink-400",
    bg: "bg-pink-500/10",
    border: "border-pink-500/30",
    glow: "shadow-[0_0_12px_rgba(236,72,153,0.15)]",
    icon: "Sparkles",
  },
};

export function getCategoryStyle(category: string) {
  const normalized = category.toLowerCase().trim();
  return CATEGORY_CONFIG[normalized] || CATEGORY_CONFIG.custom;
}

// Format date as YYYY-MM-DD in local/UTC safely
export function formatDateKey(date: Date | string): string {
  const d = typeof date === "string" ? new Date(date) : date;
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export function parseDateKey(dateStr: string): Date {
  const [year, month, day] = dateStr.split("-").map(Number);
  return new Date(year, month - 1, day);
}

// Calculate days remaining until Dec 31
export function getWinterArcDaysRemaining(currentDate: Date = new Date()): {
  dayNumber: number;
  totalDays: number;
  daysRemaining: number;
  percentElapsed: number;
} {
  const year = currentDate.getFullYear();
  const start = new Date(year, 8, 1); // Sept 1
  const end = new Date(year, 11, 31, 23, 59, 59); // Dec 31
  const totalDays = 122;

  const diffTime = currentDate.getTime() - start.getTime();
  let dayNumber = Math.floor(diffTime / (1000 * 60 * 60 * 24)) + 1;
  if (dayNumber < 1) dayNumber = 1;
  if (dayNumber > totalDays) dayNumber = totalDays;

  const daysRemaining = Math.max(0, totalDays - dayNumber);
  const percentElapsed = Math.min(100, Math.max(0, Math.round((dayNumber / totalDays) * 100)));

  return { dayNumber, totalDays, daysRemaining, percentElapsed };
}

// Routine slot classification
export function getRoutineSlot(task: { startTime?: string | null; category?: string }): {
  slotId: "morning" | "daytime" | "evening" | "night";
  slotName: string;
  slotIcon: string;
  slotColor: string;
} {
  if (task.startTime) {
    const [hour] = task.startTime.split(":").map(Number);
    if (hour >= 4 && hour < 12) {
      return { slotId: "morning", slotName: "Morning Routine", slotIcon: "Sunrise", slotColor: "text-amber-400" };
    } else if (hour >= 12 && hour < 18) {
      return { slotId: "daytime", slotName: "Daytime & Habits", slotIcon: "Sun", slotColor: "text-sky-400" };
    } else if (hour >= 18 && hour < 22) {
      return { slotId: "evening", slotName: "Evening & Placement", slotIcon: "Sunset", slotColor: "text-violet-400" };
    } else {
      return { slotId: "night", slotName: "Night Protocol", slotIcon: "Moon", slotColor: "text-indigo-400" };
    }
  }

  // Fallback by category
  if (task.category === "routine" && !task.startTime) {
    return { slotId: "morning", slotName: "Morning Routine", slotIcon: "Sunrise", slotColor: "text-amber-400" };
  } else if (task.category === "career" || task.category === "study") {
    return { slotId: "evening", slotName: "Evening & Placement", slotIcon: "Sunset", slotColor: "text-violet-400" };
  } else if (task.category === "health" || task.category === "fitness") {
    return { slotId: "daytime", slotName: "Daytime & Habits", slotIcon: "Sun", slotColor: "text-sky-400" };
  }

  return { slotId: "daytime", slotName: "Daytime & Habits", slotIcon: "Sun", slotColor: "text-sky-400" };
}
