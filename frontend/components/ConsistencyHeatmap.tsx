"use client";

import React, { useState } from "react";
import { Flame, Calendar, Trophy, Sparkles } from "lucide-react";

export interface HeatmapDayData {
  date: string;
  totalTasks: number;
  completedTasks: number;
  completionRate: number;
  steps: number;
  waterIntakeMl: number;
  sleepMinutes: number;
  gymWorkoutDone: boolean;
}

interface ConsistencyHeatmapProps {
  days: HeatmapDayData[];
  selectedDate: string;
  onSelectDate: (date: string) => void;
  currentStreak: number;
  bestStreak: number;
}

export const ConsistencyHeatmap: React.FC<ConsistencyHeatmapProps> = ({
  days,
  selectedDate,
  onSelectDate,
  currentStreak,
  bestStreak,
}) => {
  const [hoveredDay, setHoveredDay] = useState<HeatmapDayData | null>(null);

  const months = React.useMemo(() => {
    const monthGroups: Record<string, HeatmapDayData[]> = {
      September: [],
      October: [],
      November: [],
      December: [],
    };

    days.forEach((day) => {
      const d = new Date(`${day.date}T12:00:00`);
      const monthName = d.toLocaleDateString("en-US", { month: "long" });
      if (monthGroups[monthName]) {
        monthGroups[monthName].push(day);
      }
    });

    return monthGroups;
  }, [days]);

  const getCellColor = (rate: number, isSelected: boolean) => {
    if (isSelected) {
      return "ring-2 ring-cyan-300 ring-offset-2 ring-offset-slate-950 scale-110 z-10 shadow-[0_0_12px_#00f0ff]";
    }
    if (rate === 100) return "bg-cyan-400 hover:bg-cyan-300 shadow-[0_0_10px_rgba(0,240,255,0.7)] text-slate-950 font-black";
    if (rate >= 75) return "bg-cyan-600 hover:bg-cyan-500 shadow-[0_0_6px_rgba(6,182,212,0.4)] text-white";
    if (rate >= 50) return "bg-blue-900 hover:bg-blue-800 text-cyan-300";
    if (rate >= 25) return "bg-slate-900 hover:bg-slate-800 text-slate-400";
    if (rate > 0) return "bg-slate-950 hover:bg-slate-900 text-slate-500";
    return "bg-slate-950/80 border border-cyan-500/10 hover:border-cyan-500/30 text-slate-600";
  };

  return (
    <div className="w-full mb-8 system-window rounded-2xl p-4 sm:p-6 border border-cyan-500/40 shadow-xl">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 mb-5 pb-3 border-b border-cyan-500/20">
        <div>
          <div className="flex items-center gap-2">
            <Flame className="w-5 h-5 text-cyan-400 fill-cyan-400 animate-pulse" />
            <h3 className="text-base sm:text-lg font-black text-white font-mono uppercase tracking-wide glow-text-system">
              [ HUNTER EXPEDITION MATRIX : SEPT 1 — DEC 31 ]
            </h3>
          </div>
          <p className="text-xs text-slate-400 font-mono mt-0.5">
            122-Day transformation record across all 4 months.
          </p>
        </div>

        <div className="flex items-center gap-2 font-mono">
          <div className="px-3 py-1 rounded-lg bg-slate-950 border border-orange-500/40 text-xs">
            <span className="text-slate-400">STREAK: </span>
            <span className="font-bold text-orange-400">{currentStreak} DAYS</span>
          </div>
          <div className="px-3 py-1 rounded-lg bg-slate-950 border border-cyan-500/40 text-xs">
            <span className="text-slate-400">MAX: </span>
            <span className="font-bold text-cyan-300">{bestStreak} DAYS</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {Object.entries(months).map(([monthName, monthDays]) => (
          <div
            key={monthName}
            className="p-3.5 rounded-xl bg-slate-950/90 border border-cyan-500/20"
          >
            <div className="flex items-center justify-between mb-2.5">
              <span className="text-xs font-black uppercase font-mono tracking-wider text-cyan-300">
                [{monthName.toUpperCase()}]
              </span>
              <span className="text-[10px] font-mono text-slate-500">
                {monthDays.length} Days
              </span>
            </div>

            <div className="grid grid-cols-7 gap-1.5">
              {monthDays.map((day) => {
                const dayNum = new Date(`${day.date}T12:00:00`).getDate();
                const isSelected = day.date === selectedDate;
                const cellColor = getCellColor(day.completionRate, isSelected);

                return (
                  <button
                    key={day.date}
                    onClick={() => onSelectDate(day.date)}
                    onMouseEnter={() => setHoveredDay(day)}
                    onMouseLeave={() => setHoveredDay(null)}
                    className={`aspect-square rounded flex items-center justify-center text-[10px] font-mono font-bold transition-all ${cellColor}`}
                    title={`${day.date}: ${day.completionRate}% completed`}
                  >
                    {dayNum}
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 mt-5 pt-3 border-t border-cyan-500/20 text-xs text-slate-400">
        <div className="min-h-[22px] flex items-center gap-2">
          {hoveredDay ? (
            <div className="flex items-center gap-2 font-mono text-xs animate-fadeIn">
              <Calendar className="w-3.5 h-3.5 text-cyan-400" />
              <span className="text-white font-bold">{hoveredDay.date}:</span>
              <span className="text-cyan-300 font-bold">{hoveredDay.completionRate}% CLEARED</span>
              <span>•</span>
              <span>{hoveredDay.completedTasks}/{hoveredDay.totalTasks} Quests</span>
              {hoveredDay.steps > 0 && (
                <>
                  <span>•</span>
                  <span>{hoveredDay.steps.toLocaleString()} Steps</span>
                </>
              )}
            </div>
          ) : (
            <span className="text-slate-500 font-mono italic">
              [ HOVER OVER ANY MATRIX CELL TO INSPECT EXPEDITION STATS ]
            </span>
          )}
        </div>

        <div className="flex items-center gap-1.5 font-mono text-[11px]">
          <span>0%</span>
          <div className="w-3 h-3 rounded bg-slate-950 border border-slate-800" />
          <div className="w-3 h-3 rounded bg-blue-900" />
          <div className="w-3 h-3 rounded bg-cyan-600" />
          <div className="w-3 h-3 rounded bg-cyan-400 shadow-[0_0_8px_#00f0ff]" />
          <span>100%</span>
        </div>
      </div>
    </div>
  );
};
