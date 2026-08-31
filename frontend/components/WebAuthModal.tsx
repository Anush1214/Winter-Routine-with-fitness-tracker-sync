"use client";

import React, { useState } from "react";
import {
  auth,
  googleProvider,
  githubProvider,
  signInWithPopup,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
} from "@/src/lib/firebase";
import { Shield, X, Mail, Lock, User, Code, AlertCircle, Loader2, Zap } from "lucide-react";
import { audio } from "../lib/audio";

interface WebAuthModalProps {
  isOpen: boolean;
  onClose?: () => void;
  canClose?: boolean;
  onSuccess: (user: { uid: string; email: string; displayName: string; photoUrl?: string; provider: string }) => void;
}

export const WebAuthModal: React.FC<WebAuthModalProps> = ({
  isOpen,
  onClose,
  canClose = false,
  onSuccess,
}) => {
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [codename, setCodename] = useState("");
  const [loadingProvider, setLoadingProvider] = useState<string | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleGoogleLogin = async () => {
    setLoadingProvider("google");
    setErrorMsg(null);
    audio.playLevelUp();

    try {
      const res = await signInWithPopup(auth, googleProvider);
      if (res.user) {
        onSuccess({
          uid: res.user.uid,
          email: res.user.email || "hunter@gmail.com",
          displayName: res.user.displayName || "Google Hunter",
          photoUrl: res.user.photoURL || undefined,
          provider: "google",
        });
        if (onClose) onClose();
      } else {
        setErrorMsg("Google Sign-In was cancelled or failed. Please try again.");
      }
    } catch (err: any) {
      console.error("Google Web Auth error:", err);
      setErrorMsg(err.message || "Google Sign-In failed. Please verify popup permissions and try again.");
    } finally {
      setLoadingProvider(null);
    }
  };

  const handleGitHubLogin = async () => {
    setLoadingProvider("github");
    setErrorMsg(null);
    audio.playLevelUp();

    try {
      const res = await signInWithPopup(auth, githubProvider);
      if (res.user) {
        onSuccess({
          uid: res.user.uid,
          email: res.user.email || "hunter@github.com",
          displayName: res.user.displayName || "GitHub Monarch",
          photoUrl: res.user.photoURL || undefined,
          provider: "github",
        });
        if (onClose) onClose();
      } else {
        setErrorMsg("GitHub Sign-In was cancelled or failed. Please try again.");
      }
    } catch (err: any) {
      console.error("GitHub Web Auth error:", err);
      setErrorMsg(err.message || "GitHub Sign-In failed. Please verify your credentials and try again.");
    } finally {
      setLoadingProvider(null);
    }
  };

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !password.trim()) {
      setErrorMsg("Please enter both player email identifier and secret security key.");
      return;
    }

    if (password.length < 6) {
      setErrorMsg("Secret security key must be at least 6 characters.");
      return;
    }

    setLoadingProvider("email");
    setErrorMsg(null);
    audio.playClick();

    try {
      if (isSignUp) {
        const res = await createUserWithEmailAndPassword(auth, email.trim(), password.trim());
        onSuccess({
          uid: res.user.uid,
          email: res.user.email || email.trim(),
          displayName: codename.trim() || email.split("@")[0].toUpperCase(),
          provider: "email",
        });
      } else {
        const res = await signInWithEmailAndPassword(auth, email.trim(), password.trim());
        onSuccess({
          uid: res.user.uid,
          email: res.user.email || email.trim(),
          displayName: res.user.displayName || email.split("@")[0].toUpperCase(),
          provider: "email",
        });
      }
      if (onClose) onClose();
    } catch (err: any) {
      console.error("Email auth error:", err);
      if (err.code === "auth/user-not-found" || err.code === "auth/wrong-password" || err.code === "auth/invalid-credential") {
        setErrorMsg("Invalid email identifier or security key. Check your credentials.");
      } else if (err.code === "auth/email-already-in-use") {
        setErrorMsg("This email is already registered. Please switch to Hunter Sign In.");
      } else {
        setErrorMsg(err.message || "Authentication failed. Please verify your credentials and try again.");
      }
    } finally {
      setLoadingProvider(null);
    }
  };

  const handleGuestLogin = () => {
    audio.playClick();
    onSuccess({
      uid: `guest_${Date.now()}`,
      email: "guest@winterarc.solo",
      displayName: "Shadow Hunter",
      provider: "guest",
    });
    if (onClose) onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/90 backdrop-blur-lg animate-fade-in">
      <div className="relative w-full max-w-md bg-[#02050E] border-2 border-cyan-400/80 rounded-3xl p-6 sm:p-8 shadow-[0_0_50px_rgba(0,240,255,0.35)] overflow-hidden">
        {/* Glowing Background Radial */}
        <div className="absolute -top-24 -right-24 w-48 h-48 bg-cyan-500/20 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-24 -left-24 w-48 h-48 bg-violet-600/20 rounded-full blur-3xl pointer-events-none" />

        {/* Close Button (only available if user is already authenticated) */}
        {canClose && onClose && (
          <button
            onClick={onClose}
            className="absolute top-4 right-4 p-2 rounded-xl bg-slate-900/80 border border-cyan-500/30 text-slate-400 hover:text-cyan-300 hover:border-cyan-400 transition-all"
          >
            <X className="w-4 h-4" />
          </button>
        )}

        {/* Top Emblem */}
        <div className="flex flex-col items-center text-center mb-6">
          <div className="w-16 h-16 rounded-2xl bg-slate-950 border-2 border-cyan-400 p-0.5 overflow-hidden flex items-center justify-center shadow-[0_0_25px_rgba(0,240,255,0.5)] mb-3">
            <img
              src="/app_logo.jpg"
              alt="Winter Arc Protocol"
              className="w-full h-full object-cover rounded-xl"
            />
          </div>
          <span className="text-[10px] font-mono font-extrabold uppercase tracking-widest text-cyan-400">
            SOLO LEVELING // SYSTEM
          </span>
          <h2 className="text-xl font-black font-['Outfit'] uppercase tracking-wider text-white glow-text-system mt-1">
            HUNTER AWAKENING PORTAL
          </h2>
          <p className="text-xs font-mono text-slate-400 mt-1">
            Identify your Hunter credentials to access your daily quests.
          </p>
        </div>

        {/* Social OAuth Buttons */}
        <div className="grid grid-cols-2 gap-3 mb-5">
          <button
            type="button"
            onClick={handleGoogleLogin}
            disabled={loadingProvider !== null}
            className="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl bg-slate-900/90 border border-red-500/50 hover:border-red-400 hover:bg-slate-800/90 text-white text-xs font-mono font-bold transition-all shadow-[0_0_10px_rgba(239,68,68,0.15)] disabled:opacity-50"
          >
            {loadingProvider === "google" ? (
              <Loader2 className="w-4 h-4 text-red-400 animate-spin" />
            ) : (
              <>
                <span className="text-red-400 font-black text-sm">G</span>
                <span>GMAIL / GOOGLE</span>
              </>
            )}
          </button>

          <button
            type="button"
            onClick={handleGitHubLogin}
            disabled={loadingProvider !== null}
            className="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl bg-slate-900/90 border border-cyan-500/50 hover:border-cyan-400 hover:bg-slate-800/90 text-white text-xs font-mono font-bold transition-all shadow-[0_0_10px_rgba(0,240,255,0.15)] disabled:opacity-50"
          >
            {loadingProvider === "github" ? (
              <Loader2 className="w-4 h-4 text-cyan-400 animate-spin" />
            ) : (
              <>
                <Code className="w-4 h-4 text-cyan-400" />
                <span>GITHUB</span>
              </>
            )}
          </button>
        </div>

        {/* Divider */}
        <div className="flex items-center gap-3 my-4">
          <div className="flex-1 h-px bg-slate-800" />
          <span className="text-[10px] font-mono text-slate-500 uppercase">OR USE EMAIL</span>
          <div className="flex-1 h-px bg-slate-800" />
        </div>

        {/* Tab Switcher */}
        <div className="grid grid-cols-2 gap-2 p-1 rounded-xl bg-slate-950 border border-cyan-500/20 mb-4">
          <button
            type="button"
            onClick={() => {
              setIsSignUp(false);
              setErrorMsg(null);
            }}
            className={`py-1.5 text-xs font-mono font-bold rounded-lg transition-all ${
              !isSignUp
                ? "bg-cyan-950/90 border border-cyan-400 text-cyan-300 shadow-[0_0_10px_rgba(0,240,255,0.3)]"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            HUNTER SIGN IN
          </button>
          <button
            type="button"
            onClick={() => {
              setIsSignUp(true);
              setErrorMsg(null);
            }}
            className={`py-1.5 text-xs font-mono font-bold rounded-lg transition-all ${
              isSignUp
                ? "bg-cyan-950/90 border border-cyan-400 text-cyan-300 shadow-[0_0_10px_rgba(0,240,255,0.3)]"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            NEW AWAKENING
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleEmailSubmit} className="space-y-3">
          {isSignUp && (
            <div>
              <label className="block text-[10px] font-mono text-cyan-400 mb-1">HUNTER CODENAME</label>
              <div className="relative">
                <User className="absolute left-3 top-2.5 w-4 h-4 text-slate-500" />
                <input
                  type="text"
                  value={codename}
                  onChange={(e) => setCodename(e.target.value)}
                  placeholder="e.g., Sung Jin-Woo"
                  className="w-full pl-9 pr-3 py-2 rounded-xl bg-slate-950 border border-cyan-500/30 text-white text-xs font-mono focus:outline-none focus:border-cyan-400 focus:shadow-[0_0_10px_rgba(0,240,255,0.3)]"
                />
              </div>
            </div>
          )}

          <div>
            <label className="block text-[10px] font-mono text-cyan-400 mb-1">PLAYER EMAIL IDENTIFIER</label>
            <div className="relative">
              <Mail className="absolute left-3 top-2.5 w-4 h-4 text-slate-500" />
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="hunter@winterarc.com"
                className="w-full pl-9 pr-3 py-2 rounded-xl bg-slate-950 border border-cyan-500/30 text-white text-xs font-mono focus:outline-none focus:border-cyan-400 focus:shadow-[0_0_10px_rgba(0,240,255,0.3)]"
              />
            </div>
          </div>

          <div>
            <label className="block text-[10px] font-mono text-cyan-400 mb-1">SECRET SECURITY KEY</label>
            <div className="relative">
              <Lock className="absolute left-3 top-2.5 w-4 h-4 text-slate-500" />
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full pl-9 pr-3 py-2 rounded-xl bg-slate-950 border border-cyan-500/30 text-white text-xs font-mono focus:outline-none focus:border-cyan-400 focus:shadow-[0_0_10px_rgba(0,240,255,0.3)]"
              />
            </div>
          </div>

          {errorMsg && (
            <div className="flex items-start gap-2 p-2.5 rounded-xl bg-red-950/80 border border-red-500/60 text-red-300 text-xs font-mono">
              <AlertCircle className="w-4 h-4 flex-shrink-0 text-red-400 mt-0.5" />
              <span className="leading-relaxed">{errorMsg}</span>
            </div>
          )}

          <button
            type="submit"
            disabled={loadingProvider !== null}
            className="w-full py-3 rounded-xl bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-slate-950 font-black text-xs font-mono uppercase tracking-wider shadow-[0_0_20px_rgba(0,240,255,0.5)] transition-all transform active:scale-95 disabled:opacity-50 mt-2"
          >
            {loadingProvider === "email" ? (
              <Loader2 className="w-4 h-4 animate-spin mx-auto text-slate-950" />
            ) : isSignUp ? (
              "INITIATE AWAKENING"
            ) : (
              "ACCESS SYSTEM PROTOCOL"
            )}
          </button>
        </form>

        {/* Explicit Guest Mode Trigger */}
        <div className="mt-4 pt-3 border-t border-slate-800 text-center">
          <button
            type="button"
            onClick={handleGuestLogin}
            className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-slate-950 border border-violet-500/40 text-violet-300 hover:border-violet-400 text-xs font-mono font-bold transition-all"
          >
            <Zap className="w-3.5 h-3.5 text-violet-400" />
            <span>CONTINUE AS GUEST SHADOW HUNTER</span>
          </button>
        </div>
      </div>
    </div>
  );
};
