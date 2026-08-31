"use client";

import React, { useState } from "react";
import { Flame, Calendar, Info } from "lucide-react";
import { formatDateKey } from "@/lib/utils";

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

  // Group days by month
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

  // Determine cell color
  const getCellColor = (rate: number, isSelected: boolean) => {
    if (isSelected) {
      return "ring-2 ring-cyan-400 ring-offset-2 ring-offset-slate-950 scale-110 z-10";
    }
    if (rate === 100) return "bg-emerald-400 hover:bg-emerald-300 shadow-[0_0_8px_rgba(52,211,153,0.5)]";
    if (rate >= 75) return "bg-cyan-400 hover:bg-cyan-300 shadow-[0_0_6px_rgba(6,182,212,0.4)]";
    if (rate >= 50) return "bg-cyan-600 hover:bg-cyan-500";
    if (rate >= 25) return "bg-cyan-900/80 hover:bg-cyan-800";
    if (rate > 0) return "bg-slate-800 hover:bg-slate-700";
    return "bg-slate-900/90 border border-slate-800/80 hover:border-slate-700";
  };

  return (
    <div className="w-full mb-8 glass-panel rounded-2xl p-4 sm:p-6 border border-slate-800 shadow-xl">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 mb-5 pb-3 border-b border-slate-800">
        <div>
          <div className="flex items-center gap-2">
            <Flame className="w-5 h-5 text-orange-400 fill-orange-400" />
            <h3 className="text-lg sm:text-xl font-extrabold text-white font-['Outfit']">
              Consistency Matrix (Sept 1 — Dec 31)
            </h3>
          </div>
          <p className="text-xs text-slate-400 mt-0.5">
            4-Month protocol heatmap tracking your 122-day transformation.
          </p>
        </div>

        {/* Streaks pill */}
        <div className="flex items-center gap-2">
          <div className="px-3 py-1 rounded-lg bg-slate-900 border border-slate-800 text-xs font-mono">
            <span className="text-slate-400">Current: </span>
            <span className="font-bold text-orange-400">{currentStreak} Days</span>
          </div>
          <div className="px-3 py-1 rounded-lg bg-slate-900 border border-slate-800 text-xs font-mono">
            <span className="text-slate-400">Best: </span>
            <span className="font-bold text-cyan-400">{bestStreak} Days</span>
          </div>
        </div>
      </div>

      {/* Grid of Months */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {Object.entries(months).map(([monthName, monthDays]) => (
          <div
            key={monthName}
            className="p-3.5 rounded-xl bg-slate-900/60 border border-slate-800/80"
          >
            <div className="flex items-center justify-between mb-2.5">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-300 font-['Outfit']">
                {monthName}
              </span>
              <span className="text-[10px] font-mono text-slate-500">
                {monthDays.length} Days
              </span>
            </div>

            {/* Grid of days in this month */}
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
                    className={`aspect-square rounded-md flex items-center justify-center text-[10px] font-mono font-semibold transition-all ${cellColor} ${
                      day.completionRate >= 50 ? "text-slate-950 font-bold" : "text-slate-400"
                    }`}
                    title={`${day.date}: ${day.completionRate}% complete`}
                  >
                    {dayNum}
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* Legend & Hover Info Bar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 mt-5 pt-3 border-t border-slate-800 text-xs text-slate-400">
        {/* Hover summary info */}
        <div className="min-h-[22px] flex items-center gap-2">
          {hoveredDay ? (
            <div className="flex items-center gap-2 font-mono text-xs animate-fadeIn">
              <Calendar className="w-3.5 h-3.5 text-cyan-400" />
              <span className="text-white font-bold">{hoveredDay.date}:</span>
              <span className="text-cyan-300 font-bold">{hoveredDay.completionRate}% Complete</span>
              <span>•</span>
              <span>{hoveredDay.completedTasks}/{hoveredDay.totalTasks} Tasks</span>
              {hoveredDay.steps > 0 && (
                <>
                  <span>•</span>
                  <span>{hoveredDay.steps.toLocaleString()} Steps</span>
                </>
              )}
            </div>
          ) : (
            <span className="text-slate-500 italic">
              Hover over any square to preview details or click to view day routine.
            </span>
          )}
        </div>

        {/* Shading Legend */}
        <div className="flex items-center gap-1.5 font-mono text-[11px]">
          <span>0%</span>
          <div className="w-3 h-3 rounded bg-slate-900 border border-slate-800" />
          <div className="w-3 h-3 rounded bg-cyan-900/80" />
          <div className="w-3 h-3 rounded bg-cyan-600" />
          <div className="w-3 h-3 rounded bg-cyan-400" />
          <div className="w-3 h-3 rounded bg-emerald-400 shadow-[0_0_6px_#34d399]" />
          <span>100%</span>
        </div>
      </div>
    </div>
  );
};
