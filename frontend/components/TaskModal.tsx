"use client";

import React, { useState, useEffect } from "react";
import { X, Plus, Edit2, AlertCircle, Sparkles } from "lucide-react";
import { TaskData } from "./TaskItem";

interface TaskModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (taskData: {
    id?: string;
    title: string;
    category: string;
    startTime: string | null;
    autoMetric: string | null;
    applyScope: "today" | "future" | "all";
  }) => Promise<void>;
  initialTask?: TaskData | null;
  selectedDate: string;
  defaultSlotId?: string;
}

const CATEGORIES = [
  { id: "routine", label: "Routine" },
  { id: "fitness", label: "Fitness" },
  { id: "career", label: "Career & Placement" },
  { id: "health", label: "Health & Vitality" },
  { id: "study", label: "Study" },
  { id: "custom", label: "Custom Skill" },
];

const AUTO_METRICS = [
  { id: "none", label: "[ Manual Clear Only ]" },
  { id: "steps_10k", label: "[ STR: 10k Steps Automatic Link ]" },
  { id: "sleep_7h", label: "[ RECOVERY: 7h Sleep Automatic Link ]" },
  { id: "gym_workout", label: "[ GYM: Workout Automatic Link ]" },
  { id: "water_4l", label: "[ VIT: 4L+ Hydration Automatic Link ]" },
];

