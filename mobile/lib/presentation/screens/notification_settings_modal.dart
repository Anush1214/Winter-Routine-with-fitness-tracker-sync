import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../services/notification_service.dart';

class NotificationSettingsModal extends StatefulWidget {
  final Function(String topic) onTestAlert;

  const NotificationSettingsModal({
    super.key,
    required this.onTestAlert,
  });

  @override
  State<NotificationSettingsModal> createState() => _NotificationSettingsModalState();
}

class _NotificationSettingsModalState extends State<NotificationSettingsModal> {
  final TextEditingController _topicController = TextEditingController(text: 'winter-arc-routine');
  bool _isSending = false;
  String? _statusMsg;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const Icon(Icons.notifications_active_outlined, color: SoloColors.neonCyan, size: 20),
                    const SizedBox(width: 8),
                    Text("[ NATIVE ALERTS ENGINE ]", style: SoloTypography.systemTag),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Your app is configured with built-in native Android/iOS alarm notifications that trigger daily even when the app is completely closed or offline.",
              style: SoloTypography.bodyMuted,
            ),
            const SizedBox(height: 16),

            // Schedule Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SoloColors.obsidianVoid,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SoloColors.neonCyan.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BUILT-IN DAILY NATIVE PROTOCOL SCHEDULE", style: SoloTypography.systemTag.copyWith(fontSize: 9)),
                  const SizedBox(height: 8),
                  _buildScheduleRow("07:00 AM IST", "Morning Awakening Protocol"),
                  _buildScheduleRow("06:30 PM IST", "Placement & DSA Shift"),
                  _buildScheduleRow("10:30 PM IST", "Night Check-In & Penalty Warning"),
                ],
              ),
            ),

            if (_statusMsg != null) ...[
              const SizedBox(height: 12),
              Text(_statusMsg!, style: SoloTypography.bodyMuted.copyWith(color: SoloColors.rankEmerald)),
            ],

            const SizedBox(height: 20),
            // Send Test Button
            GestureDetector(
              onTap: () async {
                SoundService().playChime();
                setState(() {
                  _isSending = true;
                  _statusMsg = null;
                });
                
                // 1. Show instant native on-device notification
                await NotificationService().showInstantNotification(
                  title: "⚡ [ SYSTEM NOTIFICATION : QUEST READY ]",
                  body: "Winter Arc Protocol active. Your daily quest objectives are ready for execution!",
                );
                
                // 2. Also dispatch to server if connected
                await widget.onTestAlert(_topicController.text.trim());

                setState(() {
                  _isSending = false;
                  _statusMsg = "Native system alert triggered on your device!";
                });
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
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: SoloColors.obsidianVoid, strokeWidth: 2),
                        )
                      : Text(
                          "TEST NATIVE NOTIFICATION NOW",
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

  Widget _buildScheduleRow(String time, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time, style: SoloTypography.systemTag.copyWith(fontSize: 10, color: SoloColors.electricSky)),
          Text(label, style: SoloTypography.bodyMuted.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
