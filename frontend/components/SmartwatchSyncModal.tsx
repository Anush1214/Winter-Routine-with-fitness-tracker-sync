"use client";

import React, { useState } from "react";
import {
  X,
  Watch,
  Zap,
  Footprints,
  Moon,
  Dumbbell,
  Droplets,
  Copy,
  Check,
  Smartphone,
} from "lucide-react";
import { audio } from "../lib/audio";

interface SmartwatchSyncModalProps {
  isOpen: boolean;
  onClose: () => void;
  selectedDate: string;
  currentSteps: number;
  currentSleep: number;
  currentGym: boolean;
  currentWater: number;
  onSyncSuccess: (data: any) => void;
}

export const SmartwatchSyncModal: React.FC<SmartwatchSyncModalProps> = ({
  isOpen,
  onClose,
  selectedDate,
  currentSteps,
  currentSleep,
  currentGym,
  currentWater,
  onSyncSuccess,
}) => {
  const [steps, setSteps] = useState<number>(currentSteps || 10450);
  const [sleepMinutes, setSleepMinutes] = useState<number>(currentSleep || 450);
  const [gymDone, setGymDone] = useState<boolean>(currentGym || true);
  const [waterMl, setWaterMl] = useState<number>(currentWater || 3000);
  const [isSyncing, setIsSyncing] = useState(false);
  const [syncStatus, setSyncStatus] = useState<string | null>(null);
  const [copiedCurl, setCopiedCurl] = useState(false);
  const [copiedUrl, setCopiedUrl] = useState(false);

  if (!isOpen) return null;

  const appOrigin = typeof window !== "undefined" ? window.location.origin : "https://your-app.vercel.app";
  const webhookUrl = `${appOrigin}/api/sync-health`;

  const curlExample = `curl -X POST ${webhookUrl} \\
  -H "Content-Type: application/json" \\
  -d '{
    "date": "${selectedDate}",
    "steps": ${steps},
    "sleepMinutes": ${sleepMinutes},
    "gymWorkoutDone": ${gymDone},
    "waterIntakeMl": ${waterMl}
  }'`;

  const handleSimulateSync = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSyncing(true);
    setSyncStatus(null);

    try {
      const res = await fetch("/api/sync-health", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          date: selectedDate,
          steps: Number(steps),
          sleepMinutes: Number(sleepMinutes),
          gymWorkoutDone: Boolean(gymDone),
          waterIntakeMl: Number(waterMl),
        }),
      });

      const data = await res.json();
      if (data.success) {
        audio.playChime();
        setSyncStatus(`✅ Synced! Auto-completed: ${data.autoCheckedTasks?.join(", ") || "metrics updated"}`);
        onSyncSuccess(data);
      } else {
        setSyncStatus(`❌ Sync error: ${data.error || "Failed"}`);
      }
    } catch (err: any) {
      setSyncStatus(`❌ Network error: ${err.message}`);
    } finally {
      setIsSyncing(false);
    }
  };

  const handleCopyCurl = () => {
    navigator.clipboard.writeText(curlExample);
    setCopiedCurl(true);
    setTimeout(() => setCopiedCurl(false), 2000);
  };

  const handleCopyUrl = () => {
    navigator.clipboard.writeText(webhookUrl);
    setCopiedUrl(true);
    setTimeout(() => setCopiedUrl(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/80 backdrop-blur-sm animate-fadeIn">
      <div className="w-full max-w-2xl glass-panel rounded-2xl p-5 sm:p-6 border border-slate-700 shadow-2xl bg-slate-950/95 relative max-h-[90vh] overflow-y-auto">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-400 hover:text-white transition-colors"
        >
          <X className="w-4 h-4" />
        </button>

        <div className="flex items-center gap-2.5 mb-5 pb-3 border-b border-slate-800">
          <div className="p-2 rounded-xl bg-violet-950 border border-violet-500/30 text-violet-400">
            <Watch className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-lg sm:text-xl font-bold text-white font-['Outfit']">
              Smartwatch Health Sync & Automation
            </h3>
            <p className="text-xs text-slate-400 font-mono">
              Target Date: {selectedDate} • CMF Watch Pro 2 / Apple Health / Health Connect
            </p>
          </div>
        </div>

        <div className="mb-6 p-4 rounded-xl bg-slate-900/80 border border-slate-800 space-y-4">
          <div className="flex items-center justify-between">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-300 flex items-center gap-1.5">
              <Zap className="w-3.5 h-3.5 text-violet-400" />
              <span>Interactive Watch Simulator</span>
            </h4>
            <span className="text-[10px] font-mono text-cyan-400 bg-cyan-950 px-2 py-0.5 rounded border border-cyan-800">
              Live Test
            </span>
          </div>

          <form onSubmit={handleSimulateSync} className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div className="p-3 rounded-xl bg-slate-950 border border-slate-800">
                <label className="flex items-center gap-1.5 text-xs font-bold text-emerald-400 mb-1.5">
                  <Footprints className="w-3.5 h-3.5" />
                  <span>Step Count (10k Goal)</span>
                </label>
                <input
                  type="number"
                  value={steps}
                  onChange={(e) => setSteps(Number(e.target.value))}
                  className="w-full bg-slate-900 border border-slate-800 rounded-lg px-3 py-1.5 text-sm text-white font-mono focus:border-emerald-500 focus:outline-none"
                />
              </div>

              <div className="p-3 rounded-xl bg-slate-950 border border-slate-800">
                <label className="flex items-center gap-1.5 text-xs font-bold text-violet-400 mb-1.5">
                  <Moon className="w-3.5 h-3.5" />
                  <span>Sleep Minutes (420m = 7h)</span>
                </label>
                <input
                  type="number"
                  value={sleepMinutes}
                  onChange={(e) => setSleepMinutes(Number(e.target.value))}
                  className="w-full bg-slate-900 border border-slate-800 rounded-lg px-3 py-1.5 text-sm text-white font-mono focus:border-violet-500 focus:outline-none"
                />
              </div>

              <div className="p-3 rounded-xl bg-slate-950 border border-slate-800">
                <label className="flex items-center gap-1.5 text-xs font-bold text-cyan-400 mb-1.5">
                  <Droplets className="w-3.5 h-3.5" />
                  <span>Water Intake (ml)</span>
                </label>
                <input
                  type="number"
                  value={waterMl}
                  onChange={(e) => setWaterMl(Number(e.target.value))}
                  className="w-full bg-slate-900 border border-slate-800 rounded-lg px-3 py-1.5 text-sm text-white font-mono focus:border-cyan-500 focus:outline-none"
                />
              </div>

              <div className="p-3 rounded-xl bg-slate-950 border border-slate-800 flex items-center justify-between">
                <div>
                  <label className="flex items-center gap-1.5 text-xs font-bold text-amber-400">
                    <Dumbbell className="w-3.5 h-3.5" />
                    <span>Gym Workout Done</span>
                  </label>
                  <span className="text-[10px] text-slate-400 block mt-0.5">
                    Triggers 6-7 Gym task
                  </span>
                </div>
                <input
                  type="checkbox"
                  checked={gymDone}
                  onChange={(e) => setGymDone(e.target.checked)}
                  className="w-5 h-5 rounded accent-amber-500 cursor-pointer"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={isSyncing}
              className="w-full py-2.5 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white font-bold text-xs shadow-neon-violet transition-all transform active:scale-95 disabled:opacity-50 flex items-center justify-center gap-2"
            >
              <Zap className="w-4 h-4" />
              <span>{isSyncing ? "Syncing Watch Data..." : "Push Health Sync to Database"}</span>
            </button>
          </form>

          {syncStatus && (
            <div className="p-3 rounded-xl bg-slate-950 border border-slate-800 text-xs font-mono text-cyan-300">
              {syncStatus}
            </div>
          )}
        </div>

        <div className="p-4 rounded-xl bg-slate-900/80 border border-slate-800 space-y-3">
          <div className="flex items-center justify-between">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-300 flex items-center gap-1.5">
              <Smartphone className="w-3.5 h-3.5 text-cyan-400" />
              <span>Automate from Phone (Shortcuts / Tasker / Health Connect)</span>
            </h4>
          </div>

          <div className="space-y-2 text-xs text-slate-300">
            <p>
              Connect your <strong>CMF Watch Pro 2</strong> via Apple Health / Health Connect webhooks.
            </p>

            <div className="flex items-center justify-between gap-2 p-2 rounded-lg bg-slate-950 border border-slate-800 font-mono text-[11px]">
              <span className="truncate text-cyan-300">{webhookUrl}</span>
              <button
                onClick={handleCopyUrl}
                className="p-1.5 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 flex-shrink-0"
                title="Copy webhook URL"
              >
                {copiedUrl ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
              </button>
            </div>

            <div className="relative mt-2">
              <pre className="p-3 rounded-lg bg-slate-950 border border-slate-800 text-[11px] font-mono text-slate-300 overflow-x-auto">
                {curlExample}
              </pre>
              <button
                onClick={handleCopyCurl}
                className="absolute top-2 right-2 p-1.5 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs flex items-center gap-1"
              >
                {copiedCurl ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                <span className="text-[10px]">Copy curl</span>
              </button>
            </div>
          </div>
        </div>

        <div className="flex items-center justify-end pt-4 border-t border-slate-800 mt-5">
          <button
            onClick={onClose}
            className="px-5 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-slate-300 text-xs font-semibold border border-slate-800 transition-colors"
          >
            Done
          </button>
        </div>
      </div>
    </div>
  );
};
