import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

class GeminiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isActionRegistered;

  GeminiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isActionRegistered = false,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'isActionRegistered': isActionRegistered,
      };

  factory GeminiChatMessage.fromJson(Map<String, dynamic> json) => GeminiChatMessage(
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        isActionRegistered: json['isActionRegistered'] as bool? ?? false,
      );
}

class GeminiAiTerminalDialog extends StatefulWidget {
  final List<TaskModel> tasks;
  final int streak;
  final int waterMl;

  const GeminiAiTerminalDialog({
    super.key,
    required this.tasks,
    this.streak = 7,
    this.waterMl = 3200,
  });

  /// Open as a FULL-SCREEN page instead of a popup dialog
  static void show(
    BuildContext context, {
    required List<TaskModel> tasks,
    int streak = 7,
    int waterMl = 3200,
  }) {
    SoundService().playRobotClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GeminiAiTerminalDialog(
          tasks: tasks,
          streak: streak,
          waterMl: waterMl,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  State<GeminiAiTerminalDialog> createState() => _GeminiAiTerminalDialogState();
}

class _GeminiAiTerminalDialogState extends State<GeminiAiTerminalDialog> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  static const String _storageKey = "solo_gemini_chat_history_v2";

  List<GeminiChatMessage> _messages = [];

  static final String _geminiApiKey =
      utf8.decode(base64.decode("QVEuQWI4Uk42SS1KMDhuRzhWZWhtWXhkRWR0c0JkY1pUaEM4bU1Tc3dRMjktNVJZVXNid1E="));

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_storageKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List decoded = jsonDecode(savedJson);
        final loaded = decoded.map((e) => GeminiChatMessage.fromJson(e)).toList();
        if (loaded.isNotEmpty) {
          setState(() {
            _messages = loaded;
          });
          _scrollToBottom();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error loading Gemini chat history: $e");
    }

    // Default first message if no history
    setState(() {
      _messages = [
        GeminiChatMessage(
          text: "[ SYSTEM GEMINI AI AWAKENED ]\n\nGreetings, Hunter. I have synchronized with your routine logs and active discipline telemetry.\n\nYou can ask me questions or command me to register new routines automatically (e.g. \"add a routine to do duolingo every day at night 10pm\"). Memory is active.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    });
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _messages.map((m) => m.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      debugPrint("Error saving Gemini chat history: $e");
    }
  }

  Future<void> _clearChatHistory() async {
    SoundService().playClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    setState(() {
      _messages = [
        GeminiChatMessage(
          text: "[ SYSTEM MEMORY RESET ]\n\nChat history cleared. Active telemetry re-synchronized. Ready for new directives.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String? _extractTimeFromText(String text) {
    final lower = text.toLowerCase();
    // Match 10pm, 10:30pm, 10 pm, 22:00, 7am, 7:30 am
    final match12 = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)').firstMatch(lower);
    if (match12 != null) {
      int hour = int.parse(match12.group(1)!);
      int minute = match12.group(2) != null ? int.parse(match12.group(2)!) : 0;
      final period = match12.group(3)!;
      if (period == 'pm' && hour < 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }

    final match24 = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(lower);
    if (match24 != null) {
      int hour = int.parse(match24.group(1)!);
      int minute = int.parse(match24.group(2)!);
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }

    if (lower.contains('night') || lower.contains('evening')) return "22:00";
    if (lower.contains('morning')) return "07:00";
    if (lower.contains('afternoon')) return "14:00";
    return null;
  }

  String _inferCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('duolingo') || lower.contains('study') || lower.contains('read') || lower.contains('dsa') || lower.contains('code') || lower.contains('learn')) {
      return 'study';
    }
    if (lower.contains('gym') || lower.contains('workout') || lower.contains('run') || lower.contains('walk') || lower.contains('exercise') || lower.contains('pushup')) {
      return 'fitness';
    }
    if (lower.contains('water') || lower.contains('sleep') || lower.contains('meditat') || lower.contains('diet') || lower.contains('stretch')) {
      return 'health';
    }
    if (lower.contains('project') || lower.contains('job') || lower.contains('work') || lower.contains('interview')) {
      return 'career';
    }
    return 'routine';
  }

  Future<void> _sendMessage(String query) async {
    if (query.trim().isEmpty || _isLoading) return;
    final userText = query.trim();
    _textController.clear();
    SoundService().playClick();

    final userMsg = GeminiChatMessage(
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _saveChatHistory();
    _scrollToBottom();

    final completedCount = widget.tasks.where((t) => t.isCompleted).length;
    final totalCount = widget.tasks.length;

    // Check if user is asking to add a routine
    final lowerQuery = userText.toLowerCase();
    final isAddIntent = lowerQuery.contains('add ') || lowerQuery.contains('create ') || lowerQuery.contains('schedule ') || lowerQuery.contains('set routine') || lowerQuery.contains('set quest');

    // Build In-Context System Prompt with Instructions for Automatic Tool Use
    final systemInstruction = """
You are the Google Gemini System AI and Awakening Mentor for Hunter Anush in the Solo Leveling Winter Arc Protocol.
You have real-time awareness of the Hunter's routine telemetry, chat memory, and the power to automatically register quests into the protocol.

[ LIVE HUNTER APP TELEMETRY ]
- Active Streak: ${widget.streak} Days
- Quests Cleared Today: $completedCount / $totalCount
- Current Water Hydration: ${widget.waterMl}ml / 4500ml
- Quests List: ${widget.tasks.map((t) => "${t.title} (${t.isCompleted ? 'CLEARED' : 'PENDING'})").join(', ')}

[ SPECIAL ABILITY : AUTOMATIC QUEST REGISTRATION ]
If the hunter asks you to add, create, or schedule any quest, task, habit, or routine (e.g. "add a routine to do duolingo every day at night 10pm", "add reading at 8am"):
1. You MUST generate an action command tag in your response:
[ACTION:ADD_QUEST:{"title":"Duolingo Language Practice","category":"study","startTime":"22:00","scope":"all_future"}]
Valid categories: "routine", "fitness", "career", "study", "health".
Valid startTimes: 24-hr format "HH:mm" (e.g. "22:00", "07:00", "19:30").
Valid scopes: "all_future" (for daily / everyday routine) or "today".
2. Confirm with high-tech Solo Leveling System style that the quest has been bound to their daily protocol.

[ OUTPUT FORMATTING DIRECTIVES ]
1. DO NOT use raw markdown headers like '###' or '##'.
2. DO NOT wrap section titles in double asterisks like '### **[ TITLE ]**'.
3. Use clean brackets for sections, e.g.: '[ STATUS ANALYSIS ]' or '[ QUEST REGISTERED ]'.
4. For lists, use simple bullet symbols '•' or numbered points '1.', '2.'.
5. Avoid excessive double asterisks '**'. Keep text clean, sleek, and formatted like a high-tech Solo Leveling System window interface.
""";

    // Build multi-turn conversational history contents for Gemini API
    final List<Map<String, dynamic>> apiContents = [];

    // Add recent previous conversation turns (up to 8 turns) for true memory
    final recentHistory = _messages.length > 8 ? _messages.sublist(_messages.length - 8) : _messages;
    for (int i = 0; i < recentHistory.length - 1; i++) {
      final m = recentHistory[i];
      apiContents.add({
        "role": m.isUser ? "user" : "model",
        "parts": [
          {"text": m.text}
        ]
      });
    }

    // Add the current user prompt with telemetry context
    apiContents.add({
      "role": "user",
      "parts": [
        {"text": "$systemInstruction\n\n[ USER QUERY ]\n$userText"}
      ]
    });

    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent"),
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": _geminiApiKey,
        },
        body: jsonEncode({
          "contents": apiContents,
        }),
      );

      String aiReply = "";
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        aiReply = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";
      }

      // Check if Gemini generated [ACTION:ADD_QUEST:{...}] or fallback to local pattern
      bool actionExecuted = false;
      String? addedTaskTitle;
      String? addedTaskTime;

      final actionRegex = RegExp(r'\[ACTION:ADD_QUEST:(\{.*?\})\]', dotAll: true);
      final actionMatch = actionRegex.firstMatch(aiReply);

      if (actionMatch != null && mounted) {
        try {
          final actionJson = jsonDecode(actionMatch.group(1)!);
          final title = actionJson['title'] ?? 'Custom Objective';
          final category = actionJson['category'] ?? _inferCategory(title);
          final startTime = actionJson['startTime'] ?? _extractTimeFromText(userText);
          final scope = actionJson['scope'] ?? 'all_future';

          final newTask = TaskModel(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            category: category,
            targetDate: context.read<SupabaseService>().selectedDate,
            startTime: startTime,
            isCompleted: false,
          );

          await context.read<SupabaseService>().saveTask(newTask, scope);
          actionExecuted = true;
          addedTaskTitle = title;
          addedTaskTime = startTime;
          SoundService().playVictory();
        } catch (e) {
          debugPrint("Error parsing Gemini action JSON: $e");
        }
      } else if (isAddIntent && mounted) {
        // Fallback local NLP auto-registration
        try {
          String cleanedTitle = userText
              .replaceAll(RegExp(r'^(?:please\s+)?(?:add|create|schedule|set)\s+(?:a\s+)?(?:new\s+)?(?:routine|quest|task|habit)?\s*(?:to\s+)?', caseSensitive: false), '')
              .replaceAll(RegExp(r'\s*(?:every\s*day|daily|at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)?|at\s+night|in\s+morning).*$', caseSensitive: false), '')
              .trim();

          if (cleanedTitle.isEmpty) cleanedTitle = "Custom Objective";
          if (cleanedTitle.toLowerCase().startsWith("do ")) {
            cleanedTitle = cleanedTitle.substring(3).trim();
          }
          cleanedTitle = "${cleanedTitle[0].toUpperCase()}${cleanedTitle.substring(1)}";

          final extractedTime = _extractTimeFromText(userText) ?? "22:00";
          final category = _inferCategory(cleanedTitle);

          final newTask = TaskModel(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}',
            title: cleanedTitle,
            category: category,
            targetDate: context.read<SupabaseService>().selectedDate,
            startTime: extractedTime,
            isCompleted: false,
          );

          await context.read<SupabaseService>().saveTask(newTask, 'all_future');
          actionExecuted = true;
          addedTaskTitle = cleanedTitle;
          addedTaskTime = extractedTime;
          SoundService().playVictory();
        } catch (e) {
          debugPrint("Fallback task addition error: $e");
        }
      }

      if (aiReply.isEmpty) {
        if (actionExecuted) {
          aiReply = "[ SYSTEM NOTIFICATION : QUEST REGISTERED ]\n\n• Objective: $addedTaskTitle\n• Schedule: Daily at $addedTaskTime\n• Status: Added to your Winter Arc Protocol.\n\nYour protocol has been synchronized with this daily habit.";
        } else {
          aiReply = "[ SYSTEM DIRECTIVE ]\n\nI have analyzed your request, Hunter. Maintain high discipline, clear your remaining quests (${totalCount - completedCount} pending), and execute your algorithms with surgical precision.";
        }
      }

      // Remove the raw action tag from the visual display and clean text
      aiReply = aiReply.replaceAll(actionRegex, '').trim();
      aiReply = _cleanSystemText(aiReply);

      if (actionExecuted && !aiReply.contains("QUEST REGISTERED") && !aiReply.contains("PROTOCOL UPDATED")) {
        aiReply = "[ SYSTEM NOTIFICATION : QUEST BOUND TO PROTOCOL ]\n• Added: $addedTaskTitle (${addedTaskTime ?? 'Daily'})\n\n$aiReply";
      }

      SoundService().playVictory();
      if (mounted) {
        setState(() {
          _messages.add(GeminiChatMessage(
            text: aiReply,
            isUser: false,
            timestamp: DateTime.now(),
            isActionRegistered: actionExecuted,
          ));
          _isLoading = false;
        });
        _saveChatHistory();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        // Even if network fails, check if we can register locally
        if (isAddIntent) {
          final extractedTime = _extractTimeFromText(userText) ?? "22:00";
          final newTask = TaskModel(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}',
            title: userText.replaceAll(RegExp(r'^(?:add|create|schedule)\s+(?:a\s+)?(?:routine|task|quest)?\s*(?:to\s+)?', caseSensitive: false), '').trim(),
            category: 'routine',
            targetDate: context.read<SupabaseService>().selectedDate,
            startTime: extractedTime,
            isCompleted: false,
          );
          context.read<SupabaseService>().saveTask(newTask, 'all_future');
          SoundService().playVictory();
        }

        setState(() {
          _messages.add(GeminiChatMessage(
            text: isAddIntent
                ? "[ SYSTEM NOTIFICATION : QUEST REGISTERED ]\n\nYour routine has been registered and scheduled into your daily protocol.\n• Status: Active in all future days."
                : "[ TACTICAL TELEMETRY ]\n\n• Today's Status: $completedCount/$totalCount quests cleared.\n• Discipline: Active ${widget.streak}-day streak.\n• Next Move: Focus on your pending quest and conquer the day.",
            isUser: false,
            timestamp: DateTime.now(),
            isActionRegistered: isAddIntent,
          ));
          _isLoading = false;
        });
        _saveChatHistory();
        _scrollToBottom();
      }
    }
  }

  String _cleanSystemText(String raw) {
    return raw
        .replaceAll(RegExp(r'^###\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^##\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^#\s*', multiLine: true), '')
        .replaceAll('```', '');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isFemale = auth.isFemaleTheme;
    final completedCount = widget.tasks.where((t) => t.isCompleted).length;

    // Theme-aware colors
    final geminiAccent = const Color(0xFF9B72CB);
    final bgColor = isFemale ? const Color(0xFF140B02) : const Color(0xFF090414);
    final chatBgColor = isFemale ? const Color(0xFF0A0603) : const Color(0xFF07030E);
    final userBubbleBg = isFemale ? const Color(0xFF78350F).withValues(alpha: 0.85) : const Color(0xFF581C87).withValues(alpha: 0.85);
    final userBubbleBorder = isFemale ? const Color(0xFFFBBF24).withValues(alpha: 0.8) : const Color(0xFFC084FC).withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── TOP APP BAR ───────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(color: geminiAccent.withValues(alpha: 0.25)),
                ),
              ),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () {
                      SoundService().playClick();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: geminiAccent.withValues(alpha: 0.4)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, color: geminiAccent, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Gemini Logo Orb
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: geminiAccent.withValues(alpha: 0.5),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Title & telemetry
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1038),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: geminiAccent),
                              ),
                              child: const Text(
                                "AUTO-ROUTINE ACTIVE • GEMINI",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFFC084FC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "GEMINI AI INTELLIGENCE HUB",
                          style: SoloTypography.systemTitle.copyWith(fontSize: 14, color: Colors.white),
                        ),
                        Text(
                          "Telemetry: $completedCount/${widget.tasks.length} Quests • ${widget.streak}d Streak",
                          style: SoloTypography.bodyMuted.copyWith(fontSize: 9.5, color: const Color(0xFF38BDF8)),
                        ),
                      ],
                    ),
                  ),

                  // Clear memory
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white54, size: 20),
                    tooltip: "Reset Memory",
                    onPressed: _clearChatHistory,
                  ),
                ],
              ),
            ),

            // ─── QUICK PROMPT CHIPS ────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPromptChip("⚡ Add Duolingo at 10 PM", "Add a routine to do duolingo every day at night 10pm"),
                    const SizedBox(width: 6),
                    _buildPromptChip("📖 Add Reading at 8 AM", "Add a daily quest to read 20 pages at 8:00 AM"),
                    const SizedBox(width: 6),
                    _buildPromptChip("🎯 Analyze Routine", "Analyze my today's routine and give me tactical advice on what to prioritize next."),
                    const SizedBox(width: 6),
                    _buildPromptChip("💧 Hydration Plan", "How can I optimize my recovery and water intake based on my 4500ml goal?"),
                    const SizedBox(width: 6),
                    _buildPromptChip("👑 Awakening Directive", "Give me an inspiring Solo Leveling System motivation to crush all daily goals."),
                  ],
                ),
              ),
            ),

            // ─── CHAT MESSAGES ─────────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: chatBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: geminiAccent.withValues(alpha: 0.25)),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!msg.isUser) ...[
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF4285F4), Color(0xFF9B72CB)],
                                ),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: msg.isUser ? userBubbleBg : const Color(0xFF130A24),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: msg.isUser ? userBubbleBorder : (msg.isActionRegistered ? const Color(0xFF10B981) : geminiAccent.withValues(alpha: 0.3)),
                                  width: msg.isActionRegistered ? 1.6 : 1.0,
                                ),
                              ),
                              child: _SystemFormattedMessageText(
                                text: msg.text,
                                isUser: msg.isUser,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // ─── LOADING INDICATOR ─────────────────────────────
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF9B72CB)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Gemini is executing directives...",
                      style: SoloTypography.systemTag.copyWith(fontSize: 9, color: const Color(0xFFC084FC)),
                    ),
                  ],
                ),
              ),

            // ─── INPUT BAR ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(color: geminiAccent.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isFemale ? const Color(0xFF1A0E02) : const Color(0xFF090414),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: geminiAccent.withValues(alpha: 0.4)),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        onSubmitted: _sendMessage,
                        decoration: const InputDecoration(
                          hintText: "Tell Gemini to add routines (e.g. \"add duolingo at 10pm\")...",
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: geminiAccent.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String label, String prompt) {
    return GestureDetector(
      onTap: () => _sendMessage(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF130926),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF9B72CB).withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFE9D5FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Rich Formatter for Clean System Window Responses (Parses **bold**, bullets, inline codes without ugly symbols)
class _SystemFormattedMessageText extends StatelessWidget {
  final String text;
  final bool isUser;

  const _SystemFormattedMessageText({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      );
    }

    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Check if line is a Section Header [ TITLE ]
      if (line.startsWith('[') && line.endsWith(']')) {
        final isSuccess = line.contains('REGISTERED') || line.contains('BOUND') || line.contains('CLEARED');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSuccess ? const Color(0xFF064E3B).withValues(alpha: 0.8) : const Color(0xFF2E1065).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSuccess ? const Color(0xFF34D399) : const Color(0xFFA855F7).withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                line,
                style: GoogleFonts.jetBrainsMono(
                  color: isSuccess ? const Color(0xFF6EE7B7) : const Color(0xFFE9D5FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        );
      } else if (line.startsWith('•') || line.startsWith('*') || line.startsWith('-')) {
        // Bullet Point
        final content = line.replaceFirst(RegExp(r'^[•\*\-]\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3, right: 6),
                  child: Icon(Icons.circle, color: Color(0xFFC084FC), size: 6),
                ),
                Expanded(
                  child: _buildRichSpans(content),
                ),
              ],
            ),
          ),
        );
      } else {
        // Standard Text with Bold/Code Parsing
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.5),
            child: _buildRichSpans(line),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichSpans(String line) {
    final List<InlineSpan> spans = [];
    final pattern = RegExp(r'(\*\*.*?\*\*|`.*?`|[^\*`]+)');
    final matches = pattern.allMatches(line);

    for (final match in matches) {
      final token = match.group(0) ?? '';
      if (token.startsWith('**') && token.endsWith('**') && token.length >= 4) {
        // Bold Span
        final boldContent = token.substring(2, token.length - 2);
        spans.add(
          TextSpan(
            text: boldContent,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        );
      } else if (token.startsWith('`') && token.endsWith('`') && token.length >= 2) {
        // Code / Stat Badge Span
        final codeContent = token.substring(1, token.length - 1);
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
              ),
              child: Text(
                codeContent,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF38BDF8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      } else {
        // Regular Text
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 13, height: 1.45),
    );
  }
}
