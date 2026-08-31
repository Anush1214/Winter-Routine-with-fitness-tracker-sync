import { prisma, localStore, isDbConnected } from "../lib/prisma";

export async function getTasksAndHealth(dateParam: string) {
  if (isDbConnected && prisma) {
    const targetDate = new Date(`${dateParam}T00:00:00Z`);
    const [tasks, healthLog] = await Promise.all([
      prisma.task.findMany({
        where: { targetDate },
        orderBy: [{ startTime: "asc" }, { createdAt: "asc" }],
      }),
      prisma.healthLog.findUnique({
        where: { logDate: targetDate },
      }),
    ]);

    return {
      tasks,
      healthLog: healthLog || {
        logDate: dateParam,
        steps: 0,
        sleepMinutes: 0,
        waterIntakeMl: 0,
        gymWorkoutDone: false,
      },
    };
  }

  return {
    tasks: localStore.getTasksByDate(dateParam),
    healthLog: localStore.getHealthLog(dateParam),
  };
}

export async function createTask(data: {
  title: string;
  category?: string;
  targetDate: string;
  startTime?: string | null;
  autoMetric?: string | null;
  applyScope?: "today" | "future" | "all";
}) {
  const {
    title,
    category = "routine",
    targetDate,
    startTime = null,
    autoMetric = null,
    applyScope = "today",
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
    }> = [];

    let current = applyScope === "all" ? new Date(startDate) : new Date(`${targetDate}T00:00:00Z`);

    while (current <= endDate) {
      tasksToInsert.push({
        title,
        category,
        targetDate: new Date(current),
        startTime,
        autoMetric,
      });
      current.setUTCDate(current.getUTCDate() + 1);
    }

    await prisma.task.createMany({ data: tasksToInsert });
    return { count: tasksToInsert.length };
  }

  // Fallback local store
  if (applyScope === "today") {
    const task = localStore.createTask({
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
}) {
  if (isDbConnected && prisma) {
    return await prisma.task.update({
      where: { id },
      data: updates,
    });
  }

  return localStore.updateTask(id, updates);
}

export async function deleteTask(id: string, deleteAllRecurring = false, fromDate?: string) {
  if (isDbConnected && prisma) {
    if (deleteAllRecurring) {
      const existing = await prisma.task.findUnique({ where: { id } });
      if (existing) {
        const deleteQuery: Record<string, unknown> = {
          title: { equals: existing.title, mode: "insensitive" },
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
