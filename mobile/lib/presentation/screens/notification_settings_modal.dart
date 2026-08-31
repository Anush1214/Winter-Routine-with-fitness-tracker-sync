import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';

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
                    Text("[ ALERTS ENGINE : NTFY HUB ]", style: SoloTypography.systemTag),
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
              "Receive instant Solo Leveling system push notifications on your phone, watch, and browser.",
              style: SoloTypography.bodyMuted,
            ),
            const SizedBox(height: 16),

            // Topic field
            TextField(
              controller: _topicController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: "NTFY TOPIC IDENTIFIER",
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
                  Text("AUTOMATED DAILY PROTOCOL SCHEDULE", style: SoloTypography.systemTag.copyWith(fontSize: 9)),
                  const SizedBox(height: 8),
                  _buildScheduleRow("07:00 AM IST", "Morning Awakening Alert"),
                  _buildScheduleRow("06:30 PM IST", "Placement & DSA Shift"),
                  _buildScheduleRow("10:30 PM IST", "Night Check-In & Warning"),
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
                await widget.onTestAlert(_topicController.text.trim());
                setState(() {
                  _isSending = false;
                  _statusMsg = "System alert dispatched to ntfy.sh/${_topicController.text.trim()}!";
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
                          "DISPATCH TEST SYSTEM ALERT",
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
