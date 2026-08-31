"use client";

import React, { useRef, useEffect } from "react";
import { ChevronLeft, ChevronRight, Calendar as CalendarIcon } from "lucide-react";
import { formatDateKey } from "../lib/utils";

interface DateCarouselProps {
  selectedDate: string;
  onSelectDate: (date: string) => void;
  dayStatsMap?: Record<string, { completionRate: number; total: number; completed: number }>;
}

export const DateCarousel: React.FC<DateCarouselProps> = ({
  selectedDate,
  onSelectDate,
  dayStatsMap = {},
}) => {
  const scrollRef = useRef<HTMLDivElement>(null);
  const todayStr = formatDateKey(new Date());

  const allDates = React.useMemo(() => {
    const dates: string[] = [];
    const year = new Date().getFullYear();
    const start = new Date(Date.UTC(year, 8, 1));
    const end = new Date(Date.UTC(year, 11, 31));

    const cur = new Date(start);
    while (cur <= end) {
      dates.push(cur.toISOString().split("T")[0]);
      cur.setUTCDate(cur.getUTCDate() + 1);
    }
    return dates;
  }, []);

  useEffect(() => {
    if (scrollRef.current) {
      const selectedEl = scrollRef.current.querySelector(`[data-date="${selectedDate}"]`);
      if (selectedEl) {
        selectedEl.scrollIntoView({ behavior: "smooth", inline: "center", block: "nearest" });
      }
    }
  }, [selectedDate]);

  const handlePrevDay = () => {
    const idx = allDates.indexOf(selectedDate);
    if (idx > 0) {
      onSelectDate(allDates[idx - 1]);
    }
  };

  const handleNextDay = () => {
    const idx = allDates.indexOf(selectedDate);
    if (idx >= 0 && idx < allDates.length - 1) {
      onSelectDate(allDates[idx + 1]);
    }
  };

  const handleTodayClick = () => {
    if (allDates.includes(todayStr)) {
      onSelectDate(todayStr);
    } else {
      onSelectDate(allDates[0]);
    }
  };

  const selectedDateObj = new Date(`${selectedDate}T12:00:00`);
  const formattedSelected = selectedDateObj.toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
    year: "numeric",
  });

  return (
    <div className="w-full mb-6 glass-panel rounded-2xl p-3 sm:p-4 shadow-lg border border-slate-800">
      <div className="flex items-center justify-between gap-2 mb-3">
        <div className="flex items-center gap-2">
          <CalendarIcon className="w-4 h-4 text-cyan-400" />
          <span className="text-sm sm:text-base font-bold text-white font-['Outfit']">
            {formattedSelected}
          </span>
          {selectedDate === todayStr && (
            <span className="px-2 py-0.5 text-[10px] font-extrabold uppercase rounded bg-cyan-500/20 text-cyan-300 border border-cyan-500/40">
              Today
            </span>
          )}
        </div>

        <div className="flex items-center gap-1.5">
          <button
            onClick={handleTodayClick}
            className="px-2.5 py-1 text-xs font-semibold rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white border border-slate-700 transition-colors"
          >
            Jump to Today
          </button>
          <div className="flex items-center gap-1">
            <button
              onClick={handlePrevDay}
              aria-label="Previous Day"
              className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-slate-700 text-slate-300 hover:text-white border border-slate-700 transition-colors"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              onClick={handleNextDay}
              aria-label="Next Day"
              className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-slate-700 text-slate-300 hover:text-white border border-slate-700 transition-colors"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      <div
        ref={scrollRef}
        className="flex items-center gap-2 overflow-x-auto pb-2 pt-1 no-scrollbar scroll-smooth"
        style={{ scrollSnapType: "x mandatory" }}
      >
        {allDates.map((dateKey) => {
          const d = new Date(`${dateKey}T12:00:00`);
          const dayName = d.toLocaleDateString("en-US", { weekday: "short" });
          const monthName = d.toLocaleDateString("en-US", { month: "short" });
          const dayNum = d.getDate();
          const isSelected = dateKey === selectedDate;

          const stats = dayStatsMap[dateKey];
          const rate = stats ? stats.completionRate : 0;

          return (
            <button
              key={dateKey}
              data-date={dateKey}
              onClick={() => onSelectDate(dateKey)}
              style={{ scrollSnapAlign: "center" }}
              className={`flex-shrink-0 flex flex-col items-center justify-between w-14 sm:w-16 py-2.5 px-1.5 rounded-xl border transition-all ${
                isSelected
                  ? "bg-gradient-to-b from-cyan-950/80 to-slate-900 border-cyan-400 shadow-neon-cyan scale-105"
                  : "bg-slate-900/60 border-slate-800/80 hover:border-slate-700 text-slate-400 hover:text-slate-200"
              }`}
            >
              <span className={`text-[10px] font-bold uppercase tracking-wider ${isSelected ? "text-cyan-400" : "text-slate-500"}`}>
                {dayName}
              </span>
              <span className={`text-base sm:text-lg font-black font-['Outfit'] my-0.5 ${isSelected ? "text-white glow-text-cyan" : "text-slate-200"}`}>
                {dayNum}
              </span>
              <span className="text-[9px] uppercase tracking-wider font-semibold text-slate-500">
                {monthName}
              </span>

              <div className="w-full flex items-center justify-center mt-1.5">
                {rate === 100 ? (
                  <div className="w-2.5 h-2.5 rounded-full bg-emerald-400 shadow-[0_0_8px_#34d399]" />
                ) : rate >= 50 ? (
                  <div className="w-2.5 h-2.5 rounded-full bg-cyan-400 shadow-[0_0_8px_#38bdf8]" />
                ) : rate > 0 ? (
                  <div className="w-2 h-2 rounded-full bg-sky-600" />
                ) : (
                  <div className="w-1.5 h-1.5 rounded-full bg-slate-800" />
                )}
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
};
