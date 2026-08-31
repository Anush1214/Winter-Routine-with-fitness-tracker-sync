import { NextRequest, NextResponse } from "next/server";
import { prisma, localStore, isDbConnected } from "@/lib/prisma";
import { sendNtfyNotification } from "@/lib/notifications";
import { formatDateKey, getWinterArcDaysRemaining } from "@/lib/utils";

export const dynamic = "force-dynamic";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json().catch(() => ({}));
    const {
      slot = "morning",
      topic: customTopic,
      server: customServer,
      date = formatDateKey(new Date()),
    } = body;

    let ntfyTopic = customTopic || process.env.NTFY_TOPIC || "winter-arc-routine";
    let ntfyServer = customServer || process.env.NTFY_SERVER || "https://ntfy.sh";

    if (!customTopic) {
      if (isDbConnected && prisma) {
        const settings = await prisma.userSettings.findUnique({ where: { id: "default" } });
        if (settings?.ntfyTopic) ntfyTopic = settings.ntfyTopic;
        if (settings?.ntfyServer) ntfyServer = settings.ntfyServer;
      } else {
        const settings = localStore.getSettings();
        if (settings?.ntfyTopic) ntfyTopic = settings.ntfyTopic;
        if (settings?.ntfyServer) ntfyServer = settings.ntfyServer;
      }
    }

    const tasks = isDbConnected && prisma
      ? await prisma.task.findMany({
          where: { targetDate: new Date(`${date}T00:00:00Z`) },
          orderBy: [{ startTime: "asc" }, { createdAt: "asc" }],
        })
      : localStore.getTasksByDate(date);

    const completed = tasks.filter((t) => t.isCompleted);
    const pending = tasks.filter((t) => !t.isCompleted);
    const timeline = getWinterArcDaysRemaining(new Date(`${date}T12:00:00`));

    const healthLog = isDbConnected && prisma
      ? await prisma.healthLog.findUnique({ where: { logDate: new Date(`${date}T00:00:00Z`) } })
      : localStore.getHealthLog(date);

    const result = await sendNtfyNotification({
      topic: ntfyTopic,
      serverUrl: ntfyServer,
      slot,
      dateStr: date,
      dayNumber: timeline.dayNumber,
      totalDays: timeline.totalDays,
      tasksCompleted: completed.length,
      totalTasks: tasks.length || 11,
      pendingTasks: pending.map((t) => ({
        title: t.title,
        category: t.category,
        startTime: t.startTime,
      })),
      steps: healthLog?.steps || 6420,
      waterIntakeMl: healthLog?.waterIntakeMl || 2500,
      appUrl: process.env.NEXT_PUBLIC_APP_URL || request.nextUrl.origin,
    });

    return NextResponse.json({
      success: true,
      message: `Test push sent to topic '${ntfyTopic}'`,
      result,
    });
  } catch (error: unknown) {
    console.error("POST /api/notifications/test error:", error);
    return NextResponse.json(
      { success: false, error: (error as Error).message },
      { status: 500 }
    );
  }
}
