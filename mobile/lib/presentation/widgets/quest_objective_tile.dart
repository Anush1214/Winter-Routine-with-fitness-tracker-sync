import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../models/task_model.dart';

class QuestObjectiveTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QuestObjectiveTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color categoryColor = SoloColors.neonCyan;
    if (task.category == 'fitness') categoryColor = SoloColors.electricSky;
    if (task.category == 'career') categoryColor = SoloColors.monarchGold;
    if (task.category == 'health') categoryColor = SoloColors.rankEmerald;
    if (task.category == 'study') categoryColor = SoloColors.manaViolet;

    return GestureDetector(
      onTap: () {
        if (!task.isCompleted) {
          SoundService().playChime();
        } else {
          SoundService().playClick();
        }
        onToggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? SoloColors.obsidianCard.withOpacity(0.4)
              : SoloColors.obsidianGlass.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: task.isCompleted
                ? SoloColors.neonCyan.withOpacity(0.2)
                : SoloColors.neonCyan.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: task.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: SoloColors.neonCyan.withOpacity(0.08),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Row(
          children: [
            // Holographic Checkbox with glowing aura
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: task.isCompleted ? SoloColors.neonCyan : SoloColors.obsidianVoid,
                border: Border.all(
                  color: task.isCompleted ? Colors.white : SoloColors.neonCyan.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: task.isCompleted
                    ? [
                        BoxShadow(
                          color: SoloColors.neonCyan.withOpacity(0.8),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 14, color: SoloColors.obsidianVoid)
                  : null,
            ),
            const SizedBox(width: 10),

            // Title & category chips
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: SoloTypography.questTitle.copyWith(
                      fontSize: 13,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? SoloColors.textDim : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: SoloColors.obsidianVoid,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: categoryColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          "[${task.category.toUpperCase()}]",
                          style: SoloTypography.systemTag.copyWith(
                            fontSize: 8,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      if (task.startTime != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: SoloColors.obsidianVoid,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SoloColors.neonCyan.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, size: 9, color: SoloColors.neonCyan),
                              const SizedBox(width: 3),
                              Text(
                                task.startTime!,
                                style: SoloTypography.systemTag.copyWith(fontSize: 8, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      if (task.autoMetric != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B4B),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SoloColors.manaViolet.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.watch_outlined, size: 9, color: SoloColors.manaViolet),
                              const SizedBox(width: 3),
                              Text(
                                "AUTO-SYNC",
                                style: SoloTypography.systemTag.copyWith(fontSize: 8, color: SoloColors.manaViolet),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit & Delete Action icons
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 14, color: SoloColors.textDim),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 14, color: SoloColors.penaltyCrimson),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
