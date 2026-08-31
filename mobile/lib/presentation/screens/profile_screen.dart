import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../services/auth_service.dart';
import '../widgets/holographic_frame.dart';
import '../widgets/hunter_rank_badge.dart';
import '../widgets/sung_jinwoo_assistant_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final int streakDays;

  const ProfileScreen({super.key, this.streakDays = 0});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final user = AuthService().currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _glowController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _getRankTitle(int streak) {
    if (streak >= 100) return 'S-RANK NATIONAL LEVEL HUNTER';
    if (streak >= 75) return 'A-RANK ELITE HUNTER';
    if (streak >= 50) return 'B-RANK SPECIALIST';
    if (streak >= 30) return 'C-RANK HUNTER';
    if (streak >= 14) return 'D-RANK TRAINEE';
    return 'E-RANK INITIATE';
  }

  Color _getRankColor(int streak, bool isFemale) {
    if (isFemale) return const Color(0xFFFBBF24);
    if (streak >= 100) return const Color(0xFFFFD700);
    if (streak >= 75) return const Color(0xFFFF6B35);
    if (streak >= 50) return const Color(0xFFA855F7);
    if (streak >= 30) return const Color(0xFFC084FC);
    if (streak >= 14) return const Color(0xFFE9D5FF);
    return const Color(0xFFA89BB9);
  }

  String _getProviderLabel(String provider) {
    switch (provider) {
      case 'google':
        return 'GOOGLE / GMAIL';
      case 'github':
        return 'GITHUB';
      case 'email':
        return 'EMAIL / PASSWORD';
      case 'guest':
        return 'GUEST (ANONYMOUS)';
      default:
        return provider.toUpperCase();
    }
  }

  IconData _getProviderIcon(String provider) {
    switch (provider) {
      case 'google':
        return Icons.g_mobiledata;
      case 'github':
        return Icons.code;
      case 'email':
        return Icons.email_outlined;
      case 'guest':
        return Icons.flash_on;
      default:
        return Icons.person;
    }
  }

  Color _getProviderColor(String provider) {
    switch (provider) {
      case 'google':
        return const Color(0xFFEA4335);
      case 'github':
        return const Color(0xFF38BDF8);
      case 'email':
        return const Color(0xFFC084FC);
      case 'guest':
        return const Color(0xFFFBBF24);
      default:
        return const Color(0xFFA89BB9);
    }
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      await AuthService().updateProfile(displayName: newName);
    }
    setState(() => _isEditing = false);
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        await AuthService().updateProfile(photoUrl: base64Image);
        SoundService().playVictory();
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error picking avatar: $e");
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        await AuthService().updateProfile(photoUrl: base64Image);
        SoundService().playVictory();
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error taking photo: $e");
    }
  }

  ImageProvider? _buildAvatarImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('data:image')) {
      try {
        final base64Data = photoUrl.split(',').last;
        return MemoryImage(base64Decode(base64Data));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(photoUrl);
  }

  void _showAvatarPicker() {
    SoundService().playClick();
    final presets = [
      {'name': 'Shadow Monarch', 'url': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=150&auto=format&fit=crop&q=80'},
      {'name': 'S-Rank Dancer', 'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80'},
      {'name': 'Igris Bloodred', 'url': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=150&auto=format&fit=crop&q=80'},
      {'name': 'Beru Ant King', 'url': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&auto=format&fit=crop&q=80'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF02050E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFFC084FC), width: 1.5),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CHANGE HUNTER AVATAR',
                  style: SoloTypography.systemTitle.copyWith(fontSize: 14, color: const Color(0xFFC084FC)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickFromGallery();
                    },
                    icon: const Icon(Icons.photo_library, size: 16, color: Color(0xFFC084FC)),
                    label: Text('DEVICE GALLERY', style: SoloTypography.systemTag.copyWith(fontSize: 10, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B192C),
                      side: const BorderSide(color: Color(0xFFC084FC), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickFromCamera();
                    },
                    icon: const Icon(Icons.camera_alt, size: 16, color: Color(0xFFA855F7)),
                    label: Text('TAKE PHOTO', style: SoloTypography.systemTag.copyWith(fontSize: 10, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B192C),
                      side: const BorderSide(color: Color(0xFFA855F7), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('OR SELECT PRESET', style: SoloTypography.systemTag.copyWith(fontSize: 9, color: Colors.white54)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: presets.map((p) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await AuthService().updateProfile(photoUrl: p['url']);
                    SoundService().playVictory();
                    setState(() {});
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(p['url']!),
                      ),
                      const SizedBox(height: 4),
                      Text(p['name']!, style: SoloTypography.systemTag.copyWith(fontSize: 8.5, color: Colors.white70)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _openCompanionAssistant() {
    SoundService().playLevelUp();
    SungJinwooAssistantDialog.show(
      context,
      tasks: const [],
      onTriggerAction: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF090414),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFC084FC))),
      );
    }

    final isFemale = auth.isFemaleTheme;
    final themeColor = isFemale ? const Color(0xFFFBBF24) : const Color(0xFFC084FC);
    final rankColor = _getRankColor(widget.streakDays, isFemale);
    final rankTitle = _getRankTitle(widget.streakDays);

    return Scaffold(
      backgroundColor: isFemale ? const Color(0xFF140B02) : const Color(0xFF090414),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Top Nav Bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      SoundService().playClick();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: themeColor.withValues(alpha: 0.4)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, color: themeColor, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'HUNTER PROFILE',
                      style: SoloTypography.systemTag.copyWith(fontSize: 14, letterSpacing: 2, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Avatar & Identity
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final glow = 0.2 + (_glowController.value * 0.4);
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: rankColor.withValues(alpha: glow),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFF1E293B),
                      backgroundImage: _buildAvatarImage(user.photoUrl),
                      child: user.photoUrl == null
                          ? Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                              style: SoloTypography.monoValue.copyWith(fontSize: 36, color: rankColor),
                            )
                          : null,
                    ),
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          shape: BoxShape.circle,
                          border: Border.all(color: themeColor, width: 1.5),
                        ),
                        child: Icon(Icons.camera_alt, color: themeColor, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Hunter Name
              _isEditing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          child: TextField(
                            controller: _nameController,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: SoloTypography.systemTitle.copyWith(fontSize: 18),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check, color: themeColor, size: 20),
                          onPressed: _saveName,
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.displayName.toUpperCase(),
                            style: SoloTypography.systemTitle.copyWith(fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit, color: themeColor.withValues(alpha: 0.7), size: 14),
                        ],
                      ),
                    ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: SoloTypography.bodyMuted.copyWith(fontSize: 11, color: Colors.white60),
              ),
              const SizedBox(height: 16),

              // ─── 1. GENDER & AURA THEME SELECTION ─────────────────
              HolographicFrame(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.theater_comedy_rounded, color: themeColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'AURA THEME & HUNTER GENDER',
                          style: SoloTypography.systemTitle.copyWith(fontSize: 13, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Male Persona
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              SoundService().playClick();
                              await auth.updateGender('male');
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: !isFemale ? const Color(0xFF581C87).withValues(alpha: 0.6) : const Color(0xFF0F0720),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !isFemale ? const Color(0xFFC084FC) : Colors.white24,
                                  width: !isFemale ? 1.8 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text("👑", style: TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "MALE (SHADOW MONARCH)",
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Sung Jin-Woo Purple",
                                    style: TextStyle(fontSize: 8.5, color: const Color(0xFFC084FC)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Female Persona
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              SoundService().playVictory();
                              await auth.updateGender('female');
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isFemale ? const Color(0xFF78350F).withValues(alpha: 0.6) : const Color(0xFF1E1005),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isFemale ? const Color(0xFFFBBF24) : Colors.white24,
                                  width: isFemale ? 1.8 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text("⚔️", style: TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "FEMALE (S-RANK DANCER)",
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Cha Hae-In Radiant Gold",
                                    style: TextStyle(fontSize: 8.5, color: const Color(0xFFFDE047)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── 2. COMPANION VOICE SETTINGS & DIALOGUE CARD ──────
              HolographicFrame(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.record_voice_over_rounded, color: themeColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'VOICE COMPANION & DIALOGUE',
                              style: SoloTypography.systemTitle.copyWith(fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: themeColor),
                          ),
                          child: const Text(
                            "DUAL JP/EN",
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Authentic anime voices for Sung Jin-Woo (Taito Ban / Aleks Le) and Cha Hae-In (Reina Ueda / Michelle Rojas) with golden-yellow subtitles.",
                      style: SoloTypography.bodyMuted.copyWith(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openCompanionAssistant,
                        icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          "OPEN COMPANION & TEST VOICES",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFemale ? const Color(0xFFD97706) : const Color(0xFF7E22CE),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── 3. HUNTER STATUS CARD ────────────────────────────
              HolographicFrame(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('CURRENT RANK', style: SoloTypography.systemTag.copyWith(fontSize: 10, color: Colors.white60)),
                        Text('DISCIPLINE STREAK', style: SoloTypography.systemTag.copyWith(fontSize: 10, color: Colors.white60)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rankTitle, style: SoloTypography.systemTitle.copyWith(fontSize: 13, color: rankColor)),
                        Text('${widget.streakDays} DAYS', style: SoloTypography.monoValue.copyWith(fontSize: 18, color: rankColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── 4. LOGOUT & ACCOUNT CONTROLS ─────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    SoundService().playClick();
                    await auth.signOut();
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 16),
                  label: const Text(
                    "LOG OUT HUNTER SESSION",
                    style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }
}
