"use client";

import React, { useState, useRef } from "react";
import { X, User, Fingerprint, Flame, LogOut, Check, Edit2, Camera, Sparkles, Upload, Image as ImageIcon } from "lucide-react";
import { audio } from "../lib/audio";

interface WebProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
  user: {
    uid: string;
    email: string;
    displayName: string;
    photoUrl?: string;
    provider: string;
  };
  streakDays: number;
  onSignOut: () => void;
  onUpdateName: (newName: string) => void;
  onUpdatePhoto: (newPhotoUrl: string) => void;
}

const HUNTER_AVATAR_PRESETS = [
  {
    name: "Shadow Monarch",
    url: "/app_logo.jpg",
  },
  {
    name: "Sung Jin-Woo",
    url: "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=150&auto=format&fit=crop&q=80",
  },
  {
    name: "Igris the Bloodred",
    url: "https://images.unsplash.com/photo-1563089145-599997674d42?w=150&auto=format&fit=crop&q=80",
  },
  {
    name: "Beru Ant King",
    url: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&auto=format&fit=crop&q=80",
  },
  {
    name: "Grand Marshal Bellion",
    url: "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=150&auto=format&fit=crop&q=80",
  },
];

export const WebProfileModal: React.FC<WebProfileModalProps> = ({
  isOpen,
  onClose,
  user,
  streakDays,
  onSignOut,
  onUpdateName,
  onUpdatePhoto,
}) => {
  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState(user.displayName);
  const [showAvatarOptions, setShowAvatarOptions] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  if (!isOpen) return null;

  const handleSaveName = () => {
    if (!name.trim()) return;
    onUpdateName(name.trim());
    setIsEditing(false);
    audio.playLevelUp();
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (file.size > 8 * 1024 * 1024) {
      alert("Image size should be less than 8MB");
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      const dataUrl = reader.result as string;
      onUpdatePhoto(dataUrl);
      setShowAvatarOptions(false);
      audio.playLevelUp();
    };
    reader.readAsDataURL(file);
  };

  const handleSelectPreset = (url: string) => {
    onUpdatePhoto(url);
    setShowAvatarOptions(false);
    audio.playLevelUp();
  };

  const getRankBadge = (streak: number) => {
    if (streak >= 30) return { label: "S-RANK MONARCH", color: "text-cyan-300 border-cyan-400 bg-cyan-950/80" };
    if (streak >= 20) return { label: "A-RANK ELITE", color: "text-violet-300 border-violet-400 bg-violet-950/80" };
    if (streak >= 10) return { label: "B-RANK SPECIALIST", color: "text-amber-300 border-amber-400 bg-amber-950/80" };
    if (streak >= 5) return { label: "C-RANK HUNTER", color: "text-emerald-300 border-emerald-400 bg-emerald-950/80" };
    return { label: "E-RANK INITIATE", color: "text-slate-400 border-slate-700 bg-slate-900" };
  };

  const rank = getRankBadge(streakDays);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
      <div className="relative w-full max-w-md bg-[#02050E] border-2 border-cyan-400/80 rounded-3xl p-6 sm:p-8 shadow-[0_0_50px_rgba(0,240,255,0.35)] overflow-hidden max-h-[90vh] overflow-y-auto">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-2 rounded-xl bg-slate-900/80 border border-cyan-500/30 text-slate-400 hover:text-cyan-300 hover:border-cyan-400 transition-all"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Hidden File Input for Custom Device Upload */}
        <input
          type="file"
          ref={fileInputRef}
          accept="image/*"
          className="hidden"
          onChange={handleFileUpload}
        />

        {/* Profile Avatar with Edit Trigger */}
        <div className="flex flex-col items-center text-center mb-6">
          <div className="relative group">
            <div
              onClick={() => fileInputRef.current?.click()}
              title="Click to change profile picture from device"
              className="w-24 h-24 rounded-full border-2 border-cyan-400 p-1 shadow-[0_0_25px_rgba(0,240,255,0.5)] overflow-hidden bg-slate-950 cursor-pointer hover:border-cyan-300 transition-all"
            >
              {user.photoUrl ? (
                <img
                  src={user.photoUrl}
                  alt={user.displayName}
                  className="w-full h-full rounded-full object-cover"
                />
              ) : (
                <div className="w-full h-full rounded-full bg-slate-900 flex items-center justify-center text-cyan-300 font-black text-3xl font-mono">
                  {user.displayName.charAt(0).toUpperCase()}
                </div>
              )}
            </div>

            {/* Quick Camera Trigger */}
            <button
              onClick={() => setShowAvatarOptions(!showAvatarOptions)}
              title="Change Hunter Avatar"
              className="absolute bottom-0 right-0 p-2 rounded-full bg-cyan-950 border border-cyan-400 text-cyan-300 shadow-[0_0_10px_rgba(0,240,255,0.6)] hover:scale-110 hover:bg-cyan-900 transition-all"
            >
              <Camera className="w-3.5 h-3.5" />
            </button>
          </div>

          {/* Change Avatar Options Panel */}
          {showAvatarOptions && (
            <div className="mt-4 p-4 rounded-2xl bg-slate-950 border border-cyan-500/40 shadow-[0_0_25px_rgba(0,240,255,0.25)] animate-fade-in w-full text-left">
              <div className="flex items-center justify-between mb-3">
                <span className="text-[10px] font-mono text-cyan-400 font-bold uppercase tracking-wider flex items-center gap-1.5">
                  <Sparkles className="w-3.5 h-3.5 text-cyan-400" />
                  CUSTOMIZE HUNTER AVATAR
                </span>
                <button
                  onClick={() => setShowAvatarOptions(false)}
                  className="text-slate-500 hover:text-slate-300 p-1"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </div>

              {/* 1. Pick from Device Button */}
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="w-full mb-3 flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl bg-gradient-to-r from-cyan-600 to-blue-600 hover:from-cyan-500 hover:to-blue-500 text-slate-950 font-black text-xs font-mono uppercase shadow-[0_0_15px_rgba(0,240,255,0.4)] transition-all transform active:scale-95"
              >
                <Upload className="w-4 h-4 stroke-[2.5]" />
                <span>CHOOSE PHOTO FROM YOUR DEVICE</span>
              </button>

              {/* 2. Presets Grid */}
              <div className="text-[9px] font-mono text-slate-400 uppercase mb-2">OR SELECT PRESET CHARACTER:</div>
              <div className="grid grid-cols-5 gap-2">
                {HUNTER_AVATAR_PRESETS.map((preset, idx) => (
                  <button
                    key={idx}
                    onClick={() => handleSelectPreset(preset.url)}
                    title={preset.name}
                    className="relative rounded-xl border border-slate-700 hover:border-cyan-400 overflow-hidden group aspect-square bg-slate-900 transition-all hover:scale-105"
                  >
                    <img src={preset.url} alt={preset.name} className="w-full h-full object-cover" />
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Editable Hunter Codename */}
          {isEditing ? (
            <div className="flex items-center gap-2 mt-3">
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="px-3 py-1 rounded-lg bg-slate-950 border border-cyan-400 text-white font-black text-sm font-mono text-center focus:outline-none"
              />
              <button
                onClick={handleSaveName}
                className="p-1.5 rounded-lg bg-cyan-950 border border-cyan-400 text-cyan-300 hover:bg-cyan-900"
              >
                <Check className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <div
              onClick={() => setIsEditing(true)}
              className="flex items-center gap-2 cursor-pointer group mt-3"
            >
              <h2 className="text-xl font-black font-['Outfit'] uppercase text-white glow-text-system group-hover:text-cyan-300 transition-colors">
                {user.displayName}
              </h2>
              <Edit2 className="w-3.5 h-3.5 text-slate-500 group-hover:text-cyan-400" />
            </div>
          )}

          <p className="text-xs font-mono text-slate-400 mt-1">{user.email}</p>

          <span className={`mt-3 px-3 py-1 text-[11px] font-extrabold font-mono rounded-full border ${rank.color}`}>
            {rank.label}
          </span>
        </div>

        {/* Info Grid */}
        <div className="space-y-2.5 p-4 rounded-2xl bg-slate-950/90 border border-cyan-500/20 text-xs font-mono mb-6">
          <div className="flex items-center justify-between text-slate-300">
            <span className="flex items-center gap-2 text-slate-500">
              <Fingerprint className="w-4 h-4 text-cyan-400" />
              HUNTER UID
            </span>
            <span className="font-bold text-slate-200">
              {user.uid.length > 18 ? `${user.uid.substring(0, 18)}...` : user.uid}
            </span>
          </div>

          <div className="flex items-center justify-between text-slate-300">
            <span className="flex items-center gap-2 text-slate-500">
              <User className="w-4 h-4 text-violet-400" />
              AUTH PROVIDER
            </span>
            <span className="font-bold text-cyan-300 uppercase">{user.provider}</span>
          </div>

          <div className="flex items-center justify-between text-slate-300">
            <span className="flex items-center gap-2 text-slate-500">
              <Flame className="w-4 h-4 text-orange-400" />
              ACTIVE STREAK
            </span>
            <span className="font-bold text-orange-400">{streakDays} DAYS</span>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3">
          <button
            onClick={onSignOut}
            className="w-full flex items-center justify-center gap-2 py-3 rounded-xl bg-slate-900 border border-cyan-500/40 hover:border-cyan-400 text-cyan-300 font-bold font-mono text-xs transition-all shadow-[0_0_15px_rgba(0,240,255,0.2)]"
          >
            <LogOut className="w-4 h-4 text-cyan-400" />
            <span>DISCONNECT HUNTER (SIGN OUT)</span>
          </button>
        </div>
      </div>
    </div>
  );
};
