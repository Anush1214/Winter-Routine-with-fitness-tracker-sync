import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../models/task_model.dart';

class QuestEditorModal extends StatefulWidget {
  final TaskModel? initialTask;
  final String selectedDate;
  final Function(TaskModel task) onSave;

  const QuestEditorModal({
    super.key,
    this.initialTask,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<QuestEditorModal> createState() => _QuestEditorModalState();
}

class _QuestEditorModalState extends State<QuestEditorModal> {
  late TextEditingController _titleController;
  String _category = 'routine';
  String? _startTime;
  String? _autoMetric;

  final List<String> _categories = [
    'routine',
    'fitness',
    'career',
    'health',
    'study',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _category = widget.initialTask?.category ?? 'routine';
    _startTime = widget.initialTask?.startTime;
    _autoMetric = widget.initialTask?.autoMetric;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTask != null;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: SoloColors.obsidianCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: SoloColors.neonCyan, width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? "[ MODIFY QUEST OBJECTIVE ]" : "[ REGISTER NEW QUEST ]",
                  style: SoloTypography.systemTag,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: "QUEST OBJECTIVE TITLE",
                labelStyle: SoloTypography.systemTag.copyWith(fontSize: 10),
                filled: true,
                fillColor: SoloColors.obsidianVoid,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: SoloColors.neonCyan.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: SoloColors.neonCyan),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("CATEGORY / ATTRIBUTE", style: SoloTypography.systemTag.copyWith(fontSize: 10)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text("[${cat.toUpperCase()}]", style: SoloTypography.systemTag.copyWith(fontSize: 10)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF082F49),
                  backgroundColor: SoloColors.obsidianVoid,
                  side: BorderSide(
                    color: isSelected ? SoloColors.neonCyan : SoloColors.textDim.withOpacity(0.4),
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _category = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (_titleController.text.trim().isEmpty) return;

                final task = TaskModel(
                  id: widget.initialTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text.trim(),
                  category: _category,
                  targetDate: widget.selectedDate,
                  startTime: _startTime,
                  isCompleted: widget.initialTask?.isCompleted ?? false,
                  autoMetric: _autoMetric,
                );

                widget.onSave(task);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: SoloColors.buttonCyanGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: SoloColors.neonCyan.withOpacity(0.4),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isEditing ? "UPDATE QUEST OBJECTIVE" : "REGISTER QUEST OBJECTIVE",
                    style: SoloTypography.systemTag.copyWith(
                      color: SoloColors.obsidianVoid,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
