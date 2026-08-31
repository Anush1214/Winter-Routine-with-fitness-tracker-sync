"use client";

import React, { useState, useEffect } from "react";
import {
  Shield,
  Bell,
  Watch,
  Plus,
  Volume2,
  VolumeX,
  Flame,
  Clock,
  DownloadCloud,
  Crown,
  Sparkles,
} from "lucide-react";
import { audio } from "../lib/audio";
import { getWinterArcDaysRemaining } from "../lib/utils";

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
  const [istTimeStr, setIstTimeStr] = useState<string>("");
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);

  useEffect(() => {
    setSoundEnabled(audio.isEnabled());

    const updateClock = () => {
      const now = new Date();
      setIstTimeStr(
        now.toLocaleTimeString("en-IN", {
          timeZone: "Asia/Kolkata",
          hour: "2-digit",
          minute: "2-digit",
          second: "2-digit",
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

  // Determine Hunter Rank based on streak/day
  let hunterRank = "E-RANK";
  let rankColor = "text-slate-400 border-slate-700 bg-slate-900";
  if (activeStreak >= 30) {
    hunterRank = "S-RANK MONARCH";
    rankColor = "text-cyan-300 border-cyan-400 bg-cyan-950/80 shadow-[0_0_12px_rgba(0,240,255,0.4)]";
  } else if (activeStreak >= 20) {
    hunterRank = "A-RANK";
    rankColor = "text-violet-300 border-violet-400 bg-violet-950/80";
  } else if (activeStreak >= 10) {
    hunterRank = "B-RANK";
    rankColor = "text-amber-300 border-amber-400 bg-amber-950/80";
  } else if (activeStreak >= 5) {
    hunterRank = "C-RANK";
    rankColor = "text-emerald-300 border-emerald-400 bg-emerald-950/80";
  } else if (activeStreak >= 1) {
    hunterRank = "D-RANK";
    rankColor = "text-sky-300 border-sky-400 bg-sky-950/80";
  }

  return (
    <header className="w-full mb-6">
      {/* Solo Leveling System Header Bar */}
      <div className="system-window rounded-2xl p-4 sm:p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        {/* Left: System Identification & Hunter Title */}
        <div className="flex items-center gap-3.5">
          <div className="relative flex items-center justify-center w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-500/30 via-blue-900/40 to-slate-950 border border-cyan-400 shadow-[0_0_20px_rgba(0,240,255,0.35)]">
            <Crown className="w-6 h-6 text-cyan-300 animate-pulse" />
            <div className="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-cyan-400 animate-ping" />
            <div className="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-cyan-400" />
          </div>

          <div>
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-[10px] font-mono font-black uppercase tracking-widest text-cyan-400 bg-cyan-950/80 px-2 py-0.5 rounded border border-cyan-500/40">
                [ SYSTEM : ACTIVE ]
              </span>
              <h1 className="text-xl sm:text-2xl font-black tracking-wider uppercase font-['Outfit'] text-white glow-text-system">
                WINTER ARC PROTOCOL
              </h1>
            </div>

            <div className="flex items-center gap-2 mt-1 text-xs text-slate-300 font-mono">
              <span className="text-cyan-300 font-bold">LEVEL {timeline.dayNumber} / 122</span>
              <span className="text-slate-600">•</span>
              <span className={`px-2 py-0.2 text-[10px] font-extrabold rounded border ${rankColor}`}>
                {hunterRank}
              </span>
              <span className="text-slate-600 hidden sm:inline">•</span>
              <span className="text-slate-400 hidden sm:inline">SEPT 1 — DEC 31</span>
            </div>
          </div>
        </div>

        {/* Right: Controls & Actions */}
        <div className="flex items-center gap-2 flex-wrap w-full sm:w-auto justify-between sm:justify-end">
          {/* Streak Badge */}
          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-orange-950/60 border border-orange-500/40 text-orange-300 text-xs font-bold font-mono shadow-[0_0_10px_rgba(249,115,22,0.2)]">
            <Flame className="w-3.5 h-3.5 fill-orange-400 text-orange-400 animate-bounce" />
            <span>{activeStreak}D STREAK</span>
          </div>

          {/* Live IST System Clock */}
          <div className="hidden md:flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-slate-950/80 border border-cyan-500/20 text-cyan-300 text-xs font-mono">
            <Clock className="w-3.5 h-3.5 text-cyan-400" />
            <span>{istTimeStr}</span>
          </div>

          {/* Sound FX */}
          <button
            onClick={handleToggleSound}
            aria-label="Toggle Sound"
            className="p-2 rounded-lg bg-slate-950/80 border border-cyan-500/30 hover:border-cyan-400 text-cyan-300 hover:shadow-[0_0_10px_rgba(0,240,255,0.3)] transition-all"
            title={soundEnabled ? "System Audio: ON" : "System Audio: MUTED"}
          >
            {soundEnabled ? (
              <Volume2 className="w-4 h-4 text-cyan-400" />
            ) : (
              <VolumeX className="w-4 h-4 text-slate-600" />
            )}
          </button>

          {/* Alerts / Notifications */}
          <button
            onClick={onOpenNotificationModal}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-950/80 border border-cyan-500/30 hover:border-cyan-400 text-cyan-300 text-xs font-mono font-bold hover:shadow-[0_0_10px_rgba(0,240,255,0.3)] transition-all"
          >
            <Bell className="w-3.5 h-3.5 text-cyan-400" />
            <span className="hidden xs:inline">Alerts Hub</span>
          </button>

          {/* Smartwatch Sync */}
          <button
            onClick={onOpenSmartwatchModal}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-950/80 border border-violet-500/40 hover:border-violet-400 text-violet-300 text-xs font-mono font-bold hover:shadow-[0_0_10px_rgba(139,92,246,0.3)] transition-all"
          >
            <Watch className="w-3.5 h-3.5 text-violet-400" />
            <span className="hidden xs:inline">Watch Sync</span>
          </button>

          {/* Add Routine */}
          <button
            onClick={onOpenTaskModal}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-slate-950 font-black text-xs font-mono shadow-[0_0_15px_rgba(0,240,255,0.5)] transition-all transform active:scale-95"
          >
            <Plus className="w-3.5 h-3.5 stroke-[3]" />
            <span>+ Add Quest</span>
          </button>

          {/* PWA Install */}
          {deferredPrompt && (
            <button
              onClick={handleInstallPWA}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-emerald-950/80 border border-emerald-400 text-emerald-300 text-xs font-bold"
            >
              <DownloadCloud className="w-3.5 h-3.5" />
              <span>Install PWA</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
};
