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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? SoloColors.obsidianCard.withOpacity(0.5)
              : SoloColors.obsidianGlass.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
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
            // Holographic Checkbox
            Container(
              width: 24,
              height: 24,
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
                  ? const Icon(Icons.check, size: 16, color: SoloColors.obsidianVoid)
                  : null,
            ),
            const SizedBox(width: 12),
            // Title & category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: SoloTypography.questTitle.copyWith(
                      fontSize: 14,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? SoloColors.textDim : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        "[${task.category.toUpperCase()}]",
                        style: SoloTypography.systemTag.copyWith(
                          fontSize: 9,
                          color: SoloColors.neonCyan.withOpacity(0.8),
                        ),
                      ),
                      if (task.startTime != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: SoloColors.obsidianVoid,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SoloColors.neonCyan.withOpacity(0.3)),
                          ),
                          child: Text(
                            task.startTime!,
                            style: SoloTypography.systemTag.copyWith(fontSize: 9, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 16, color: SoloColors.textDim),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
