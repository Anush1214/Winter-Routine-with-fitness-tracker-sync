import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../services/auth_service.dart';
import '../widgets/holographic_frame.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Per-button loading states
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _isGitHubLoading = false;
  bool _isGuestLoading = false;
  bool _obscurePassword = true;

  bool get _anyLoading =>
      _isEmailLoading || _isGoogleLoading || _isGitHubLoading || _isGuestLoading;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: SoloColors.penaltyCrimson,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please provide both email and password.');
      return;
    }

    if (_isSignUp && password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isEmailLoading = true);
    SoundService().playChime();

    try {
      if (_isSignUp) {
        await AuthService().signUpWithEmail(email, password, name);
      } else {
        await AuthService().signInWithEmail(email, password);
      }
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _isGoogleLoading = true);
    SoundService().playChime();

    try {
      await AuthService().signInWithGoogle();
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _githubLogin() async {
    setState(() => _isGitHubLoading = true);
    SoundService().playChime();

    try {
      await AuthService().signInWithGitHub();
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _isGitHubLoading = false);
    }
  }

  Future<void> _guestLogin() async {
    setState(() => _isGuestLoading = true);
    SoundService().playClick();

    try {
      await AuthService().signInAsGuest();
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloColors.obsidianVoid,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                // Top Awakening Rune Crest
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC084FC), Color(0xFF7E22CE), Color(0xFF1E0B36)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFFC084FC), width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.flash_on, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  "⚡ AWAKEN",
                  style: SoloTypography.systemTag.copyWith(
                    fontSize: 12,
                    letterSpacing: 4,
                    color: const Color(0xFFC084FC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Awakening Hero Art Card
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2E1065),
                        Color(0xFF0F0826),
                        Color(0xFF090414),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Radial Glowing Aura
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Center(
                          child: Image.asset(
                            'assets/app_logo.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.remove_red_eye_rounded,
                                color: Color(0xFFC084FC),
                                size: 54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // "YOUR AWAKENING BEGINS NOW!" (Reference UI Title)
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE9D5FF), Color(0xFFC084FC)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    "YOUR AWAKENING\nBEGINS NOW!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Walk your path. Take action. Conquer. Become a legend!",
                  textAlign: TextAlign.center,
                  style: SoloTypography.bodyMuted.copyWith(
                    fontSize: 11.5,
                    color: const Color(0xFFA89BB9),
                  ),
                ),

                // Firebase status indicator
                if (!AuthService().isFirebaseAvailable) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SoloColors.penaltyCrimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SoloColors.penaltyCrimson.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber, color: SoloColors.penaltyCrimson, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Firebase not configured — only Guest mode available',
                            style: SoloTypography.bodyMuted.copyWith(
                              fontSize: 9,
                              color: SoloColors.penaltyCrimson,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Main Holographic Login Box
                HolographicFrame(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Social OAuth Providers (Google & GitHub)
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              onTap: _anyLoading ? null : _googleLogin,
                              isLoading: _isGoogleLoading,
                              icon: Icons.g_mobiledata,
                              iconColor: const Color(0xFFEA4335),
                              label: 'GMAIL / GOOGLE',
                              borderColor: const Color(0xFFEA4335).withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SocialButton(
                              onTap: _anyLoading ? null : _githubLogin,
                              isLoading: _isGitHubLoading,
                              icon: Icons.code,
                              iconColor: SoloColors.neonCyan,
                              label: 'GITHUB',
                              borderColor: SoloColors.neonCyan.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(child: Divider(color: SoloColors.textDim.withValues(alpha: 0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("OR USE EMAIL", style: SoloTypography.bodyMuted.copyWith(fontSize: 9)),
                          ),
                          Expanded(child: Divider(color: SoloColors.textDim.withValues(alpha: 0.3))),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Mode Selector (Sign In / Sign Up)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isSignUp = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: !_isSignUp ? const Color(0xFF042F2E) : SoloColors.obsidianVoid,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !_isSignUp ? SoloColors.neonCyan : SoloColors.textDim.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "HUNTER SIGN IN",
                                    style: SoloTypography.systemTag.copyWith(
                                      fontSize: 10,
                                      color: !_isSignUp ? SoloColors.neonCyan : SoloColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isSignUp = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _isSignUp ? const Color(0xFF042F2E) : SoloColors.obsidianVoid,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _isSignUp ? SoloColors.neonCyan : SoloColors.textDim.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "NEW AWAKENING",
                                    style: SoloTypography.systemTag.copyWith(
                                      fontSize: 10,
                                      color: _isSignUp ? SoloColors.neonCyan : SoloColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isSignUp) ...[
                        _buildTextField(
                          controller: _nameController,
                          label: "HUNTER CODENAME",
                          hint: "e.g., Jin-Woo",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                      ],

                      _buildTextField(
                        controller: _emailController,
                        label: "PLAYER EMAIL IDENTIFIER",
                        hint: "hunter@winterarc.com",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _passwordController,
                        label: "SECRET SECURITY KEY",
                        hint: "••••••••••••",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: SoloColors.textDim,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Submit Button
                      GestureDetector(
                        onTap: _anyLoading ? null : _submit,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: _anyLoading ? null : SoloColors.buttonCyanGradient,
                            color: _anyLoading ? const Color(0xFF1E293B) : null,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _anyLoading
                                ? null
                                : [
                                    BoxShadow(
                                      color: SoloColors.neonCyan.withValues(alpha: 0.4),
                                      blurRadius: 15,
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: _isEmailLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: SoloColors.neonCyan, strokeWidth: 2),
                                  )
                                : Text(
                                    _isSignUp ? "INITIATE AWAKENING" : "ACCESS SYSTEM PROTOCOL",
                                    style: SoloTypography.systemTag.copyWith(
                                      color: _anyLoading ? SoloColors.textMuted : SoloColors.obsidianVoid,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Guest Mode Trigger
                GestureDetector(
                  onTap: _anyLoading ? null : _guestLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: SoloColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SoloColors.manaViolet.withValues(alpha: 0.5)),
                    ),
                    child: _isGuestLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: SoloColors.manaViolet, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on, color: SoloColors.manaViolet, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "CONTINUE AS GUEST SHADOW HUNTER",
                                style: SoloTypography.systemTag.copyWith(
                                  color: SoloColors.manaViolet,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (_anyLoading)
        _SoloAwakeningOverlay(
          isSignUp: _isSignUp,
        ),
    ],
  ),
);
}

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: SoloTypography.systemTag.copyWith(fontSize: 10),
        hintText: hint,
        hintStyle: SoloTypography.bodyMuted.copyWith(fontSize: 11),
        filled: true,
        fillColor: SoloColors.obsidianVoid,
        prefixIcon: Icon(icon, color: SoloColors.neonCyan, size: 16),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: SoloColors.neonCyan.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: SoloColors.neonCyan),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: SoloColors.neonCyan.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

// Reusable Social OAuth Button Widget
class _SocialButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color borderColor;

  const _SocialButton({
    required this.onTap,
    required this.isLoading,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: iconColor, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: SoloTypography.systemTag.copyWith(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}

// Solo Leveling System Awakening Loading Screen Overlay
class _SoloAwakeningOverlay extends StatefulWidget {
  final bool isSignUp;

  const _SoloAwakeningOverlay({
    required this.isSignUp,
  });

  @override
  State<_SoloAwakeningOverlay> createState() => _SoloAwakeningOverlayState();
}

class _SoloAwakeningOverlayState extends State<_SoloAwakeningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 6.28318).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: SoloColors.obsidianVoid.withValues(alpha: 0.92),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Shadow Monarch Rune Crest
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0x9900F0FF),
                            Color(0x448B5CF6),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SoloColors.neonCyan.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: SoloColors.manaViolet.withValues(alpha: 0.4),
                            blurRadius: 45,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating outer rune ring
                          Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: SoloColors.neonCyan.withValues(alpha: 0.6),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Center App Logo
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/app_logo.jpg',
                              width: 58,
                              height: 58,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.shield_outlined,
                                color: SoloColors.neonCyan,
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // System Awakening Holographic Dialog Box
              HolographicFrame(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, color: SoloColors.neonCyan, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.isSignUp
                              ? "[ SYSTEM : NEW AWAKENING ENGAGED ]"
                              : "[ SYSTEM : HUNTER IDENTIFICATION ]",
                          style: SoloTypography.systemTag.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: SoloColors.neonCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.isSignUp
                          ? "ESTABLISHING SHADOW MONARCH SOUL LINK..."
                          : "SYNCHRONIZING WITH SYSTEM DUNGEON PROTOCOL...",
                      textAlign: TextAlign.center,
                      style: SoloTypography.systemTitle.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 14),

                    // Glowing Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const SizedBox(
                        height: 4,
                        width: 200,
                        child: LinearProgressIndicator(
                          backgroundColor: Color(0xFF0F172A),
                          valueColor: AlwaysStoppedAnimation<Color>(SoloColors.neonCyan),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "COMMAND: 「 A R I S E 」",
                      style: SoloTypography.systemTag.copyWith(
                        fontSize: 9,
                        letterSpacing: 3.0,
                        color: SoloColors.electricSky,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

