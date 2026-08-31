"use client";

import React, { useState, useEffect } from "react";
import {
  Shield,
  Flame,
  Clock,
  DownloadCloud,
  Crown,
} from "lucide-react";
import { audio } from "../lib/audio";
import { getWinterArcDaysRemaining } from "../lib/utils";

interface HeaderProps {
  currentDate: string;
  onOpenTaskModal: () => void;
  onOpenNotificationModal: () => void;
  onOpenSmartwatchModal: () => void;
  activeStreak: number;
  hunterUser?: {
    uid: string;
    email: string;
    displayName: string;
    photoUrl?: string;
    provider: string;
    gender?: string;
  } | null;
  onOpenProfile?: () => void;
  onOpenAuth?: () => void;
  onOpenGeminiAI?: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  currentDate,
  onOpenTaskModal,
  onOpenNotificationModal,
  onOpenSmartwatchModal,
  activeStreak,
  hunterUser,
  onOpenProfile,
  onOpenAuth,
  onOpenGeminiAI,
}) => {
  const [istTimeStr, setIstTimeStr] = useState<string>("");
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);

  useEffect(() => {
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

  const handleInstallPWA = async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === "accepted") {
      setDeferredPrompt(null);
    }
  };

  const currentLevel = 1;
  const isFemale = hunterUser?.gender === "female";
  const systemName = isFemale ? "S-Rank Dancer" : "Shadow Monarch";

  return (
    <header className={`relative z-10 w-full px-4 sm:px-6 py-4 backdrop-blur-xl border-b ${
      isFemale ? "bg-[#140b02]/90 border-amber-500/40" : "bg-[#090414]/90 border-purple-500/30"
    }`}>
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
        {/* Left: Branding & Identity */}
        <div className="flex items-center gap-3.5 w-full md:w-auto justify-between md:justify-start">
          <div className="flex items-center gap-3">
            <div className={`relative flex items-center justify-center w-12 h-12 rounded-2xl bg-gradient-to-br p-0.5 shadow-lg ${
              isFemale
                ? "from-amber-400 via-yellow-500 to-amber-700 shadow-[0_0_20px_rgba(251,191,36,0.4)]"
                : "from-blue-500 via-purple-600 to-purple-900 shadow-[0_0_20px_rgba(168,85,247,0.4)]"
            }`}>
              <div className="w-full h-full bg-slate-950 rounded-[14px] flex items-center justify-center">
                <Crown className={`w-6 h-6 ${isFemale ? "text-amber-400 animate-pulse" : "text-cyan-400 animate-pulse"}`} />
              </div>
            </div>

            <div>
              <div className="flex items-center gap-2">
                <span className={`px-2 py-0.5 rounded text-[10px] font-mono font-bold uppercase tracking-widest border ${
                  isFemale
                    ? "bg-amber-950/80 text-amber-300 border-amber-500/40"
                    : "bg-purple-950/80 text-purple-300 border-purple-500/30"
                }`}>
                  [ SYSTEM : {hunterUser?.displayName || systemName} ]
                </span>
              </div>
              <h1 className={`text-xl sm:text-2xl font-black font-['Outfit'] uppercase tracking-wider ${
                isFemale ? "text-amber-200" : "text-white"
              }`}>
                WINTER ARC PROTOCOL
              </h1>
              <p className="text-[11px] font-mono text-slate-400">
                LEVEL {currentLevel} / 122 • <span className={`font-bold ${isFemale ? "text-amber-400" : "text-purple-400"}`}>E-RANK</span> • SEPT 1 – DEC 31
              </p>
            </div>
          </div>

          {/* Profile Button on Mobile Right */}
          <div className="md:hidden">
            {hunterUser ? (
              <button
                onClick={onOpenProfile}
                className={`p-1 rounded-xl bg-slate-950 border ${
                  isFemale ? "border-amber-400" : "border-purple-400"
                }`}
              >
                {hunterUser.photoUrl ? (
                  <img
                    src={hunterUser.photoUrl}
                    alt={hunterUser.displayName}
                    className="w-8 h-8 rounded-lg object-cover"
                  />
                ) : (
                  <div className="w-8 h-8 rounded-lg bg-purple-950 flex items-center justify-center text-purple-300 font-bold font-mono text-xs">
                    {hunterUser.displayName.charAt(0).toUpperCase()}
                  </div>
                )}
              </button>
            ) : (
              <button
                onClick={onOpenAuth}
                className="px-3 py-1 rounded-lg bg-slate-900 border border-purple-500/50 text-purple-300 text-xs font-mono font-bold"
              >
                Login
              </button>
            )}
          </div>
        </div>

        {/* Right Action Bar: STREAMLINED TO ONLY STREAK & TIME (Controls in bottom navbar) */}
        <div className="flex items-center flex-wrap gap-2.5 justify-center md:justify-end w-full md:w-auto">
          {/* Streak Flame Badge */}
          <div className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-amber-950/80 border border-amber-500/50 text-amber-300 font-mono font-bold text-xs shadow-[0_0_12px_rgba(245,158,11,0.25)]">
            <Flame className="w-4 h-4 text-amber-400 fill-amber-400 animate-pulse" />
            <span>{activeStreak}D STREAK</span>
          </div>

          {/* Live IST Clock */}
          <div className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-slate-950 border text-xs font-mono font-bold ${
            isFemale ? "border-amber-500/40 text-amber-200" : "border-purple-500/30 text-purple-200"
          }`}>
            <Clock className={`w-3.5 h-3.5 ${isFemale ? "text-amber-400" : "text-purple-400"}`} />
            <span>{istTimeStr}</span>
          </div>

          {/* Hunter Profile Avatar / Login (Desktop) */}
          <div className="hidden md:block">
            {hunterUser ? (
              <button
                onClick={onOpenProfile}
                title={`Hunter Profile (${hunterUser.displayName})`}
                className={`flex items-center gap-1.5 p-1 rounded-xl bg-slate-950 border shadow-lg hover:scale-105 transition-all ${
                  isFemale ? "border-amber-400 shadow-amber-500/20" : "border-purple-400 shadow-purple-500/20"
                }`}
              >
                {hunterUser.photoUrl ? (
                  <img
                    src={hunterUser.photoUrl}
                    alt={hunterUser.displayName}
                    className="w-8 h-8 rounded-lg object-cover"
                  />
                ) : (
                  <div className="w-8 h-8 rounded-lg bg-purple-950 flex items-center justify-center text-purple-300 font-bold font-mono text-xs">
                    {hunterUser.displayName.charAt(0).toUpperCase()}
                  </div>
                )}
              </button>
            ) : (
              <button
                onClick={onOpenAuth}
                className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-slate-900 border border-purple-500/50 hover:border-purple-400 text-purple-300 text-xs font-mono font-bold transition-all"
              >
                <Shield className="w-3.5 h-3.5 text-purple-400" />
                <span>Login</span>
              </button>
            )}
          </div>

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
