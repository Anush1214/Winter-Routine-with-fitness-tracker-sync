import { prisma, localStore, isDbConnected } from "../lib/prisma";

export async function processWaterIntake(payload: {
  date: string;
  amountMl: number;
  mode: "increment" | "set";
  userId?: string;
}) {
  const { date, amountMl = 250, mode = "increment", userId = "default_hunter" } = payload;
  const parsedAmount = Number(amountMl) || 0;
  const targetDate = new Date(`${date}T00:00:00Z`);

  if (isDbConnected && prisma) {
    const existing = await prisma.healthLog.findUnique({
      where: {
        userId_logDate: {
          userId,
          logDate: targetDate,
        },
      },
    });

    const currentWater = existing?.waterIntakeMl || 0;
    const newWater = mode === "set" ? Math.max(0, parsedAmount) : Math.max(0, currentWater + parsedAmount);

    const healthLog = await prisma.healthLog.upsert({
      where: {
        userId_logDate: {
          userId,
          logDate: targetDate,
        },
      },
      update: {
        waterIntakeMl: newWater,
        syncedAt: new Date(),
      },
      create: {
        userId,
        logDate: targetDate,
        waterIntakeMl: newWater,
        syncedAt: new Date(),
      },
    });

    let autoChecked = false;
    if (newWater >= 4000) {
      await prisma.task.updateMany({
        where: {
          userId,
          targetDate,
          OR: [
            { title: { contains: "4-5l water", mode: "insensitive" } },
            { autoMetric: "water_4l" },
          ],
        },
        data: { isCompleted: true },
      });
      autoChecked = true;
    }

    const tasks = await prisma.task.findMany({
      where: { userId, targetDate },
      orderBy: [{ startTime: "asc" }, { createdAt: "asc" }],
    });

    return { healthLog, waterIntakeMl: newWater, autoChecked, tasks };
  }

  // Fallback
  const existing = localStore.getHealthLog(date);
  const currentWater = existing.waterIntakeMl || 0;
  const newWater = mode === "set" ? Math.max(0, parsedAmount) : Math.max(0, currentWater + parsedAmount);

  const healthLog = localStore.upsertHealthLog(date, {
    waterIntakeMl: newWater,
  });

  let autoChecked = false;
  if (newWater >= 4000) {
    const dayTasks = localStore.getTasksByDate(date);
    for (const t of dayTasks) {
      if (t.title.toLowerCase().includes("4-5l water") || t.autoMetric === "water_4l") {
        localStore.updateTask(t.id, { isCompleted: true });
        autoChecked = true;
      }
    }
  }

  return {
    healthLog,
    waterIntakeMl: newWater,
    autoChecked,
    tasks: localStore.getTasksByDate(date),
  };
}
