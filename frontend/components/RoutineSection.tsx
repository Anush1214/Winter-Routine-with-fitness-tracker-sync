"use client";

import React from "react";
import { TaskItem, TaskData } from "./TaskItem";
import { Sunrise, Sun, Sunset, Moon, Plus, Target, Sword, Sparkles } from "lucide-react";
import { getRoutineSlot } from "../lib/utils";

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
    title: "[ QUEST PART I : MORNING AWAKENING ]",
    timeSpan: "06:00 — 08:30",
    icon: Sunrise,
    color: "text-amber-400",
    border: "border-cyan-500/30",
  },
  {
    id: "daytime",
    title: "[ QUEST PART II : DAYTIME ATTRIBUTES & DISCIPLINE ]",
    timeSpan: "09:00 — 18:00",
    icon: Sun,
    color: "text-cyan-400",
    border: "border-cyan-500/30",
  },
  {
    id: "evening",
    title: "[ QUEST PART III : EVENING PLACEMENT & SKILL DUNGEON ]",
    timeSpan: "18:30 — 21:30",
    icon: Sword,
    color: "text-violet-400",
    border: "border-cyan-500/30",
  },
  {
    id: "night",
    title: "[ QUEST PART IV : NIGHT PROTOCOL & RECOVERY ]",
    timeSpan: "21:30 — 23:00",
    icon: Moon,
    color: "text-indigo-400",
    border: "border-cyan-500/30",
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
  const groupedTasks: Record<string, TaskData[]> = {
    morning: [],
    daytime: [],
    evening: [],
    night: [],
  };

  tasks.forEach((t) => {
    const titleLower = t.title.toLowerCase();
    if (
      titleLower.includes("wake up") ||
      titleLower.includes("gym") ||
      (titleLower.includes("sleep") && t.autoMetric === "sleep_7h")
    ) {
      groupedTasks.morning.push(t);
    } else if (
      titleLower.includes("office") ||
      titleLower.includes("water") ||
      titleLower.includes("hydration") ||
      titleLower.includes("10,000 steps") ||
      titleLower.includes("10k steps") ||
      titleLower.includes("study")
    ) {
      groupedTasks.daytime.push(t);
    } else if (
      titleLower.includes("fresh up") ||
      titleLower.includes("placement") ||
      titleLower.includes("japanese") ||
      titleLower.includes("dsa")
    ) {
      groupedTasks.evening.push(t);
    } else if (
      titleLower.includes("major project") ||
      titleLower.includes("night protocol") ||
      titleLower.includes("sleep by 11") ||
      titleLower.includes("sleep 11")
    ) {
      groupedTasks.night.push(t);
    } else {
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
            className={`system-window rounded-2xl p-4 sm:p-5 border ${sec.border} transition-all`}
          >
            {/* Section Header */}
            <div className="flex items-center justify-between gap-2 mb-3.5 pb-2.5 border-b border-cyan-500/20">
              <div className="flex items-center gap-2.5">
                <div className={`p-2 rounded-lg bg-slate-950 border border-cyan-500/30 ${sec.color}`}>
                  <IconComponent className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="text-sm sm:text-base font-black text-white font-mono tracking-wide glow-text-system">
                    {sec.title}
                  </h3>
                  <p className="text-[10px] font-mono text-cyan-400/80">
                    TIMEFRAME: {sec.timeSpan}
                  </p>
                </div>
              </div>

              {/* Progress Count Badge & Add Quest Button */}
              <div className="flex items-center gap-2">
                <span className="px-2.5 py-0.5 rounded text-xs font-mono font-black bg-slate-950 border border-cyan-500/40 text-cyan-300 shadow-[0_0_8px_rgba(0,240,255,0.2)]">
                  [{completedCount} / {totalCount} CLEARED]
                </span>

                <button
                  onClick={() => onAddTaskToSlot(sec.id)}
                  className="p-1.5 rounded-lg bg-slate-950 hover:bg-slate-900 text-cyan-300 hover:border-cyan-400 border border-cyan-500/30 transition-all"
                  title="Add Quest Objective"
                >
                  <Plus className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

            {/* Tasks List */}
            {sectionTasks.length === 0 ? (
              <div className="py-4 text-center text-xs font-mono text-slate-500 italic">
                [ NO QUEST OBJECTIVES ASSIGNED FOR THIS SLOT ]
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
