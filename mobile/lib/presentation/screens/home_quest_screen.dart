import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/utils/timeline_utils.dart';
import '../../services/supabase_service.dart';
import '../widgets/holographic_frame.dart';
import '../widgets/mana_circular_ring.dart';
import '../widgets/hydration_wave_card.dart';
import '../widgets/quest_objective_tile.dart';
import '../widgets/hunter_rank_badge.dart';
import '../widgets/penalty_warning_banner.dart';
import '../widgets/expedition_matrix.dart';
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
      appBar: AppBar(
        backgroundColor: SoloColors.obsidianVoid,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: SoloColors.neonCyan, size: 20),
            const SizedBox(width: 8),
            Text(
              "WINTER ARC PROTOCOL",
              style: SoloTypography.systemTitle.copyWith(fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.watch_outlined, color: SoloColors.manaViolet),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const SmartwatchSyncSheet(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: SoloColors.neonCyan),
            onPressed: () => service.loadDateData(service.selectedDate),
          ),
        ],
      ),
      body: service.isLoading
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
                    // Top Player Info Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "[ SYSTEM LEVEL $dayNum / 122 ]",
                              style: SoloTypography.systemTag,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              TimelineUtils.formatDisplayDate(selectedDate),
                              style: SoloTypography.questTitle.copyWith(fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            HunterRankBadge(streakDays: service.currentStreak),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF431407),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: SoloColors.flameOrange.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department, color: SoloColors.flameOrange, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    "${service.currentStreak}D",
                                    style: SoloTypography.systemTag.copyWith(color: SoloColors.flameOrange),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Daily Quest Main Holographic Window
                    HolographicFrame(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "[ DAILY QUEST : BECOME STRONG ]",
                                style: SoloTypography.systemTag,
                              ),
                              Text(
                                "$completedTasks / $totalTasks OBJECTIVES",
                                style: SoloTypography.bodyMuted.copyWith(color: SoloColors.neonCyan),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                                          ? "ALL DAILY QUESTS CLEARED"
                                          : "EXECUTE YOUR PROTOCOL",
                                      style: SoloTypography.questTitle.copyWith(
                                        color: percentage >= 100
                                            ? SoloColors.rankEmerald
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$daysRemaining days remaining in 2026 Winter Arc timeline.",
                                      style: SoloTypography.bodyMuted.copyWith(fontSize: 11),
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

                    // Stats: Hydration Chamber
                    HydrationWaveCard(
                      waterIntakeMl: service.healthLog.waterIntakeMl,
                      onUpdateWater: (delta) => service.updateWater(delta),
                    ),
                    const SizedBox(height: 16),

                    // Quest Objectives Checklist
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "[ ACTIVE QUEST OBJECTIVES ]",
                          style: SoloTypography.systemTag,
                        ),
                        Text(
                          "$completedTasks / $totalTasks CLEARED",
                          style: SoloTypography.bodyMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ...service.tasks.map(
                      (task) => QuestObjectiveTile(
                        task: task,
                        onToggle: () => service.toggleTask(task.id, task.isCompleted),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Expedition Matrix
                    ExpeditionMatrix(
                      heatmapRates: service.heatmapRates,
                      selectedDate: service.selectedDate,
                      onSelectDate: (d) => service.selectDate(d),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
