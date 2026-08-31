"use client";

import React, { useState } from "react";
import { X, Volume2, Sparkles, CheckCircle2, Shield, Sword } from "lucide-react";
import { audio } from "../lib/audio";

export type CompanionPersona = "jinwoo" | "chahaein";
export type CompanionLang = "ja" | "en";

interface WebCompanionAssistantModalProps {
  isOpen: boolean;
  onClose: () => void;
  tasks: Array<{ id: string; title: string; isCompleted: boolean; startTime?: string | null }>;
  onExecuteNextTask?: (taskId: string) => void;
}

export const WebCompanionAssistantModal: React.FC<WebCompanionAssistantModalProps> = ({
  isOpen,
  onClose,
  tasks,
  onExecuteNextTask,
}) => {
  const [persona, setPersona] = useState<CompanionPersona>("jinwoo");
  const [lang, setLang] = useState<CompanionLang>("en");
  const [isSpeaking, setIsSpeaking] = useState(false);

  if (!isOpen) return null;

  const nextTask = tasks.find((t) => !t.isCompleted);
  const now = new Date();
  const hour = now.getHours();

  const getVoiceActorName = () => {
    if (persona === "jinwoo") {
      return lang === "ja" ? "Taito Ban (坂 泰斗)" : "Aleks Le";
    } else {
      return lang === "ja" ? "Reina Ueda (上田 麗奈)" : "Michelle Rojas";
    }
  };

  const getQuote = () => {
    if (persona === "jinwoo") {
      if (lang === "ja") {
        if (nextTask) {
          const t = nextTask.title.toLowerCase();
          if (t.includes("wake") || t.includes("gym")) {
            return "「日課クエストを開始せよ。朝の鍛錬を怠るな。目を覚ませ、影の軍団よ。」";
          } else if (t.includes("dsa") || t.includes("japanese")) {
            return "「ここからは試練のダンジョンだ。DSAと集中力を極限まで研ぎ澄ませ。」";
          } else if (t.includes("night") || t.includes("sleep")) {
            return "「夜の規律を守れ。ペナルティを回避し、明日へ備えよ。起きろ (Okiro)。」";
          }
          return `「目標 『${nextTask.title}』 を確認した。立ち止まるな、一人でレベルアップせよ。」`;
        }
        if (hour >= 6 && hour < 12) return "「今日も一歩ずつ強くなる。朝のクエストを全てクリアしろ。」";
        if (hour >= 18 && hour < 22) return "「夕方の修練を開始する。限界を超えろ、立ち向かえ。」";
        return "「休息もまた力の一部だ。体を癒し、明日再び立ち上がれ。起きろ。」";
      } else {
        if (nextTask) {
          const t = nextTask.title.toLowerCase();
          if (t.includes("wake") || t.includes("gym")) {
            return "“The morning trial has begun, Hunter. Hydrate, initiate your protocol, and conquer the workout dungeon.”";
          } else if (t.includes("dsa") || t.includes("japanese")) {
            return "“Placement & DSA dungeon is active. Focus your mind, write clean algorithms, and master your skills.”";
          } else if (t.includes("night") || t.includes("sleep")) {
            return "“Penalty zone approaches at 11:00 PM. Wrap up all objectives, recover your mana, and Arise.”";
          }
          return `“Next objective detected: ‘${nextTask.title}’. If you don’t fight, you don’t survive. Complete it now.”`;
        }
        if (hour >= 6 && hour < 12) return "“The system chose you for a reason. Clear your morning quests and seize the day.”";
        if (hour >= 18 && hour < 22) return "“Evening dungeon is in progress. Push through your placement shift and level up.”";
        return "“All daily quests cleared. Recover your stamina, sleep early, and prepare to Arise tomorrow.”";
      }
    } else {
      // CHA HAE-IN (S-RANK DANCER / GOLD THEME)
      if (lang === "ja") {
        if (nextTask) {
          const t = nextTask.title.toLowerCase();
          if (t.includes("wake") || t.includes("gym")) {
            return "「私の剣は決して鈍りません。朝の鍛錬、一緒に全力を尽くしましょう。」";
          } else if (t.includes("dsa") || t.includes("japanese")) {
            return "「DSAと修練のダンジョンですね。集中力を極限まで研ぎ澄ませて、共に勝利を掴みましょう。」";
          } else if (t.includes("night") || t.includes("sleep")) {
            return "「今日も素晴らしい一日でした。体をしっかり休めて、明日に備えてくださいね。」";
          }
          return `「次の目標 『${nextTask.title}』 を確認しました。Sランクの誇りを持って挑みましょう！」`;
        }
        if (hour >= 6 && hour < 12) return "「おはようございます！ 今日も光り輝く一日を、一歩ずつ歩んでいきましょう。」";
        if (hour >= 18 && hour < 22) return "「夕方の修練時間です。剣筋を乱さず、最後までやり遂げましょう！」";
        return "「本日のデイリークエスト、見事な達成でした。ゆっくりお休みくださいね。」";
      } else {
        if (nextTask) {
          const t = nextTask.title.toLowerCase();
          if (t.includes("wake") || t.includes("gym")) {
            return "“A true S-Rank Hunter never hesitates. Hydrate, initiate your morning routine, and conquer the workout dungeon.”";
          } else if (t.includes("dsa") || t.includes("japanese")) {
            return "“Placement & DSA training is active. Keep your focus razor-sharp and execute every algorithm with precision.”";
          } else if (t.includes("night") || t.includes("sleep")) {
            return "“You demonstrated true S-Rank discipline today. Rest your body, recover your strength, and prepare for tomorrow.”";
          }
          return `“Target objective locked: ‘${nextTask.title}’. Believe in your training and clear it with absolute mastery.”`;
        }
        if (hour >= 6 && hour < 12) return "“Good morning! A new day awaits. Let's make every single minute count with golden determination.”";
        if (hour >= 18 && hour < 22) return "“Evening training shift is underway. Stay centered, maintain your stance, and push forward!”";
        return "“All daily protocol quests cleared with flying colors! Sleep well and restore your mana tonight.”";
      }
    }
  };

  const handlePlayVoice = () => {
    audio.playLevelUp();
    if (typeof window !== "undefined" && "speechSynthesis" in window) {
      window.speechSynthesis.cancel();
      const quote = getQuote();
      const cleanQuote = quote.replace(/[「」“”"']/g, "");
      const utterance = new SpeechSynthesisUtterance(cleanQuote);
      utterance.lang = lang === "ja" ? "ja-JP" : "en-US";
      utterance.pitch = persona === "jinwoo" ? 0.85 : 1.18;
      utterance.rate = persona === "jinwoo" ? 0.95 : 1.02;

      utterance.onstart = () => setIsSpeaking(true);
      utterance.onend = () => setIsSpeaking(false);
      utterance.onerror = () => setIsSpeaking(false);

      window.speechSynthesis.speak(utterance);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/90 backdrop-blur-lg animate-fade-in">
      <div
        className={`relative w-full max-w-lg bg-[#090414] border-2 ${
          persona === "jinwoo"
            ? "border-purple-400/80 shadow-[0_0_50px_rgba(192,132,252,0.35)]"
            : "border-amber-400/80 shadow-[0_0_50px_rgba(251,191,36,0.35)]"
        } rounded-3xl p-6 sm:p-8 overflow-hidden`}
      >
        {/* Glowing Background Radial */}
        <div
          className={`absolute -top-24 -right-24 w-48 h-48 ${
            persona === "jinwoo" ? "bg-purple-500/20" : "bg-amber-500/20"
          } rounded-full blur-3xl pointer-events-none`}
        />
        <div
          className={`absolute -bottom-24 -left-24 w-48 h-48 ${
            persona === "jinwoo" ? "bg-violet-600/20" : "bg-yellow-600/20"
          } rounded-full blur-3xl pointer-events-none`}
        />

        {/* Close Button */}
        <button
          onClick={() => {
            if (typeof window !== "undefined" && "speechSynthesis" in window) {
              window.speechSynthesis.cancel();
            }
            onClose();
          }}
          className="absolute top-4 right-4 p-2 rounded-xl bg-slate-900/80 border border-slate-700 text-slate-400 hover:text-white transition-all"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Top Header */}
        <div className="flex items-center gap-3.5 mb-5">
          <div
            className={`w-14 h-14 rounded-2xl ${
              persona === "jinwoo"
                ? "bg-slate-950 border-2 border-purple-400 shadow-[0_0_20px_rgba(192,132,252,0.5)]"
                : "bg-slate-950 border-2 border-amber-400 shadow-[0_0_20px_rgba(251,191,36,0.5)]"
            } flex items-center justify-center`}
          >
            {persona === "jinwoo" ? (
              <Shield className="w-7 h-7 text-purple-400" />
            ) : (
              <Sword className="w-7 h-7 text-amber-400" />
            )}
          </div>
          <div>
            <span
              className={`inline-block px-2 py-0.5 rounded text-[9px] font-mono font-bold uppercase tracking-widest ${
                persona === "jinwoo"
                  ? "bg-purple-950/80 text-purple-300 border border-purple-500/30"
                  : "bg-amber-950/80 text-amber-300 border border-amber-500/30"
              }`}
            >
              {persona === "jinwoo" ? "SHADOW MONARCH COMPANION" : "S-RANK THE DANCER (GOLD THEME)"}
            </span>
            <h2 className="text-xl font-black font-['Outfit'] uppercase tracking-wider text-white mt-0.5">
              {persona === "jinwoo" ? "SUNG JIN-WOO" : "CHA HAE-IN (차해イン)"}
            </h2>
            <p className="text-[11px] font-mono text-slate-400">
              VA: <span className={persona === "jinwoo" ? "text-purple-300 font-bold" : "text-amber-300 font-bold"}>{getVoiceActorName()}</span>
            </p>
          </div>
        </div>

        {/* Persona Switcher: Male Purple vs Female Gold */}
        <div className="grid grid-cols-2 gap-2 p-1 bg-slate-950 rounded-xl border border-slate-800 mb-3">
          <button
            type="button"
            onClick={() => {
              audio.playClick();
              setPersona("jinwoo");
            }}
            className={`flex items-center justify-center gap-1.5 py-2 rounded-lg font-mono text-xs font-bold transition-all ${
              persona === "jinwoo"
                ? "bg-purple-500/20 text-purple-300 border border-purple-400"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            <span>👑</span>
            <span>JIN-WOO (MALE)</span>
          </button>

          <button
            type="button"
            onClick={() => {
              audio.playClick();
              setPersona("chahaein");
            }}
            className={`flex items-center justify-center gap-1.5 py-2 rounded-lg font-mono text-xs font-bold transition-all ${
              persona === "chahaein"
                ? "bg-amber-500/25 text-amber-300 border border-amber-400"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            <span>⚔️</span>
            <span>CHA HAE-IN (GOLD)</span>
          </button>
        </div>

        {/* Language Selection */}
        <div className="grid grid-cols-2 gap-2 p-1 bg-slate-950 rounded-xl border border-slate-800 mb-4">
          <button
            type="button"
            onClick={() => {
              audio.playClick();
              setLang("en");
            }}
            className={`py-1.5 text-center font-mono text-[11px] font-bold rounded-lg transition-all ${
              lang === "en"
                ? persona === "jinwoo"
                  ? "bg-purple-950 text-purple-300 border border-purple-500/40"
                  : "bg-amber-950 text-amber-300 border border-amber-500/40"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            🇺🇸 {persona === "jinwoo" ? "ALEKS LE (EN)" : "MICHELLE ROJAS (EN)"}
          </button>

          <button
            type="button"
            onClick={() => {
              audio.playClick();
              setLang("ja");
            }}
            className={`py-1.5 text-center font-mono text-[11px] font-bold rounded-lg transition-all ${
              lang === "ja"
                ? persona === "jinwoo"
                  ? "bg-violet-950 text-violet-300 border border-violet-500/40"
                  : "bg-yellow-950 text-yellow-300 border border-yellow-500/40"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            🇯🇵 {persona === "jinwoo" ? "TAITO BAN (JP)" : "REINA UEDA (JP)"}
          </button>
        </div>

        {/* Holographic Quote Dialogue Box */}
        <div
          className={`p-4 sm:p-5 rounded-2xl bg-gradient-to-br ${
            persona === "jinwoo"
              ? "from-purple-950/40 via-slate-950 to-[#090414] border-purple-500/40"
              : "from-amber-950/40 via-slate-950 to-[#140C03] border-amber-500/50"
          } border mb-5 relative`}
        >
          <div className="flex items-center justify-between mb-2">
            <span
              className={`text-[10px] font-mono font-bold ${
                persona === "jinwoo" ? "text-purple-300" : "text-amber-300"
              }`}
            >
              [ {getVoiceActorName()} // VOICE CUE ]
            </span>
            <button
              onClick={handlePlayVoice}
              className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-slate-950 border ${
                persona === "jinwoo"
                  ? "border-purple-500/40 text-purple-300 hover:border-purple-400"
                  : "border-amber-500/40 text-amber-300 hover:border-amber-400"
              } text-[10px] font-mono font-bold transition-all`}
            >
              <Volume2 className={`w-3.5 h-3.5 ${isSpeaking ? "animate-pulse" : ""}`} />
              <span>{isSpeaking ? "SPEAKING..." : "PLAY AUDIO"}</span>
            </button>
          </div>

          <p className="text-sm sm:text-base text-slate-100 font-medium leading-relaxed my-2">
            {getQuote()}
          </p>

          {nextTask && (
            <div className="mt-3 pt-3 border-t border-slate-800 flex items-center gap-2">
              <CheckCircle2
                className={`w-4 h-4 ${persona === "jinwoo" ? "text-purple-400" : "text-amber-400"}`}
              />
              <span className="text-xs font-mono text-slate-300 truncate">
                TARGET: <span className="text-white font-bold">{nextTask.title}</span>
              </span>
            </div>
          )}
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={onClose}
            className="flex-1 py-3 rounded-xl border border-slate-700 hover:bg-slate-900 text-slate-300 font-mono text-xs font-bold transition-all"
          >
            DISMISS
          </button>
          {nextTask && onExecuteNextTask && (
            <button
              type="button"
              onClick={() => {
                audio.playLevelUp();
                onExecuteNextTask(nextTask.id);
                onClose();
              }}
              className={`flex-[2] py-3 rounded-xl ${
                persona === "jinwoo"
                  ? "bg-purple-400 hover:bg-purple-300 text-black shadow-[0_0_20px_rgba(192,132,252,0.4)]"
                  : "bg-amber-400 hover:bg-amber-300 text-black shadow-[0_0_20px_rgba(251,191,36,0.4)]"
              } font-mono text-xs font-black uppercase tracking-wider transition-all flex items-center justify-center gap-2`}
            >
              <Sparkles className="w-4 h-4" />
              <span>{persona === "jinwoo" ? "EXECUTE QUEST" : "CONQUER S-RANK QUEST"}</span>
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
