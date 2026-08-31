import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../models/task_model.dart';
import '../../models/health_log_model.dart';
import '../../services/auth_service.dart';
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
    final isFemale = context.watch<AuthService>().isFemaleTheme;

    // 4 Distinct Solo Leveling Quest Categories
    final morningTasks = <TaskModel>[];
    final daytimeTasks = <TaskModel>[];
    final eveningTasks = <TaskModel>[];
    final nightTasks = <TaskModel>[];
    final unclassified = <TaskModel>[];

    for (final t in tasks) {
      final titleLower = t.title.toLowerCase();
      final startTime = t.startTime;
      final hour = startTime != null && startTime.isNotEmpty
          ? int.tryParse(startTime.split(':')[0])
          : null;

      // Phase 1: Morning Awakening (06:00 - 08:30 & Daily Health/Fitness Fundamentals)
      if ((hour != null && hour >= 5 && hour < 9) ||
          titleLower.contains('wake') ||
          titleLower.contains('gym') ||
          t.autoMetric == 'gym_workout' ||
          t.autoMetric == 'water_4l' ||
          t.autoMetric == 'sleep_7h' ||
          t.autoMetric == 'steps_10k' ||
          titleLower.contains('hydration') ||
          titleLower.contains('10,000 steps') ||
          titleLower.contains('sleep recovery')) {
        morningTasks.add(t);
      }
      // Phase 2: Daytime Attributes & Discipline (09:00 - 18:00)
      else if ((hour != null && hour >= 9 && hour < 18) ||
          titleLower.contains('office') ||
          titleLower.contains('self-study') ||
          titleLower.contains('work shift') ||
          titleLower.contains('revision') ||
          t.category == 'fitness') {
        daytimeTasks.add(t);
      }
      // Phase 3: Evening Placement & Skill Dungeon (18:30 - 21:30)
      else if ((hour != null && hour >= 18 && hour < 21) ||
          titleLower.contains('dsa') ||
          titleLower.contains('placement') ||
          titleLower.contains('leetcode') ||
          titleLower.contains('project') ||
          titleLower.contains('fresh up') ||
          titleLower.contains('japanese') ||
          t.category == 'career' ||
          t.category == 'study') {
        eveningTasks.add(t);
      }
      // Phase 4: Night Protocol & Sleep (21:30 - 23:00+)
      else if ((hour != null && (hour >= 21 || hour < 5)) ||
          titleLower.contains('night') ||
          titleLower.contains('sleep by') ||
          titleLower.contains('duolingo')) {
        nightTasks.add(t);
      } else {
        unclassified.add(t);
      }
    }

    return Column(
      children: [
        _buildSectionCard(
          title: "QUEST PART I : MORNING AWAKENING",
          timeframe: "06:00 — 08:30",
          icon: Icons.wb_sunny_outlined,
          color: isFemale ? const Color(0xFFF59E0B) : SoloColors.electricSky,
          tasks: morningTasks,
          categoryKey: 'routine',
        ),
        const SizedBox(height: 14),

        _buildSectionCard(
          title: "QUEST PART II : DAYTIME ATTRIBUTES & DISCIPLINE",
          timeframe: "09:00 — 18:00",
          icon: Icons.shield_outlined,
          color: isFemale ? const Color(0xFFFDE047) : SoloColors.neonCyan,
          tasks: daytimeTasks,
          categoryKey: 'fitness',
        ),
        const SizedBox(height: 14),

        _buildSectionCard(
          title: "QUEST PART III : EVENING PLACEMENT & SKILL DUNGEON",
          timeframe: "18:30 — 21:30",
          icon: Icons.code,
          color: isFemale ? const Color(0xFFD97706) : const Color(0xFFC084FC),
          tasks: eveningTasks,
          categoryKey: 'career',
        ),
        const SizedBox(height: 14),

        _buildSectionCard(
          title: "QUEST PART IV : NIGHT PROTOCOL & RECOVERY",
          timeframe: "21:30 — 23:00",
          icon: Icons.nightlight_round,
          color: isFemale ? const Color(0xFFF59E0B) : const Color(0xFFA855F7),
          tasks: nightTasks,
          categoryKey: 'routine',
        ),

        if (unclassified.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildSectionCard(
            title: "ADDITIONAL HUNTER OBJECTIVES",
            timeframe: "ALL-DAY",
            icon: Icons.star_border,
            color: isFemale ? const Color(0xFFFDE047) : const Color(0xFF38BDF8),
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
      borderColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: SoloTypography.systemTag.copyWith(color: color, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            timeframe,
                            style: SoloTypography.bodyMuted.copyWith(fontSize: 9),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.add, color: color, size: 14),
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
