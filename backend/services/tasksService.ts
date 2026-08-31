import { prisma, localStore, isDbConnected } from "../lib/prisma";

export async function getTasksAndHealth(dateParam: string, userId: string = "default_hunter") {
  if (isDbConnected && prisma) {
    const targetDate = new Date(`${dateParam}T00:00:00Z`);
    const [fetchedTasks, healthLog] = await Promise.all([
      prisma.task.findMany({
        where: { targetDate, userId },
        orderBy: [{ startTime: "asc" }, { createdAt: "asc" }],
      }),
      prisma.healthLog.findUnique({
        where: {
          userId_logDate: {
            userId,
            logDate: targetDate,
          },
        },
      }),
    ]);

    let tasks = fetchedTasks;

    if (tasks.length === 0) {
      const year = new Date().getFullYear();
      const gymStartDate = new Date(Date.UTC(year, 8, 5));
      const targetDateObj = new Date(`${dateParam}T00:00:00Z`);

      const defaultTasksData = [
        { title: "Gym Workout Session (06:00 - 07:00)", category: "fitness", startTime: "06:00", autoMetric: "gym_workout" },
        { title: "Wake Up & Morning Protocol", category: "routine", startTime: "07:00", autoMetric: null },
        { title: "Hydration Goal: 4-5L Water", category: "health", startTime: null, autoMetric: "water_4l" },
        { title: "Sleep Recovery: 7-8 Hours", category: "health", startTime: null, autoMetric: "sleep_7h" },
        { title: "Daily Movement: 10,000 Steps", category: "fitness", startTime: null, autoMetric: "steps_10k" },
        { title: "Office Work Shift", category: "routine", startTime: "09:00", autoMetric: null },
        { title: "Self-Study & Revision (If Time Permits)", category: "study", startTime: null, autoMetric: null },
        { title: "Evening Fresh Up & Transition", category: "routine", startTime: "18:30", autoMetric: null },
        { title: "DSA & Placement Preparation Shift", category: "career", startTime: "19:00", autoMetric: null },
        { title: "DSA Practice & Japanese Language", category: "career", startTime: null, autoMetric: null },
        { title: "Major Project Development", category: "career", startTime: null, autoMetric: null },
        { title: "Night Protocol & Sleep by 11:00 PM", category: "routine", startTime: "23:00", autoMetric: null },
      ];

      try {
        await prisma.task.createMany({
          data: defaultTasksData.map((t) => ({
            ...t,
            targetDate: targetDateObj,
            userId,
          })),
        });

        tasks = await prisma.task.findMany({
          where: { targetDate: targetDateObj, userId },
          orderBy: [{ startTime: "asc" }, { createdAt: "asc" }],
        });
      } catch (_) {}
    }

    return {
      tasks: tasks.length > 0 ? tasks : localStore.getTasksByDate(dateParam, userId),
      healthLog: healthLog || {
        logDate: dateParam,
        userId,
        steps: 0,
        sleepMinutes: 0,
        waterIntakeMl: 0,
        gymWorkoutDone: false,
      },
    };
  }

  return {
    tasks: localStore.getTasksByDate(dateParam, userId),
    healthLog: localStore.getHealthLog(dateParam, userId),
  };
}

export async function createTask(data: {
  title: string;
  category?: string;
  targetDate: string;
  startTime?: string | null;
  autoMetric?: string | null;
  applyScope?: "today" | "future" | "all";
  userId?: string;
}) {
  const {
    title,
    category = "routine",
    targetDate,
    startTime = null,
    autoMetric = null,
    applyScope = "today",
    userId = "default_hunter",
  } = data;

  const year = new Date().getFullYear();
  const endDate = new Date(Date.UTC(year, 11, 31)); // Dec 31
  const startDate = new Date(Date.UTC(year, 8, 1)); // Sept 1

  if (isDbConnected && prisma) {
    if (applyScope === "today") {
      const newTask = await prisma.task.create({
        data: {
          title,
          category,
          targetDate: new Date(`${targetDate}T00:00:00Z`),
          startTime,
          autoMetric,
          userId,
        },
      });
      return { task: newTask, count: 1 };
    }

    const tasksToInsert: Array<{
      title: string;
      category: string;
      targetDate: Date;
      startTime: string | null;
      autoMetric: string | null;
      userId: string;
    }> = [];

    let current = applyScope === "all" ? new Date(startDate) : new Date(`${targetDate}T00:00:00Z`);

    while (current <= endDate) {
      tasksToInsert.push({
        title,
        category,
        targetDate: new Date(current),
        startTime,
        autoMetric,
        userId,
      });
      current.setUTCDate(current.getUTCDate() + 1);
    }

    await prisma.task.createMany({ data: tasksToInsert });
    return { count: tasksToInsert.length };
  }

  // Fallback local store
  if (applyScope === "today") {
    const task = localStore.createTask({
      userId,
      title,
      category,
      targetDate,
      startTime,
      isCompleted: false,
      autoMetric,
    });
    return { task, count: 1 };
  }

  let count = 0;
  let current = applyScope === "all" ? new Date(startDate) : new Date(`${targetDate}T00:00:00Z`);

  while (current <= endDate) {
    const dateKey = current.toISOString().split("T")[0];
    localStore.createTask({
      userId,
      title,
      category,
      targetDate: dateKey,
      startTime,
      isCompleted: false,
      autoMetric,
    });
    count++;
    current.setUTCDate(current.getUTCDate() + 1);
  }

  return { count };
}

export async function updateTask(id: string, updates: {
  isCompleted?: boolean;
  title?: string;
  category?: string;
  startTime?: string | null;
  autoMetric?: string | null;
  userId?: string;
}) {
  const { userId, ...data } = updates;
  if (isDbConnected && prisma) {
    return await prisma.task.update({
      where: { id },
      data,
    });
  }

  return localStore.updateTask(id, data);
}

export async function deleteTask(id: string, deleteAllRecurring = false, fromDate?: string, userId?: string) {
  if (isDbConnected && prisma) {
    if (deleteAllRecurring) {
      const existing = await prisma.task.findUnique({ where: { id } });
      if (existing) {
        const deleteQuery: Record<string, unknown> = {
          title: { equals: existing.title, mode: "insensitive" },
          userId: existing.userId,
        };
        if (fromDate) {
          deleteQuery.targetDate = { gte: new Date(`${fromDate}T00:00:00Z`) };
        }
        const result = await prisma.task.deleteMany({ where: deleteQuery });
        return { deletedCount: result.count };
      }
    }
    await prisma.task.delete({ where: { id } });
    return { deletedId: id };
  }

  if (deleteAllRecurring) {
    const existing = localStore.getTaskById(id);
    if (existing) {
      const count = localStore.deleteTasksByTitle(existing.title, fromDate);
      return { deletedCount: count };
    }
  }

  localStore.deleteTask(id);
  return { deletedId: id };
}
