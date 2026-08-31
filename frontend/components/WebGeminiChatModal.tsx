"use client";

import React, { useState, useRef, useEffect } from "react";
import { X, Send, Sparkles, Bot, User, RefreshCw } from "lucide-react";
import { audio } from "../lib/audio";

interface WebGeminiChatModalProps {
  isOpen: boolean;
  onClose: () => void;
  tasks: Array<{ id: string; title: string; isCompleted: boolean; startTime?: string | null }>;
  streak?: number;
  waterMl?: number;
}

interface ChatMessage {
  text: string;
  isUser: boolean;
  timestamp: Date;
}

export const WebGeminiChatModal: React.FC<WebGeminiChatModalProps> = ({
  isOpen,
  onClose,
  tasks,
  streak = 7,
  waterMl = 3200,
}) => {
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      text: "**[ SYSTEM GEMINI AI AWAKENED ]**\n\nGreetings, Hunter. I have ingested your real-time routine telemetry and active discipline metrics.\n\nAsk me anything regarding workout dungeon optimization, DSA & placement strategy, recovery metrics, or general knowledge.",
      isUser: false,
      timestamp: new Date(),
    },
  ]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  if (!isOpen) return null;

  const completedCount = tasks.filter((t) => t.isCompleted).length;
  const totalCount = tasks.length;

  const handleSendMessage = async (queryText?: string) => {
    const textToSend = queryText || input;
    if (!textToSend.trim() || isLoading) return;

    audio.playClick();
    const userMsg: ChatMessage = {
      text: textToSend.trim(),
      isUser: true,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setIsLoading(true);

    try {
      const response = await fetch("/api/gemini/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message: textToSend.trim(),
          telemetry: {
            userName: "Anush",
            rank: "S-Rank",
            level: 14,
            streak,
            clearedTasks: completedCount,
            totalTasks: totalCount,
            tasks,
            waterMl,
            sleepHours: 7.2,
            consistency: 94,
          },
        }),
      });

      const data = await response.json();
      audio.playVictory();
      setMessages((prev) => [
        ...prev,
        {
          text: data.reply || "Tactical telemetry updated. Arise Hunter!",
          isUser: false,
          timestamp: new Date(),
        },
      ]);
    } catch (e) {
      setMessages((prev) => [
        ...prev,
        {
          text: `👑 **[ TACTICAL ANALYSIS ]**\n\n- **Today's Status**: ${completedCount}/${totalCount} quests cleared.\n- **Discipline**: Keep your ${streak}-day streak alive.\n- **Next Move**: Focus on your next pending quest and conquer the day!`,
          isUser: false,
          timestamp: new Date(),
        },
      ]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/90 backdrop-blur-lg animate-fade-in">
      <div className="relative w-full max-w-xl bg-[#090414] border-2 border-purple-400/80 shadow-[0_0_50px_rgba(155,114,203,0.35)] rounded-3xl p-6 sm:p-7 flex flex-col max-h-[85vh] overflow-hidden">
        {/* Glowing Background Radial */}
        <div className="absolute -top-24 -right-24 w-48 h-48 bg-gradient-to-br from-blue-500/20 via-purple-500/20 to-pink-500/20 rounded-full blur-3xl pointer-events-none" />

        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-2 rounded-xl bg-slate-900/80 border border-slate-700 text-slate-400 hover:text-white transition-all"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Header with Authentic Gemini Sparkle Logo */}
        <div className="flex items-center gap-3.5 mb-4">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#4285F4] via-[#9B72CB] to-[#D96570] p-0.5 flex items-center justify-center shadow-[0_0_20px_rgba(155,114,203,0.6)]">
            <Sparkles className="w-6 h-6 text-white animate-pulse" />
          </div>
          <div>
            <span className="inline-block px-2 py-0.5 rounded text-[9px] font-mono font-bold uppercase tracking-widest bg-purple-950/80 text-purple-300 border border-purple-500/30">
              POWERED BY GOOGLE GEMINI
            </span>
            <h2 className="text-lg font-black font-['Outfit'] uppercase tracking-wider text-white mt-0.5">
              GEMINI AI INTELLIGENCE HUB
            </h2>
            <p className="text-[11px] font-mono text-cyan-400">
              Telemetry: {completedCount}/{totalCount} Quests • {streak}d Streak • {waterMl}ml Water
            </p>
          </div>
        </div>

        {/* Quick Action Prompt Chips */}
        <div className="flex items-center gap-2 overflow-x-auto pb-2 mb-3 no-scrollbar">
          <button
            onClick={() =>
              handleSendMessage(
                "Analyze my today's routine and give me tactical advice on what to prioritize next."
              )
            }
            className="shrink-0 px-2.5 py-1 rounded-lg bg-slate-950 border border-purple-500/40 text-purple-200 text-[11px] font-mono hover:border-purple-300 transition-all"
          >
            ⚡ Analyze Routine
          </button>
          <button
            onClick={() =>
              handleSendMessage(
                "Give me a step-by-step strategy to master Binary Trees and LeetCode Mediums tonight."
              )
            }
            className="shrink-0 px-2.5 py-1 rounded-lg bg-slate-950 border border-blue-500/40 text-blue-200 text-[11px] font-mono hover:border-blue-300 transition-all"
          >
            🎯 DSA Binary Trees
          </button>
          <button
            onClick={() =>
              handleSendMessage(
                "How can I optimize my recovery and water intake based on my 4500ml goal?"
              )
            }
            className="shrink-0 px-2.5 py-1 rounded-lg bg-slate-950 border border-cyan-500/40 text-cyan-200 text-[11px] font-mono hover:border-cyan-300 transition-all"
          >
            💧 Hydration Plan
          </button>
          <button
            onClick={() =>
              handleSendMessage(
                "Give me an inspiring Solo Leveling System motivation to crush all daily goals."
              )
            }
            className="shrink-0 px-2.5 py-1 rounded-lg bg-slate-950 border border-amber-500/40 text-amber-200 text-[11px] font-mono hover:border-amber-300 transition-all"
          >
            👑 S-Rank Awakening
          </button>
        </div>

        {/* Messages Scroll Area */}
        <div className="flex-1 overflow-y-auto space-y-3 p-3 rounded-2xl bg-[#06030c] border border-purple-500/20 mb-3 text-xs sm:text-sm leading-relaxed">
          {messages.map((msg, i) => (
            <div
              key={i}
              className={`flex gap-2.5 ${msg.isUser ? "justify-end" : "justify-start"}`}
            >
              {!msg.isUser && (
                <div className="w-6 h-6 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center shrink-0 mt-1">
                  <Sparkles className="w-3 h-3 text-white" />
                </div>
              )}
              <div
                className={`max-w-[85%] p-3.5 rounded-2xl ${
                  msg.isUser
                    ? "bg-purple-700/80 text-white border border-purple-400/60 rounded-tr-none"
                    : "bg-[#140b24] text-slate-100 border border-purple-500/30 rounded-tl-none"
                }`}
              >
                <div className="whitespace-pre-wrap font-sans">{msg.text}</div>
              </div>
            </div>
          ))}
          {isLoading && (
            <div className="flex items-center gap-2 text-xs font-mono text-purple-300">
              <RefreshCw className="w-3.5 h-3.5 animate-spin text-purple-400" />
              <span>Gemini is synthesizing tactical intelligence...</span>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Input Bar */}
        <form
          onSubmit={(e) => {
            e.preventDefault();
            handleSendMessage();
          }}
          className="flex items-center gap-2"
        >
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Ask Gemini anything (DSA, workouts, routine, algorithms)..."
            className="flex-1 bg-slate-950 border border-purple-500/40 rounded-xl px-4 py-3 text-xs sm:text-sm text-white placeholder-slate-500 focus:outline-none focus:border-purple-400"
          />
          <button
            type="submit"
            disabled={isLoading || !input.trim()}
            className="p-3 rounded-xl bg-gradient-to-br from-[#4285F4] via-[#9B72CB] to-[#D96570] text-white hover:opacity-90 disabled:opacity-40 transition-all flex items-center justify-center shadow-[0_0_15px_rgba(155,114,203,0.5)]"
          >
            <Send className="w-4 h-4" />
          </button>
        </form>
      </div>
    </div>
  );
};
