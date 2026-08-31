import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    SoundService().playRobotClick();
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
  bool _isPlayingAudio = false;
  Timer? _subtitleTimer;

  @override
  void initState() {
    super.initState();
    _selectedPersona = widget.initialPersona;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _subtitleTimer?.cancel();
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

  // Dual Quotes (Japanese & English)
  String _getJapaneseQuote(TaskModel? nextTask) {
    if (_selectedPersona == CompanionPersona.sungJinwoo) {
      if (nextTask != null) {
        final title = nextTask.title.toLowerCase();
        if (title.contains('wake') || title.contains('gym')) {
          return "「日課クエストを開始せよ。朝の鍛錬を怠るな。目を覚ませ、影の軍団よ。」";
        } else if (title.contains('dsa') || title.contains('japanese')) {
          return "「ここからは試練のダンジョンだ。DSAと集中力を極限まで研ぎ澄ませ。」";
        } else if (title.contains('night') || title.contains('sleep')) {
          return "「夜の規律を守れ。ペナルティを回避し、明日へ備えよ。起きろ (Okiro)。」";
        }
        return "「目標 『${nextTask.title}』 を確認した。立ち止まるな、一人でレベルアップせよ。」";
      }
      return "「今日も一歩ずつ強くなる。朝のクエストを全てクリアしろ。起きろ。」";
    } else {
      // Cha Hae-In
      if (nextTask != null) {
        final title = nextTask.title.toLowerCase();
        if (title.contains('wake') || title.contains('gym')) {
          return "「私の剣は決して鈍りません。朝の鍛錬、一緒に全力を尽くしましょう。」";
        } else if (title.contains('dsa') || title.contains('japanese')) {
          return "「DSAと修練のダンジョンですね。集中力を極限まで研ぎ澄ませて、共に勝利を掴みましょう。」";
        } else if (title.contains('night') || title.contains('sleep')) {
          return "「今日も素晴らしい一日でした。体をしっかり休めて、明日に備えてくださいね。」";
        }
        return "「次の目標 『${nextTask.title}』 を確認しました。Sランクの誇りを持って挑みましょう！」";
      }
      return "「おはようございます！ 今日も光り輝く一日を、一歩ずつ歩んでいきましょう。」";
    }
  }

  String _getEnglishQuote(TaskModel? nextTask) {
    if (_selectedPersona == CompanionPersona.sungJinwoo) {
      if (nextTask != null) {
        final title = nextTask.title.toLowerCase();
        if (title.contains('wake') || title.contains('gym')) {
          return "“The morning trial has begun, Hunter. Hydrate, initiate your protocol, and conquer the workout dungeon.”";
        } else if (title.contains('dsa') || title.contains('japanese')) {
          return "“Placement & DSA dungeon is active. Focus your mind, write clean algorithms, and master your skills.”";
        } else if (title.contains('night') || title.contains('sleep')) {
          return "“Penalty zone approaches at 11:00 PM. Wrap up all objectives, recover your mana, and Arise.”";
        }
        return "“Next objective detected: ‘${nextTask.title}’. If you don’t fight, you don’t survive. Complete it now.”";
      }
      return "“The system chose you for a reason. Clear your daily quests and prepare to Arise tomorrow.”";
    } else {
      // Cha Hae-In
      if (nextTask != null) {
        final title = nextTask.title.toLowerCase();
        if (title.contains('wake') || title.contains('gym')) {
          return "“A true S-Rank Hunter never hesitates. Hydrate, initiate your morning routine, and conquer the workout dungeon.”";
        } else if (title.contains('dsa') || title.contains('japanese')) {
          return "“Placement & DSA training is active. Keep your focus razor-sharp and execute every algorithm with precision.”";
        } else if (title.contains('night') || title.contains('sleep')) {
          return "“You demonstrated true S-Rank discipline today. Rest your body, recover your strength, and prepare for tomorrow.”";
        }
        return "“Target objective locked: ‘${nextTask.title}’. Believe in your training and clear it with absolute mastery.”";
      }
      return "“Good morning! A new day awaits. Let's make every single minute count with golden determination.”";
    }
  }

  Color _getThemeColor() {
    return _selectedPersona == CompanionPersona.sungJinwoo
        ? const Color(0xFFC084FC) // Purple Mana
        : const Color(0xFFFBBF24); // Cha Hae-In Radiant Gold
  }

  void _triggerVoiceWithSubtitles() {
    final nextTask = _getNextPendingTask();
    final isJp = _selectedLang == JinwooVoiceLang.japanese;
    final primaryQuote = isJp ? _getJapaneseQuote(nextTask) : _getEnglishQuote(nextTask);

    _subtitleTimer?.cancel();
    setState(() => _isPlayingAudio = true);

    SoundService().speakCharacter(
      text: primaryQuote,
      isJapanese: isJp,
      isJinwoo: _selectedPersona == CompanionPersona.sungJinwoo,
      clipIndex: 1,
    );

    // Auto-dismiss playing state after spoken duration
    _subtitleTimer = Timer(const Duration(milliseconds: 4800), () {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nextTask = _getNextPendingTask();
    final jpQuote = _getJapaneseQuote(nextTask);
    final enQuote = _getEnglishQuote(nextTask);
    final vaName = _getVoiceActorName();
    final themeColor = _getThemeColor();
    final isJp = _selectedLang == JinwooVoiceLang.japanese;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: const BoxConstraints(maxWidth: 450),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: HolographicFrame(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header with Persona Avatar & Attribution
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
                            style: GoogleFonts.notoSansJp(
                              fontSize: 11,
                              color: themeColor,
                              fontWeight: FontWeight.w700,
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

                // Persona Switcher: Jin-Woo (Male Purple) vs Cha Hae-In (Female Gold)
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
                                  ? themeColor.withValues(alpha: 0.25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                              border: _selectedLang == JinwooVoiceLang.japanese
                                  ? Border.all(color: themeColor, width: 1.2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                _selectedPersona == CompanionPersona.sungJinwoo
                                    ? "🇯🇵 TAITO BAN (JP)"
                                    : "🇯🇵 REINA UEDA (JP)",
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
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

                // Holographic Dialogue Quote Box with PLAY AUDIO Trigger
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
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 10,
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _triggerVoiceWithSubtitles,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: _isPlayingAudio
                                    ? themeColor
                                    : const Color(0xFF090414),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: themeColor.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.volume_up_rounded,
                                    color: _isPlayingAudio ? Colors.black : themeColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isPlayingAudio ? "PLAYING..." : "PLAY AUDIO",
                                    style: SoloTypography.systemTag.copyWith(
                                      fontSize: 8.5,
                                      color: _isPlayingAudio ? Colors.black : themeColor,
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

                      // Quote Display (Supports Noto Sans JP for Japanese)
                      Text(
                        isJp ? jpQuote : enQuote,
                        style: isJp
                            ? GoogleFonts.notoSansJp(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w700,
                              )
                            : const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                      ),

                      // 🎬 LIVE ANIME-STYLE SUBTITLES HUD (English + Japanese)
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isPlayingAudio
                              ? const Color(0xFF000000).withValues(alpha: 0.9)
                              : const Color(0xFF130926).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isPlayingAudio
                                ? const Color(0xFFFACC15)
                                : const Color(0xFFA855F7).withValues(alpha: 0.3),
                            width: _isPlayingAudio ? 1.4 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_isPlayingAudio) ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  _isPlayingAudio
                                      ? "ANIME SUBTITLES // NOW BROADCASTING"
                                      : "SUBTITLES (ENGLISH TRANSLATION)",
                                  style: SoloTypography.systemTag.copyWith(
                                    fontSize: 8,
                                    color: _isPlayingAudio
                                        ? const Color(0xFFFACC15)
                                        : const Color(0xFFA89BB9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              enQuote,
                              style: TextStyle(
                                color: _isPlayingAudio
                                    ? const Color(0xFFFACC15)
                                    : const Color(0xFFE9D5FF),
                                fontSize: 11.5,
                                fontWeight: _isPlayingAudio
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                height: 1.35,
                              ),
                            ),
                          ],
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
                          SoundService().playVictory();
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
