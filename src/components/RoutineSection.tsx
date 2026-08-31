"use client";

import React from "react";
import { TaskItem, TaskData } from "./TaskItem";
import { Sunrise, Sun, Sunset, Moon, Plus } from "lucide-react";
import { getRoutineSlot } from "@/lib/utils";

interface RoutineSectionProps {
  tasks: TaskData[];
  onToggle: (id: string, current: boolean) => void;
  onEdit: (task: TaskData) => void;
  onDelete: (id: string, title: string) => void;
  onAddTaskToSlot: (slotId: string) => void;
  healthMetrics?: {
    steps: number;
    sleepMinutes: number;
    waterIntakeMl: number;
    gymWorkoutDone: boolean;
  };
}

const SECTIONS = [
  {
    id: "morning",
    title: "Morning Routine",
    timeSpan: "06:00 — 08:30",
    icon: Sunrise,
    color: "text-amber-400",
    border: "border-amber-500/20",
    glow: "shadow-[0_0_15px_rgba(245,158,11,0.06)]",
  },
  {
    id: "daytime",
    title: "Daytime & Habits",
    timeSpan: "09:00 — 18:00",
    icon: Sun,
    color: "text-sky-400",
    border: "border-sky-500/20",
    glow: "shadow-[0_0_15px_rgba(56,189,248,0.06)]",
  },
  {
    id: "evening",
    title: "Evening & Placement Shift",
    timeSpan: "18:30 — 21:30",
    icon: Sunset,
    color: "text-violet-400",
    border: "border-violet-500/20",
    glow: "shadow-[0_0_15px_rgba(139,92,246,0.06)]",
  },
  {
    id: "night",
    title: "Night Routine & Wrap-up",
    timeSpan: "21:30 — 23:00",
    icon: Moon,
    color: "text-indigo-400",
    border: "border-indigo-500/20",
    glow: "shadow-[0_0_15px_rgba(99,102,241,0.06)]",
  },
];

export const RoutineSection: React.FC<RoutineSectionProps> = ({
  tasks,
  onToggle,
  onEdit,
  onDelete,
  onAddTaskToSlot,
  healthMetrics,
}) => {
  // Group tasks into the 4 sections
  const groupedTasks: Record<string, TaskData[]> = {
    morning: [],
    daytime: [],
    evening: [],
    night: [],
  };

  tasks.forEach((t) => {
    // Specific custom rules matching user requirements
    const titleLower = t.title.toLowerCase();
    if (
      titleLower.includes("wake up") ||
      titleLower.includes("gym") ||
      titleLower.includes("sleep") && t.autoMetric === "sleep_7h"
    ) {
      groupedTasks.morning.push(t);
    } else if (
      titleLower.includes("office") ||
      titleLower.includes("water") ||
      titleLower.includes("10k steps") ||
      titleLower.includes("study")
    ) {
      groupedTasks.daytime.push(t);
    } else if (
      titleLower.includes("fresh up") ||
      titleLower.includes("placement") ||
      titleLower.includes("japanese")
    ) {
      groupedTasks.evening.push(t);
    } else if (
      titleLower.includes("major project") ||
      titleLower.includes("sleep 11")
    ) {
      groupedTasks.night.push(t);
    } else {
      // Fallback by generic slot decider
      const slot = getRoutineSlot(t);
      groupedTasks[slot.slotId].push(t);
    }
  });

  return (
    <div className="space-y-6 mb-8">
      {SECTIONS.map((sec) => {
        const sectionTasks = groupedTasks[sec.id] || [];
        const completedCount = sectionTasks.filter((t) => t.isCompleted).length;
        const totalCount = sectionTasks.length;
        const IconComponent = sec.icon;

        return (
          <div
            key={sec.id}
            className={`glass-panel rounded-2xl p-4 sm:p-5 border ${sec.border} ${sec.glow} transition-all`}
          >
            {/* Section Header */}
            <div className="flex items-center justify-between gap-2 mb-3.5 pb-2.5 border-b border-slate-800/80">
              <div className="flex items-center gap-2.5">
                <div className={`p-2 rounded-xl bg-slate-900 border border-slate-800 ${sec.color}`}>
                  <IconComponent className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-base sm:text-lg font-bold text-white font-['Outfit']">
                    {sec.title}
                  </h3>
                  <p className="text-[11px] font-mono text-slate-400">
                    {sec.timeSpan}
                  </p>
                </div>
              </div>

              {/* Counter badge & Add Task button */}
              <div className="flex items-center gap-2">
                <span className="px-2 py-0.5 rounded-full text-xs font-mono font-bold bg-slate-900 border border-slate-800 text-slate-300">
                  {completedCount}/{totalCount}
                </span>

                <button
                  onClick={() => onAddTaskToSlot(sec.id)}
                  className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-slate-700 text-slate-300 hover:text-cyan-300 border border-slate-700 transition-colors"
                  title={`Add Task to ${sec.title}`}
                >
                  <Plus className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

            {/* Tasks List */}
            {sectionTasks.length === 0 ? (
              <div className="py-4 text-center text-xs text-slate-500 italic">
                No items configured in this slot. Click + to add one.
              </div>
            ) : (
              <div className="space-y-2">
                {sectionTasks.map((t) => (
                  <TaskItem
                    key={t.id}
                    task={t}
                    onToggle={onToggle}
                    onEdit={onEdit}
                    onDelete={onDelete}
                    healthMetrics={healthMetrics}
                  />
                ))}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
};
