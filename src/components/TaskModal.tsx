"use client";

import React, { useState, useEffect } from "react";
import { X, Plus, Edit2, Clock, Dumbbell, Tag, Calendar, Zap, AlertCircle } from "lucide-react";
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
  { id: "routine", label: "Routine", color: "text-sky-400" },
  { id: "fitness", label: "Fitness", color: "text-emerald-400" },
  { id: "career", label: "Career & Placement", color: "text-violet-400" },
  { id: "health", label: "Health & Habits", color: "text-cyan-400" },
  { id: "study", label: "Study", color: "text-amber-400" },
  { id: "custom", label: "Custom", color: "text-pink-400" },
];

const AUTO_METRICS = [
  { id: "none", label: "Manual Check Only" },
  { id: "steps_10k", label: "Auto-check on 10k Steps" },
  { id: "sleep_7h", label: "Auto-check on 7+ Hours Sleep" },
  { id: "gym_workout", label: "Auto-check on Gym Workout Log" },
  { id: "water_4l", label: "Auto-check on 4L+ Hydration" },
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
      // Default category and time based on slot clicked
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
      setError(err.message || "Failed to save task");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fadeIn">
      <div className="w-full max-w-lg glass-panel rounded-2xl p-5 sm:p-6 border border-slate-700 shadow-2xl bg-slate-950/95 relative max-h-[90vh] overflow-y-auto">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-400 hover:text-white transition-colors"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Modal Header */}
        <div className="flex items-center gap-2.5 mb-5 pb-3 border-b border-slate-800">
          <div className="p-2 rounded-xl bg-cyan-950 border border-cyan-500/30 text-cyan-400">
            {initialTask ? <Edit2 className="w-4 h-4" /> : <Plus className="w-4 h-4" />}
          </div>
          <div>
            <h3 className="text-lg font-bold text-white font-['Outfit']">
              {initialTask ? "Edit Routine Task" : "Add Routine Task"}
            </h3>
            <p className="text-xs text-slate-400 font-mono">Target Date: {selectedDate}</p>
          </div>
        </div>

        {error && (
          <div className="mb-4 p-3 rounded-xl bg-red-950/80 border border-red-500/40 text-red-300 text-xs flex items-center gap-2">
            <AlertCircle className="w-4 h-4 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Task Title */}
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-slate-300 mb-1.5">
              Task Title
            </label>
            <input
              type="text"
              required
              placeholder="e.g. 7:00 sit and do DSA and prepare for placement"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full bg-slate-900 border border-slate-800 focus:border-cyan-500 rounded-xl px-3.5 py-2.5 text-sm text-white placeholder:text-slate-600 focus:outline-none transition-colors"
            />
          </div>

          {/* Category Selector */}
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-slate-300 mb-1.5">
              Category
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
              {CATEGORIES.map((cat) => (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => setCategory(cat.id)}
                  className={`p-2 rounded-xl text-xs font-semibold border transition-all text-left flex items-center justify-between ${
                    category === cat.id
                      ? "bg-cyan-950/80 border-cyan-500 text-cyan-300 shadow-[0_0_10px_rgba(6,182,212,0.2)]"
                      : "bg-slate-900/80 border-slate-800 text-slate-400 hover:border-slate-700"
                  }`}
                >
                  <span>{cat.label}</span>
                  {category === cat.id && <div className="w-1.5 h-1.5 rounded-full bg-cyan-400" />}
                </button>
              ))}
            </div>
          </div>

          {/* Start Time (Optional) */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-300 mb-1.5">
                Target Time (Optional)
              </label>
              <div className="relative">
                <input
                  type="time"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-800 focus:border-cyan-500 rounded-xl px-3.5 py-2 text-sm text-white font-mono focus:outline-none"
                />
              </div>
            </div>

            {/* Smartwatch Auto-Metric Binding */}
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-300 mb-1.5">
                Smartwatch Metric Binding
              </label>
              <select
                value={autoMetric}
                onChange={(e) => setAutoMetric(e.target.value)}
                className="w-full bg-slate-900 border border-slate-800 focus:border-cyan-500 rounded-xl px-3.5 py-2 text-xs text-white font-mono focus:outline-none"
              >
                {AUTO_METRICS.map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Scope Selector */}
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-slate-300 mb-1.5">
              Apply Modification Scope
            </label>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
              <button
                type="button"
                onClick={() => setApplyScope("today")}
                className={`p-2.5 rounded-xl text-xs font-semibold border transition-all text-center ${
                  applyScope === "today"
                    ? "bg-cyan-950 border-cyan-400 text-cyan-300"
                    : "bg-slate-900 border-slate-800 text-slate-400"
                }`}
              >
                Only This Day
              </button>
              <button
                type="button"
                onClick={() => setApplyScope("future")}
                className={`p-2.5 rounded-xl text-xs font-semibold border transition-all text-center ${
                  applyScope === "future"
                    ? "bg-cyan-950 border-cyan-400 text-cyan-300"
                    : "bg-slate-900 border-slate-800 text-slate-400"
                }`}
              >
                From Today Onwards
              </button>
              <button
                type="button"
                onClick={() => setApplyScope("all")}
                className={`p-2.5 rounded-xl text-xs font-semibold border transition-all text-center ${
                  applyScope === "all"
                    ? "bg-cyan-950 border-cyan-400 text-cyan-300"
                    : "bg-slate-900 border-slate-800 text-slate-400"
                }`}
              >
                All 4 Months
              </button>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center justify-end gap-2 pt-4 border-t border-slate-800">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-slate-300 text-xs font-semibold border border-slate-800 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-5 py-2 rounded-xl bg-gradient-to-r from-cyan-500 to-sky-500 hover:from-cyan-400 hover:to-sky-400 text-slate-950 font-bold text-xs shadow-neon-cyan transition-all transform active:scale-95 disabled:opacity-50"
            >
              {isSubmitting ? "Saving..." : initialTask ? "Update Routine" : "Create Task"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
