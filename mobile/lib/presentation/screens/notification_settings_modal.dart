import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../services/notification_service.dart';
import '../../services/supabase_service.dart';
import '../../models/task_model.dart';

class NotificationSettingsModal extends StatefulWidget {
  final Function(String topic)? onTestAlert;

  const NotificationSettingsModal({
    super.key,
    this.onTestAlert,
  });

  @override
  State<NotificationSettingsModal> createState() => _NotificationSettingsModalState();
}

class _NotificationSettingsModalState extends State<NotificationSettingsModal> {
  bool _isSending = false;
  String? _statusMsg;

  @override
  Widget build(BuildContext context) {
    final supabase = context.watch<SupabaseService>();
    final allTasks = supabase.tasks;
    final scheduledTasks = allTasks.where((t) => t.startTime != null && t.startTime!.isNotEmpty).toList();

    // Sort by startTime
    scheduledTasks.sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0826).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: const Color(0xFFA855F7).withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF581C87).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA855F7)),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFC084FC), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LIVE SYSTEM ALERTS ENGINE",
                        style: SoloTypography.systemTitle.copyWith(fontSize: 16),
                      ),
                      Text(
                        "${scheduledTasks.length} Active Real-Time Protocol Alarms",
                        style: SoloTypography.bodyMuted.copyWith(fontSize: 10, color: const Color(0xFFC084FC)),
                      ),
                    ],
                  ),
                ],
              ),
              if (Navigator.canPop(context))
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Every scheduled routine objective is synchronized with your phone's native alarm clock in real time. Alarms trigger automatically even when the app is completely closed or offline.",
            style: SoloTypography.bodyMuted.copyWith(fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Real-time Dynamic Schedule List
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF090414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SYNCHRONIZED DAILY PROTOCOLS",
                      style: SoloTypography.systemTag.copyWith(fontSize: 9, color: const Color(0xFFC084FC)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF34D399)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF34D399),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "REAL-TIME ACTIVE",
                            style: SoloTypography.systemTag.copyWith(fontSize: 8, color: const Color(0xFF34D399)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (scheduledTasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        "No routine alarms detected. Add tasks with scheduled times to register live alarms.",
                        style: SoloTypography.bodyMuted.copyWith(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...scheduledTasks.map((task) => _buildLiveAlarmTile(task)),
              ],
            ),
          ),

          if (_statusMsg != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF34D399)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF34D399), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMsg!,
                      style: SoloTypography.bodyMuted.copyWith(fontSize: 11, color: const Color(0xFF34D399)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Send Test Instant Notification Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _isSending
                  ? null
                  : () async {
                      SoundService().playChime();
                      setState(() {
                        _isSending = true;
                        _statusMsg = null;
                      });

                      await NotificationService().showInstantNotification(
                        title: "⚡ [ SYSTEM PROTOCOL : REAL-TIME TEST ]",
                        body: "Awakening alert engine verified! All ${scheduledTasks.length} daily routine alarms are active.",
                      );

                      if (widget.onTestAlert != null) {
                        await widget.onTestAlert!('winter-arc-routine');
                      }

                      if (mounted) {
                        setState(() {
                          _isSending = false;
                          _statusMsg = "System alarm test transmitted successfully!";
                        });
                      }
                    },
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.flash_on, color: Colors.white, size: 18),
              label: Text(
                _isSending ? "TRANSMITTING ALARM..." : "TEST NATIVE PHONE NOTIFICATION NOW",
                style: SoloTypography.systemTag.copyWith(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 6,
                shadowColor: const Color(0xFFA855F7).withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAlarmTile(TaskModel task) {
    final isDone = task.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF130926),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone
              ? const Color(0xFF34D399).withValues(alpha: 0.4)
              : const Color(0xFFA855F7).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF581C87).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.4)),
            ),
            child: Text(
              task.startTime ?? '--:--',
              style: SoloTypography.systemTag.copyWith(
                fontSize: 10,
                color: const Color(0xFFE9D5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDone ? Colors.white60 : Colors.white,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isDone ? "Cleared today" : "Armed for execution",
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isDone ? const Color(0xFF34D399) : const Color(0xFFA89BB9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isDone ? Icons.check_circle : Icons.alarm_on_rounded,
            color: isDone ? const Color(0xFF34D399) : const Color(0xFFC084FC),
            size: 18,
          ),
        ],
      ),
    );
  }
}
