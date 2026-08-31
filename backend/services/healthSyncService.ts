import { prisma, localStore, isDbConnected } from "../lib/prisma";

export async function processHealthSync(payload: {
  date: string;
  steps: number;
  sleepMinutes: number;
  gymWorkoutDone: boolean;
  waterIntakeMl: number;
  userId?: string;
}) {
  const { date, steps = 0, sleepMinutes = 0, gymWorkoutDone = false, waterIntakeMl = 0, userId = "default_hunter" } = payload;
  const parsedSteps = Number(steps) || 0;
  const parsedSleep = Number(sleepMinutes) || 0;
  const parsedWater = Number(waterIntakeMl) || 0;
  const parsedGym = Boolean(gymWorkoutDone);
  const autoCheckedTasks: string[] = [];

  if (isDbConnected && prisma) {
    const targetDate = new Date(`${date}T00:00:00Z`);
    const settings = await prisma.userSettings.findUnique({ where: { userId } });
    const stepsGoal = settings?.stepsGoal || 10000;
    const sleepGoal = settings?.sleepGoalMinutes || 420;

    const healthLog = await prisma.healthLog.upsert({
      where: {
        userId_logDate: {
          userId,
          logDate: targetDate,
        },
      },
      update: {
        steps: parsedSteps,
        sleepMinutes: parsedSleep,
        gymWorkoutDone: parsedGym,
        ...(parsedWater > 0 ? { waterIntakeMl: parsedWater } : {}),
        syncedAt: new Date(),
      },
      create: {
        userId,
        logDate: targetDate,
        steps: parsedSteps,
        sleepMinutes: parsedSleep,
        gymWorkoutDone: parsedGym,
        waterIntakeMl: parsedWater,
        syncedAt: new Date(),
      },
    });

    if (parsedSteps >= stepsGoal) {
      await prisma.task.updateMany({
        where: { targetDate, userId, autoMetric: "steps_10k" },
        data: { isCompleted: true },
      });
      autoCheckedTasks.push("10k steps");
    }

    if (parsedSleep >= sleepGoal) {
      await prisma.task.updateMany({
        where: { targetDate, userId, autoMetric: "sleep_7h" },
        data: { isCompleted: true },
      });
      autoCheckedTasks.push("7-8hr Sleep");
    }

    if (parsedGym) {
      await prisma.task.updateMany({
        where: { targetDate, userId, autoMetric: "gym_workout" },
        data: { isCompleted: true },
      });
      autoCheckedTasks.push("Gym Workout");
    }

    if ((healthLog.waterIntakeMl || parsedWater) >= 4000) {
      await prisma.task.updateMany({
        where: {
          targetDate,
          userId,
          OR: [
            { title: { contains: "4-5l water", mode: "insensitive" } },
            { autoMetric: "water_4l" },
          ],
        },
        data: { isCompleted: true },
      });
      autoCheckedTasks.push("4-5l water");
    }

    const tasks = await prisma.task.findMany({
      where: { targetDate, userId },
      orderBy: [{ startTime: "asc" }, { createdAt: "asc" }],
    });

    return { healthLog, autoCheckedTasks, tasks };
  }

  // Fallback
  const settings = localStore.getSettings();
  const stepsGoal = settings.stepsGoal || 10000;
  const sleepGoal = settings.sleepGoalMinutes || 420;

  const healthLog = localStore.upsertHealthLog(date, {
    steps: parsedSteps,
    sleepMinutes: parsedSleep,
    gymWorkoutDone: parsedGym,
    ...(parsedWater > 0 ? { waterIntakeMl: parsedWater } : {}),
  });

  const dayTasks = localStore.getTasksByDate(date);
  for (const task of dayTasks) {
    if (task.autoMetric === "steps_10k" && parsedSteps >= stepsGoal) {
      localStore.updateTask(task.id, { isCompleted: true });
      autoCheckedTasks.push(task.title);
    }
    if (task.autoMetric === "sleep_7h" && parsedSleep >= sleepGoal) {
      localStore.updateTask(task.id, { isCompleted: true });
      autoCheckedTasks.push(task.title);
    }
    if (task.autoMetric === "gym_workout" && parsedGym) {
      localStore.updateTask(task.id, { isCompleted: true });
      autoCheckedTasks.push(task.title);
    }
    if (
      (task.title.toLowerCase().includes("4-5l water") || task.autoMetric === "water_4l") &&
      healthLog.waterIntakeMl >= 4000
    ) {
      localStore.updateTask(task.id, { isCompleted: true });
      autoCheckedTasks.push(task.title);
    }
  }

  return {
    healthLog,
    autoCheckedTasks,
    tasks: localStore.getTasksByDate(date),
  };
}
