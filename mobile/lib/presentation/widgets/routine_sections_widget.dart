import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../models/task_model.dart';
import '../../models/health_log_model.dart';
import 'holographic_frame.dart';
import 'quest_objective_tile.dart';

class RoutineSectionsWidget extends StatelessWidget {
  final List<TaskModel> tasks;
  final HealthLogModel healthLog;
  final Function(String id, bool currentStatus) onToggleTask;
  final Function(TaskModel task) onEditTask;
  final Function(String id) onDeleteTask;
  final Function(String defaultCategory) onAddTaskForCategory;

  const RoutineSectionsWidget({
    super.key,
    required this.tasks,
    required this.healthLog,
    required this.onToggleTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onAddTaskForCategory,
  });

  @override
  Widget build(BuildContext context) {
    // 4 Distinct Solo Leveling Quest Categories
    final morningTasks = tasks.where((t) {
      if (t.startTime != null) {
        final hour = int.tryParse(t.startTime!.split(':')[0]) ?? 0;
        return hour >= 5 && hour < 9;
      }
      return t.category == 'routine' && (t.title.toLowerCase().contains('wake') || t.title.toLowerCase().contains('gym'));
    }).toList();

    final daytimeTasks = tasks.where((t) {
      if (t.startTime != null) {
        final hour = int.tryParse(t.startTime!.split(':')[0]) ?? 0;
        return hour >= 9 && hour < 18;
      }
      return t.category == 'health' || t.category == 'fitness' || t.category == 'study';
    }).toList();

    final eveningTasks = tasks.where((t) {
      if (t.startTime != null) {
        final hour = int.tryParse(t.startTime!.split(':')[0]) ?? 0;
        return hour >= 18 && hour < 21;
      }
      return t.category == 'career' || t.title.toLowerCase().contains('dsa') || t.title.toLowerCase().contains('fresh');
    }).toList();

    final nightTasks = tasks.where((t) {
      if (t.startTime != null) {
        final hour = int.tryParse(t.startTime!.split(':')[0]) ?? 0;
        return hour >= 21 || hour < 5;
      }
      return t.title.toLowerCase().contains('night') || t.title.toLowerCase().contains('sleep');
    }).toList();

    // Fallback for custom tasks
    final unclassified = tasks.where((t) =>
        !morningTasks.contains(t) &&
        !daytimeTasks.contains(t) &&
        !eveningTasks.contains(t) &&
        !nightTasks.contains(t)).toList();

    return Column(
      children: [
        _buildSectionCard(
          title: "QUEST PART I : MORNING AWAKENING",
          timeframe: "06:00 — 08:30",
          icon: Icons.wb_sunny_outlined,
          color: SoloColors.electricSky,
          tasks: morningTasks,
          categoryKey: 'routine',
        ),
        const SizedBox(height: 14),

        _buildSectionCard(
          title: "QUEST PART II : DAYTIME ATTRIBUTES & DISCIPLINE",
          timeframe: "09:00 — 18:00",
          icon: Icons.shield_outlined,
          color: SoloColors.neonCyan,
          tasks: daytimeTasks,
          categoryKey: 'fitness',
        ),
        const SizedBox(height: 14),

        _buildSectionCard(
          title: "QUEST PART III : EVENING PLACEMENT & SKILL DUNGEON",
          timeframe: "18:30 — 21:30",
          icon: Icons.code,
          color: SoloColors.monarchGold,
          tasks: eveningTasks,
          categoryKey: 'career',
        ),
        const SizedBox(height: 14),

        _buildSectionCard(
          title: "QUEST PART IV : NIGHT PROTOCOL & RECOVERY",
          timeframe: "21:30 — 23:00",
          icon: Icons.nightlight_round,
          color: SoloColors.manaViolet,
          tasks: nightTasks,
          categoryKey: 'routine',
        ),

        if (unclassified.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildSectionCard(
            title: "ADDITIONAL HUNTER OBJECTIVES",
            timeframe: "ALL-DAY",
            icon: Icons.star_border,
            color: SoloColors.flameOrange,
            tasks: unclassified,
            categoryKey: 'custom',
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String timeframe,
    required IconData icon,
    required Color color,
    required List<TaskModel> tasks,
    required String categoryKey,
  }) {
    final completed = tasks.where((t) => t.isCompleted).length;

    return HolographicFrame(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: SoloTypography.systemTag.copyWith(color: color, fontSize: 10),
                      ),
                      Text(
                        timeframe,
                        style: SoloTypography.bodyMuted.copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: SoloColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      "$completed / ${tasks.length} CLEARED",
                      style: SoloTypography.systemTag.copyWith(color: color, fontSize: 8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      SoundService().playClick();
                      onAddTaskForCategory(categoryKey);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: SoloColors.obsidianVoid,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: SoloColors.neonCyan.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.add, color: SoloColors.neonCyan, size: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "No objectives registered in this phase.",
                style: SoloTypography.bodyMuted.copyWith(fontSize: 11),
              ),
            )
          else
            ...tasks.map(
              (task) => QuestObjectiveTile(
                task: task,
                onToggle: () => onToggleTask(task.id, task.isCompleted),
                onEdit: () => onEditTask(task),
                onDelete: () => onDeleteTask(task.id),
              ),
            ),
        ],
      ),
    );
  }
}
