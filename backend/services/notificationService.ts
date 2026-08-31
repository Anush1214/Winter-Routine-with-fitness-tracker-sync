import { prisma, localStore, isDbConnected } from "../lib/prisma";
import { sendNtfyNotification } from "../lib/notifications";
import { formatDateKey, getWinterArcDaysRemaining } from "@/lib/utils";

export async function triggerScheduledNotification(slot: string, targetDateParam: string, appUrl?: string) {
  let ntfyTopic = process.env.NTFY_TOPIC || "winter-arc-routine";
  let ntfyServer = process.env.NTFY_SERVER || "https://ntfy.sh";
  let slotEnabled = true;

  if (isDbConnected && prisma) {
    const settings = await prisma.userSettings.findUnique({ where: { id: "default" } });
    if (settings) {
      if (settings.ntfyTopic) ntfyTopic = settings.ntfyTopic;
      if (settings.ntfyServer) ntfyServer = settings.ntfyServer;
      if (slot === "morning") slotEnabled = settings.morningEnabled;
      if (slot === "evening") slotEnabled = settings.eveningEnabled;
      if (slot === "night") slotEnabled = settings.nightEnabled;
    }
  } else {
    const settings = localStore.getSettings();
    if (settings) {
      if (settings.ntfyTopic) ntfyTopic = settings.ntfyTopic;
      if (settings.ntfyServer) ntfyServer = settings.ntfyServer;
      if (slot === "morning") slotEnabled = settings.morningEnabled;
      if (slot === "evening") slotEnabled = settings.eveningEnabled;
      if (slot === "night") slotEnabled = settings.nightEnabled;
    }
  }

  if (!slotEnabled) {
    return { skipped: true, message: `Slot '${slot}' is disabled in settings` };
  }

  let tasks: Array<{ title: string; category: string; startTime: string | null; isCompleted: boolean }> = [];
  let steps = 0;
  let waterIntakeMl = 0;

  const userId = "default_hunter";

  if (isDbConnected && prisma) {
    const targetDate = new Date(`${targetDateParam}T00:00:00Z`);
    const [dbTasks, healthLog] = await Promise.all([
      prisma.task.findMany({
        where: { userId, targetDate },
        orderBy: [{ startTime: "asc" }, { createdAt: "asc" }],
      }),
      prisma.healthLog.findFirst({
        where: { userId, logDate: targetDate },
      }),
    ]);
    tasks = dbTasks;
    if (healthLog) {
      steps = healthLog.steps;
      waterIntakeMl = healthLog.waterIntakeMl;
    }
  } else {
    tasks = localStore.getTasksByDate(targetDateParam);
    const healthLog = localStore.getHealthLog(targetDateParam);
    steps = healthLog.steps;
    waterIntakeMl = healthLog.waterIntakeMl;
  }

  const completedTasks = tasks.filter((t) => t.isCompleted);
  const pendingTasks = tasks.filter((t) => !t.isCompleted);
  const timeline = getWinterArcDaysRemaining(new Date(`${targetDateParam}T12:00:00`));

  const result = await sendNtfyNotification({
    topic: ntfyTopic,
    serverUrl: ntfyServer,
    slot,
    dateStr: targetDateParam,
    dayNumber: timeline.dayNumber,
    totalDays: timeline.totalDays,
    tasksCompleted: completedTasks.length,
    totalTasks: tasks.length,
    pendingTasks: pendingTasks.map((t) => ({
      title: t.title,
      category: t.category,
      startTime: t.startTime,
    })),
    steps,
    waterIntakeMl,
    appUrl,
  });

  return {
    success: true,
    slot,
    topic: ntfyTopic,
    tasksCount: tasks.length,
    completedCount: completedTasks.length,
    pendingCount: pendingTasks.length,
    delivery: result,
  };
}
