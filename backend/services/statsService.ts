import { prisma, localStore, isDbConnected } from "../lib/prisma";
import { formatDateKey, getWinterArcDaysRemaining } from "@/lib/utils";

export async function getHeatmapMatrix() {
  const year = new Date().getFullYear();
  const startDate = new Date(Date.UTC(year, 8, 1)); // Sept 1
  const endDate = new Date(Date.UTC(year, 11, 31)); // Dec 31

  if (isDbConnected && prisma) {
    const [tasks, healthLogs] = await Promise.all([
      prisma.task.findMany({
        where: { targetDate: { gte: startDate, lte: endDate } },
        select: { targetDate: true, isCompleted: true },
      }),
      prisma.healthLog.findMany({
        where: { logDate: { gte: startDate, lte: endDate } },
      }),
    ]);

    const taskMap = new Map<string, { total: number; completed: number }>();
    tasks.forEach((t) => {
      const key = t.targetDate.toISOString().split("T")[0];
      const cur = taskMap.get(key) || { total: 0, completed: 0 };
      cur.total += 1;
      if (t.isCompleted) cur.completed += 1;
      taskMap.set(key, cur);
    });

    const logMap = new Map<string, typeof healthLogs[0]>();
    healthLogs.forEach((l) => {
      const key = l.logDate.toISOString().split("T")[0];
      logMap.set(key, l);
    });

    const days: Array<{
      date: string;
      totalTasks: number;
      completedTasks: number;
      completionRate: number;
      steps: number;
      waterIntakeMl: number;
      sleepMinutes: number;
      gymWorkoutDone: boolean;
    }> = [];

    const current = new Date(startDate);
    while (current <= endDate) {
      const key = current.toISOString().split("T")[0];
      const taskInfo = taskMap.get(key) || { total: 11, completed: 0 };
      const log = logMap.get(key);
      const rate = taskInfo.total > 0 ? Math.round((taskInfo.completed / taskInfo.total) * 100) : 0;

      days.push({
        date: key,
        totalTasks: taskInfo.total,
        completedTasks: taskInfo.completed,
        completionRate: rate,
        steps: log?.steps || 0,
        waterIntakeMl: log?.waterIntakeMl || 0,
        sleepMinutes: log?.sleepMinutes || 0,
        gymWorkoutDone: log?.gymWorkoutDone || false,
      });

      current.setUTCDate(current.getUTCDate() + 1);
    }

    return days;
  }

  // Fallback
  const allTasks = localStore.getAllTasks();
  const allLogs = localStore.getAllHealthLogs();

  const taskMap = new Map<string, { total: number; completed: number }>();
  allTasks.forEach((t) => {
    const cur = taskMap.get(t.targetDate) || { total: 0, completed: 0 };
    cur.total += 1;
    if (t.isCompleted) cur.completed += 1;
    taskMap.set(t.targetDate, cur);
  });

  const logMap = new Map<string, typeof allLogs[0]>();
  allLogs.forEach((l) => {
    logMap.set(l.logDate, l);
  });

  const days: Array<{
    date: string;
    totalTasks: number;
    completedTasks: number;
    completionRate: number;
    steps: number;
    waterIntakeMl: number;
    sleepMinutes: number;
    gymWorkoutDone: boolean;
  }> = [];

  const current = new Date(startDate);
  while (current <= endDate) {
    const key = current.toISOString().split("T")[0];
    const taskInfo = taskMap.get(key) || { total: 11, completed: 0 };
    const log = logMap.get(key);
    const rate = taskInfo.total > 0 ? Math.round((taskInfo.completed / taskInfo.total) * 100) : 0;

    days.push({
      date: key,
      totalTasks: taskInfo.total,
      completedTasks: taskInfo.completed,
      completionRate: rate,
      steps: log?.steps || 0,
      waterIntakeMl: log?.waterIntakeMl || 0,
      sleepMinutes: log?.sleepMinutes || 0,
      gymWorkoutDone: log?.gymWorkoutDone || false,
    });

    current.setUTCDate(current.getUTCDate() + 1);
  }

  return days;
}

export async function getSummaryStats() {
  const todayStr = formatDateKey(new Date());
  const timeline = getWinterArcDaysRemaining(new Date());

  let totalTasksCount = 0;
  let completedTasksCount = 0;
  let currentStreak = 0;
  let bestStreak = 0;

  if (isDbConnected && prisma) {
    const allTasks = await prisma.task.findMany({
      select: { targetDate: true, isCompleted: true },
      orderBy: { targetDate: "asc" },
    });

    totalTasksCount = allTasks.length;
    completedTasksCount = allTasks.filter((t) => t.isCompleted).length;

    const dateMap = new Map<string, { total: number; completed: number }>();
    allTasks.forEach((t) => {
      const key = t.targetDate.toISOString().split("T")[0];
      const cur = dateMap.get(key) || { total: 0, completed: 0 };
      cur.total += 1;
      if (t.isCompleted) cur.completed += 1;
      dateMap.set(key, cur);
    });

    let tempStreak = 0;
    for (const [dateKey, info] of dateMap.entries()) {
      if (dateKey > todayStr) break;
      const rate = info.total > 0 ? info.completed / info.total : 0;
      if (rate >= 0.75) {
        tempStreak++;
        if (tempStreak > bestStreak) bestStreak = tempStreak;
      } else if (dateKey < todayStr) {
        tempStreak = 0;
      }
    }
    currentStreak = tempStreak;
  } else {
    const allTasks = localStore.getAllTasks();
    totalTasksCount = allTasks.length;
    completedTasksCount = allTasks.filter((t) => t.isCompleted).length;

    const dateMap = new Map<string, { total: number; completed: number }>();
    allTasks.forEach((t) => {
      const cur = dateMap.get(t.targetDate) || { total: 0, completed: 0 };
      cur.total += 1;
      if (t.isCompleted) cur.completed += 1;
      dateMap.set(t.targetDate, cur);
    });

    let tempStreak = 0;
    for (const [dateKey, info] of dateMap.entries()) {
      if (dateKey > todayStr) break;
      const rate = info.total > 0 ? info.completed / info.total : 0;
      if (rate >= 0.75) {
        tempStreak++;
        if (tempStreak > bestStreak) bestStreak = tempStreak;
      } else if (dateKey < todayStr) {
        tempStreak = 0;
      }
    }
    currentStreak = tempStreak;
  }

  const overallRate = totalTasksCount > 0 ? Math.round((completedTasksCount / totalTasksCount) * 100) : 0;

  return {
    timeline,
    currentStreak,
    bestStreak,
    totalTasksCount,
    completedTasksCount,
    overallRate,
  };
}
