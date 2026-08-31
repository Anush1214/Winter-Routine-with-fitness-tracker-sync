"use client";

import React, { useState, useEffect } from "react";
import { audio } from "../lib/audio";
import { Shield, Sparkles } from "lucide-react";

interface WebAriseSplashProps {
  onComplete: () => void;
}

export const WebAriseSplash: React.FC<WebAriseSplashProps> = ({ onComplete }) => {
  const [phase, setPhase] = useState<number>(0);
  const [statusText, setStatusText] = useState<string>("INITIALIZING SYSTEM PROTOCOL...");
  const [progress, setProgress] = useState<number>(10);

  useEffect(() => {
    audio.playLevelUp();

    const t1 = setTimeout(() => {
      setPhase(1);
      setStatusText("[ SYSTEM COMMAND DETECTED ]");
      setProgress(55);
      audio.playClick();
    }, 1100);

    const t2 = setTimeout(() => {
      setPhase(2);
      setStatusText("COMMAND: 「 A R I S E 」");
      setProgress(100);
      audio.playVictory();
    }, 2200);

    const t3 = setTimeout(() => {
      onComplete();
    }, 3400);

    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
      clearTimeout(t3);
    };
  }, [onComplete]);

  return (
    <div className="fixed inset-0 z-50 bg-[#02050E] flex flex-col items-center justify-between p-6 sm:p-10 select-none overflow-hidden">
      {/* Background radial aura */}
      <div
        className={`absolute inset-0 transition-opacity duration-1000 pointer-events-none ${
          phase === 2
            ? "opacity-80 bg-[radial-gradient(circle_at_center,rgba(0,240,255,0.25)_0%,rgba(168,85,247,0.15)_40%,transparent_70%)]"
            : "opacity-40 bg-[radial-gradient(circle_at_center,rgba(0,240,255,0.15)_0%,transparent_60%)]"
        }`}
      />

      {/* Top Tag */}
      <div className="relative z-10 pt-4">
        <div className="flex items-center gap-2 px-4 py-1.5 rounded-full bg-slate-950/80 border border-cyan-400/60 shadow-[0_0_15px_rgba(0,240,255,0.3)]">
          <span className="w-2 h-2 rounded-full bg-cyan-400 animate-ping" />
          <span className="text-[11px] font-mono font-extrabold uppercase tracking-widest text-cyan-300">
            SOLO LEVELING // SYSTEM LINK
          </span>
        </div>
      </div>

      {/* Center Monarch Emblem */}
      <div className="relative z-10 flex flex-col items-center justify-center my-auto">
        <div className="relative w-28 h-28 sm:w-36 sm:h-36 rounded-3xl bg-slate-950 border-2 border-cyan-400 p-1 flex items-center justify-center shadow-[0_0_40px_rgba(0,240,255,0.6)] animate-pulse overflow-hidden">
          <img
            src="/app_logo.jpg"
            alt="Winter Arc Protocol"
            className="w-full h-full object-cover rounded-2xl"
          />
          <Sparkles className="absolute -top-2 -right-2 w-6 h-6 text-violet-400 animate-spin" />
        </div>

        <h1 className="mt-8 text-2xl sm:text-4xl font-black font-['Outfit'] tracking-widest uppercase text-white glow-text-system text-center">
          WINTER ARC PROTOCOL
        </h1>
        <p className="mt-2 text-xs font-mono text-cyan-400/80 tracking-widest uppercase text-center">
          SHADOW MONARCH AWAKENING PROTOCOL
        </p>
      </div>

      {/* Bottom Holographic Command Bar */}
      <div className="relative z-10 w-full max-w-md pb-4">
        <div
          className={`p-4 rounded-2xl bg-slate-950/90 border transition-all duration-500 text-center ${
            phase === 2
              ? "border-cyan-400 shadow-[0_0_30px_rgba(0,240,255,0.5)] scale-105"
              : "border-cyan-500/30 shadow-[0_0_15px_rgba(0,240,255,0.15)]"
          }`}
        >
          <div
            className={`font-black font-mono tracking-wider transition-all ${
              phase === 2
                ? "text-xl sm:text-2xl text-cyan-300 drop-shadow-[0_0_12px_rgba(0,240,255,0.8)]"
                : "text-sm text-white"
            }`}
          >
            {statusText}
          </div>
          <div className="text-[10px] font-mono text-sky-400 tracking-wider mt-1 uppercase">
            HUNTER AWAKENING SEQUENCE: ACTIVE
          </div>

          {/* Linear Progress Bar */}
          <div className="w-full bg-slate-900 rounded-full h-1.5 mt-3 overflow-hidden border border-cyan-500/20">
            <div
              className={`h-full transition-all duration-700 rounded-full ${
                phase === 2 ? "bg-cyan-400 shadow-[0_0_10px_#00F0FF]" : "bg-violet-500"
              }`}
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>
      </div>
    </div>
  );
};
