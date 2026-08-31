import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../models/task_model.dart';
import 'holographic_frame.dart';

enum CompanionPersona { sungJinwoo, chaHaeIn }
enum JinwooVoiceLang { japanese, english }

class SungJinwooAssistantDialog extends StatefulWidget {
  final List<TaskModel> tasks;
  final VoidCallback? onTriggerAction;
  final CompanionPersona initialPersona;

  const SungJinwooAssistantDialog({
    super.key,
    required this.tasks,
    this.onTriggerAction,
    this.initialPersona = CompanionPersona.sungJinwoo,
  });

  static void show(
    BuildContext context, {
    required List<TaskModel> tasks,
    VoidCallback? onTriggerAction,
    CompanionPersona initialPersona = CompanionPersona.sungJinwoo,
  }) {
    SoundService().playLevelUp();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => SungJinwooAssistantDialog(
        tasks: tasks,
        onTriggerAction: onTriggerAction,
        initialPersona: initialPersona,
      ),
    );
  }

  @override
  State<SungJinwooAssistantDialog> createState() => _SungJinwooAssistantDialogState();
}

class _SungJinwooAssistantDialogState extends State<SungJinwooAssistantDialog>
    with SingleTickerProviderStateMixin {
  late CompanionPersona _selectedPersona;
  JinwooVoiceLang _selectedLang = JinwooVoiceLang.english;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _selectedPersona = widget.initialPersona;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  TaskModel? _getNextPendingTask() {
    final pending = widget.tasks.where((t) => !t.isCompleted).toList();
    if (pending.isEmpty) return null;
    return pending.first;
  }

  String _getVoiceActorName() {
    if (_selectedPersona == CompanionPersona.sungJinwoo) {
      return _selectedLang == JinwooVoiceLang.japanese
          ? "Taito Ban (坂 泰斗)"
          : "Aleks Le";
    } else {
      return _selectedLang == JinwooVoiceLang.japanese
          ? "Reina Ueda (上田 麗奈)"
          : "Michelle Rojas";
    }
  }

  String _getQuote(TaskModel? nextTask) {
    final now = DateTime.now();
    final hour = now.hour;

    if (_selectedPersona == CompanionPersona.sungJinwoo) {
      // SUNG JIN-WOO (MALE)
      if (_selectedLang == JinwooVoiceLang.japanese) {
        if (nextTask != null) {
          final title = nextTask.title;
          if (title.toLowerCase().contains('wake') || title.toLowerCase().contains('gym')) {
            return "「日課クエストを開始せよ。朝の鍛錬を怠るな。目を覚ませ、影の軍団よ。」";
          } else if (title.toLowerCase().contains('dsa') || title.toLowerCase().contains('japanese')) {
            return "「ここからは試練のダンジョンだ。DSAと集中力を極限まで研ぎ澄ませ。」";
          } else if (title.toLowerCase().contains('night') || title.toLowerCase().contains('sleep')) {
            return "「夜の規律を守れ。ペナルティを回避し、明日へ備えよ。起きろ (Okiro)。」";
          }
          return "「目標 『$title』 を確認した。立ち止まるな、一人でレベルアップせよ。」";
        }

        if (hour >= 6 && hour < 12) {
          return "「今日も一歩ずつ強くなる。朝のクエストを全てクリアしろ。」";
        } else if (hour >= 18 && hour < 22) {
          return "「夕方の修練を開始する。限界を超えろ、立ち向かえ。」";
        } else {
          return "「休息もまた力の一部だ。体を癒し、明日再び立ち上がれ。起きろ。」";
        }
      } else {
        // English (Aleks Le)
        if (nextTask != null) {
          final title = nextTask.title;
          if (title.toLowerCase().contains('wake') || title.toLowerCase().contains('gym')) {
            return "“The morning trial has begun, Hunter. Hydrate, initiate your protocol, and conquer the workout dungeon.”";
          } else if (title.toLowerCase().contains('dsa') || title.toLowerCase().contains('japanese')) {
            return "“Placement & DSA dungeon is active. Focus your mind, write clean algorithms, and master your skills.”";
          } else if (title.toLowerCase().contains('night') || title.toLowerCase().contains('sleep')) {
            return "“Penalty zone approaches at 11:00 PM. Wrap up all objectives, recover your mana, and Arise.”";
          }
          return "“Next objective detected: ‘$title’. If you don’t fight, you don’t survive. Complete it now.”";
        }

        if (hour >= 6 && hour < 12) {
          return "“The system chose you for a reason. Clear your morning quests and seize the day.”";
        } else if (hour >= 18 && hour < 22) {
          return "“Evening dungeon is in progress. Push through your placement shift and level up.”";
        } else {
          return "“All daily quests cleared. Recover your stamina, sleep early, and prepare to Arise tomorrow.”";
        }
      }
    } else {
      // CHA HAE-IN (FEMALE / S-RANK DANCER - GOLD THEME)
      if (_selectedLang == JinwooVoiceLang.japanese) {
        if (nextTask != null) {
          final title = nextTask.title;
          if (title.toLowerCase().contains('wake') || title.toLowerCase().contains('gym')) {
            return "「私の剣は決して鈍りません。朝の鍛錬、一緒に全力を尽くしましょう。」";
          } else if (title.toLowerCase().contains('dsa') || title.toLowerCase().contains('japanese')) {
            return "「DSAと修練のダンジョンですね。集中力を極限まで研ぎ澄ませて、共に勝利を掴みましょう。」";
          } else if (title.toLowerCase().contains('night') || title.toLowerCase().contains('sleep')) {
            return "「今日も素晴らしい一日でした。体をしっかり休めて、明日に備えてくださいね。」";
          }
          return "「次の目標 『$title』 を確認しました。Sランクの誇りを持って、堂々と挑みましょう！」";
        }

        if (hour >= 6 && hour < 12) {
          return "「おはようございます！ 今日も光り輝く一日を、一歩ずつ歩んでいきましょう。」";
        } else if (hour >= 18 && hour < 22) {
          return "「夕方の修練時間です。剣筋を乱さず、最後までやり遂げましょう！」";
        } else {
          return "「本日のデイリークエスト、見事な達成でした。ゆっくりお休みくださいね。」";
        }
      } else {
        // English (Michelle Rojas)
        if (nextTask != null) {
          final title = nextTask.title;
          if (title.toLowerCase().contains('wake') || title.toLowerCase().contains('gym')) {
            return "“A true S-Rank Hunter never hesitates. Hydrate, initiate your morning routine, and conquer the workout dungeon.”";
          } else if (title.toLowerCase().contains('dsa') || title.toLowerCase().contains('japanese')) {
            return "“Placement & DSA training is active. Keep your focus razor-sharp and execute every algorithm with precision.”";
          } else if (title.toLowerCase().contains('night') || title.toLowerCase().contains('sleep')) {
            return "“You demonstrated true S-Rank discipline today. Rest your body, recover your strength, and prepare for tomorrow.”";
          }
          return "“Target objective locked: ‘$title’. Believe in your training and clear it with absolute mastery.”";
        }

        if (hour >= 6 && hour < 12) {
          return "“Good morning! A new day awaits. Let's make every single minute count with golden determination.”";
        } else if (hour >= 18 && hour < 22) {
          return "“Evening training shift is underway. Stay centered, maintain your stance, and push forward!”";
        } else {
          return "“All daily protocol quests cleared with flying colors! Sleep well and restore your mana tonight.”";
        }
      }
    }
  }

  Color _getThemeColor() {
    return _selectedPersona == CompanionPersona.sungJinwoo
        ? const Color(0xFFC084FC) // Purple Mana
        : const Color(0xFFFBBF24); // Cha Hae-In Radiant Gold / Amber
  }

  Color _getSecondaryColor() {
    return _selectedPersona == CompanionPersona.sungJinwoo
        ? const Color(0xFFA855F7)
        : const Color(0xFFF59E0B); // Deep Amber Gold
  }

  @override
  Widget build(BuildContext context) {
    final nextTask = _getNextPendingTask();
    final quote = _getQuote(nextTask);
    final vaName = _getVoiceActorName();
    final themeColor = _getThemeColor();
    final secondaryColor = _getSecondaryColor();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: const BoxConstraints(maxWidth: 440),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: HolographicFrame(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header with Persona Avatar & VA Attribution
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: themeColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: _glowAnimation.value * 0.65),
                                blurRadius: 22,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: _selectedPersona == CompanionPersona.sungJinwoo
                                ? const Color(0xFF090414)
                                : const Color(0xFF1B1104),
                            child: Icon(
                              _selectedPersona == CompanionPersona.sungJinwoo
                                  ? Icons.flash_on_rounded
                                  : Icons.auto_awesome_rounded,
                              color: themeColor,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _selectedPersona == CompanionPersona.sungJinwoo
                                      ? const Color(0xFF3B0764)
                                      : const Color(0xFF451A03),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  _selectedPersona == CompanionPersona.sungJinwoo
                                      ? "SHADOW MONARCH COMPANION"
                                      : "S-RANK THE DANCER COMPANION",
                                  style: SoloTypography.systemTag.copyWith(
                                    fontSize: 8,
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedPersona == CompanionPersona.sungJinwoo
                                ? "SUNG JIN-WOO"
                                : "CHA HAE-IN (차해인)",
                            style: SoloTypography.systemTitle.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "VA: $vaName",
                            style: SoloTypography.bodyMuted.copyWith(
                              fontSize: 10,
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () {
                        SoundService().playClick();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Persona Switcher: Sung Jin-Woo (Male Purple) vs Cha Hae-In (Female Gold)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090414),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            SoundService().playClick();
                            setState(() => _selectedPersona = CompanionPersona.sungJinwoo);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: _selectedPersona == CompanionPersona.sungJinwoo
                                  ? const Color(0xFFA855F7).withValues(alpha: 0.25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              border: _selectedPersona == CompanionPersona.sungJinwoo
                                  ? Border.all(color: const Color(0xFFC084FC), width: 1.2)
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("👑 ", style: TextStyle(fontSize: 11)),
                                Text(
                                  "JIN-WOO (MALE)",
                                  style: SoloTypography.systemTag.copyWith(
                                    fontSize: 9,
                                    color: _selectedPersona == CompanionPersona.sungJinwoo
                                        ? Colors.white
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            SoundService().playClick();
                            setState(() => _selectedPersona = CompanionPersona.chaHaeIn);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: _selectedPersona == CompanionPersona.chaHaeIn
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              border: _selectedPersona == CompanionPersona.chaHaeIn
                                  ? Border.all(color: const Color(0xFFFBBF24), width: 1.2)
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("⚔️ ", style: TextStyle(fontSize: 11)),
                                Text(
                                  "CHA HAE-IN (GOLD)",
                                  style: SoloTypography.systemTag.copyWith(
                                    fontSize: 9,
                                    color: _selectedPersona == CompanionPersona.chaHaeIn
                                        ? const Color(0xFFFDE047)
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Language Selection Buttons (JP vs EN)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090414),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            SoundService().playClick();
                            setState(() => _selectedLang = JinwooVoiceLang.english);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedLang == JinwooVoiceLang.english
                                  ? themeColor.withValues(alpha: 0.25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                              border: _selectedLang == JinwooVoiceLang.english
                                  ? Border.all(color: themeColor, width: 1.2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                _selectedPersona == CompanionPersona.sungJinwoo
                                    ? "🇺🇸 ALEKS LE (EN)"
                                    : "🇺🇸 MICHELLE ROJAS (EN)",
                                style: SoloTypography.systemTag.copyWith(
                                  fontSize: 8.5,
                                  color: _selectedLang == JinwooVoiceLang.english
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            SoundService().playClick();
                            setState(() => _selectedLang = JinwooVoiceLang.japanese);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedLang == JinwooVoiceLang.japanese
                                  ? secondaryColor.withValues(alpha: 0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                              border: _selectedLang == JinwooVoiceLang.japanese
                                  ? Border.all(color: secondaryColor, width: 1.2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                _selectedPersona == CompanionPersona.sungJinwoo
                                    ? "🇯🇵 TAITO BAN (JP)"
                                    : "🇯🇵 REINA UEDA (JP)",
                                style: SoloTypography.systemTag.copyWith(
                                  fontSize: 8.5,
                                  color: _selectedLang == JinwooVoiceLang.japanese
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Holographic Dialogue Quote Box (Gold / Purple)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _selectedPersona == CompanionPersona.sungJinwoo
                            ? const Color(0xFF1E1038)
                            : const Color(0xFF291B08),
                        themeColor.withValues(alpha: 0.12),
                        const Color(0xFF090414),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.record_voice_over,
                                color: themeColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "[ $vaName // VOICE CUE ]",
                                style: SoloTypography.systemTag.copyWith(
                                  fontSize: 9,
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              SoundService().speakCharacter(
                                text: quote,
                                isJapanese: _selectedLang == JinwooVoiceLang.japanese,
                                isJinwoo: _selectedPersona == CompanionPersona.sungJinwoo,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF090414),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: themeColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.volume_up, color: themeColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    "PLAY AUDIO",
                                    style: SoloTypography.systemTag.copyWith(
                                      fontSize: 8.5,
                                      color: themeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        quote,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          fontFamily: _selectedLang == JinwooVoiceLang.japanese ? 'sans-serif' : 'monospace',
                        ),
                      ),
                      if (nextTask != null) ...[
                        const SizedBox(height: 10),
                        Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: themeColor, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "TARGET: ${nextTask.title}",
                                style: SoloTypography.systemTag.copyWith(
                                  fontSize: 9,
                                  color: themeColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          SoundService().playClick();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          "DISMISS",
                          style: SoloTypography.systemTag.copyWith(fontSize: 10, color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          SoundService().playLevelUp();
                          Navigator.of(context).pop();
                          if (widget.onTriggerAction != null) {
                            widget.onTriggerAction!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          shadowColor: themeColor.withValues(alpha: 0.6),
                        ),
                        child: Text(
                          _selectedPersona == CompanionPersona.sungJinwoo
                              ? "⚡ EXECUTE QUEST"
                              : "⚔️ CONQUER S-RANK QUEST",
                          style: SoloTypography.systemTag.copyWith(
                            fontSize: 10.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
