"use client";

import React, { useState, useEffect } from "react";
import {
  Snowflake,
  Bell,
  Watch,
  Plus,
  Volume2,
  VolumeX,
  Calendar,
  Flame,
  Clock,
  Sparkles,
  DownloadCloud,
} from "lucide-react";
import { audio } from "@/lib/audio";
import { getWinterArcDaysRemaining } from "@/lib/utils";

interface HeaderProps {
  currentDate: string;
  onOpenTaskModal: () => void;
  onOpenNotificationModal: () => void;
  onOpenSmartwatchModal: () => void;
  activeStreak: number;
}

export const Header: React.FC<HeaderProps> = ({
  currentDate,
  onOpenTaskModal,
  onOpenNotificationModal,
  onOpenSmartwatchModal,
  activeStreak,
}) => {
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [timeStr, setTimeStr] = useState<string>("");
  const [istTimeStr, setIstTimeStr] = useState<string>("");
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);

  useEffect(() => {
    setSoundEnabled(audio.isEnabled());

    const updateClock = () => {
      const now = new Date();
      setTimeStr(
        now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" })
      );
      setIstTimeStr(
        now.toLocaleTimeString("en-IN", {
          timeZone: "Asia/Kolkata",
          hour: "2-digit",
          minute: "2-digit",
        }) + " IST"
      );
    };

    updateClock();
    const interval = setInterval(updateClock, 1000);

    const handleBeforeInstallPrompt = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e);
    };

    window.addEventListener("beforeinstallprompt", handleBeforeInstallPrompt);

    return () => {
      clearInterval(interval);
      window.removeEventListener("beforeinstallprompt", handleBeforeInstallPrompt);
    };
  }, []);

  const handleToggleSound = () => {
    const next = audio.toggleSound();
    setSoundEnabled(next);
  };

  const handleInstallPWA = async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === "accepted") {
      setDeferredPrompt(null);
    }
  };

  const timeline = getWinterArcDaysRemaining(new Date(`${currentDate}T12:00:00`));

  return (
    <header className="w-full mb-6">
      {/* Top Banner / Protocol Badge */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pb-4 border-b border-slate-800/80">
        <div className="flex items-center gap-3">
          <div className="relative flex items-center justify-center w-11 h-11 rounded-xl bg-gradient-to-br from-cyan-500/20 via-sky-500/10 to-violet-500/20 border border-cyan-500/30 shadow-neon-cyan">
            <Snowflake className="w-6 h-6 text-cyan-400 animate-spin-slow" />
            <div className="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-emerald-400 animate-ping" />
            <div className="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-emerald-400" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl sm:text-2xl font-black tracking-wider uppercase font-['Outfit'] bg-gradient-to-r from-white via-cyan-200 to-sky-400 bg-clip-text text-transparent">
                WINTER ARC
              </h1>
              <span className="px-2 py-0.5 text-[10px] font-bold uppercase tracking-widest rounded-full bg-cyan-950 text-cyan-400 border border-cyan-800/50">
                2026
              </span>
            </div>
            <p className="text-xs text-slate-400 flex items-center gap-2">
              <span>Sept 1 — Dec 31</span>
              <span className="text-slate-600">•</span>
              <span className="text-cyan-400 font-mono font-medium">Day {timeline.dayNumber}/122</span>
            </p>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex items-center gap-1.5 sm:gap-2 flex-wrap w-full sm:w-auto justify-between sm:justify-end">
          {/* Active Streak */}
          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-orange-950/40 border border-orange-500/30 text-orange-400 text-xs font-bold font-mono">
            <Flame className="w-3.5 h-3.5 fill-orange-400 text-orange-400 animate-bounce" />
            <span>{activeStreak}D STREAK</span>
          </div>

          {/* Time indicator */}
          <div className="hidden md:flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-slate-900/80 border border-slate-800 text-slate-300 text-xs font-mono">
            <Clock className="w-3.5 h-3.5 text-cyan-400" />
            <span>{istTimeStr || timeStr}</span>
          </div>

          {/* Sound Toggle */}
          <button
            onClick={handleToggleSound}
            aria-label="Toggle Sound"
            className="p-2 rounded-lg bg-slate-900/80 border border-slate-800 hover:border-slate-700 text-slate-300 hover:text-cyan-300 transition-colors"
            title={soundEnabled ? "Sound FX: On" : "Sound FX: Muted"}
          >
            {soundEnabled ? (
              <Volume2 className="w-4 h-4 text-cyan-400" />
            ) : (
              <VolumeX className="w-4 h-4 text-slate-500" />
            )}
          </button>

          {/* Push Notifications Hub */}
          <button
            onClick={onOpenNotificationModal}
            className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-slate-900/80 border border-slate-800 hover:border-cyan-500/40 text-slate-300 hover:text-cyan-300 transition-all text-xs font-medium"
            title="Notification Hub & Mobile Push"
          >
            <Bell className="w-3.5 h-3.5 text-cyan-400" />
            <span className="hidden xs:inline">Alerts</span>
          </button>

          {/* Smartwatch Sync */}
          <button
            onClick={onOpenSmartwatchModal}
            className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-slate-900/80 border border-slate-800 hover:border-violet-500/40 text-slate-300 hover:text-violet-300 transition-all text-xs font-medium"
            title="CMF Watch Pro 2 / Smartwatch Ingestion"
          >
            <Watch className="w-3.5 h-3.5 text-violet-400" />
            <span className="hidden xs:inline">Watch Sync</span>
          </button>

          {/* Add Custom Task */}
          <button
            onClick={onOpenTaskModal}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-gradient-to-r from-cyan-500 to-sky-500 hover:from-cyan-400 hover:to-sky-400 text-slate-950 font-bold text-xs shadow-neon-cyan transition-all transform active:scale-95"
          >
            <Plus className="w-3.5 h-3.5 stroke-[3]" />
            <span>Add Routine</span>
          </button>

          {/* Install PWA Prompt Button */}
          {deferredPrompt && (
            <button
              onClick={handleInstallPWA}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-emerald-950/60 border border-emerald-500/40 text-emerald-400 text-xs font-bold hover:bg-emerald-900/40 transition-colors"
            >
              <DownloadCloud className="w-3.5 h-3.5" />
              <span>Install App</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
};
