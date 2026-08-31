"use client";

import React, { useState, useEffect, useCallback } from "react";
import { Header } from "@/frontend/components/Header";
import { DateCarousel } from "@/frontend/components/DateCarousel";
import { DailyProgressCard } from "@/frontend/components/DailyProgressCard";
import { RoutineSection } from "@/frontend/components/RoutineSection";
import { HabitCounters } from "@/frontend/components/HabitCounters";
import { ConsistencyHeatmap, HeatmapDayData } from "@/frontend/components/ConsistencyHeatmap";
import { TaskModal } from "@/frontend/components/TaskModal";
import { NotificationSettingsModal } from "@/frontend/components/NotificationSettingsModal";
import { SmartwatchSyncModal } from "@/frontend/components/SmartwatchSyncModal";
import { WebAriseSplash } from "@/frontend/components/WebAriseSplash";
import { WebAuthModal } from "@/frontend/components/WebAuthModal";
import { WebProfileModal } from "@/frontend/components/WebProfileModal";
import { TaskData } from "@/frontend/components/TaskItem";
import { formatDateKey } from "@/frontend/lib/utils";
import { Loader2 } from "lucide-react";

interface HunterUser {
  uid: string;
  email: string;
  displayName: string;
  photoUrl?: string;
  provider: string;
}

