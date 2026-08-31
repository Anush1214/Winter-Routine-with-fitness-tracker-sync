import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const BASE_DAILY_TASKS = [
  { title: 'Wake Up & Morning Protocol', category: 'routine', startTime: '07:00', autoMetric: null },
  { title: 'Hydration Goal: 4-5L Water', category: 'health', startTime: null, autoMetric: 'water_4l' },
  { title: 'Sleep Recovery: 7-8 Hours', category: 'health', startTime: null, autoMetric: 'sleep_7h' },
  { title: 'Daily Movement: 10,000 Steps', category: 'fitness', startTime: null, autoMetric: 'steps_10k' },
  { title: 'Office Work Shift', category: 'routine', startTime: '09:00', autoMetric: null },
  { title: 'Self-Study & Revision (If Time Permits)', category: 'study', startTime: null, autoMetric: null },
  { title: 'Evening Fresh Up & Transition', category: 'routine', startTime: '18:30', autoMetric: null },
  { title: 'DSA & Placement Preparation Shift', category: 'career', startTime: '19:00', autoMetric: null },
  { title: 'DSA Practice & Japanese Language', category: 'career', startTime: null, autoMetric: null },
  { title: 'Major Project Development', category: 'career', startTime: null, autoMetric: null },
  { title: 'Night Protocol & Sleep by 11:00 PM', category: 'routine', startTime: '23:00', autoMetric: null },
];

const GYM_TASK = {
  title: 'Gym Workout Session (06:00 - 07:00)',
  category: 'fitness',
  startTime: '06:00',
  autoMetric: 'gym_workout',
};

async function main() {
  console.log('🌱 Starting Winter Arc Database Seeding (Sept 1 - Dec 31)...');

  // 1. Seed or Upsert UserSettings
  await prisma.userSettings.upsert({
    where: { id: 'default' },
    update: {},
    create: {
      id: 'default',
      ntfyTopic: 'winter-arc-' + Math.random().toString(36).substring(2, 8),
      ntfyServer: 'https://ntfy.sh',
      morningTime: '07:00',
      morningEnabled: true,
      eveningTime: '18:30',
      eveningEnabled: true,
      nightTime: '22:30',
      nightEnabled: true,
      waterGoalMl: 4500,
      stepsGoal: 10000,
      sleepGoalMinutes: 420,
      customSlots: JSON.stringify([
        { id: 'midday_sync', name: 'Midday Hydration & Step Check', time: '13:30', enabled: true }
      ]),
    },
  });

  const year = new Date().getFullYear();
  const startDate = new Date(Date.UTC(year, 8, 1)); // September 1 (month index 8)
  const endDate = new Date(Date.UTC(year, 11, 31)); // December 31 (month index 11)
  const gymStartDate = new Date(Date.UTC(year, 8, 5)); // September 5

  const tasksToCreate: Array<{
    title: string;
    category: string;
    targetDate: Date;
    startTime: string | null;
    isCompleted: boolean;
    autoMetric: string | null;
  }> = [];

  const healthLogsToCreate: Array<{
    logDate: Date;
    steps: number;
    sleepMinutes: number;
    waterIntakeMl: number;
    gymWorkoutDone: boolean;
  }> = [];

  const current = new Date(startDate);
  while (current <= endDate) {
    const targetDate = new Date(current);

    // 11 Base Tasks
    for (const task of BASE_DAILY_TASKS) {
      tasksToCreate.push({
        title: task.title,
        category: task.category,
        targetDate,
        startTime: task.startTime,
        isCompleted: false,
        autoMetric: task.autoMetric,
      });
    }

    // Conditional Gym task from Sept 5 onwards
    if (targetDate >= gymStartDate) {
      tasksToCreate.push({
        title: GYM_TASK.title,
        category: GYM_TASK.category,
        targetDate,
        startTime: GYM_TASK.startTime,
        isCompleted: false,
        autoMetric: GYM_TASK.autoMetric,
      });
    }

    healthLogsToCreate.push({
      logDate: targetDate,
      steps: 0,
      sleepMinutes: 0,
      waterIntakeMl: 0,
      gymWorkoutDone: false,
    });

    // Advance 1 day
    current.setUTCDate(current.getUTCDate() + 1);
  }

  console.log(`Prepared ${tasksToCreate.length} tasks and ${healthLogsToCreate.length} health log entries for 122 days.`);

  // Clear existing tasks & logs if any (or batch create)
  console.log('Inserting tasks in batches...');
  const batchSize = 100;
  for (let i = 0; i < tasksToCreate.length; i += batchSize) {
    const batch = tasksToCreate.slice(i, i + batchSize);
    await prisma.task.createMany({
      data: batch,
      skipDuplicates: true,
    });
  }

  for (let i = 0; i < healthLogsToCreate.length; i += batchSize) {
    const batch = healthLogsToCreate.slice(i, i + batchSize);
    await prisma.healthLog.createMany({
      data: batch,
      skipDuplicates: true,
    });
  }

  console.log('✅ Seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
