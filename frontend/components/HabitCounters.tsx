"use client";

import React, { useState } from "react";
import {
  Droplets,
  Footprints,
  Moon,
  Plus,
  Minus,
  Zap,
  Shield,
  Activity,
} from "lucide-react";
import { audio } from "../lib/audio";

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
      {/* 1. Vitality - Hydration Chamber */}
      <div className="system-window rounded-2xl p-5 border border-cyan-500/30 flex flex-col justify-between relative overflow-hidden">
        <div>
          <div className="flex items-center justify-between gap-2 mb-3">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-lg bg-slate-950 border border-cyan-500/30 text-cyan-400">
                <Droplets className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-xs font-mono font-black text-cyan-400 uppercase tracking-widest">
                  [ STAT: VITALITY ]
                </h4>
                <p className="text-sm font-bold text-white font-['Outfit']">
                  Hydration Chamber
                </p>
              </div>
            </div>

            <span className="text-xs font-mono font-black text-cyan-300 px-2 py-0.5 rounded bg-slate-950 border border-cyan-500/40">
              {waterPercent}%
            </span>
          </div>

          <div className="flex items-baseline gap-1 my-3 font-mono">
            <span className="text-3xl sm:text-4xl font-black text-white font-['Outfit'] glow-text-system">
              {waterIntakeMl.toLocaleString()}
            </span>
            <span className="text-xs text-cyan-400">/ {waterGoalMl} ml</span>
          </div>

          {/* Water Fill Bar */}
          <div className="w-full h-5 bg-slate-950 rounded-lg overflow-hidden border border-cyan-500/30 p-0.5 relative mb-4">
            <div
              className="h-full rounded bg-gradient-to-r from-cyan-500 via-blue-500 to-sky-400 transition-all duration-500 shadow-[0_0_10px_#00f0ff]"
              style={{ width: `${waterPercent}%` }}
            />
            <div
              className="absolute top-0 bottom-0 w-0.5 bg-amber-400 z-10"
              style={{ left: "88%" }}
              title="4.0L Minimum Requirement"
            />
          </div>
        </div>

        {/* Quick buttons */}
        <div>
          <div className="grid grid-cols-3 gap-1.5 mb-2 font-mono">
            <button
              onClick={() => handleWaterClick(250)}
              className="py-1.5 px-2 rounded-lg bg-slate-950 hover:bg-cyan-950 text-cyan-300 border border-cyan-500/30 hover:border-cyan-400 text-xs font-bold transition-all flex items-center justify-center gap-1"
            >
              <Plus className="w-3 h-3" />
              <span>250ml</span>
            </button>
            <button
              onClick={() => handleWaterClick(500)}
              className="py-1.5 px-2 rounded-lg bg-slate-950 hover:bg-cyan-950 text-cyan-300 border border-cyan-500/30 hover:border-cyan-400 text-xs font-bold transition-all flex items-center justify-center gap-1"
            >
              <Plus className="w-3 h-3" />
              <span>500ml</span>
            </button>
            <button
              onClick={() => handleWaterClick(-250)}
              disabled={waterIntakeMl <= 0}
              className="py-1.5 px-2 rounded-lg bg-slate-950 hover:bg-slate-900 text-slate-500 disabled:opacity-30 border border-slate-800 text-xs font-bold transition-all flex items-center justify-center gap-1"
            >
              <Minus className="w-3 h-3" />
              <span>250ml</span>
            </button>
          </div>

          <form onSubmit={handleCustomWaterSubmit} className="flex gap-1.5 font-mono">
            <input
              type="number"
              placeholder="Custom ml..."
              value={customWater}
              onChange={(e) => setCustomWater(e.target.value)}
              className="w-full bg-slate-950 border border-cyan-500/30 focus:border-cyan-400 rounded-lg px-2.5 py-1 text-xs text-white placeholder:text-slate-600 focus:outline-none"
            />
            <button
              type="submit"
              className="px-3 py-1 rounded-lg bg-cyan-950 hover:bg-cyan-900 text-cyan-300 text-xs font-bold border border-cyan-500/40 transition-colors"
            >
              Log
            </button>
          </form>
        </div>
      </div>

      {/* 2. Strength - Step & Movement Chamber */}
      <div className="system-window rounded-2xl p-5 border border-cyan-500/30 flex flex-col justify-between">
        <div>
          <div className="flex items-center justify-between gap-2 mb-3">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-lg bg-slate-950 border border-cyan-500/30 text-cyan-400">
                <Footprints className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-xs font-mono font-black text-cyan-400 uppercase tracking-widest">
                  [ STAT: STRENGTH ]
                </h4>
                <p className="text-sm font-bold text-white font-['Outfit']">
                  Movement Gauge
                </p>
              </div>
            </div>

            <span className="text-xs font-mono font-black text-cyan-300 px-2 py-0.5 rounded bg-slate-950 border border-cyan-500/40">
              {stepsPercent}%
            </span>
          </div>

          <div className="flex items-baseline gap-1 my-3 font-mono">
            <span className="text-3xl sm:text-4xl font-black text-white font-['Outfit'] glow-text-system">
              {steps.toLocaleString()}
            </span>
            <span className="text-xs text-cyan-400">/ 10,000 steps</span>
          </div>

          <div className="w-full h-5 bg-slate-950 rounded-lg overflow-hidden border border-cyan-500/30 p-0.5 mb-4">
            <div
              className="h-full rounded bg-gradient-to-r from-cyan-400 to-blue-500 transition-all duration-500 shadow-[0_0_10px_#00f0ff]"
              style={{ width: `${stepsPercent}%` }}
            />
          </div>

          <div className="grid grid-cols-2 gap-2 text-xs font-mono">
            <div className="p-2 rounded-lg bg-slate-950 border border-cyan-500/20">
              <span className="text-slate-400 block text-[10px]">DISTANCE</span>
              <span className="font-bold text-cyan-300">{kmWalked} km</span>
            </div>
            <div className="p-2 rounded-lg bg-slate-950 border border-cyan-500/20">
              <span className="text-slate-400 block text-[10px]">BURNED</span>
              <span className="font-bold text-orange-400">{caloriesBurned} kcal</span>
            </div>
          </div>
        </div>

        <button
          onClick={onOpenSmartwatchModal}
          className="mt-4 w-full py-2 rounded-lg bg-slate-950 hover:bg-cyan-950/80 border border-cyan-500/30 hover:border-cyan-400 text-cyan-300 text-xs font-mono font-bold transition-all flex items-center justify-center gap-1.5 shadow-[0_0_10px_rgba(0,240,255,0.15)]"
        >
          <Zap className="w-3.5 h-3.5 text-cyan-400" />
          <span>[ SYNC SMARTWATCH / PHONE ]</span>
        </button>
      </div>

      {/* 3. Perception / Vitality - Sleep Recovery Chamber */}
      <div className="system-window rounded-2xl p-5 border border-cyan-500/30 flex flex-col justify-between">
        <div>
          <div className="flex items-center justify-between gap-2 mb-3">
            <div className="flex items-center gap-2">
              <div className="p-2 rounded-lg bg-slate-950 border border-cyan-500/30 text-cyan-400">
                <Moon className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-xs font-mono font-black text-cyan-400 uppercase tracking-widest">
                  [ STAT: RECOVERY ]
                </h4>
                <p className="text-sm font-bold text-white font-['Outfit']">
                  Restoration Chamber
                </p>
              </div>
            </div>

            <span className="text-xs font-mono font-black text-cyan-300 px-2 py-0.5 rounded bg-slate-950 border border-cyan-500/40">
              {sleepPercent}%
            </span>
          </div>

          <div className="flex items-baseline gap-1 my-3 font-mono">
            <span className="text-3xl sm:text-4xl font-black text-white font-['Outfit'] glow-text-system">
              {sleepHours}h
            </span>
            <span className="text-xs text-cyan-400">({sleepMinutes} mins)</span>
          </div>

          <div className="w-full h-5 bg-slate-950 rounded-lg overflow-hidden border border-cyan-500/30 p-0.5 mb-4">
            <div
              className="h-full rounded bg-gradient-to-r from-violet-500 to-cyan-400 transition-all duration-500 shadow-[0_0_10px_#8b5cf6]"
              style={{ width: `${sleepPercent}%` }}
            />
          </div>

          <div className="p-2.5 rounded-lg bg-slate-950 border border-cyan-500/20 text-xs font-mono">
            <div className="flex items-center justify-between">
              <span className="text-slate-400">RESTORATION STATE</span>
              <span className={`font-bold ${sleepMinutes >= 420 ? "text-emerald-400" : "text-amber-400"}`}>
                {sleepMinutes >= 420 ? "[ OPTIMAL RECOVERY ]" : "[ BELOW THRESHOLD ]"}
              </span>
            </div>
          </div>
        </div>

        <button
          onClick={onOpenSmartwatchModal}
          className="mt-4 w-full py-2 rounded-lg bg-slate-950 hover:bg-violet-950/80 border border-violet-500/30 hover:border-violet-400 text-violet-300 text-xs font-mono font-bold transition-all flex items-center justify-center gap-1.5 shadow-[0_0_10px_rgba(139,92,246,0.15)]"
        >
          <Activity className="w-3.5 h-3.5 text-violet-400" />
          <span>[ UPDATE SLEEP DATA ]</span>
        </button>
      </div>
    </div>
  );
};
