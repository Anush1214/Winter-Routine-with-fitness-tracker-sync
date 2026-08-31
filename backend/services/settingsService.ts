import { prisma, localStore, isDbConnected } from "../lib/prisma";

export async function getUserSettings(userId: string = "default_hunter") {
  if (isDbConnected && prisma) {
    let settings = await prisma.userSettings.findUnique({
      where: { userId },
    });

    if (!settings) {
      settings = await prisma.userSettings.create({
        data: {
          id: userId,
          userId,
          ntfyTopic: "winter-arc-routine",
          ntfyServer: "https://ntfy.sh",
          morningTime: "07:00",
          morningEnabled: true,
          eveningTime: "18:30",
          eveningEnabled: true,
          nightTime: "22:30",
          nightEnabled: true,
          waterGoalMl: 4500,
          stepsGoal: 10000,
          sleepGoalMinutes: 420,
          customSlots: JSON.stringify([
            { id: "midday_sync", name: "Midday Hydration & Step Check", time: "13:30", enabled: true },
          ]),
        },
      });
    }

    return settings;
  }

  return localStore.getSettings(userId);
}

export async function updateUserSettings(updates: Record<string, unknown>, userId: string = "default_hunter") {
  if (isDbConnected && prisma) {
    return await prisma.userSettings.upsert({
      where: { userId },
      update: updates,
      create: {
        id: userId,
        userId,
        ...updates,
      },
    });
  }

  return localStore.updateSettings(updates, userId);
}
