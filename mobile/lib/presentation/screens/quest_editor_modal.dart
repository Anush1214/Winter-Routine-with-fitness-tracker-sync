import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../models/task_model.dart';

class QuestEditorModal extends StatefulWidget {
  final TaskModel? initialTask;
  final String selectedDate;
  final String? defaultCategory;
  final Function(TaskModel task, String scope) onSave;

  const QuestEditorModal({
    super.key,
    this.initialTask,
    required this.selectedDate,
    this.defaultCategory,
    required this.onSave,
  });

  @override
  State<QuestEditorModal> createState() => _QuestEditorModalState();
}

class _QuestEditorModalState extends State<QuestEditorModal> {
  late TextEditingController _titleController;
  late TextEditingController _timeController;
  String _category = 'routine';
  String? _autoMetric;
  String _scope = 'all_forward'; // 'today', 'all_forward', 'all_122'

  final List<Map<String, String>> _categories = [
    {'key': 'routine', 'label': 'ROUTINE'},
    {'key': 'fitness', 'label': 'FITNESS'},
    {'key': 'career', 'label': 'CAREER & DSA'},
    {'key': 'health', 'label': 'HEALTH & VITALITY'},
    {'key': 'study', 'label': 'SELF STUDY'},
  ];

  final List<Map<String, String?>> _metrics = [
    {'key': null, 'label': 'None (Manual Objective Clear)'},
    {'key': 'steps_10k', 'label': 'Step Count (STR: 10,000+ Steps)'},
    {'key': 'sleep_7h', 'label': 'Sleep Restoration (RECOVERY: 7h+ Sleep)'},
    {'key': 'gym_workout', 'label': 'Gym Workout (STR: Session Cleared)'},
    {'key': 'water_4l', 'label': 'Hydration Chamber (VIT: 4.0L+ Water)'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _timeController = TextEditingController(text: widget.initialTask?.startTime ?? '');
    _category = widget.initialTask?.category ?? widget.defaultCategory ?? 'routine';
    _autoMetric = widget.initialTask?.autoMetric;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: SoloColors.neonCyan, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? "[ MODIFY QUEST OBJECTIVE ]" : "[ REGISTER NEW QUEST ]",
                      style: SoloTypography.systemTag,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title Field
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: "QUEST OBJECTIVE TITLE",
                labelStyle: SoloTypography.systemTag.copyWith(fontSize: 10),
                hintText: "e.g., LeetCode 2 Hard Problems",
                hintStyle: SoloTypography.bodyMuted.copyWith(fontSize: 12),
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
            const SizedBox(height: 14),

            // Time Field
            TextField(
              controller: _timeController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: "SCHEDULED TIME (HH:MM 24H)",
                labelStyle: SoloTypography.systemTag.copyWith(fontSize: 10),
                hintText: "e.g., 07:00 or 19:00",
                hintStyle: SoloTypography.bodyMuted.copyWith(fontSize: 12),
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

            // Category Chips
            Text("CATEGORY / ATTRIBUTE", style: SoloTypography.systemTag.copyWith(fontSize: 10)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _categories.map((cat) {
                final isSelected = _category == cat['key'];
                return ChoiceChip(
                  label: Text("[${cat['label']}]", style: SoloTypography.systemTag.copyWith(fontSize: 9)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF082F49),
                  backgroundColor: SoloColors.obsidianVoid,
                  side: BorderSide(
                    color: isSelected ? SoloColors.neonCyan : SoloColors.textDim.withOpacity(0.4),
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _category = cat['key']!);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Smartwatch Auto-Binding Dropdown
            Text("SMARTWATCH AUTO-SYNC METRIC", style: SoloTypography.systemTag.copyWith(fontSize: 10)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: SoloColors.obsidianVoid,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SoloColors.neonCyan.withOpacity(0.4)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _autoMetric,
                  isExpanded: true,
                  dropdownColor: SoloColors.obsidianCard,
                  items: _metrics.map((m) {
                    return DropdownMenuItem<String?>(
                      value: m['key'],
                      child: Text(
                        m['label']!,
                        style: SoloTypography.bodyMuted.copyWith(color: Colors.white, fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _autoMetric = val),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scope Selector
            Text("TIMELINE APPLICATION SCOPE", style: SoloTypography.systemTag.copyWith(fontSize: 10)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildScopeOption('today', 'Today Only'),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildScopeOption('all_forward', 'Until Dec 31'),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildScopeOption('all_122', 'All 122 Days'),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Save Button
            GestureDetector(
              onTap: () {
                if (_titleController.text.trim().isEmpty) return;
                SoundService().playChime();

                final task = TaskModel(
                  id: widget.initialTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text.trim(),
                  category: _category,
                  targetDate: widget.selectedDate,
                  startTime: _timeController.text.trim().isNotEmpty ? _timeController.text.trim() : null,
                  isCompleted: widget.initialTask?.isCompleted ?? false,
                  autoMetric: _autoMetric,
                );

                widget.onSave(task, _scope);
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

  Widget _buildScopeOption(String scopeKey, String label) {
    final isSelected = _scope == scopeKey;
    return GestureDetector(
      onTap: () => setState(() => _scope = scopeKey),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF082F49) : SoloColors.obsidianVoid,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? SoloColors.neonCyan : SoloColors.textDim.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: SoloTypography.systemTag.copyWith(
              fontSize: 9,
              color: isSelected ? SoloColors.neonCyan : SoloColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