export default function WinterArcDashboard() {
  const [splashComplete, setSplashComplete] = useState<boolean>(false);
  const [hunterUser, setHunterUser] = useState<HunterUser | null>(null);

  const [selectedDate, setSelectedDate] = useState<string>(() => {
    const today = formatDateKey(new Date());
    const year = new Date().getFullYear();
    const sept1 = `${year}-09-01`;
    const dec31 = `${year}-12-31`;
    if (today >= sept1 && today <= dec31) return today;
    return sept1;
  });

  const [tasks, setTasks] = useState<TaskData[]>([]);
  const [healthLog, setHealthLog] = useState<{
    steps: number;
    sleepMinutes: number;
    waterIntakeMl: number;
    gymWorkoutDone: boolean;
  }>({
    steps: 0,
    sleepMinutes: 0,
    waterIntakeMl: 0,
    gymWorkoutDone: false,
  });

  const [heatmapDays, setHeatmapDays] = useState<HeatmapDayData[]>([]);
  const [currentStreak, setCurrentStreak] = useState<number>(0);
  const [bestStreak, setBestStreak] = useState<number>(0);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Modals state
  const [taskModalOpen, setTaskModalOpen] = useState(false);
  const [editingTask, setEditingTask] = useState<TaskData | null>(null);
  const [targetSlotId, setTargetSlotId] = useState<string | undefined>(undefined);
  const [notificationModalOpen, setNotificationModalOpen] = useState(false);
  const [smartwatchModalOpen, setSmartwatchModalOpen] = useState(false);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [profileModalOpen, setProfileModalOpen] = useState(false);

  // Restore saved hunter user session from localStorage
  useEffect(() => {
    try {
      const saved = localStorage.getItem("winter_arc_hunter_user");
      if (saved) {
        setHunterUser(JSON.parse(saved));
      }
    } catch (_) {}
  }, []);

  const activeUserId = hunterUser?.uid || "default_hunter";

  // 1. Fetch tasks & health for selected date & user
  const loadDateData = useCallback(async (date: string, userId: string) => {
    try {
      const res = await fetch(`/api/tasks?date=${date}&userId=${userId}`);
      const data = await res.json();
      if (data.success) {
        setTasks(data.tasks || []);
        if (data.healthLog) {
          setHealthLog({
            steps: data.healthLog.steps || 0,
            sleepMinutes: data.healthLog.sleepMinutes || 0,
            waterIntakeMl: data.healthLog.waterIntakeMl || 0,
            gymWorkoutDone: Boolean(data.healthLog.gymWorkoutDone),
          });
        }
      }
    } catch (err) {
      console.error("Failed to load tasks:", err);
    }
  }, []);

  // 2. Fetch Heatmap and Summary scoped to user
  const loadStats = useCallback(async (userId: string) => {
    try {
      const [heatRes, sumRes] = await Promise.all([
        fetch(`/api/stats/heatmap?userId=${userId}`),
        fetch(`/api/stats/summary?userId=${userId}`),
      ]);
      const heatData = await heatRes.json();
      const sumData = await sumRes.json();

      if (heatData.success) {
        setHeatmapDays(heatData.days || []);
      }
      if (sumData.success) {
        setCurrentStreak(sumData.currentStreak || 0);
        setBestStreak(sumData.bestStreak || 0);
      }
    } catch (err) {
      console.error("Failed to load stats:", err);
    }
  }, []);

  useEffect(() => {
    const init = async () => {
      setIsLoading(true);
      await Promise.all([loadDateData(selectedDate, activeUserId), loadStats(activeUserId)]);
      setIsLoading(false);
    };
    init();
  }, [selectedDate, activeUserId, loadDateData, loadStats]);

  const handleAuthSuccess = (user: HunterUser) => {
    setHunterUser(user);
    try {
      localStorage.setItem("winter_arc_hunter_user", JSON.stringify(user));
    } catch (_) {}
  };

  const handleSignOut = () => {
    setHunterUser(null);
    try {
      localStorage.removeItem("winter_arc_hunter_user");
    } catch (_) {}
    setProfileModalOpen(false);
  };

  const handleUpdateName = (newName: string) => {
    if (!hunterUser) return;
    const updated = { ...hunterUser, displayName: newName };
    setHunterUser(updated);
    try {
      localStorage.setItem("winter_arc_hunter_user", JSON.stringify(updated));
    } catch (_) {}
  };

  // Toggle task completed
  const handleToggleTask = async (id: string, current: boolean) => {
    const newStatus = !current;
    setTasks((prev) =>
      prev.map((t) => (t.id === id ? { ...t, isCompleted: newStatus } : t))
    );

    setHeatmapDays((prev) =>
      prev.map((d) => {
        if (d.date === selectedDate) {
          const newCompleted = newStatus ? d.completedTasks + 1 : Math.max(0, d.completedTasks - 1);
          const newRate = d.totalTasks > 0 ? Math.round((newCompleted / d.totalTasks) * 100) : 0;
          return { ...d, completedTasks: newCompleted, completionRate: newRate };
        }
        return d;
      })
    );

    try {
      await fetch(`/api/tasks/${id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ isCompleted: newStatus, userId: activeUserId }),
      });
      loadStats(activeUserId);
    } catch (err) {
      console.error("Task toggle failed:", err);
      loadDateData(selectedDate, activeUserId);
    }
  };

  // Delete task
  const handleDeleteTask = async (id: string, title: string) => {
    const confirmDelete = window.confirm(`Delete routine task "${title}" for this day?`);
    if (!confirmDelete) return;

    setTasks((prev) => prev.filter((t) => t.id !== id));

    try {
      await fetch(`/api/tasks/${id}`, { method: "DELETE" });
      loadDateData(selectedDate, activeUserId);
      loadStats(activeUserId);
    } catch (err) {
      console.error("Delete task failed:", err);
    }
  };

  const handleEditTask = (task: TaskData) => {
    setEditingTask(task);
    setTaskModalOpen(true);
  };

  const handleAddTaskToSlot = (slotId: string) => {
    setEditingTask(null);
    setTargetSlotId(slotId);
    setTaskModalOpen(true);
  };

  const handleSaveTask = async (taskData: {
    id?: string;
    title: string;
    category: string;
    startTime: string | null;
    autoMetric: string | null;
    applyScope: "today" | "future" | "all";
  }) => {
    if (taskData.id) {
      await fetch(`/api/tasks/${taskData.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: taskData.title,
          category: taskData.category,
          startTime: taskData.startTime,
          autoMetric: taskData.autoMetric,
          userId: activeUserId,
        }),
      });
    } else {
      await fetch("/api/tasks", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: taskData.title,
          category: taskData.category,
          targetDate: selectedDate,
          startTime: taskData.startTime,
          autoMetric: taskData.autoMetric,
          applyScope: taskData.applyScope,
          userId: activeUserId,
        }),
      });
    }
    await loadDateData(selectedDate, activeUserId);
    await loadStats(activeUserId);
  };

  const handleUpdateWater = async (deltaOrAmount: number, mode: "increment" | "set" = "increment") => {
    const current = healthLog.waterIntakeMl;
    const nextWater = mode === "set" ? deltaOrAmount : Math.max(0, current + deltaOrAmount);

    setHealthLog((prev) => ({ ...prev, waterIntakeMl: nextWater }));

    try {
      const res = await fetch("/api/water-intake", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          date: selectedDate,
          amountMl: deltaOrAmount,
          mode,
          userId: activeUserId,
        }),
      });
      const data = await res.json();
      if (data.success) {
        if (data.tasks) setTasks(data.tasks);
        loadStats(activeUserId);
      }
    } catch (err) {
      console.error("Water update error:", err);
    }
  };

  const handleSmartwatchSyncSuccess = (data: any) => {
    if (data.healthLog) {
      setHealthLog({
        steps: data.healthLog.steps || 0,
        sleepMinutes: data.healthLog.sleepMinutes || 0,
        waterIntakeMl: data.healthLog.waterIntakeMl || 0,
        gymWorkoutDone: Boolean(data.healthLog.gymWorkoutDone),
      });
    }
    if (data.tasks) {
      setTasks(data.tasks);
    }
    loadStats(activeUserId);
  };

  const dayStatsMap = React.useMemo(() => {
    const map: Record<string, { completionRate: number; total: number; completed: number }> = {};
    heatmapDays.forEach((d) => {
      map[d.date] = {
        completionRate: d.completionRate,
        total: d.totalTasks,
        completed: d.completedTasks,
      };
    });
    return map;
  }, [heatmapDays]);

  const completedCount = tasks.filter((t) => t.isCompleted).length;
  const totalCount = tasks.length;

  if (!splashComplete) {
    return <WebAriseSplash onComplete={() => setSplashComplete(true)} />;
  }

  return (
    <div className="w-full pb-16">
      {/* 1. Header with Controls & Hunter Authentication */}
      <Header
        currentDate={selectedDate}
        onOpenTaskModal={() => {
          setEditingTask(null);
          setTargetSlotId(undefined);
          setTaskModalOpen(true);
        }}
        onOpenNotificationModal={() => setNotificationModalOpen(true)}
        onOpenSmartwatchModal={() => setSmartwatchModalOpen(true)}
        activeStreak={currentStreak}
        hunterUser={hunterUser}
        onOpenProfile={() => setProfileModalOpen(true)}
        onOpenAuth={() => setAuthModalOpen(true)}
      />

      {/* 2. 122-Day Sliding Date Picker */}
      <DateCarousel
        selectedDate={selectedDate}
        onSelectDate={setSelectedDate}
        dayStatsMap={dayStatsMap}
      />

      {isLoading ? (
        <div className="py-20 flex flex-col items-center justify-center text-slate-400">
          <Loader2 className="w-8 h-8 text-cyan-400 animate-spin mb-3" />
          <p className="text-xs font-mono">Synchronizing Winter Arc Protocol Data...</p>
        </div>
      ) : (
        <>
          {/* 3. Daily Execution Score Card */}
          <DailyProgressCard
            totalTasks={totalCount}
            completedTasks={completedCount}
            dateStr={selectedDate}
          />

          {/* 4. Habit Counters (4.5L Water, 10k Steps, Sleep) */}
          <HabitCounters
            waterIntakeMl={healthLog.waterIntakeMl}
            steps={healthLog.steps}
            sleepMinutes={healthLog.sleepMinutes}
            onUpdateWater={handleUpdateWater}
            onOpenSmartwatchModal={() => setSmartwatchModalOpen(true)}
          />

          {/* 5. Routine Checklist (Morning / Daytime / Evening / Night) */}
          <RoutineSection
            tasks={tasks}
            onToggle={handleToggleTask}
            onEdit={handleEditTask}
            onDelete={handleDeleteTask}
            onAddTaskToSlot={handleAddTaskToSlot}
            healthMetrics={healthLog}
          />

          {/* 6. Consistency Heatmap Matrix */}
          <ConsistencyHeatmap
            days={heatmapDays}
            selectedDate={selectedDate}
            onSelectDate={setSelectedDate}
            currentStreak={currentStreak}
            bestStreak={bestStreak}
          />
        </>
      )}

      {/* Modals */}
      <TaskModal
        isOpen={taskModalOpen}
        onClose={() => setTaskModalOpen(false)}
        onSave={handleSaveTask}
        initialTask={editingTask}
        selectedDate={selectedDate}
        defaultSlotId={targetSlotId}
      />

      <NotificationSettingsModal
        isOpen={notificationModalOpen}
        onClose={() => setNotificationModalOpen(false)}
        selectedDate={selectedDate}
      />

      <SmartwatchSyncModal
        isOpen={smartwatchModalOpen}
        onClose={() => setSmartwatchModalOpen(false)}
        selectedDate={selectedDate}
        currentSteps={healthLog.steps}
        currentSleep={healthLog.sleepMinutes}
        currentGym={healthLog.gymWorkoutDone}
        currentWater={healthLog.waterIntakeMl}
        onSyncSuccess={handleSmartwatchSyncSuccess}
      />

      {/* Web Auth Modal */}
      <WebAuthModal
        isOpen={authModalOpen}
        onClose={() => setAuthModalOpen(false)}
        onSuccess={handleAuthSuccess}
      />

      {/* Web Profile Modal */}
      {hunterUser && (
        <WebProfileModal
          isOpen={profileModalOpen}
          onClose={() => setProfileModalOpen(false)}
          user={hunterUser}
          streakDays={currentStreak}
          onSignOut={handleSignOut}
          onUpdateName={handleUpdateName}
        />
      )}
    </div>
  );
}
