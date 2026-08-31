import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../widgets/floating_glass_navbar.dart';
import 'home_quest_screen.dart';
import 'profile_screen.dart';
import 'notification_settings_modal.dart';
import 'quest_editor_modal.dart';
import 'smartwatch_sync_sheet.dart';
import '../widgets/gemini_ai_terminal_dialog.dart';
import '../widgets/consistency_heatmap_widget.dart';
import '../widgets/expedition_matrix.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentTabIndex = 0;

  void _openGeminiAiTerminal() {
    final service = context.read<SupabaseService>();
    GeminiAiTerminalDialog.show(
      context,
      tasks: service.tasks,
      streak: service.currentStreak,
      waterMl: service.healthLog.waterIntakeMl,
    );
  }

  void _openTaskEditor() {
    final service = context.read<SupabaseService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuestEditorModal(
        selectedDate: service.selectedDate,
        onSave: (savedTask, scope) {
          service.saveTask(savedTask, scope);
        },
      ),
    );
  }

  void _openSmartwatchSync() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SmartwatchSyncSheet(),
    );
  }

  void _showStreakModal(int streakDays) {
    SoundService().playVictory();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F0720),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF97316), width: 1.5),
        ),
        title: Row(
          children: [
            const Text("🔥", style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              "HUNTER STREAK: $streakDays DAYS",
              style: SoloTypography.systemTitle.copyWith(fontSize: 14, color: const Color(0xFFFBBF24)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your discipline flame burns unyielding. Continue checking off quests daily to awaken S-Rank multiplier status and maintain zero penalty strikes.",
              style: SoloTypography.bodyMuted.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E0C03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFBBF24), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "EXP Multiplier Active: 1.5x",
                    style: SoloTypography.systemTag.copyWith(fontSize: 11, color: const Color(0xFFFDE047)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CLOSE", style: TextStyle(color: Color(0xFFC084FC), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsMatrixView(SupabaseService service) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF581C87).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA855F7)),
                ),
                child: const Icon(Icons.show_chart_rounded, color: Color(0xFFC084FC), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EXPEDITION MATRIX",
                    style: SoloTypography.systemTitle.copyWith(fontSize: 18),
                  ),
                  Text(
                    "122-Day Awakening & Consistency Telemetry",
                    style: SoloTypography.bodyMuted.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Streak & Heatmap Matrix
          ConsistencyHeatmapWidget(
            heatmapRates: service.heatmapRates,
            selectedDate: service.selectedDate,
            onSelectDate: (d) => service.selectDate(d),
          ),
          const SizedBox(height: 16),

          // Expedition Matrix
          ExpeditionMatrix(
            heatmapRates: service.heatmapRates,
            selectedDate: service.selectedDate,
            onSelectDate: (d) => service.selectDate(d),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final supabase = context.watch<SupabaseService>();
    final user = auth.currentUser;
    final isFemale = auth.isFemaleTheme;

    return Scaffold(
      backgroundColor: isFemale ? const Color(0xFF140B02) : const Color(0xFF090314),
      body: Stack(
        children: [
          // Background Mana Gradient
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFemale
                    ? const Color(0xFFB45309).withValues(alpha: 0.15)
                    : const Color(0xFF581C87).withValues(alpha: 0.15),
              ),
            ),
          ),

          // Active Tab Content
          IndexedStack(
            index: _currentTabIndex,
            children: [
              // Tab 0: Main Home Quests Screen
              const HomeQuestScreen(hideFabForNavbar: true),

              // Tab 1: Stats & Consistency Matrix
              _buildStatsMatrixView(supabase),

              // Tab 2: Notification Alerts Hub
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    NotificationSettingsModal(
                      onTestAlert: (topic) => supabase.sendTestAlert(topic),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),

              // Tab 3: Hunter Profile Screen
              ProfileScreen(streakDays: supabase.currentStreak),
            ],
          ),

          // Floating Glassmorphic Bottom Navigation Bar with 3D Center Flames Streak
          FloatingGlassNavbar(
            selectedIndex: _currentTabIndex,
            streakDays: supabase.currentStreak,
            onTabSelected: (index) {
              setState(() => _currentTabIndex = index);
            },
            onAddQuest: _openTaskEditor,
            onOpenWatchSync: _openSmartwatchSync,
            onOpenGeminiAi: _openGeminiAiTerminal,
            onStreakTap: () => _showStreakModal(supabase.currentStreak),
            userPhotoUrl: user?.photoUrl,
            isFemaleTheme: isFemale,
          ),
        ],
      ),
    );
  }
}
