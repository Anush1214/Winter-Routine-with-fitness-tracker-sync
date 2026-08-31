"use client";

import React from "react";
import {
  Check,
  Clock,
  Dumbbell,
  Briefcase,
  HeartPulse,
  BookOpen,
  Zap,
  Moon,
  Trash2,
  Edit2,
  Droplets,
  Sparkles,
} from "lucide-react";
import { audio } from "../lib/audio";
import { getCategoryStyle } from "../lib/utils";

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

  const renderMetricChip = () => {
    if (!task.autoMetric && !task.title.toLowerCase().includes("4-5l water")) return null;

    if (task.autoMetric === "steps_10k") {
      const steps = healthMetrics?.steps || 0;
      const isMet = steps >= 10000;
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-mono font-bold ${
            isMet
              ? "bg-cyan-950 text-cyan-300 border border-cyan-400 shadow-[0_0_8px_rgba(0,240,255,0.4)]"
              : "bg-slate-900 text-slate-400 border border-slate-700"
          }`}
        >
          <Zap className={`w-3 h-3 ${isMet ? "text-cyan-400 fill-cyan-400" : "text-slate-400"}`} />
          <span>[ STR: {steps.toLocaleString()} / 10k ]</span>
        </span>
      );
    }

    if (task.autoMetric === "sleep_7h") {
      const mins = healthMetrics?.sleepMinutes || 0;
      const hours = (mins / 60).toFixed(1);
      const isMet = mins >= 420;
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-mono font-bold ${
            isMet
              ? "bg-violet-950 text-violet-300 border border-violet-400 shadow-[0_0_8px_rgba(139,92,246,0.4)]"
              : "bg-slate-900 text-slate-400 border border-slate-700"
          }`}
        >
          <Moon className={`w-3 h-3 ${isMet ? "text-violet-400" : "text-slate-400"}`} />
          <span>[ RECOVERY: {hours}h / 7h ]</span>
        </span>
      );
    }

    if (task.autoMetric === "gym_workout") {
      const done = Boolean(healthMetrics?.gymWorkoutDone);
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-mono font-bold ${
            done
              ? "bg-cyan-950 text-cyan-300 border border-cyan-400 shadow-[0_0_8px_rgba(0,240,255,0.4)]"
              : "bg-slate-900 text-slate-400 border border-slate-700"
          }`}
        >
          <Dumbbell className={`w-3 h-3 ${done ? "text-cyan-400" : "text-slate-400"}`} />
          <span>[ GYM: {done ? "CLEARED" : "PENDING"} ]</span>
        </span>
      );
    }

    if (task.title.toLowerCase().includes("4-5l water") || task.autoMetric === "water_4l") {
      const water = healthMetrics?.waterIntakeMl || 0;
      const isMet = water >= 4000;
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-mono font-bold ${
            isMet
              ? "bg-cyan-950 text-cyan-300 border border-cyan-400 shadow-[0_0_8px_rgba(0,240,255,0.4)]"
              : "bg-slate-900 text-slate-400 border border-slate-700"
          }`}
        >
          <Droplets className={`w-3 h-3 ${isMet ? "text-cyan-400" : "text-slate-400"}`} />
          <span>[ VIT: {water} / 4,500ml ]</span>
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
          ? "bg-slate-950/40 border-cyan-500/20 opacity-70"
          : "system-window-interactive bg-slate-950/90 border-cyan-500/30 hover:border-cyan-400"
      }`}
    >
      {/* Left: Custom Checkbox + Task Title */}
      <div className="flex items-center gap-3 min-w-0 flex-1">
        {/* Solo Leveling Holographic Checkbox */}
        <button
          type="button"
          onClick={handleCheckboxClick}
          className={`flex-shrink-0 w-6 h-6 rounded-md flex items-center justify-center border transition-all ${
            task.isCompleted
              ? "bg-gradient-to-br from-cyan-500 to-blue-600 border-cyan-300 text-slate-950 shadow-[0_0_12px_rgba(0,240,255,0.7)] scale-105"
              : "bg-slate-950 border-cyan-500/40 hover:border-cyan-400 hover:shadow-[0_0_8px_rgba(0,240,255,0.3)]"
          }`}
        >
          {task.isCompleted && <Check className="w-4 h-4 stroke-[3.5]" />}
        </button>

        {/* Title & metadata */}
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2 flex-wrap">
            <span
              className={`text-sm sm:text-base font-semibold truncate transition-all font-['Outfit'] ${
                task.isCompleted
                  ? "line-through text-slate-500 decoration-cyan-500/50 decoration-2"
                  : "text-white glow-text-system"
              }`}
            >
              {task.title}
            </span>

            {renderMetricChip()}
          </div>

          <div className="flex items-center gap-2 mt-1 text-[11px] font-mono">
            {/* Category tag */}
            <span className="text-cyan-400/90 font-bold uppercase tracking-wider">
              [{task.category.toUpperCase()}]
            </span>

            {/* Time badge */}
            {task.startTime && (
              <span className="flex items-center gap-1 text-slate-300 bg-slate-900/80 px-1.5 py-0.5 rounded border border-cyan-500/20">
                <Clock className="w-3 h-3 text-cyan-400" />
                <span>{task.startTime}</span>
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Right: Actions */}
      <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
        <button
          onClick={(e) => {
            e.stopPropagation();
            onEdit(task);
          }}
          className="p-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-400 hover:text-cyan-300 border border-slate-700 transition-colors"
          title="Edit Quest Objective"
        >
          <Edit2 className="w-3.5 h-3.5" />
        </button>
        <button
          onClick={(e) => {
            e.stopPropagation();
            onDelete(task.id, task.title);
          }}
          className="p-1.5 rounded-lg bg-slate-900 hover:bg-red-950 text-slate-400 hover:text-red-400 border border-slate-700 transition-colors"
          title="Delete Quest Objective"
        >
          <Trash2 className="w-3.5 h-3.5" />
        </button>
      </div>
    </div>
  );
};
