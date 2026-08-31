"use client";

import React, { useState, useEffect } from "react";
import {
  X,
  Bell,
  Send,
  QrCode,
  ExternalLink,
  CheckCircle2,
  Clock,
  Plus,
  Trash2,
  Settings2,
  Smartphone,
  Copy,
  Check,
  AlertCircle,
} from "lucide-react";

interface NotificationSettings {
  ntfyTopic: string;
  ntfyServer: string;
  morningTime: string;
  morningEnabled: boolean;
  eveningTime: string;
  eveningEnabled: boolean;
  nightTime: string;
  nightEnabled: boolean;
  waterGoalMl: number;
  stepsGoal: number;
  sleepGoalMinutes: number;
  customSlots?: string | null;
}

interface NotificationSettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
  selectedDate: string;
}

export const NotificationSettingsModal: React.FC<NotificationSettingsModalProps> = ({
  isOpen,
  onClose,
  selectedDate,
}) => {
  const [settings, setSettings] = useState<NotificationSettings>({
    ntfyTopic: "winter-arc-routine",
    ntfyServer: "https://ntfy.sh",
    morningTime: "07:00",
    morningEnabled: true,
    eveningTime: "18:30",
    eveningEnabled: true,
    nightTime: "22:30",
    nightEnabled: true,
    waterGoalMl: 4500,
    stepsGoal: 10000,
    sleepGoalMinutes: 420,
    customSlots: "[]",
  });

  const [customSlotsList, setCustomSlotsList] = useState<
    Array<{ id: string; name: string; time: string; enabled: boolean }>
  >([]);

  const [newSlotName, setNewSlotName] = useState("");
  const [newSlotTime, setNewSlotTime] = useState("14:00");

  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isTesting, setIsTesting] = useState(false);
  const [testSlot, setTestSlot] = useState("morning");
  const [testResult, setTestResult] = useState<string | null>(null);
  const [copiedUrl, setCopiedUrl] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);

  useEffect(() => {
    if (isOpen) {
      fetchSettings();
    }
  }, [isOpen]);

  const fetchSettings = async () => {
    try {
      setIsLoading(true);
      const res = await fetch("/api/settings");
      const data = await res.json();
      if (data.success && data.settings) {
        setSettings(data.settings);
        if (data.settings.customSlots) {
          try {
            setCustomSlotsList(JSON.parse(data.settings.customSlots));
          } catch {
            setCustomSlotsList([]);
          }
        }
      }
    } catch (e) {
      console.error("Error loading settings:", e);
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) return null;

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setIsSaving(true);
      setSaveSuccess(false);

      const payload = {
        ...settings,
        customSlots: JSON.stringify(customSlotsList),
      };

      const res = await fetch("/api/settings", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      const data = await res.json();
      if (data.success) {
        setSaveSuccess(true);
        setTimeout(() => setSaveSuccess(false), 3000);
      }
    } catch (err) {
      console.error("Save settings error:", err);
    } finally {
      setIsSaving(false);
    }
  };

  const handleTestPush = async () => {
    try {
      setIsTesting(true);
      setTestResult(null);

      const res = await fetch("/api/notifications/test", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          slot: testSlot,
          topic: settings.ntfyTopic,
          server: settings.ntfyServer,
          date: selectedDate,
        }),
      });

      const data = await res.json();
      if (data.success) {
        setTestResult(`✅ Push alert dispatched to '${settings.ntfyTopic}'!`);
      } else {
        setTestResult(`❌ Error: ${data.error || "Failed to trigger push"}`);
      }
    } catch (err: any) {
      setTestResult(`❌ Push error: ${err.message}`);
    } finally {
      setIsTesting(false);
    }
  };

  const handleAddCustomSlot = () => {
    if (!newSlotName.trim()) return;
    const newSlot = {
      id: `slot_${Date.now()}`,
      name: newSlotName.trim(),
      time: newSlotTime,
      enabled: true,
    };
    setCustomSlotsList([...customSlotsList, newSlot]);
    setNewSlotName("");
  };

  const handleRemoveCustomSlot = (id: string) => {
    setCustomSlotsList(customSlotsList.filter((s) => s.id !== id));
  };

  const handleToggleCustomSlot = (id: string) => {
    setCustomSlotsList(
      customSlotsList.map((s) => (s.id === id ? { ...s, enabled: !s.enabled } : s))
    );
  };

  const ntfyWebUrl = `${settings.ntfyServer}/${settings.ntfyTopic}`;

  const handleCopyNtfyUrl = () => {
    navigator.clipboard.writeText(ntfyWebUrl);
    setCopiedUrl(true);
    setTimeout(() => setCopiedUrl(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/80 backdrop-blur-sm animate-fadeIn">
      <div className="w-full max-w-2xl glass-panel rounded-2xl p-5 sm:p-6 border border-slate-700 shadow-2xl bg-slate-950/95 relative max-h-[90vh] overflow-y-auto">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-400 hover:text-white transition-colors"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Header */}
        <div className="flex items-center gap-2.5 mb-5 pb-3 border-b border-slate-800">
          <div className="p-2 rounded-xl bg-cyan-950 border border-cyan-500/30 text-cyan-400">
            <Bell className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-lg sm:text-xl font-bold text-white font-['Outfit']">
              Push Notification & Schedule Hub
            </h3>
            <p className="text-xs text-slate-400">
              Free native iOS & Android alerts via ntfy.sh (Zero developer account fee)
            </p>
          </div>
        </div>

        {/* 1-Click Mobile Subscription Card */}
        <div className="mb-6 p-4 rounded-xl bg-gradient-to-br from-cyan-950/40 via-slate-900 to-violet-950/30 border border-cyan-500/30">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
            <div>
              <span className="inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-wider text-cyan-400 mb-1">
                <Smartphone className="w-3.5 h-3.5" />
                <span>1-Step Mobile Setup</span>
              </span>
              <p className="text-xs text-slate-300">
                Install the free <strong className="text-white">ntfy app</strong> on iOS or Android, then subscribe to your topic:
              </p>
              <div className="flex items-center gap-2 mt-2">
                <code className="px-2.5 py-1 rounded bg-slate-950 border border-slate-800 text-cyan-300 font-mono text-xs">
                  {settings.ntfyTopic}
                </code>
                <button
                  onClick={handleCopyNtfyUrl}
                  className="p-1.5 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs flex items-center gap-1 transition-colors"
                  title="Copy direct ntfy link"
                >
                  {copiedUrl ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                </button>
              </div>
            </div>

            <a
              href={ntfyWebUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex-shrink-0 flex items-center gap-1.5 px-3 py-2 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-slate-950 text-xs font-bold shadow-neon-cyan transition-all"
            >
              <ExternalLink className="w-3.5 h-3.5" />
              <span>Open on ntfy.sh</span>
            </a>
          </div>
        </div>

        <form onSubmit={handleSave} className="space-y-5">
          {/* Channel / Topic Configuration */}
          <div className="p-4 rounded-xl bg-slate-900/80 border border-slate-800 space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-300 flex items-center gap-1.5">
              <Settings2 className="w-3.5 h-3.5 text-cyan-400" />
              <span>Channel Settings</span>
            </h4>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label className="block text-[11px] font-bold text-slate-400 mb-1">
                  ntfy Topic Name
                </label>
                <input
                  type="text"
                  required
                  value={settings.ntfyTopic}
                  onChange={(e) => setSettings({ ...settings, ntfyTopic: e.target.value })}
                  className="w-full bg-slate-950 border border-slate-800 focus:border-cyan-500 rounded-lg px-3 py-2 text-xs text-white font-mono focus:outline-none"
                />
              </div>
              <div>
                <label className="block text-[11px] font-bold text-slate-400 mb-1">
                  Server URL
                </label>
                <input
                  type="text"
                  value={settings.ntfyServer}
                  onChange={(e) => setSettings({ ...settings, ntfyServer: e.target.value })}
                  className="w-full bg-slate-950 border border-slate-800 focus:border-cyan-500 rounded-lg px-3 py-2 text-xs text-white font-mono focus:outline-none"
                />
              </div>
            </div>
          </div>

          {/* Dynamic Alert Delivery Slots */}
          <div className="p-4 rounded-xl bg-slate-900/80 border border-slate-800 space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-300 flex items-center gap-1.5">
              <Clock className="w-3.5 h-3.5 text-cyan-400" />
              <span>Daily Alert Slots & Timings (IST)</span>
            </h4>

            {/* Morning Slot */}
            <div className="flex items-center justify-between gap-3 p-2.5 rounded-lg bg-slate-950 border border-slate-800">
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={settings.morningEnabled}
                  onChange={(e) => setSettings({ ...settings, morningEnabled: e.target.checked })}
                  className="w-4 h-4 rounded accent-cyan-500 cursor-pointer"
                />
                <div>
                  <span className="text-xs font-bold text-white block">🌅 Morning Briefing</span>
                  <span className="text-[10px] text-slate-400">Day X/122 kickoff, gym & wake up routine</span>
                </div>
              </div>
              <input
                type="time"
                value={settings.morningTime}
                onChange={(e) => setSettings({ ...settings, morningTime: e.target.value })}
                className="bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-white font-mono"
              />
            </div>

            {/* Evening Slot */}
            <div className="flex items-center justify-between gap-3 p-2.5 rounded-lg bg-slate-950 border border-slate-800">
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={settings.eveningEnabled}
                  onChange={(e) => setSettings({ ...settings, eveningEnabled: e.target.checked })}
                  className="w-4 h-4 rounded accent-violet-500 cursor-pointer"
                />
                <div>
                  <span className="text-xs font-bold text-white block">🎯 Evening DSA & Placement Shift</span>
                  <span className="text-[10px] text-slate-400">Office wrap-up, DSA lock-in & Japanese</span>
                </div>
              </div>
              <input
                type="time"
                value={settings.eveningTime}
                onChange={(e) => setSettings({ ...settings, eveningTime: e.target.value })}
                className="bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-white font-mono"
              />
            </div>

            {/* Night Slot */}
            <div className="flex items-center justify-between gap-3 p-2.5 rounded-lg bg-slate-950 border border-slate-800">
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={settings.nightEnabled}
                  onChange={(e) => setSettings({ ...settings, nightEnabled: e.target.checked })}
                  className="w-4 h-4 rounded accent-indigo-500 cursor-pointer"
                />
                <div>
                  <span className="text-xs font-bold text-white block">🌙 Nightly Protocol Review</span>
                  <span className="text-[10px] text-slate-400">Major project wrap-up & sleep 11 PM</span>
                </div>
              </div>
              <input
                type="time"
                value={settings.nightTime}
                onChange={(e) => setSettings({ ...settings, nightTime: e.target.value })}
                className="bg-slate-900 border border-slate-800 rounded px-2 py-1 text-xs text-white font-mono"
              />
            </div>

            {/* Custom User-Defined Slots */}
            {customSlotsList.map((slot) => (
              <div
                key={slot.id}
                className="flex items-center justify-between gap-3 p-2.5 rounded-lg bg-slate-950 border border-slate-800"
              >
                <div className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={slot.enabled}
                    onChange={() => handleToggleCustomSlot(slot.id)}
                    className="w-4 h-4 rounded accent-pink-500 cursor-pointer"
                  />
                  <div>
                    <span className="text-xs font-bold text-white block">⚡ {slot.name}</span>
                    <span className="text-[10px] text-slate-400">Custom user alert slot</span>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-xs font-mono text-slate-300">{slot.time}</span>
                  <button
                    type="button"
                    onClick={() => handleRemoveCustomSlot(slot.id)}
                    className="p-1 text-slate-500 hover:text-red-400 transition-colors"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            ))}

            {/* Add Custom Slot Input */}
            <div className="pt-2 flex items-center gap-2">
              <input
                type="text"
                placeholder="New slot name (e.g. Office Start, Midday Check)..."
                value={newSlotName}
                onChange={(e) => setNewSlotName(e.target.value)}
                className="flex-1 bg-slate-950 border border-slate-800 rounded-lg px-3 py-1.5 text-xs text-white placeholder:text-slate-600 focus:outline-none"
              />
              <input
                type="time"
                value={newSlotTime}
                onChange={(e) => setNewSlotTime(e.target.value)}
                className="bg-slate-950 border border-slate-800 rounded-lg px-2 py-1.5 text-xs text-white font-mono focus:outline-none"
              />
              <button
                type="button"
                onClick={handleAddCustomSlot}
                className="px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-cyan-300 text-xs font-bold flex items-center gap-1 border border-slate-700"
              >
                <Plus className="w-3 h-3" />
                <span>Add</span>
              </button>
            </div>
          </div>

          {/* Test Push Dispatcher */}
          <div className="p-4 rounded-xl bg-slate-900/80 border border-slate-800 space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-300 flex items-center gap-1.5">
              <Send className="w-3.5 h-3.5 text-cyan-400" />
              <span>Instant Push Tester</span>
            </h4>

            <div className="flex flex-col sm:flex-row items-center gap-2">
              <select
                value={testSlot}
                onChange={(e) => setTestSlot(e.target.value)}
                className="w-full sm:w-auto flex-1 bg-slate-950 border border-slate-800 rounded-lg px-3 py-2 text-xs text-white font-mono focus:outline-none"
              >
                <option value="morning">Morning Briefing Alert</option>
                <option value="evening">Evening DSA & Placement Alert</option>
                <option value="night">Night Review Alert</option>
                <option value="custom">Custom Protocol Ping</option>
              </select>

              <button
                type="button"
                onClick={handleTestPush}
                disabled={isTesting}
                className="w-full sm:w-auto px-4 py-2 rounded-lg bg-cyan-950 hover:bg-cyan-900 border border-cyan-500/50 text-cyan-300 text-xs font-bold font-mono transition-all flex items-center justify-center gap-1.5 disabled:opacity-50"
              >
                <Send className="w-3.5 h-3.5" />
                <span>{isTesting ? "Dispatching..." : "Send Test Alert"}</span>
              </button>
            </div>

            {testResult && (
              <div className="p-2.5 rounded-lg bg-slate-950 border border-slate-800 text-xs font-mono text-cyan-300">
                {testResult}
              </div>
            )}
          </div>

          {/* Save / Status buttons */}
          <div className="flex items-center justify-between pt-3 border-t border-slate-800">
            {saveSuccess ? (
              <span className="text-xs font-bold text-emerald-400 flex items-center gap-1">
                <CheckCircle2 className="w-4 h-4" />
                <span>Notification preferences saved!</span>
              </span>
            ) : (
              <div />
            )}

            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-slate-300 text-xs font-semibold border border-slate-800 transition-colors"
              >
                Close
              </button>
              <button
                type="submit"
                disabled={isSaving}
                className="px-5 py-2 rounded-xl bg-gradient-to-r from-cyan-500 to-sky-500 hover:from-cyan-400 hover:to-sky-400 text-slate-950 font-bold text-xs shadow-neon-cyan transition-all transform active:scale-95 disabled:opacity-50"
              >
                {isSaving ? "Saving..." : "Save Preferences"}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};
