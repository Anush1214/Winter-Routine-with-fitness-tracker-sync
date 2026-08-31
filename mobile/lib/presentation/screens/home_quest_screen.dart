import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/utils/timeline_utils.dart';
import '../../models/task_model.dart';
import '../../services/supabase_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/date_carousel_widget.dart';
import '../widgets/holographic_frame.dart';
import '../widgets/mana_circular_ring.dart';
import '../widgets/penalty_warning_banner.dart';
import '../widgets/habit_counters_widget.dart';
import '../widgets/routine_sections_widget.dart';
import '../widgets/consistency_heatmap_widget.dart';
import 'quest_editor_modal.dart';
import 'notification_settings_modal.dart';
import 'smartwatch_sync_sheet.dart';

class HomeQuestScreen extends StatefulWidget {
  const HomeQuestScreen({super.key});

  @override
  State<HomeQuestScreen> createState() => _HomeQuestScreenState();
}

class _HomeQuestScreenState extends State<HomeQuestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupabaseService>().loadDateData(
            TimelineUtils.formatDateKey(DateTime.now()),
          );
    });
  }

  void _openTaskEditor({TaskModel? task, String? defaultCategory}) {
    final service = context.read<SupabaseService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuestEditorModal(
        initialTask: task,
        selectedDate: service.selectedDate,
        defaultCategory: defaultCategory,
        onSave: (savedTask, scope) {
          service.saveTask(savedTask, scope);
        },
      ),
    );
  }

  void _openNotificationSettings() {
    final service = context.read<SupabaseService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NotificationSettingsModal(
        onTestAlert: (topic) => service.sendTestAlert(topic),
      ),
    );
  }

  void _openSmartwatchSync() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SmartwatchSyncSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();
    final selectedDate = DateTime.tryParse(service.selectedDate) ?? DateTime.now();
    final dayNum = TimelineUtils.getDayNumber(selectedDate);
    final daysRemaining = TimelineUtils.getDaysRemaining(selectedDate);

    final totalTasks = service.tasks.length;
    final completedTasks = service.tasks.where((t) => t.isCompleted).length;
    final percentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return Scaffold(
      backgroundColor: SoloColors.obsidianVoid,
      body: SafeArea(
        child: service.isLoading && service.tasks.isEmpty
            ? const Center(child: CircularProgressIndicator(color: SoloColors.neonCyan))
            : RefreshIndicator(
                color: SoloColors.neonCyan,
                backgroundColor: SoloColors.obsidianVoid,
                onRefresh: () => service.loadDateData(service.selectedDate),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header with Identity & Actions
                      HeaderWidget(
                        currentDate: service.selectedDate,
                        activeStreak: service.currentStreak,
                        onOpenTaskModal: () => _openTaskEditor(),
                        onOpenNotificationModal: _openNotificationSettings,
                        onOpenSmartwatchModal: _openSmartwatchSync,
                      ),
                      const SizedBox(height: 14),

                      // 2. 122-Day Timeline Carousel
                      DateCarouselWidget(
                        selectedDate: service.selectedDate,
                        onSelectDate: (d) => service.selectDate(d),
                        dayStatsMap: service.heatmapRates,
                      ),
                      const SizedBox(height: 16),

                      // 3. Main Solo Leveling Quest Progress Card
                      HolographicFrame(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: SoloColors.neonCyan,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "[ SYSTEM NOTIFICATION : QUEST WINDOW ]",
                                      style: SoloTypography.systemTag,
                                    ),
                                  ],
                                ),
                                Text(
                                  TimelineUtils.formatDisplayDate(selectedDate),
                                  style: SoloTypography.bodyMuted.copyWith(
                                    color: SoloColors.neonCyan,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                ManaCircularRing(
                                  percentage: percentage,
                                  size: 110,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        percentage >= 100
                                            ? "DAILY QUEST COMPLETED"
                                            : "DAILY QUEST: PREPARATION TO BECOME STRONG",
                                        style: SoloTypography.questTitle.copyWith(
                                          fontSize: 14,
                                          color: percentage >= 100
                                              ? SoloColors.rankEmerald
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$completedTasks / $totalTasks OBJECTIVES CLEARED",
                                        style: SoloTypography.systemTag.copyWith(
                                          fontSize: 10,
                                          color: SoloColors.electricSky,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$daysRemaining days remaining in 2026 Winter Arc timeline.",
                                        style: SoloTypography.bodyMuted.copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (percentage < 100) ...[
                              const SizedBox(height: 14),
                              const PenaltyWarningBanner(),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Habit Counters (Vitality, Strength, Perception)
                      HabitCountersWidget(
                        waterIntakeMl: service.healthLog.waterIntakeMl,
                        steps: service.healthLog.steps,
                        sleepMinutes: service.healthLog.sleepMinutes,
                        onUpdateWater: (delta, mode) => service.updateWater(delta, mode),
                        onOpenSmartwatchModal: _openSmartwatchSync,
                      ),
                      const SizedBox(height: 16),

                      // 5. 4 Solo Leveling Routine Quest Sections
                      RoutineSectionsWidget(
                        tasks: service.tasks,
                        healthLog: service.healthLog,
                        onToggleTask: (id, status) => service.toggleTask(id, status),
                        onEditTask: (task) => _openTaskEditor(task: task),
                        onDeleteTask: (id) => service.deleteTask(id),
                        onAddTaskForCategory: (cat) => _openTaskEditor(defaultCategory: cat),
                      ),
                      const SizedBox(height: 16),

                      // 6. 122-Day Hunter Expedition Matrix Heatmap
                      ConsistencyHeatmapWidget(
                        heatmapRates: service.heatmapRates,
                        selectedDate: service.selectedDate,
                        onSelectDate: (d) => service.selectDate(d),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
