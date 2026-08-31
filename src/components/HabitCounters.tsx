"use client";

import React, { useState } from "react";
import {
  Droplets,
  Footprints,
  Moon,
  Plus,
  Minus,
  CheckCircle,
  Sparkles,
  Flame,
  Zap,
} from "lucide-react";
import { audio } from "@/lib/audio";

interface HabitCountersProps {
  waterIntakeMl: number;
  steps: number;
  sleepMinutes: number;
  waterGoalMl?: number;
  stepsGoal?: number;
  sleepGoalMinutes?: number;
  onUpdateWater: (delta: number, mode?: "increment" | "set") => void;
  onOpenSmartwatchModal: () => void;
}

export const HabitCounters: React.FC<HabitCountersProps> = ({
  waterIntakeMl,
  steps,
  sleepMinutes,
  waterGoalMl = 4500,
  stepsGoal = 10000,
  sleepGoalMinutes = 420,
  onUpdateWater,
  onOpenSmartwatchModal,
}) => {
  const [customWater, setCustomWater] = useState<string>("");

  const waterPercent = Math.min(100, Math.round((waterIntakeMl / waterGoalMl) * 100));
  const stepsPercent = Math.min(100, Math.round((steps / stepsGoal) * 100));
  const sleepHours = (sleepMinutes / 60).toFixed(1);
  const sleepPercent = Math.min(100, Math.round((sleepMinutes / sleepGoalMinutes) * 100));

  // Approx calories & distance
  const kmWalked = ((steps * 0.76) / 1000).toFixed(1);
  const caloriesBurned = Math.round(steps * 0.04);

  const handleWaterClick = (amount: number) => {
    audio.playWaterDrop();
    onUpdateWater(amount, "increment");
  };

  const handleCustomWaterSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseInt(customWater, 10);
    if (!isNaN(val) && val >= 0) {
      audio.playWaterDrop();
      onUpdateWater(val, "set");
      setCustomWater("");
    }
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-5 mb-8">
      {/* 1. Interactive 4.5L Water Cylinder Card */}
      <div className="glass-panel rounded-2xl p-5 border border-cyan-500/20 shadow-[0_0_20px_rgba(6,182,212,0.08)] flex flex-col justify-between relative overflow-hidden">
        <div>
          <div className="flex items-center justify-between gap-2 mb-3">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-xl bg-cyan-950/80 border border-cyan-500/30 text-cyan-400">
                <Droplets className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-white font-['Outfit']">
                  Hydration Chamber
                </h4>
                <p className="text-[11px] font-mono text-cyan-400">
                  Target: {waterGoalMl.toLocaleString()} ml
                </p>
              </div>
            </div>

            <span className="text-xs font-mono font-black text-cyan-300 px-2 py-0.5 rounded bg-cyan-950 border border-cyan-800">
              {waterPercent}%
            </span>
          </div>

          {/* Current Volume Counter */}
          <div className="flex items-baseline gap-1 my-3">
            <span className="text-3xl sm:text-4xl font-black text-white font-['Outfit'] glow-text-cyan">
              {waterIntakeMl.toLocaleString()}
            </span>
            <span className="text-xs font-mono text-slate-400">/ {waterGoalMl} ml</span>
          </div>

          {/* Visual Water Fill Tube */}
          <div className="w-full h-7 bg-slate-900/90 rounded-xl overflow-hidden border border-slate-800 p-0.5 relative mb-4">
            {/* Liquid Fill */}
            <div
              className="h-full rounded-lg bg-gradient-to-r from-cyan-500 via-sky-400 to-teal-400 transition-all duration-500 relative"
              style={{ width: `${waterPercent}%` }}
            >
              <div className="absolute inset-0 bg-white/20 animate-pulse" />
            </div>

            {/* Target Marker at 4000ml */}
            <div
              className="absolute top-0 bottom-0 w-0.5 bg-amber-400/80 z-10"
              style={{ left: "88%" }}
              title="4.0L Protocol Minimum"
            />
          </div>
        </div>

        {/* Quick Increment Buttons */}
        <div>
          <div className="grid grid-cols-3 gap-1.5 mb-2">
            <button
              onClick={() => handleWaterClick(250)}
              className="py-1.5 px-2 rounded-lg bg-cyan-950/60 hover:bg-cyan-900/80 text-cyan-300 border border-cyan-800/60 text-xs font-bold font-mono transition-all transform active:scale-95 flex items-center justify-center gap-1"
            >
              <Plus className="w-3 h-3" />
              <span>250ml</span>
            </button>
            <button
              onClick={() => handleWaterClick(500)}
              className="py-1.5 px-2 rounded-lg bg-cyan-950/60 hover:bg-cyan-900/80 text-cyan-300 border border-cyan-800/60 text-xs font-bold font-mono transition-all transform active:scale-95 flex items-center justify-center gap-1"
            >
              <Plus className="w-3 h-3" />
              <span>500ml</span>
            </button>
            <button
              onClick={() => handleWaterClick(-250)}
              disabled={waterIntakeMl <= 0}
              className="py-1.5 px-2 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-400 disabled:opacity-30 border border-slate-800 text-xs font-bold font-mono transition-all flex items-center justify-center gap-1"
            >
              <Minus className="w-3 h-3" />
              <span>250ml</span>
            </button>
          </div>

          {/* Custom ml input */}
          <form onSubmit={handleCustomWaterSubmit} className="flex gap-1.5">
            <input
              type="number"
              placeholder="Custom ml..."
              value={customWater}
              onChange={(e) => setCustomWater(e.target.value)}
              className="w-full bg-slate-900 border border-slate-800 rounded-lg px-2.5 py-1 text-xs text-white font-mono placeholder:text-slate-600 focus:outline-none focus:border-cyan-500"
            />
            <button
              type="submit"
              className="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-cyan-950 hover:border-cyan-700 text-cyan-300 text-xs font-bold border border-slate-700 transition-colors"
            >
              Set
            </button>
          </form>
        </div>
      </div>

      {/* 2. Live 10,000 Step Tracker */}
      <div className="glass-panel rounded-2xl p-5 border border-emerald-500/20 shadow-[0_0_20px_rgba(16,185,129,0.08)] flex flex-col justify-between">
        <div>
          <div className="flex items-center justify-between gap-2 mb-3">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-xl bg-emerald-950/80 border border-emerald-500/30 text-emerald-400">
                <Footprints className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-white font-['Outfit']">
                  Daily Movement
                </h4>
                <p className="text-[11px] font-mono text-emerald-400">
                  Target: {stepsGoal.toLocaleString()} steps
                </p>
              </div>
            </div>

            <span className="text-xs font-mono font-black text-emerald-300 px-2 py-0.5 rounded bg-emerald-950 border border-emerald-800">
              {stepsPercent}%
            </span>
          </div>

          <div className="flex items-baseline gap-1 my-3">
            <span className="text-3xl sm:text-4xl font-black text-white font-['Outfit'] glow-text-emerald">
              {steps.toLocaleString()}
            </span>
            <span className="text-xs font-mono text-slate-400">/ 10,000</span>
          </div>

          {/* Progress Bar */}
          <div className="w-full h-3.5 bg-slate-900/90 rounded-full overflow-hidden border border-slate-800 p-0.5 mb-4">
            <div
              className="h-full rounded-full bg-gradient-to-r from-emerald-500 to-teal-400 transition-all duration-500 shadow-[0_0_10px_#10b981]"
              style={{ width: `${stepsPercent}%` }}
            />
          </div>

          {/* Distance & Calorie stats */}
          <div className="grid grid-cols-2 gap-2 text-xs">
            <div className="p-2 rounded-lg bg-slate-900/80 border border-slate-800/80">
              <span className="text-slate-400 block text-[10px]">Distance</span>
              <span className="font-mono font-bold text-white text-sm">{kmWalked} km</span>
            </div>
            <div className="p-2 rounded-lg bg-slate-900/80 border border-slate-800/80">
              <span className="text-slate-400 block text-[10px]">Burned</span>
              <span className="font-mono font-bold text-orange-400 text-sm">{caloriesBurned} kcal</span>
            </div>
          </div>
        </div>

        <button
          onClick={onOpenSmartwatchModal}
          className="mt-4 w-full py-1.5 rounded-lg bg-slate-900 hover:bg-emerald-950/60 border border-slate-800 hover:border-emerald-500/40 text-slate-300 hover:text-emerald-300 text-xs font-medium font-mono transition-all flex items-center justify-center gap-1.5"
        >
          <Zap className="w-3.5 h-3.5 text-emerald-400" />
          <span>Sync CMF Watch / Phone</span>
        </button>
      </div>

      {/* 3. Sleep Recovery Log */}
      <div className="glass-panel rounded-2xl p-5 border border-violet-500/20 shadow-[0_0_20px_rgba(139,92,246,0.08)] flex flex-col justify-between">
        <div>
          <div className="flex items-center justify-between gap-2 mb-3">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-xl bg-violet-950/80 border border-violet-500/30 text-violet-400">
                <Moon className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-white font-['Outfit']">
                  Sleep Recovery
                </h4>
                <p className="text-[11px] font-mono text-violet-400">
                  Target: 7h 00m (420m)
                </p>
              </div>
            </div>

            <span className="text-xs font-mono font-black text-violet-300 px-2 py-0.5 rounded bg-violet-950 border border-violet-800">
              {sleepPercent}%
            </span>
          </div>

          <div className="flex items-baseline gap-1 my-3">
            <span className="text-3xl sm:text-4xl font-black text-white font-['Outfit'] glow-text-violet">
              {sleepHours}h
            </span>
            <span className="text-xs font-mono text-slate-400">({sleepMinutes} mins)</span>
          </div>

          {/* Progress Bar */}
          <div className="w-full h-3.5 bg-slate-900/90 rounded-full overflow-hidden border border-slate-800 p-0.5 mb-4">
            <div
              className="h-full rounded-full bg-gradient-to-r from-violet-500 to-indigo-400 transition-all duration-500 shadow-[0_0_10px_#8b5cf6]"
              style={{ width: `${sleepPercent}%` }}
            />
          </div>

          <div className="p-2.5 rounded-lg bg-slate-900/80 border border-slate-800/80 text-xs">
            <div className="flex items-center justify-between">
              <span className="text-slate-400">Score</span>
              <span className={`font-bold font-mono ${sleepMinutes >= 420 ? "text-emerald-400" : "text-amber-400"}`}>
                {sleepMinutes >= 420 ? "OPTIMAL RECOVERY" : "BELOW TARGET"}
              </span>
            </div>
          </div>
        </div>

        <button
          onClick={onOpenSmartwatchModal}
          className="mt-4 w-full py-1.5 rounded-lg bg-slate-900 hover:bg-violet-950/60 border border-slate-800 hover:border-violet-500/40 text-slate-300 hover:text-violet-300 text-xs font-medium font-mono transition-all flex items-center justify-center gap-1.5"
        >
          <Sparkles className="w-3.5 h-3.5 text-violet-400" />
          <span>Update Sleep Data</span>
        </button>
      </div>
    </div>
  );
};
