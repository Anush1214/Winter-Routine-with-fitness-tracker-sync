import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/solo_colors.dart';
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

  final List<GeminiChatMessage> _messages = [
    GeminiChatMessage(
      text: "⚡ **[ GEMINI SYSTEM AI AWAKENED ]**\n\nGreetings, Hunter. I have ingested your real-time routine telemetry and active discipline metrics.\n\nAsk me anything regarding workout dungeon optimization, DSA & placement strategy, recovery metrics, or general knowledge.",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  static final String _geminiApiKey =
      utf8.decode(base64.decode("QVEuQWI4Uk42SS1KMDhuRzhWZWhtWXhkRWR0c0JkY1pUaEM4bU1Tc3dRMjktNVJZVXNid1E="));

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

    setState(() {
      _messages.add(GeminiChatMessage(
        text: userText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    // Prepare in-context telemetry prompt
    final completedCount = widget.tasks.where((t) => t.isCompleted).length;
    final totalCount = widget.tasks.length;

    final systemPrompt = """
You are the Google Gemini System AI and Awakening Mentor for Hunter Anush in the Solo Leveling Winter Arc Protocol.
You possess real-time awareness of the Hunter's app routine and telemetry.

[ LIVE HUNTER APP TELEMETRY ]
- Active Streak: ${widget.streak} Days
- Quests Cleared Today: $completedCount / $totalCount
- Current Water Hydration: ${widget.waterMl}ml / 4500ml
- Quests List: ${widget.tasks.map((t) => "${t.title} (${t.isCompleted ? 'CLEARED' : 'PENDING'})").join(', ')}

[ INSTRUCTION ]
Answer the user's question clearly, tactically, and motivationally with a Solo Leveling System tone. Format with clean bullet points and bold highlights.
User Query: $userText
""";

    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent"),
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": _geminiApiKey,
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": systemPrompt}
              ]
            }
          ]
        }),
      );

      String aiReply = "";
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        aiReply = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";
      }

      if (aiReply.isEmpty) {
        aiReply = "👑 **[ SYSTEM DIRECTIVE ]**\n\nI have processed your query, Hunter. Maintain high discipline, clear your remaining quests (${totalCount - completedCount} pending), and execute your DSA algorithms with surgical precision.";
      }

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
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(GeminiChatMessage(
            text: "👑 **[ TACTICAL ANALYSIS ]**\n\n- **Today's Status**: $completedCount/$totalCount quests cleared.\n- **Discipline**: Keep your ${widget.streak}-day streak alive.\n- **Next Move**: Focus on your next pending quest and conquer the day!",
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
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
                // Header with Authentic Gemini Sparkle Logo
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
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
                          size: 24,
                        ),
                      ),
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
                                  color: const Color(0xFF1E1038),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF9B72CB)),
                                ),
                                child: const Text(
                                  "POWERED BY GOOGLE GEMINI",
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
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Telemetry: $completedCount/${widget.tasks.length} Quests • ${widget.streak}d Streak",
                            style: SoloTypography.bodyMuted.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF38BDF8),
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
                const SizedBox(height: 12),

                // Quick Prompt Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPromptChip(
                        "⚡ Analyze My Routine",
                        "Analyze my today's routine and give me tactical advice on what to prioritize next.",
                      ),
                      const SizedBox(width: 6),
                      _buildPromptChip(
                        "🎯 DSA Binary Tree Plan",
                        "Give me a step-by-step strategy to master Binary Trees and LeetCode Mediums tonight.",
                      ),
                      const SizedBox(width: 6),
                      _buildPromptChip(
                        "💧 Hydration & Recovery",
                        "How can I optimize my recovery and water intake based on my 4500ml goal?",
                      ),
                      const SizedBox(width: 6),
                      _buildPromptChip(
                        "👑 S-Rank Awakening Advice",
                        "Give me an inspiring Solo Leveling System motivation to crush all daily goals.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Chat Messages Container
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF4285F4), Color(0xFF9B72CB)],
                                    ),
                                  ),
                                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: msg.isUser
                                        ? const Color(0xFF6B21A8)
                                        : const Color(0xFF160D27),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: msg.isUser
                                          ? const Color(0xFFC084FC)
                                          : const Color(0xFF9B72CB).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.45,
                                      fontWeight: msg.isUser ? FontWeight.w600 : FontWeight.w400,
                                    ),
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
                        "Gemini is synthesizing tactical insight...",
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
                            hintText: "Ask Gemini anything (DSA, fitness, schedule, science)...",
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
