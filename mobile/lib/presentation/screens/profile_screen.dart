import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../services/auth_service.dart';
import '../widgets/holographic_frame.dart';
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

  String _getRankBadge(int streak) {
    if (streak >= 100) return 'S-RANK';
    if (streak >= 75) return 'A-RANK';
    if (streak >= 50) return 'B-RANK';
    if (streak >= 30) return 'C-RANK';
    if (streak >= 14) return 'D-RANK';
    return 'E-RANK';
  }

  String _getProviderLabel(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'GOOGLE / GMAIL';
      case 'github':
        return 'GITHUB';
      case 'email':
        return 'EMAIL / PASSWORD';
      case 'guest':
        return 'GUEST SHADOW HUNTER';
      default:
        return provider.toUpperCase();
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
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF090414),
        body: SizedBox.shrink(),
      );
    }

    final isFemale = auth.isFemaleTheme;
    final themeColor = isFemale ? const Color(0xFFFBBF24) : const Color(0xFFC084FC);
    final themeShadow = isFemale ? const Color(0xFFF59E0B) : const Color(0xFFA855F7);
    final rankBadge = _getRankBadge(widget.streakDays);
    final rankTitle = _getRankTitle(widget.streakDays);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(user.createdAt);

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
                      style: SoloTypography.systemTag.copyWith(
                        fontSize: 14,
                        letterSpacing: 2,
                        color: themeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Avatar with Glow
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
                          color: themeShadow.withValues(alpha: glow),
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
                              style: SoloTypography.monoValue.copyWith(fontSize: 36, color: themeColor),
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
                            user.displayName,
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
              const SizedBox(height: 8),

              // Rank Badge and Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isFemale ? const Color(0xFF291B08) : const Color(0xFF1E1038),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  rankBadge,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rankTitle,
                style: SoloTypography.systemTag.copyWith(fontSize: 9.5, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // ─── EXACT ORIGINAL HUNTER DETAILS CARD ──────────────────
              HolographicFrame(
                padding: const EdgeInsets.all(16),
                borderColor: themeColor,
                child: Column(
                  children: [
                    // 1. AUTH PROVIDER
                    _buildOriginalProfileRow(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF450A0A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text("G", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      label: "AUTH PROVIDER",
                      value: _getProviderLabel(user.provider),
                    ),
                    const Divider(color: Color(0x22C084FC), height: 20),

                    // 2. HUNTER UID
                    _buildOriginalProfileRow(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isFemale ? const Color(0xFF451A03) : const Color(0xFF2E1065),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.fingerprint, color: themeColor, size: 18),
                      ),
                      label: "HUNTER UID",
                      value: user.uid.length > 20 ? "${user.uid.substring(0, 20)}..." : user.uid,
                    ),
                    const Divider(color: Color(0x22C084FC), height: 20),

                    // 3. AWAKENED ON
                    _buildOriginalProfileRow(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B4B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF818CF8), size: 16),
                      ),
                      label: "AWAKENED ON",
                      value: formattedDate,
                    ),
                    const Divider(color: Color(0x22C084FC), height: 20),

                    // 4. ACTIVE STREAK
                    _buildOriginalProfileRow(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF451A03),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_fire_department, color: Color(0xFFF97316), size: 18),
                      ),
                      label: "ACTIVE STREAK",
                      value: "${widget.streakDays} DAYS",
                    ),
                    const Divider(color: Color(0x22C084FC), height: 20),

                    // 5. ACCOUNT TYPE
                    _buildOriginalProfileRow(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF022C22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 18),
                      ),
                      label: "ACCOUNT TYPE",
                      value: "VERIFIED HUNTER",
                    ),
                    const Divider(color: Color(0x22C084FC), height: 20),

                    // 6. FIREBASE STATUS
                    _buildOriginalProfileRow(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF34D399), size: 18),
                      ),
                      label: "FIREBASE STATUS",
                      value: "CONNECTED",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    SoundService().playClick();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    await auth.signOut();
                  },
                  icon: Icon(Icons.logout_rounded, color: themeColor, size: 18),
                  label: Text(
                    "SIGN OUT",
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF130A24),
                    side: BorderSide(color: themeColor.withValues(alpha: 0.5), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Delete Account Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    SoundService().playClick();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    await auth.deleteAccount();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                  label: const Text(
                    "DELETE ACCOUNT",
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C0A0A),
                    side: const BorderSide(color: Color(0xFF7F1D1D), width: 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── 3 NEW ADDITIONS DIRECTLY BELOW (NO CHANGES TO ORIGINAL UI) ───

              // 1. AURA THEME & HUNTER GENDER SWITCHER
              HolographicFrame(
                padding: const EdgeInsets.all(16),
                borderColor: themeColor,
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
                              child: const Column(
                                children: [
                                  Text("👑", style: TextStyle(fontSize: 22)),
                                  SizedBox(height: 4),
                                  Text(
                                    "MALE (SHADOW MONARCH)",
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Sung Jin-Woo Purple",
                                    style: TextStyle(fontSize: 8.5, color: Color(0xFFC084FC)),
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
                              child: const Column(
                                children: [
                                  Text("⚔️", style: TextStyle(fontSize: 22)),
                                  SizedBox(height: 4),
                                  Text(
                                    "FEMALE (S-RANK DANCER)",
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Cha Hae-In Radiant Gold",
                                    style: TextStyle(fontSize: 8.5, color: Color(0xFFFDE047)),
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

              // 2. VOICE COMPANION & DIALOGUE CARD
              HolographicFrame(
                padding: const EdgeInsets.all(16),
                borderColor: themeColor,
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

              // 3. SOUND FX & MUTE TOGGLE
              HolographicFrame(
                padding: const EdgeInsets.all(16),
                borderColor: themeColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          SoundService().isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: themeColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SYSTEM SOUND FX",
                              style: SoloTypography.systemTitle.copyWith(fontSize: 12, color: Colors.white),
                            ),
                            Text(
                              SoundService().isSoundEnabled ? "Haptic cues & voice feedback active" : "Audio muted",
                              style: SoloTypography.bodyMuted.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: SoundService().isSoundEnabled,
                      activeColor: themeColor,
                      activeTrackColor: themeShadow.withValues(alpha: 0.4),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.white10,
                      onChanged: (val) {
                        SoundService().toggleSound();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginalProfileRow({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
