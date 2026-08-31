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
import { Shield, X, Mail, Lock, User, Code, AlertCircle, Loader2 } from "lucide-react";
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
      setErrorMsg(err.message || "GitHub Sign-In failed. Please verify popup permissions and try again.");
    } finally {
      setLoadingProvider(null);
    }
  };

  const handleEmailAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !password.trim()) {
      setErrorMsg("Please enter both Hunter Email and Security Key.");
      return;
    }

    setLoadingProvider("email");
    setErrorMsg(null);
    audio.playClick();

    try {
      if (isSignUp) {
        const res = await createUserWithEmailAndPassword(auth, email.trim(), password);
        onSuccess({
          uid: res.user.uid,
          email: res.user.email || email.trim(),
          displayName: codename.trim() || email.split("@")[0].toUpperCase(),
          provider: "email",
        });
      } else {
        const res = await signInWithEmailAndPassword(auth, email.trim(), password);
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
      <div className="relative w-full max-w-md bg-[#090414] border-2 border-purple-400/80 rounded-3xl overflow-hidden shadow-[0_0_50px_rgba(192,132,252,0.35)]">
        {/* Full Immersive Shadow Monarch Background Banner */}
        <div className="relative w-full h-44 overflow-hidden">
          <img
            src="/app_logo.jpg"
            alt="Solo Leveling Awakening"
            className="w-full h-full object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-b from-transparent via-[#090414]/60 to-[#090414]" />
        </div>

        {/* Close Button */}
        {canClose && onClose && (
          <button
            onClick={onClose}
            className="absolute top-4 right-4 z-20 p-2 rounded-xl bg-slate-900/80 border border-slate-700 text-slate-400 hover:text-white transition-all"
          >
            <X className="w-4 h-4" />
          </button>
        )}

        <div className="p-6 sm:p-8 pt-0">
          {/* Header Title */}
          <div className="flex flex-col items-center text-center mb-6">
            <h2 className="text-2xl font-black font-serif uppercase tracking-wider text-white bg-gradient-to-b from-white via-purple-100 to-purple-400 bg-clip-text text-transparent mt-1">
              YOUR AWAKENING<br />BEGINS NOW!
            </h2>
            <p className="text-xs font-mono text-slate-400 mt-1">
              Walk your path. Take action. Conquer. Become a legend!
            </p>
          </div>

          {/* Social OAuth Buttons */}
          <div className="grid grid-cols-2 gap-3 mb-5">
            <button
              type="button"
              onClick={handleGoogleLogin}
              disabled={loadingProvider !== null}
              className="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl bg-slate-900/90 border border-purple-500/40 hover:border-purple-400 hover:bg-slate-800 text-white text-xs font-mono font-bold transition-all disabled:opacity-50"
            >
              {loadingProvider === "google" ? (
                <Loader2 className="w-4 h-4 text-purple-400 animate-spin" />
              ) : (
                <>
                  <span className="text-red-400 font-black text-sm">G</span>
                  <span>GOOGLE SIGN IN</span>
                </>
              )}
            </button>

            <button
              type="button"
              onClick={handleGitHubLogin}
              disabled={loadingProvider !== null}
              className="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl bg-slate-900/90 border border-purple-500/40 hover:border-purple-400 hover:bg-slate-800 text-white text-xs font-mono font-bold transition-all disabled:opacity-50"
            >
              {loadingProvider === "github" ? (
                <Loader2 className="w-4 h-4 text-purple-400 animate-spin" />
              ) : (
                <>
                  <Code className="w-4 h-4 text-purple-300" />
                  <span>GITHUB SIGN IN</span>
                </>
              )}
            </button>
          </div>

          <div className="relative flex items-center justify-center mb-5">
            <div className="border-t border-slate-800 w-full" />
            <span className="bg-[#090414] px-3 text-[10px] font-mono uppercase text-slate-500">
              OR CREDENTIALS
            </span>
            <div className="border-t border-slate-800 w-full" />
          </div>

          {/* Error Message */}
          {errorMsg && (
            <div className="mb-4 p-3 rounded-xl bg-red-950/60 border border-red-500/50 flex items-start gap-2.5">
              <AlertCircle className="w-4 h-4 text-red-400 shrink-0 mt-0.5" />
              <p className="text-xs font-mono text-red-300">{errorMsg}</p>
            </div>
          )}

          {/* Email / Password Form */}
          <form onSubmit={handleEmailAuth} className="space-y-3.5">
            {isSignUp && (
              <div>
                <label className="block text-[10px] font-mono uppercase text-purple-300 mb-1">
                  Hunter Codename
                </label>
                <div className="relative">
                  <User className="absolute left-3.5 top-3 w-4 h-4 text-slate-500" />
                  <input
                    type="text"
                    value={codename}
                    onChange={(e) => setCodename(e.target.value)}
                    placeholder="SHADOW_MONARCH_01"
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-950/80 border border-slate-700 focus:border-purple-400 rounded-xl text-xs font-mono text-white placeholder-slate-600 outline-none transition-all"
                  />
                </div>
              </div>
            )}

            <div>
              <label className="block text-[10px] font-mono uppercase text-purple-300 mb-1">
                Hunter Email
              </label>
              <div className="relative">
                <Mail className="absolute left-3.5 top-3 w-4 h-4 text-slate-500" />
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="hunter@system.solo"
                  className="w-full pl-10 pr-4 py-2.5 bg-slate-950/80 border border-slate-700 focus:border-purple-400 rounded-xl text-xs font-mono text-white placeholder-slate-600 outline-none transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-[10px] font-mono uppercase text-purple-300 mb-1">
                Security Key (Password)
              </label>
              <div className="relative">
                <Lock className="absolute left-3.5 top-3 w-4 h-4 text-slate-500" />
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  className="w-full pl-10 pr-4 py-2.5 bg-slate-950/80 border border-slate-700 focus:border-purple-400 rounded-xl text-xs font-mono text-white placeholder-slate-600 outline-none transition-all"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loadingProvider !== null}
              className="w-full py-3 rounded-xl bg-gradient-to-r from-purple-500 to-indigo-600 hover:from-purple-400 hover:to-indigo-500 text-white font-mono text-xs font-black uppercase tracking-wider transition-all shadow-[0_0_20px_rgba(168,85,247,0.4)] disabled:opacity-50 flex items-center justify-center gap-2"
            >
              {loadingProvider === "email" ? (
                <Loader2 className="w-4 h-4 animate-spin text-white" />
              ) : (
                <span>{isSignUp ? "INITIALIZE AWAKENING" : "ENTER DUNGEON GATE"}</span>
              )}
            </button>
          </form>

          {/* Toggle between Login / Sign Up */}
          <div className="mt-4 flex items-center justify-between text-xs font-mono">
            <button
              type="button"
              onClick={() => {
                audio.playClick();
                setIsSignUp(!isSignUp);
                setErrorMsg(null);
              }}
              className="text-purple-300 hover:text-purple-200 transition-colors"
            >
              {isSignUp ? "Already Awakened? Sign In" : "Need Awakening? Register"}
            </button>

            <button
              type="button"
              onClick={handleGuestLogin}
              className="text-slate-400 hover:text-slate-200 transition-colors"
            >
              Guest Access →
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
