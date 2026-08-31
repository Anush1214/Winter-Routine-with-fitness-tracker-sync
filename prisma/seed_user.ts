import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: "postgresql://postgres.xdtfkfzrsjbflfzbawhb:oy43lIJGHav5TzsR@aws-0-ap-south-1.pooler.supabase.com:6543/postgres?pgbouncer=true",
    },
  },
});

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

const TARGET_USERS = [
  'anushrao021@gmail.com',
  'hunter_anushrao021_gmail_com',
  'default_hunter',
];

async function seedUsers() {
  console.log('🚀 Synchronizing Supabase Database for User Accounts:', TARGET_USERS);

  const year = new Date().getFullYear();
  const startDate = new Date(Date.UTC(year, 8, 1)); // Sept 1
  const endDate = new Date(Date.UTC(year, 11, 31)); // Dec 31
  const gymStartDate = new Date(Date.UTC(year, 8, 5)); // Sept 5

  for (const userId of TARGET_USERS) {
    console.log(`\n📦 Processing User: ${userId}`);

    // 1. Settings
    await prisma.userSettings.upsert({
      where: { userId },
      update: {},
      create: {
        id: `settings_${userId.replace(/[^a-zA-Z0-9]/g, '_')}`,
        userId,
        ntfyTopic: 'winter-arc-routine',
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
      },
    });

    const tasksToCreate: any[] = [];
    const healthLogsToCreate: any[] = [];

    const current = new Date(startDate);
    while (current <= endDate) {
      const targetDate = new Date(current);

      for (const task of BASE_DAILY_TASKS) {
        tasksToCreate.push({
          userId,
          title: task.title,
          category: task.category,
          targetDate,
          startTime: task.startTime,
          isCompleted: false,
          autoMetric: task.autoMetric,
        });
      }

      if (targetDate >= gymStartDate) {
        tasksToCreate.push({
          userId,
          title: GYM_TASK.title,
          category: GYM_TASK.category,
          targetDate,
          startTime: GYM_TASK.startTime,
          isCompleted: false,
          autoMetric: GYM_TASK.autoMetric,
        });
      }

      healthLogsToCreate.push({
        userId,
        logDate: targetDate,
        steps: 0,
        sleepMinutes: 0,
        waterIntakeMl: 0,
        gymWorkoutDone: false,
      });

      current.setUTCDate(current.getUTCDate() + 1);
    }

    console.log(`Inserting ${tasksToCreate.length} tasks and ${healthLogsToCreate.length} health logs...`);
    const batchSize = 100;
    for (let i = 0; i < tasksToCreate.length; i += batchSize) {
      await prisma.task.createMany({
        data: tasksToCreate.slice(i, i + batchSize),
        skipDuplicates: true,
      });
    }

    for (let i = 0; i < healthLogsToCreate.length; i += batchSize) {
      await prisma.healthLog.createMany({
        data: healthLogsToCreate.slice(i, i + batchSize),
        skipDuplicates: true,
      });
    }
  }

  console.log('\n✅ All User Data successfully created and synchronized in Supabase!');
}

seedUsers()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
