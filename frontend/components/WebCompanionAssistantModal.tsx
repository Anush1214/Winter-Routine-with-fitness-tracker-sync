"use client";

import React, { useState } from "react";
import { X, Volume2, Sparkles, CheckCircle2, Shield, Heart } from "lucide-react";
import { audio } from "../lib/audio";

export type CompanionPersona = "jinwoo" | "hinata";
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
      return lang === "ja" ? "Nana Mizuki (水樹 奈々)" : "Stephanie Sheh";
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
      // HINATA HYUGA
      if (lang === "ja") {
        if (nextTask) {
          const t = nextTask.title.toLowerCase();
          if (t.includes("wake") || t.includes("gym")) {
            return "「おはようございます！ 朝の鍛錬、一緒に頑張ろうね... 私も諦めないよ！」";
          } else if (t.includes("dsa") || t.includes("japanese")) {
            return "「DSAのお勉強、ずっと応援してるよ... あなたの努力、ちゃんと見てるからね！」";
          } else if (t.includes("night") || t.includes("sleep")) {
            return "「今日も一日本当にお疲れ様でした。ゆっくり休んで、明日も前を向こうね... おやすみなさい。」";
          }
          return `「次の目標は 『${nextTask.title}』 だね... 私、信じてるから、頑張ってね！」`;
        }
        if (hour >= 6 && hour < 12) return "「今日も新しい一日の始まりだよ！ お水もしっかり飲んで、一緒に歩んでいこうね。」";
        if (hour >= 18 && hour < 22) return "「夕方の修行の時間だよ！ 自分の忍道を貫いて、一歩ずつ前に進もう！」";
        return "「クエスト達成おめでとう！ あなたは本当にすごいよ... 今夜はゆっくり休んでね。」";
      } else {
        if (nextTask) {
          const t = nextTask.title.toLowerCase();
          if (t.includes("wake") || t.includes("gym")) {
            return "“Good morning! Let's give our best in today's morning training. I won't back down, and I know you won't either!”";
          } else if (t.includes("dsa") || t.includes("japanese")) {
            return "“Time for Placement & DSA practice! Keep your focus sharp—I believe in you with all my heart.”";
          } else if (t.includes("night") || t.includes("sleep")) {
            return "“You did amazing today! Please get plenty of rest so you can restore your chakra for tomorrow. Good night!”";
          }
          return `“Your next mission is ‘${nextTask.title}’. Take a deep breath, stay confident, and conquer it!”`;
        }
        if (hour >= 6 && hour < 12) return "“A new day begins! Hydrate, stay strong, and let's make every moment count together.”";
        if (hour >= 18 && hour < 22) return "“Evening training is here. Never give up on your dreams—that is our ninja way!”";
        return "“All daily objectives completed! I'm so proud of how far you've come. Rest well tonight!”";
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
      utterance.pitch = persona === "jinwoo" ? 0.85 : 1.25;
      utterance.rate = persona === "jinwoo" ? 0.95 : 1.05;

      utterance.onstart = () => setIsSpeaking(true);
      utterance.onend = () => setIsSpeaking(false);
      utterance.onerror = () => setIsSpeaking(false);

      window.speechSynthesis.speak(utterance);
    }
  };

  const themeColor = persona === "jinwoo" ? "cyan" : "pink";

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/90 backdrop-blur-lg animate-fade-in">
      <div
        className={`relative w-full max-w-lg bg-[#02050E] border-2 ${
          persona === "jinwoo"
            ? "border-cyan-400/80 shadow-[0_0_50px_rgba(0,240,255,0.35)]"
            : "border-pink-400/80 shadow-[0_0_50px_rgba(255,119,169,0.35)]"
        } rounded-3xl p-6 sm:p-8 overflow-hidden`}
      >
        {/* Glowing Background Radial */}
        <div
          className={`absolute -top-24 -right-24 w-48 h-48 ${
            persona === "jinwoo" ? "bg-cyan-500/20" : "bg-pink-500/20"
          } rounded-full blur-3xl pointer-events-none`}
        />
        <div
          className={`absolute -bottom-24 -left-24 w-48 h-48 ${
            persona === "jinwoo" ? "bg-violet-600/20" : "bg-purple-600/20"
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
                ? "bg-slate-950 border-2 border-cyan-400 shadow-[0_0_20px_rgba(0,240,255,0.5)]"
                : "bg-slate-950 border-2 border-pink-400 shadow-[0_0_20px_rgba(255,119,169,0.5)]"
            } flex items-center justify-center`}
          >
            {persona === "jinwoo" ? (
              <Shield className="w-7 h-7 text-cyan-400" />
            ) : (
              <Heart className="w-7 h-7 text-pink-400" />
            )}
          </div>
          <div>
            <span
              className={`inline-block px-2 py-0.5 rounded text-[9px] font-mono font-bold uppercase tracking-widest ${
                persona === "jinwoo"
                  ? "bg-cyan-950/80 text-cyan-400 border border-cyan-500/30"
                  : "bg-pink-950/80 text-pink-400 border border-pink-500/30"
              }`}
            >
              {persona === "jinwoo" ? "SHADOW MONARCH COMPANION" : "GENTLE STEP NINJA COMPANION"}
            </span>
            <h2 className="text-xl font-black font-['Outfit'] uppercase tracking-wider text-white mt-0.5">
              {persona === "jinwoo" ? "SUNG JIN-WOO" : "HINATA HYUGA"}
            </h2>
            <p className="text-[11px] font-mono text-slate-400">
              VA: <span className={persona === "jinwoo" ? "text-cyan-300 font-bold" : "text-pink-300 font-bold"}>{getVoiceActorName()}</span>
            </p>
          </div>
        </div>

        {/* Persona Switcher */}
        <div className="grid grid-cols-2 gap-2 p-1 bg-slate-950 rounded-xl border border-slate-800 mb-3">
          <button
            type="button"
            onClick={() => {
              audio.playClick();
              setPersona("jinwoo");
            }}
            className={`flex items-center justify-center gap-1.5 py-2 rounded-lg font-mono text-xs font-bold transition-all ${
              persona === "jinwoo"
                ? "bg-cyan-500/20 text-cyan-300 border border-cyan-400"
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
              setPersona("hinata");
            }}
            className={`flex items-center justify-center gap-1.5 py-2 rounded-lg font-mono text-xs font-bold transition-all ${
              persona === "hinata"
                ? "bg-pink-500/20 text-pink-300 border border-pink-400"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            <span>🌸</span>
            <span>HINATA (FEMALE)</span>
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
                  ? "bg-cyan-950 text-cyan-300 border border-cyan-500/40"
                  : "bg-pink-950 text-pink-300 border border-pink-500/40"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            🇺🇸 {persona === "jinwoo" ? "ALEKS LE (EN)" : "STEPHANIE SHEH (EN)"}
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
                  : "bg-purple-950 text-purple-300 border border-purple-500/40"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            🇯🇵 {persona === "jinwoo" ? "TAITO BAN (JP)" : "NANA MIZUKI (JP)"}
          </button>
        </div>

        {/* Holographic Quote Dialogue Box */}
        <div
          className={`p-4 sm:p-5 rounded-2xl bg-gradient-to-br from-slate-900 via-slate-950 to-[#02050E] border ${
            persona === "jinwoo" ? "border-cyan-500/40" : "border-pink-500/40"
          } mb-5 relative`}
        >
          <div className="flex items-center justify-between mb-2">
            <span
              className={`text-[10px] font-mono font-bold ${
                persona === "jinwoo" ? "text-cyan-400" : "text-pink-400"
              }`}
            >
              [ {getVoiceActorName()} // VOICE CUE ]
            </span>
            <button
              onClick={handlePlayVoice}
              className={`flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-slate-950 border ${
                persona === "jinwoo"
                  ? "border-cyan-500/40 text-cyan-300 hover:border-cyan-400"
                  : "border-pink-500/40 text-pink-300 hover:border-pink-400"
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
                className={`w-4 h-4 ${persona === "jinwoo" ? "text-cyan-400" : "text-pink-400"}`}
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
                  ? "bg-cyan-400 hover:bg-cyan-300 text-black shadow-[0_0_20px_rgba(0,240,255,0.4)]"
                  : "bg-pink-400 hover:bg-pink-300 text-black shadow-[0_0_20px_rgba(255,119,169,0.4)]"
              } font-mono text-xs font-black uppercase tracking-wider transition-all flex items-center justify-center gap-2`}
            >
              <Sparkles className="w-4 h-4" />
              <span>{persona === "jinwoo" ? "EXECUTE QUEST" : "CONQUER QUEST"}</span>
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
