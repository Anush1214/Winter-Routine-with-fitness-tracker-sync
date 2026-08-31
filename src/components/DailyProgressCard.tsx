"use client";

import React, { useEffect, useRef } from "react";
import confetti from "canvas-confetti";
import { CheckCircle2, Trophy, Zap, Target, Flame } from "lucide-react";
import { audio } from "@/lib/audio";

interface DailyProgressCardProps {
  totalTasks: number;
  completedTasks: number;
  dateStr: string;
}

export const DailyProgressCard: React.FC<DailyProgressCardProps> = ({
  totalTasks,
  completedTasks,
  dateStr,
}) => {
  const prevCompletedRef = useRef<number>(completedTasks);
  const percentage = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

  // Trigger celebration on 100%
  useEffect(() => {
    if (percentage === 100 && totalTasks > 0 && prevCompletedRef.current < totalTasks) {
      audio.playVictory();
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 },
        colors: ["#00f0ff", "#8b5cf6", "#10b981", "#ff5e3a", "#ffffff"],
      });
    }
    prevCompletedRef.current = completedTasks;
  }, [percentage, totalTasks, completedTasks]);

  // SVG Circular Gauge calculation
  const radius = 42;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;

  let statusText = "INITIALIZING";
  let statusColor = "text-slate-400";
  let statusBadge = "bg-slate-800 border-slate-700 text-slate-300";

  if (percentage === 100) {
    statusText = "100% PROTOCOL COMPLETE";
    statusColor = "text-emerald-400 glow-text-emerald";
    statusBadge = "bg-emerald-950/80 border-emerald-500/40 text-emerald-300 shadow-[0_0_15px_rgba(16,185,129,0.3)]";
  } else if (percentage >= 75) {
    statusText = "DIALED IN & LOCKED";
    statusColor = "text-cyan-400 glow-text-cyan";
    statusBadge = "bg-cyan-950/80 border-cyan-500/40 text-cyan-300 shadow-[0_0_15px_rgba(0,240,255,0.3)]";
  } else if (percentage >= 40) {
    statusText = "IN PROGRESS";
    statusColor = "text-sky-400";
    statusBadge = "bg-sky-950/80 border-sky-500/30 text-sky-300";
  } else if (percentage > 0) {
    statusText = "DAY STARTED";
    statusColor = "text-amber-400";
    statusBadge = "bg-amber-950/80 border-amber-500/30 text-amber-300";
  }

  return (
    <div className="w-full mb-6 glass-panel rounded-2xl p-4 sm:p-6 border border-slate-800/90 relative overflow-hidden">
      {/* Background ambient lighting */}
      <div className="absolute -right-12 -top-12 w-48 h-48 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -left-12 -bottom-12 w-48 h-48 bg-violet-500/10 rounded-full blur-3xl pointer-events-none" />

      <div className="relative flex flex-col sm:flex-row items-center justify-between gap-6">
        {/* Left: Progress info */}
        <div className="flex-1 text-center sm:text-left">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-black uppercase tracking-wider mb-2.5 border transition-all ${statusBadge}">
            {percentage === 100 ? (
              <Trophy className="w-3.5 h-3.5 text-emerald-400" />
            ) : percentage >= 75 ? (
              <Zap className="w-3.5 h-3.5 text-cyan-400" />
            ) : (
              <Target className="w-3.5 h-3.5 text-sky-400" />
            )}
            <span>{statusText}</span>
          </div>

          <h2 className="text-2xl sm:text-3xl font-extrabold text-white font-['Outfit'] tracking-tight">
            Daily Execution Score
          </h2>
          <p className="text-xs sm:text-sm text-slate-400 mt-1">
            {completedTasks} of {totalTasks} checklist items completed for this day.
          </p>

          <div className="flex items-center justify-center sm:justify-start gap-4 mt-4">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-emerald-400" />
              <span className="text-xs font-semibold text-slate-300 font-mono">
                {completedTasks} Completed
              </span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-slate-700" />
              <span className="text-xs font-semibold text-slate-400 font-mono">
                {Math.max(0, totalTasks - completedTasks)} Remaining
              </span>
            </div>
          </div>
        </div>

        {/* Right: Circular SVG Gauge */}
        <div className="relative flex items-center justify-center flex-shrink-0">
          <svg className="w-32 h-32 transform -rotate-90" viewBox="0 0 100 100">
            {/* Background track */}
            <circle
              cx="50"
              cy="50"
              r={radius}
              className="stroke-slate-800"
              strokeWidth="9"
              fill="transparent"
            />
            {/* Animated progress ring */}
            <circle
              cx="50"
              cy="50"
              r={radius}
              stroke="url(#progressGradient)"
              strokeWidth="9"
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              strokeLinecap="round"
              fill="transparent"
              className="transition-all duration-700 ease-out"
            />
            <defs>
              <linearGradient id="progressGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#00f0ff" />
                <stop offset="60%" stopColor="#38bdf8" />
                <stop offset="100%" stopColor="#8b5cf6" />
              </linearGradient>
            </defs>
          </svg>

          {/* Center text */}
          <div className="absolute flex flex-col items-center justify-center text-center">
            <span className="text-2xl sm:text-3xl font-black text-white font-['Outfit'] tracking-tight">
              {percentage}%
            </span>
            <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wider">
              Complete
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};
