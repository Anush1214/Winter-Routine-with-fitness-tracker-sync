// ntfy.sh Dynamic Push Notification Service

export interface NotificationPayload {
  topic: string;
  serverUrl?: string;
  slot: "morning" | "evening" | "night" | "custom" | string;
  dateStr: string;
  dayNumber: number;
  totalDays: number;
  tasksCompleted: number;
  totalTasks: number;
  pendingTasks: Array<{ title: string; category: string; startTime?: string | null }>;
  steps?: number;
  waterIntakeMl?: number;
  appUrl?: string;
}

export async function sendNtfyNotification(payload: NotificationPayload) {
  const server = payload.serverUrl || process.env.NTFY_SERVER || "https://ntfy.sh";
  const topic = payload.topic || process.env.NTFY_TOPIC || "winter-arc-routine";
  const appUrl = payload.appUrl || process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";

  let title = "❄️ Winter Arc Protocol";
  let priority = "4";
  let tags = "snowflake,dart";
  let greeting = "";

  const percent = payload.totalTasks > 0 ? Math.round((payload.tasksCompleted / payload.totalTasks) * 100) : 0;
  const pendingCount = payload.pendingTasks.length;

  if (payload.slot === "morning") {
    title = `🌅 Day ${payload.dayNumber}/122: Morning Briefing`;
    priority = "4";
    tags = "sunrise,muscle,snowflake";
    greeting = `**Rise and conquer.** Today is Day **${payload.dayNumber} of ${payload.totalDays}** in your 4-month transformation.`;
  } else if (payload.slot === "evening") {
    title = `🎯 Evening Shift: DSA & Placement Prep`;
    priority = "4";
    tags = "fire,target,laptop";
    greeting = `**Time to lock in.** Office is done—now dedicate yourself to DSA, placement preparation, and Japanese.`;
  } else if (payload.slot === "night") {
    title = `🌙 Nightly Review: Wrap-up & Recovery`;
    priority = "3";
    tags = "moon,bed,trophy";
    greeting = `**Daily protocol wrap-up.** Review your major project progress and prep for 11 PM sleep.`;
  } else {
    title = `⚡ Winter Arc: ${payload.slot.toUpperCase()} Alert`;
    priority = "3";
    tags = "zap,snowflake";
    greeting = `**Winter Arc Protocol Check-in.** Stay disciplined and focused.`;
  }

  // Build Markdown body
  let body = `${greeting}\n\n`;
  body += `📊 **Today's Score:** \`${payload.tasksCompleted}/${payload.totalTasks} Done (${percent}%)\`\n`;

  if (payload.steps !== undefined || payload.waterIntakeMl !== undefined) {
    body += `💧 Water: \`${payload.waterIntakeMl || 0} / 4,500 ml\` | 👟 Steps: \`${(payload.steps || 0).toLocaleString()} / 10,000\`\n\n`;
  }

  if (pendingCount > 0) {
    body += `### 🔥 Pending Routine Tasks (${pendingCount}):\n`;
    payload.pendingTasks.slice(0, 7).forEach((t) => {
      const timeStr = t.startTime ? ` [${t.startTime}]` : "";
      body += `- ⏳ **${t.title}**${timeStr} *(${t.category})*\n`;
    });
    if (pendingCount > 7) {
      body += `*...and ${pendingCount - 7} more tasks.*\n`;
    }
  } else {
    body += `\n🎉 **100% COMPLETE! All protocol targets achieved for today.** Elite discipline. 🏆\n`;
  }

  body += `\n🔗 [Open Winter Arc Tracker](${appUrl})`;

  const endpoint = `${server.replace(/\/$/, "")}/${topic}`;

  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Title: title,
      Priority: priority,
      Tags: tags,
      Markdown: "yes",
      Actions: `view, Open Protocol, ${appUrl}, clear=true`,
    },
    body,
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`ntfy push failed (${response.status}): ${errorText}`);
  }

  return { success: true, topic, message: "Notification delivered successfully" };
}
