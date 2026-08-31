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

  Color _getRankColor(int streak) {
    if (streak >= 100) return const Color(0xFFFFD700);
    if (streak >= 75) return const Color(0xFFFF6B35);
    if (streak >= 50) return SoloColors.manaViolet;
    if (streak >= 30) return SoloColors.neonCyan;
    if (streak >= 14) return SoloColors.electricSky;
    return SoloColors.textMuted;
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
        return SoloColors.neonCyan;
      case 'email':
        return SoloColors.electricSky;
      case 'guest':
        return SoloColors.manaViolet;
      default:
        return SoloColors.textMuted;
    }
  }

  Future<void> _saveDisplayName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      await AuthService().updateDisplayName(newName);
      SoundService().playChime();
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hunter codename updated to: $newName'),
            backgroundColor: const Color(0xFF042F2E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: $e'),
            backgroundColor: SoloColors.penaltyCrimson,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        await AuthService().updatePhotoUrl(base64String);
        SoundService().playChime();
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: SoloColors.penaltyCrimson,
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        await AuthService().updatePhotoUrl(base64String);
        SoundService().playChime();
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: SoloColors.penaltyCrimson,
          ),
        );
      }
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
      {'name': 'Igris Bloodred', 'url': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=150&auto=format&fit=crop&q=80'},
      {'name': 'Beru Ant King', 'url': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&auto=format&fit=crop&q=80'},
      {'name': 'Grand Marshal', 'url': 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=150&auto=format&fit=crop&q=80'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF02050E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: SoloColors.neonCyan, width: 1.5),
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
                  style: SoloTypography.systemTitle.copyWith(fontSize: 14, color: SoloColors.neonCyan),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: SoloColors.textMuted, size: 18),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Device Gallery & Camera Upload Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickFromGallery();
                    },
                    icon: const Icon(Icons.photo_library, size: 16, color: SoloColors.neonCyan),
                    label: Text(
                      'DEVICE GALLERY',
                      style: SoloTypography.systemTag.copyWith(fontSize: 10, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B192C),
                      side: const BorderSide(color: SoloColors.neonCyan, width: 1.2),
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
                    icon: const Icon(Icons.camera_alt, size: 16, color: SoloColors.manaViolet),
                    label: Text(
                      'TAKE PHOTO',
                      style: SoloTypography.systemTag.copyWith(fontSize: 10, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B192C),
                      side: const BorderSide(color: SoloColors.manaViolet, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'OR SELECT SOLO LEVELING PRESET',
              style: SoloTypography.systemTag.copyWith(fontSize: 9, color: SoloColors.textMuted),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: presets.map((p) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await AuthService().updatePhotoUrl(p['url']!);
                    SoundService().playChime();
                    setState(() {});
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: SoloColors.neonCyan.withValues(alpha: 0.6), width: 1.5),
                          image: DecorationImage(
                            image: NetworkImage(p['url']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p['name']!.split(' ').first,
                        style: SoloTypography.systemTag.copyWith(fontSize: 9, color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: SoloColors.neonCyan.withValues(alpha: 0.4)),
        ),
        title: Text(
          'SYSTEM // SIGN OUT',
          style: SoloTypography.systemTag.copyWith(fontSize: 14, color: SoloColors.neonCyan),
        ),
        content: Text(
          'Are you sure you want to disconnect from the System? Your quest progress is saved.',
          style: SoloTypography.bodyMuted.copyWith(fontSize: 12, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: SoloTypography.systemTag.copyWith(fontSize: 10, color: SoloColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('SIGN OUT', style: SoloTypography.systemTag.copyWith(fontSize: 10, color: SoloColors.penaltyCrimson)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      SoundService().playClick();
      await AuthService().signOut();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SoloColors.penaltyCrimson),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: SoloColors.penaltyCrimson, size: 20),
            const SizedBox(width: 8),
            Text(
              'DANGER ZONE',
              style: SoloTypography.systemTag.copyWith(fontSize: 14, color: SoloColors.penaltyCrimson),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete your Hunter account and all associated data. This action cannot be undone.',
          style: SoloTypography.bodyMuted.copyWith(fontSize: 12, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: SoloTypography.systemTag.copyWith(fontSize: 10, color: SoloColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE ACCOUNT', style: SoloTypography.systemTag.copyWith(fontSize: 10, color: SoloColors.penaltyCrimson)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AuthService().deleteAccount();
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$e'),
              backgroundColor: SoloColors.penaltyCrimson,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: SoloColors.obsidianVoid,
        body: Center(child: CircularProgressIndicator(color: SoloColors.neonCyan)),
      );
    }

    final rankColor = _getRankColor(widget.streakDays);
    final rankTitle = _getRankTitle(widget.streakDays);

    return Scaffold(
      backgroundColor: SoloColors.obsidianVoid,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // ─── Top Nav Bar ─────────────────────────────
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
                        color: SoloColors.obsidianVoid,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: SoloColors.neonCyan.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: SoloColors.neonCyan, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'HUNTER PROFILE',
                      style: SoloTypography.systemTag.copyWith(fontSize: 14, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Profile Avatar & Identity ─────────────
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
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: SoloTypography.monoValue.copyWith(
                                fontSize: 36,
                                color: rankColor,
                              ),
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
                          border: Border.all(color: SoloColors.neonCyan, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: SoloColors.neonCyan.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: SoloColors.neonCyan, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Hunter Name (editable)
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: SoloColors.neonCyan),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: SoloColors.neonCyan),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _saveDisplayName,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF042F2E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: SoloColors.neonCyan),
                            ),
                            child: const Icon(Icons.check, color: SoloColors.neonCyan, size: 16),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            _nameController.text = user.displayName;
                            setState(() => _isEditing = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: SoloColors.obsidianVoid,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: SoloColors.textDim.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(Icons.close, color: SoloColors.textDim, size: 16),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.displayName,
                            style: SoloTypography.systemTitle.copyWith(fontSize: 20),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit, color: SoloColors.textDim.withValues(alpha: 0.5), size: 14),
                        ],
                      ),
                    ),
              const SizedBox(height: 6),

              Text(
                user.email,
                style: SoloTypography.bodyMuted.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 10),

              // Rank Badge
              HunterRankBadge(streakDays: widget.streakDays),
              const SizedBox(height: 4),
              Text(
                rankTitle,
                style: SoloTypography.systemTag.copyWith(fontSize: 10, color: rankColor),
              ),
              const SizedBox(height: 20),

              // ─── Info Cards ─────────────────────────────
              HolographicFrame(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: _getProviderIcon(user.provider),
                      iconColor: _getProviderColor(user.provider),
                      label: 'AUTH PROVIDER',
                      value: _getProviderLabel(user.provider),
                    ),
                    _divider(),
                    _buildInfoRow(
                      icon: Icons.fingerprint,
                      iconColor: SoloColors.neonCyan,
                      label: 'HUNTER UID',
                      value: user.uid.length > 20
                          ? '${user.uid.substring(0, 20)}...'
                          : user.uid,
                    ),
                    _divider(),
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: SoloColors.electricSky,
                      label: 'AWAKENED ON',
                      value: DateFormat('MMM d, yyyy • hh:mm a').format(user.createdAt),
                    ),
                    _divider(),
                    _buildInfoRow(
                      icon: Icons.local_fire_department,
                      iconColor: SoloColors.flameOrange,
                      label: 'ACTIVE STREAK',
                      value: '${widget.streakDays} DAYS',
                    ),
                    _divider(),
                    _buildInfoRow(
                      icon: user.isAnonymous ? Icons.visibility_off : Icons.verified_user,
                      iconColor: user.isAnonymous ? SoloColors.textMuted : Colors.green,
                      label: 'ACCOUNT TYPE',
                      value: user.isAnonymous ? 'ANONYMOUS GUEST' : 'VERIFIED HUNTER',
                    ),
                    if (AuthService().isFirebaseAvailable) ...[
                      _divider(),
                      _buildInfoRow(
                        icon: Icons.cloud_done,
                        iconColor: Colors.green,
                        label: 'FIREBASE STATUS',
                        value: 'CONNECTED',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── Sign Out Button ────────────────────────
              GestureDetector(
                onTap: _confirmSignOut,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SoloColors.neonCyan.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: SoloColors.neonCyan, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'SIGN OUT',
                        style: SoloTypography.systemTag.copyWith(
                          fontSize: 12,
                          color: SoloColors.neonCyan,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ─── Delete Account Button ──────────────────
              if (!user.isAnonymous)
                GestureDetector(
                  onTap: _confirmDeleteAccount,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: SoloColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SoloColors.penaltyCrimson.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever, color: SoloColors.penaltyCrimson.withValues(alpha: 0.7), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'DELETE ACCOUNT',
                          style: SoloTypography.systemTag.copyWith(
                            fontSize: 10,
                            color: SoloColors.penaltyCrimson.withValues(alpha: 0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: SoloTypography.systemTag.copyWith(
                    fontSize: 8,
                    color: SoloColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: SoloTypography.bodyMuted.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        color: SoloColors.neonCyan.withValues(alpha: 0.1),
        height: 1,
      );
}
