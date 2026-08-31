import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../services/supabase_service.dart';
import '../../services/health_service.dart';

class SmartwatchSyncSheet extends StatefulWidget {
  const SmartwatchSyncSheet({super.key});

  @override
  State<SmartwatchSyncSheet> createState() => _SmartwatchSyncSheetState();
}

class _SmartwatchSyncSheetState extends State<SmartwatchSyncSheet> {
  int _steps = 10450;
  int _sleep = 450;
  int _water = 4200;
  bool _gym = true;
  bool _isSyncing = false;
  String? _statusMsg;

  @override
  Widget build(BuildContext context) {
    final service = context.read<SupabaseService>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: SoloColors.obsidianCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: SoloColors.neonCyan, width: 1.5),
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
                  const Icon(Icons.watch_outlined, color: SoloColors.manaViolet, size: 22),
                  const SizedBox(width: 8),
                  Text("[ SMARTWATCH SYNC ENGINE ]", style: SoloTypography.systemTag),
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
            "Sync CMF Watch Pro 2 / Apple Health directly to your 24/7 Supabase Database.",
            style: SoloTypography.bodyMuted,
          ),
          const SizedBox(height: 16),

          // Real HealthKit sync button
          GestureDetector(
            onTap: () async {
              setState(() {
                _isSyncing = true;
                _statusMsg = "Reading health metrics from device...";
              });
              final ok = await HealthService().requestPermissions();
              if (ok) {
                final metrics = await HealthService().fetchDailyMetrics(DateTime.now());
                setState(() {
                  _steps = metrics['steps'] ?? _steps;
                  _sleep = metrics['sleepMinutes'] ?? _sleep;
                  _gym = metrics['gymWorkoutDone'] ?? _gym;
                  _statusMsg = "Health data fetched! Ready to push.";
                });
              } else {
                setState(() {
                  _statusMsg = "Permissions not granted. You can use manual push below.";
                });
              }
              setState(() => _isSyncing = false);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: SoloColors.obsidianVoid,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SoloColors.manaViolet.withOpacity(0.6)),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: SoloColors.manaViolet, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "AUTO-FETCH FROM PHONE REPOSITORY",
                      style: SoloTypography.systemTag.copyWith(color: SoloColors.manaViolet),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_statusMsg != null) ...[
            const SizedBox(height: 8),
            Text(_statusMsg!, style: SoloTypography.bodyMuted.copyWith(color: SoloColors.electricSky)),
          ],

          const SizedBox(height: 20),
          // Push button
          GestureDetector(
            onTap: () async {
              setState(() => _isSyncing = true);
              await service.syncHealth(
                steps: _steps,
                sleepMinutes: _sleep,
                gymWorkoutDone: _gym,
                waterIntakeMl: _water,
              );
              setState(() {
                _isSyncing = false;
                _statusMsg = "Push successful! Linked quests auto-checked.";
              });
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) Navigator.pop(context);
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
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: _isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: SoloColors.obsidianVoid, strokeWidth: 2),
                      )
                    : Text(
                        "PUSH HEALTH SYNC TO DATABASE",
                        style: SoloTypography.systemTag.copyWith(
                          color: SoloColors.obsidianVoid,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
