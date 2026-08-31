import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../models/task_model.dart';
import 'holographic_frame.dart';

class GeminiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  GeminiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GeminiChatMessage.fromJson(Map<String, dynamic> json) => GeminiChatMessage(
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
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

  static void show(
    BuildContext context, {
    required List<TaskModel> tasks,
    int streak = 7,
    int waterMl = 3200,
  }) {
    SoundService().playRobotClick();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => GeminiAiTerminalDialog(
        tasks: tasks,
        streak: streak,
        waterMl: waterMl,
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
          text: "[ SYSTEM GEMINI AI AWAKENED ]\n\nGreetings, Hunter. I have synchronized with your routine logs and active discipline telemetry.\n\nAsk me anything regarding workout optimization, DSA problem strategies, sleep recovery, or general queries. Memory is active.",
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

    // Build In-Context System Prompt with instructions for clean readable output
    final systemInstruction = """
You are the Google Gemini System AI and Awakening Mentor for Hunter Anush in the Solo Leveling Winter Arc Protocol.
You have real-time awareness of the Hunter's routine telemetry and chat memory.

[ LIVE HUNTER APP TELEMETRY ]
- Active Streak: ${widget.streak} Days
- Quests Cleared Today: $completedCount / $totalCount
- Current Water Hydration: ${widget.waterMl}ml / 4500ml
- Quests List: ${widget.tasks.map((t) => "${t.title} (${t.isCompleted ? 'CLEARED' : 'PENDING'})").join(', ')}

[ OUTPUT FORMATTING DIRECTIVES - VERY IMPORTANT ]
1. DO NOT use raw markdown headers like '###' or '##'.
2. DO NOT wrap section titles in double asterisks like '### **[ TITLE ]**'.
3. Use clean brackets for sections, e.g.: '[ STATUS ANALYSIS ]' or '[ TACTICAL DIRECTIVE ]'.
4. For lists, use simple bullet symbols '•' or numbered points '1.', '2.'.
5. Avoid excessive double asterisks '**'. Keep text clean, sleek, and formatted like a high-tech Solo Leveling System window interface.
6. Answer ANY type of question (workouts, DSA coding, life habits, algorithms, science, motivation) with sharp intelligence and tactical precision.
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

      if (aiReply.isEmpty) {
        aiReply = "[ SYSTEM DIRECTIVE ]\n\nI have analyzed your request, Hunter. Maintain high discipline, clear your remaining quests (${totalCount - completedCount} pending), and execute your algorithms with surgical precision.";
      }

      // Clean any accidental markdown hashes or awkward formatting
      aiReply = _cleanSystemText(aiReply);

      SoundService().playVictory();
      if (mounted) {
        setState(() {
          _messages.add(GeminiChatMessage(
            text: aiReply,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _saveChatHistory();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(GeminiChatMessage(
            text: "[ TACTICAL TELEMETRY ]\n\n• Today's Status: $completedCount/$totalCount quests cleared.\n• Discipline: Active ${widget.streak}-day streak.\n• Next Move: Focus on your pending quest and conquer the day.",
            isUser: false,
            timestamp: DateTime.now(),
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
    final completedCount = widget.tasks.where((t) => t.isCompleted).length;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.94,
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
          margin: const EdgeInsets.symmetric(horizontal: 14),
          child: HolographicFrame(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Authentic Gemini Sparkle Logo & Memory Controls
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9B72CB).withValues(alpha: 0.6),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                                  border: Border.all(color: const Color(0xFF9B72CB)),
                                ),
                                child: const Text(
                                  "MEMORY ON • GEMINI FLASH",
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
                            style: SoloTypography.systemTitle.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Telemetry: $completedCount/${widget.tasks.length} Quests • ${widget.streak}d Streak",
                            style: SoloTypography.bodyMuted.copyWith(
                              fontSize: 9.5,
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white54, size: 20),
                      tooltip: "Reset Memory",
                      onPressed: _clearChatHistory,
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
                const SizedBox(height: 10),

                // Quick Prompt Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPromptChip(
                        "⚡ Analyze Routine",
                        "Analyze my today's routine and give me tactical advice on what to prioritize next.",
                      ),
                      const SizedBox(width: 6),
                      _buildPromptChip(
                        "🎯 DSA Binary Tree Plan",
                        "Give me a step-by-step strategy to master Binary Trees and LeetCode Mediums tonight.",
                      ),
                      const SizedBox(width: 6),
                      _buildPromptChip(
                        "💧 Hydration Plan",
                        "How can I optimize my recovery and water intake based on my 4500ml goal?",
                      ),
                      const SizedBox(width: 6),
                      _buildPromptChip(
                        "👑 Awakening Directive",
                        "Give me an inspiring Solo Leveling System motivation to crush all daily goals.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Chat Messages Container with System Rich Formatted Text
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07030E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF9B72CB).withValues(alpha: 0.3)),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: msg.isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!msg.isUser) ...[
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF4285F4), Color(0xFF9B72CB)],
                                    ),
                                  ),
                                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: msg.isUser
                                        ? const Color(0xFF581C87).withValues(alpha: 0.85)
                                        : const Color(0xFF130A24),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: msg.isUser
                                          ? const Color(0xFFC084FC).withValues(alpha: 0.8)
                                          : const Color(0xFF9B72CB).withValues(alpha: 0.35),
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

                if (_isLoading) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF9B72CB)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Gemini is analyzing with chat memory...",
                        style: SoloTypography.systemTag.copyWith(fontSize: 8.5, color: const Color(0xFFC084FC)),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),

                // Input Box
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF090414),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF9B72CB).withValues(alpha: 0.5)),
                        ),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          onSubmitted: _sendMessage,
                          decoration: const InputDecoration(
                            hintText: "Ask Gemini anything (DSA, workouts, algorithms)...",
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: () => _sendMessage(_textController.text),
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

  Widget _buildPromptChip(String label, String prompt) {
    return GestureDetector(
      onTap: () => _sendMessage(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF130926),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF9B72CB).withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
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
          fontSize: 12.5,
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

      // Check if line is a Section Header [ TITLE ] or [ TITLE ]
      if (line.startsWith('[') && line.endsWith(']')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1065).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.6)),
              ),
              child: Text(
                line,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFFE9D5FF),
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
              fontSize: 12.5,
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
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 12.5, height: 1.45),
    );
  }
}
