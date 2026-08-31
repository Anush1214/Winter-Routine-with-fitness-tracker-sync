"use client";

import React, { useEffect, useRef } from "react";
import confetti from "canvas-confetti";
import { Trophy, Zap, AlertTriangle, ShieldCheck, Flame, Sparkles } from "lucide-react";
import { audio } from "../lib/audio";

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

  useEffect(() => {
    if (percentage === 100 && totalTasks > 0 && prevCompletedRef.current < totalTasks) {
      audio.playVictory();
      confetti({
        particleCount: 150,
        spread: 90,
        origin: { y: 0.6 },
        colors: ["#00f0ff", "#38bdf8", "#8b5cf6", "#f59e0b", "#ffffff"],
      });
    }
    prevCompletedRef.current = completedTasks;
  }, [percentage, totalTasks, completedTasks]);

  const radius = 46;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;

  return (
    <div className="w-full mb-6 system-window rounded-2xl p-5 sm:p-6 border border-cyan-500/40 relative overflow-hidden">
      {/* Background ambient mana aura */}
      <div className="absolute -right-16 -top-16 w-56 h-56 bg-cyan-500/15 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -left-16 -bottom-16 w-56 h-56 bg-blue-600/15 rounded-full blur-3xl pointer-events-none" />

      {/* Solo Leveling Top Window Header Banner */}
      <div className="flex items-center justify-between gap-2 pb-3 mb-4 border-b border-cyan-500/20">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-cyan-400 animate-ping" />
          <span className="text-xs font-black font-mono uppercase tracking-widest text-cyan-400 glow-text-system">
            [ SYSTEM NOTIFICATION : QUEST WINDOW ]
          </span>
        </div>
        <span className="text-[11px] font-mono text-slate-400">
          DATE: {dateStr}
        </span>
      </div>

      <div className="flex flex-col sm:flex-row items-center justify-between gap-6">
        {/* Left: Quest Information */}
        <div className="flex-1 text-center sm:text-left">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-md text-xs font-black font-mono uppercase tracking-wider mb-2.5 bg-cyan-950/80 border border-cyan-400 text-cyan-300 shadow-[0_0_15px_rgba(0,240,255,0.3)]">
            <Zap className="w-3.5 h-3.5 text-cyan-400" />
            <span>DAILY QUEST: PREPARATION TO BECOME STRONG</span>
          </div>

          <h2 className="text-2xl sm:text-3xl font-black text-white font-['Outfit'] tracking-tight glow-text-system">
            {completedTasks} / {totalTasks} OBJECTIVES CLEARED
          </h2>

          <p className="text-xs sm:text-sm text-slate-300 mt-1 font-mono">
            {percentage === 100 ? (
              <span className="text-emerald-400 font-bold flex items-center gap-1.5 justify-center sm:justify-start">
                <ShieldCheck className="w-4 h-4" />
                <span>[ ALL DAILY QUESTS CLEARED: STAT POINTS +3 & FULL RECOVERY ]</span>
              </span>
            ) : (
              <span>Execute your morning, placement DSA, Japanese, and major project routines.</span>
            )}
          </p>

          {/* Penalty Quest Warning Banner */}
          {percentage < 100 && (
            <div className="mt-4 p-2.5 rounded-lg bg-red-950/40 border border-red-500/40 text-red-300 text-xs font-mono flex items-center gap-2 justify-center sm:justify-start system-alert-pulse">
              <AlertTriangle className="w-4 h-4 text-red-400 flex-shrink-0 animate-pulse" />
              <span>
                <strong>[ CAUTION ]</strong> Failure to complete daily quests will result in a <strong>Penalty Quest</strong>.
              </span>
            </div>
          )}
        </div>

        {/* Right: Circular Blue Holographic Gauge */}
        <div className="relative flex items-center justify-center flex-shrink-0">
          <svg className="w-36 h-36 transform -rotate-90" viewBox="0 0 110 110">
            {/* Outer decorative tech ring */}
            <circle
              cx="55"
              cy="55"
              r={52}
              className="stroke-cyan-500/20"
              strokeWidth="1"
              strokeDasharray="4 6"
              fill="transparent"
            />
            {/* Background track */}
            <circle
              cx="55"
              cy="55"
              r={radius}
              className="stroke-slate-900"
              strokeWidth="9"
              fill="transparent"
            />
            {/* Animated Mana Ring */}
            <circle
              cx="55"
              cy="55"
              r={radius}
              stroke="url(#soloLevelingManaGrad)"
              strokeWidth="9"
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              strokeLinecap="round"
              fill="transparent"
              className="transition-all duration-700 ease-out"
            />
            <defs>
              <linearGradient id="soloLevelingManaGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#00f0ff" />
                <stop offset="70%" stopColor="#0284c7" />
                <stop offset="100%" stopColor="#8b5cf6" />
              </linearGradient>
            </defs>
          </svg>

          <div className="absolute flex flex-col items-center justify-center text-center">
            <span className="text-3xl sm:text-4xl font-black text-white font-['Outfit'] tracking-tight glow-text-system">
              {percentage}%
            </span>
            <span className="text-[10px] font-mono uppercase font-bold text-cyan-400 tracking-wider">
              {percentage === 100 ? "CLEARED" : "PROGRESS"}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};
