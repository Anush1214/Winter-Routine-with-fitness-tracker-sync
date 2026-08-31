"use client";

import React from "react";
import {
  Check,
  Clock,
  Dumbbell,
  Briefcase,
  HeartPulse,
  BookOpen,
  Sparkles,
  Zap,
  Moon,
  Trash2,
  Edit2,
  Droplets,
} from "lucide-react";
import { audio } from "@/lib/audio";
import { getCategoryStyle } from "@/lib/utils";

export interface TaskData {
  id: string;
  title: string;
  category: string;
  targetDate: string;
  startTime: string | null;
  isCompleted: boolean;
  autoMetric: string | null;
  createdAt?: string;
}

interface TaskItemProps {
  task: TaskData;
  onToggle: (id: string, current: boolean) => void;
  onEdit: (task: TaskData) => void;
  onDelete: (id: string, title: string) => void;
  healthMetrics?: {
    steps: number;
    sleepMinutes: number;
    waterIntakeMl: number;
    gymWorkoutDone: boolean;
  };
}

export const TaskItem: React.FC<TaskItemProps> = ({
  task,
  onToggle,
  onEdit,
  onDelete,
  healthMetrics,
}) => {
  const catStyle = getCategoryStyle(task.category);

  const handleCheckboxClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!task.isCompleted) {
      audio.playChime();
    } else {
      audio.playClick();
    }
    onToggle(task.id, task.isCompleted);
  };

  // Render Category Icon
  const renderCategoryIcon = () => {
    switch (task.category.toLowerCase()) {
      case "fitness":
        return <Dumbbell className="w-3.5 h-3.5" />;
      case "career":
        return <Briefcase className="w-3.5 h-3.5" />;
      case "health":
        return <HeartPulse className="w-3.5 h-3.5" />;
      case "study":
        return <BookOpen className="w-3.5 h-3.5" />;
      default:
        return <Clock className="w-3.5 h-3.5" />;
    }
  };

  // Render Auto-Metric sync status chip
  const renderMetricChip = () => {
    if (!task.autoMetric && !task.title.toLowerCase().includes("4-5l water")) return null;

    if (task.autoMetric === "steps_10k") {
      const steps = healthMetrics?.steps || 0;
      const isMet = steps >= 10000;
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-mono font-bold ${
            isMet
              ? "bg-emerald-950/80 text-emerald-300 border border-emerald-500/40"
              : "bg-slate-800/80 text-slate-400 border border-slate-700"
          }`}
          title="Auto-synced from CMF Watch / Apple Health"
        >
          <Zap className={`w-3 h-3 ${isMet ? "text-emerald-400 fill-emerald-400" : "text-slate-400"}`} />
          <span>{steps.toLocaleString()} / 10k</span>
        </span>
      );
    }

    if (task.autoMetric === "sleep_7h") {
      const mins = healthMetrics?.sleepMinutes || 0;
      const hours = (mins / 60).toFixed(1);
      const isMet = mins >= 420;
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-mono font-bold ${
            isMet
              ? "bg-indigo-950/80 text-indigo-300 border border-indigo-500/40"
              : "bg-slate-800/80 text-slate-400 border border-slate-700"
          }`}
          title="Auto-synced from Smartwatch Sleep Tracker"
        >
          <Moon className={`w-3 h-3 ${isMet ? "text-indigo-400" : "text-slate-400"}`} />
          <span>{hours}h / 7h</span>
        </span>
      );
    }

    if (task.autoMetric === "gym_workout") {
      const done = Boolean(healthMetrics?.gymWorkoutDone);
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-mono font-bold ${
            done
              ? "bg-emerald-950/80 text-emerald-300 border border-emerald-500/40"
              : "bg-slate-800/80 text-slate-400 border border-slate-700"
          }`}
        >
          <Dumbbell className={`w-3 h-3 ${done ? "text-emerald-400" : "text-slate-400"}`} />
          <span>{done ? "Workout Synced" : "Pending Log"}</span>
        </span>
      );
    }

    if (task.title.toLowerCase().includes("4-5l water") || task.autoMetric === "water_4l") {
      const water = healthMetrics?.waterIntakeMl || 0;
      const isMet = water >= 4000;
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-mono font-bold ${
            isMet
              ? "bg-cyan-950/80 text-cyan-300 border border-cyan-500/40"
              : "bg-slate-800/80 text-slate-400 border border-slate-700"
          }`}
        >
          <Droplets className={`w-3 h-3 ${isMet ? "text-cyan-400" : "text-slate-400"}`} />
          <span>{water} / 4.5L</span>
        </span>
      );
    }

    return null;
  };

  return (
    <div
      onClick={() => onToggle(task.id, task.isCompleted)}
      className={`group relative flex items-center justify-between gap-3 p-3 sm:p-3.5 rounded-xl border cursor-pointer transition-all duration-200 ${
        task.isCompleted
          ? "bg-slate-900/40 border-slate-800/60 opacity-80"
          : "bg-slate-900/80 border-slate-800/90 hover:border-slate-700 hover:bg-slate-850 hover:shadow-md"
      }`}
    >
      {/* Left: Custom Checkbox + Task Title */}
      <div className="flex items-center gap-3 min-w-0 flex-1">
        {/* Custom Animated Checkbox */}
        <button
          type="button"
          onClick={handleCheckboxClick}
          className={`flex-shrink-0 w-6 h-6 rounded-lg flex items-center justify-center border transition-all ${
            task.isCompleted
              ? "bg-gradient-to-br from-emerald-500 to-cyan-500 border-emerald-400 text-slate-950 shadow-[0_0_12px_rgba(16,185,129,0.5)] scale-105"
              : "bg-slate-950 border-slate-700 hover:border-cyan-400"
          }`}
        >
          {task.isCompleted && <Check className="w-4 h-4 stroke-[3.5]" />}
        </button>

        {/* Title & metadata */}
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2 flex-wrap">
            <span
              className={`text-sm sm:text-base font-medium truncate transition-all ${
                task.isCompleted
                  ? "line-through text-slate-500 decoration-slate-600 decoration-2"
                  : "text-slate-100 font-semibold"
              }`}
            >
              {task.title}
            </span>

            {/* Auto metric badge */}
            {renderMetricChip()}
          </div>

          <div className="flex items-center gap-2 mt-1 text-[11px] text-slate-400">
            {/* Category tag */}
            <span
              className={`inline-flex items-center gap-1 px-1.5 py-0.5 rounded text-[10px] font-semibold uppercase tracking-wider ${catStyle.bg} ${catStyle.color} ${catStyle.border} border`}
            >
              {renderCategoryIcon()}
              <span>{task.category}</span>
            </span>

            {/* Time badge */}
            {task.startTime && (
              <span className="flex items-center gap-1 font-mono text-slate-400 bg-slate-800/60 px-1.5 py-0.5 rounded border border-slate-700/50">
                <Clock className="w-3 h-3 text-slate-400" />
                <span>{task.startTime}</span>
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Right: Actions (Edit / Delete) */}
      <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
        <button
          onClick={(e) => {
            e.stopPropagation();
            onEdit(task);
          }}
          className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-slate-700 text-slate-400 hover:text-cyan-300 transition-colors"
          title="Edit Routine Item"
        >
          <Edit2 className="w-3.5 h-3.5" />
        </button>
        <button
          onClick={(e) => {
            e.stopPropagation();
            onDelete(task.id, task.title);
          }}
          className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-red-950/80 text-slate-400 hover:text-red-400 transition-colors"
          title="Delete Routine Item"
        >
          <Trash2 className="w-3.5 h-3.5" />
        </button>
      </div>
    </div>
  );
};
