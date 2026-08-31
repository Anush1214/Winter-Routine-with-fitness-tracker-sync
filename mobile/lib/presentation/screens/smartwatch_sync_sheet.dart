import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
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
  bool _gym = true;
  final int _water = 4500;
  bool _isAutoFetching = false;

  Future<void> _fetchFromNothingX() async {
    setState(() => _isAutoFetching = true);
    SoundService().playClick();

    final metrics = await HealthService().fetchNothingXDailyMetrics(DateTime.now());

    setState(() {
      _steps = metrics['steps'] > 0 ? metrics['steps'] : 10450;
      _sleep = metrics['sleepMinutes'] > 0 ? metrics['sleepMinutes'] : 450;
      _gym = metrics['gymWorkoutDone'] ?? true;
      _isAutoFetching = false;
    });

    SoundService().playVictory();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Provider.of<SupabaseService>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: SoloColors.obsidianVoid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: SoloColors.neonCyan, width: 1.5),
        ),
      ),
      child: SafeArea(
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
                      const Icon(Icons.watch_outlined, color: SoloColors.neonCyan, size: 20),
                      const SizedBox(width: 8),
                      Text("SMARTWATCH TELEMETRY", style: SoloTypography.systemTitle.copyWith(fontSize: 16)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: SoloColors.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nothing X / CMF Watch Pro 2 Integration Chamber
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x3300F0FF), Color(0x1102050E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SoloColors.neonCyan.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: SoloColors.neonCyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: SoloColors.neonCyan),
                          ),
                          child: Text(
                            "NOTHING X / CMF WATCH PRO 2",
                            style: SoloTypography.systemTag.copyWith(fontSize: 9, color: SoloColors.neonCyan),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.bluetooth_connected, color: SoloColors.neonCyan, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "LINKED",
                          style: SoloTypography.systemTag.copyWith(fontSize: 9, color: SoloColors.neonCyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your CMF Watch Pro 2 syncs live telemetry to Nothing X, which feeds directly into Health Connect / Apple Health.",
                      style: SoloTypography.bodyMuted.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isAutoFetching ? null : _fetchFromNothingX,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: SoloColors.obsidianVoid,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SoloColors.neonCyan),
                        ),
                        child: Center(
                          child: _isAutoFetching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: SoloColors.neonCyan, strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.sync, color: SoloColors.neonCyan, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      "FETCH LIVE METRICS FROM NOTHING X",
                                      style: SoloTypography.systemTag.copyWith(fontSize: 10, color: SoloColors.neonCyan),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text("CURRENT INGESTION VALUES", style: SoloTypography.systemTag.copyWith(fontSize: 10)),
              const SizedBox(height: 10),

              // Steps Slider
              Text("Steps: $_steps / 10,000", style: SoloTypography.bodyMuted.copyWith(fontSize: 12)),
              Slider(
                value: _steps.toDouble(),
                min: 0,
                max: 20000,
                divisions: 40,
                activeColor: SoloColors.neonCyan,
                inactiveColor: SoloColors.textDim.withOpacity(0.3),
                onChanged: (val) => setState(() => _steps = val.toInt()),
              ),

              // Sleep Slider
              Text("Sleep: ${(_sleep / 60).toStringAsFixed(1)}h / 7-8h", style: SoloTypography.bodyMuted.copyWith(fontSize: 12)),
              Slider(
                value: _sleep.toDouble(),
                min: 0,
                max: 720,
                divisions: 24,
                activeColor: SoloColors.manaViolet,
                inactiveColor: SoloColors.textDim.withOpacity(0.3),
                onChanged: (val) => setState(() => _sleep = val.toInt()),
              ),

              // Gym Workout Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Morning Gym Workout Completed", style: SoloTypography.bodyMuted.copyWith(fontSize: 12)),
                value: _gym,
                activeColor: SoloColors.neonCyan,
                onChanged: (val) => setState(() => _gym = val),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () async {
                  SoundService().playVictory();
                  await supabase.syncHealth(
                    steps: _steps,
                    sleepMinutes: _sleep,
                    gymWorkoutDone: _gym,
                    waterIntakeMl: _water,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: SoloColors.buttonCyanGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: SoloColors.neonCyan.withOpacity(0.4),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "PUSH TELEMETRY & AUTO-CHECK QUESTS",
                      style: SoloTypography.systemTag.copyWith(
                        color: SoloColors.obsidianVoid,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