export const TaskModal: React.FC<TaskModalProps> = ({
  isOpen,
  onClose,
  onSave,
  initialTask,
  selectedDate,
  defaultSlotId,
}) => {
  const [title, setTitle] = useState("");
  const [category, setCategory] = useState("routine");
  const [startTime, setStartTime] = useState("");
  const [autoMetric, setAutoMetric] = useState("none");
  const [applyScope, setApplyScope] = useState<"today" | "future" | "all">("today");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (initialTask) {
      setTitle(initialTask.title);
      setCategory(initialTask.category || "routine");
      setStartTime(initialTask.startTime || "");
      setAutoMetric(initialTask.autoMetric || "none");
      setApplyScope("today");
    } else {
      setTitle("");
      if (defaultSlotId === "morning") {
        setCategory("routine");
        setStartTime("07:00");
      } else if (defaultSlotId === "daytime") {
        setCategory("health");
        setStartTime("13:00");
      } else if (defaultSlotId === "evening") {
        setCategory("career");
        setStartTime("19:00");
      } else if (defaultSlotId === "night") {
        setCategory("routine");
        setStartTime("22:30");
      } else {
        setCategory("routine");
        setStartTime("");
      }
      setAutoMetric("none");
      setApplyScope("today");
    }
    setError(null);
  }, [initialTask, isOpen, defaultSlotId]);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      setError("Task title is required");
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      await onSave({
        id: initialTask?.id,
        title: title.trim(),
        category,
        startTime: startTime ? startTime : null,
        autoMetric: autoMetric === "none" ? null : autoMetric,
        applyScope,
      });
      onClose();
    } catch (err: any) {
      setError(err.message || "Failed to save quest");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md animate-fadeIn">
      <div className="w-full max-w-lg system-window rounded-2xl p-5 sm:p-6 border border-cyan-500/50 shadow-2xl bg-slate-950/95 relative max-h-[90vh] overflow-y-auto">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-400 hover:text-white transition-colors"
        >
          <X className="w-4 h-4" />
        </button>

        <div className="flex items-center gap-2.5 mb-5 pb-3 border-b border-cyan-500/20">
          <div className="p-2 rounded-lg bg-cyan-950 border border-cyan-500/40 text-cyan-400">
            {initialTask ? <Edit2 className="w-4 h-4" /> : <Plus className="w-4 h-4" />}
          </div>
          <div>
            <h3 className="text-base sm:text-lg font-black text-white font-mono uppercase tracking-wide glow-text-system">
              {initialTask ? "[ MODIFY QUEST OBJECTIVE ]" : "[ REGISTER NEW QUEST OBJECTIVE ]"}
            </h3>
            <p className="text-xs text-cyan-400 font-mono">TARGET DATE: {selectedDate}</p>
          </div>
        </div>

        {error && (
          <div className="mb-4 p-3 rounded-lg bg-red-950/80 border border-red-500/40 text-red-300 text-xs font-mono flex items-center gap-2">
            <AlertCircle className="w-4 h-4 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-black uppercase font-mono tracking-wider text-cyan-400 mb-1.5">
              QUEST TITLE / OBJECTIVE
            </label>
            <input
              type="text"
              required
              placeholder="e.g. 7 sit and do dsa and prepare for placement"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full bg-slate-950 border border-cyan-500/30 focus:border-cyan-400 rounded-lg px-3.5 py-2.5 text-sm text-white placeholder:text-slate-600 focus:outline-none transition-colors font-mono"
            />
          </div>

          <div>
            <label className="block text-xs font-black uppercase font-mono tracking-wider text-cyan-400 mb-1.5">
              CATEGORY / ATTRIBUTE
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
              {CATEGORIES.map((cat) => (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => setCategory(cat.id)}
                  className={`p-2 rounded-lg text-xs font-bold font-mono border transition-all text-left flex items-center justify-between ${
                    category === cat.id
                      ? "bg-cyan-950 border-cyan-400 text-cyan-300 shadow-[0_0_10px_rgba(0,240,255,0.4)]"
                      : "bg-slate-950 border-slate-800 text-slate-400 hover:border-slate-700"
                  }`}
                >
                  <span>[{cat.label}]</span>
                  {category === cat.id && <div className="w-1.5 h-1.5 rounded-full bg-cyan-400" />}
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-black uppercase font-mono tracking-wider text-cyan-400 mb-1.5">
                TIMEFRAME (OPTIONAL)
              </label>
              <input
                type="time"
                value={startTime}
                onChange={(e) => setStartTime(e.target.value)}
                className="w-full bg-slate-950 border border-cyan-500/30 focus:border-cyan-400 rounded-lg px-3.5 py-2 text-sm text-white font-mono focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-black uppercase font-mono tracking-wider text-cyan-400 mb-1.5">
                SMARTWATCH AUTO-BINDING
              </label>
              <select
                value={autoMetric}
                onChange={(e) => setAutoMetric(e.target.value)}
                className="w-full bg-slate-950 border border-cyan-500/30 focus:border-cyan-400 rounded-lg px-3 py-2 text-xs text-white font-mono focus:outline-none"
              >
                {AUTO_METRICS.map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-black uppercase font-mono tracking-wider text-cyan-400 mb-1.5">
              PROPAGATION SCOPE
            </label>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-2 font-mono">
              <button
                type="button"
                onClick={() => setApplyScope("today")}
                className={`p-2.5 rounded-lg text-xs font-bold border transition-all text-center ${
                  applyScope === "today"
                    ? "bg-cyan-950 border-cyan-400 text-cyan-300 shadow-[0_0_8px_rgba(0,240,255,0.3)]"
                    : "bg-slate-950 border-slate-800 text-slate-400"
                }`}
              >
                [ TODAY ONLY ]
              </button>
              <button
                type="button"
                onClick={() => setApplyScope("future")}
                className={`p-2.5 rounded-lg text-xs font-bold border transition-all text-center ${
                  applyScope === "future"
                    ? "bg-cyan-950 border-cyan-400 text-cyan-300 shadow-[0_0_8px_rgba(0,240,255,0.3)]"
                    : "bg-slate-950 border-slate-800 text-slate-400"
                }`}
              >
                [ FORWARD TILL DEC 31 ]
              </button>
              <button
                type="button"
                onClick={() => setApplyScope("all")}
                className={`p-2.5 rounded-lg text-xs font-bold border transition-all text-center ${
                  applyScope === "all"
                    ? "bg-cyan-950 border-cyan-400 text-cyan-300 shadow-[0_0_8px_rgba(0,240,255,0.3)]"
                    : "bg-slate-950 border-slate-800 text-slate-400"
                }`}
              >
                [ ALL 122 DAYS ]
              </button>
            </div>
          </div>

          <div className="flex items-center justify-end gap-2 pt-4 border-t border-cyan-500/20 font-mono">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-300 text-xs font-bold border border-slate-800 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-5 py-2 rounded-lg bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-slate-950 font-black text-xs shadow-[0_0_15px_rgba(0,240,255,0.5)] transition-all transform active:scale-95 disabled:opacity-50"
            >
              {isSubmitting ? "SAVING..." : initialTask ? "UPDATE OBJECTIVE" : "REGISTER OBJECTIVE"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
