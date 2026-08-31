import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
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
import '../widgets/sung_jinwoo_assistant_dialog.dart';
import '../../services/health_service.dart';

class HomeQuestScreen extends StatefulWidget {
  final bool hideFabForNavbar;

  const HomeQuestScreen({super.key, this.hideFabForNavbar = false});

  @override
  State<HomeQuestScreen> createState() => _HomeQuestScreenState();
}

class _HomeQuestScreenState extends State<HomeQuestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final supabase = context.read<SupabaseService>();
      await supabase.loadDateData(
        TimelineUtils.formatDateKey(DateTime.now()),
      );

      // Auto-ingest live telemetry from Nothing X / Health Connect
      try {
        final metrics = await HealthService().fetchNothingXDailyMetrics(DateTime.now());
        if ((metrics['steps'] ?? 0) > 0 || (metrics['sleepMinutes'] ?? 0) > 0 || (metrics['waterIntakeMl'] ?? 0) > 0) {
          await supabase.syncHealth(
            steps: (metrics['steps'] ?? 0) > 0 ? metrics['steps'] : supabase.healthLog.steps,
            sleepMinutes: (metrics['sleepMinutes'] ?? 0) > 0 ? metrics['sleepMinutes'] : supabase.healthLog.sleepMinutes,
            gymWorkoutDone: metrics['gymWorkoutDone'] ?? supabase.healthLog.gymWorkoutDone,
            waterIntakeMl: (metrics['waterIntakeMl'] ?? 0) > 0 ? metrics['waterIntakeMl'] : supabase.healthLog.waterIntakeMl,
          );
        }
      } catch (_) {}
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
    final auth = context.watch<AuthService>();
    final isFemale = auth.isFemaleTheme;
    final themeColor = isFemale ? const Color(0xFFFBBF24) : SoloColors.neonCyan;
    final selectedDate = DateTime.tryParse(service.selectedDate) ?? DateTime.now();
    final dayNum = TimelineUtils.getDayNumber(selectedDate);
    final daysRemaining = TimelineUtils.getDaysRemaining(selectedDate);

    final totalTasks = service.tasks.length;
    final completedTasks = service.tasks.where((t) => t.isCompleted).length;
    final percentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return Scaffold(
      backgroundColor: isFemale ? const Color(0xFF140B02) : SoloColors.obsidianVoid,
      body: SafeArea(
        child: service.isLoading && service.tasks.isEmpty
            ? Center(child: CircularProgressIndicator(color: themeColor))
            : RefreshIndicator(
                color: themeColor,
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
                        borderColor: themeColor,
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
                                      decoration: BoxDecoration(
                                        color: themeColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "[ SYSTEM NOTIFICATION : QUEST WINDOW ]",
                                      style: SoloTypography.systemTag.copyWith(color: themeColor),
                                    ),
                                  ],
                                ),
                                Text(
                                  TimelineUtils.formatDisplayDate(selectedDate),
                                  style: SoloTypography.bodyMuted.copyWith(
                                    color: themeColor,
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
                                          color: isFemale ? const Color(0xFFFDE047) : SoloColors.electricSky,
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
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: widget.hideFabForNavbar
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                SungJinwooAssistantDialog.show(
                  context,
                  tasks: service.tasks,
                  onTriggerAction: () {
                    final pending = service.tasks.where((t) => !t.isCompleted).toList();
                    if (pending.isNotEmpty) {
                      service.toggleTask(pending.first.id, false);
                    }
                  },
                );
              },
              backgroundColor: SoloColors.obsidianVoid,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: SoloColors.neonCyan, width: 1.5),
              ),
              icon: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF042F2E),
                ),
                child: const Icon(Icons.record_voice_over, color: SoloColors.neonCyan, size: 16),
              ),
              label: Text(
                "JIN-WOO",
                style: SoloTypography.systemTag.copyWith(
                  fontSize: 10,
                  color: SoloColors.neonCyan,
                  letterSpacing: 1.5,
                ),
              ),
            ),
    );
  }
}
