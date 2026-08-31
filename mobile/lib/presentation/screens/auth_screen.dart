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
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = "Please provide email and password.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    SoundService().playChime();

    try {
      if (_isSignUp) {
        await AuthService().signUpWithEmail(email, password, name);
      } else {
        await AuthService().signInWithEmail(email, password);
      }
    } catch (e) {
      setState(() => _errorMsg = "Authentication failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guestLogin() async {
    setState(() => _isLoading = true);
    SoundService().playClick();
    await AuthService().signInAsGuest();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloColors.obsidianVoid,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Glowing Crown Emblem
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0x7700F0FF), Color(0x330284C7), Color(0x2202050E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SoloColors.neonCyan, width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: SoloColors.neonCyan.withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_outlined, color: SoloColors.neonCyan, size: 34),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "SOLO LEVELING // SYSTEM",
                  style: SoloTypography.systemTag.copyWith(fontSize: 11, letterSpacing: 2.5),
                ),
                const SizedBox(height: 4),
                Text(
                  "WINTER ARC PROTOCOL",
                  style: SoloTypography.systemTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  "Identify your Hunter credentials to synchronize your daily quests.",
                  textAlign: TextAlign.center,
                  style: SoloTypography.bodyMuted.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 24),

                // Main Holographic Login Box
                HolographicFrame(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode Selector (Sign In / Sign Up)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isSignUp = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isSignUp ? const Color(0xFF042F2E) : SoloColors.obsidianVoid,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !_isSignUp ? SoloColors.neonCyan : SoloColors.textDim.withOpacity(0.3),
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
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isSignUp ? const Color(0xFF042F2E) : SoloColors.obsidianVoid,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _isSignUp ? SoloColors.neonCyan : SoloColors.textDim.withOpacity(0.3),
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
                      const SizedBox(height: 18),

                      if (_isSignUp) ...[
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: "HUNTER CODENAME",
                            labelStyle: SoloTypography.systemTag.copyWith(fontSize: 10),
                            hintText: "e.g., Jin-Woo",
                            hintStyle: SoloTypography.bodyMuted.copyWith(fontSize: 11),
                            filled: true,
                            fillColor: SoloColors.obsidianVoid,
                            prefixIcon: const Icon(Icons.person_outline, color: SoloColors.neonCyan, size: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: SoloColors.neonCyan.withOpacity(0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: SoloColors.neonCyan),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "PLAYER EMAIL IDENTIFIER",
                          labelStyle: SoloTypography.systemTag.copyWith(fontSize: 10),
                          hintText: "hunter@winterarc.com",
                          hintStyle: SoloTypography.bodyMuted.copyWith(fontSize: 11),
                          filled: true,
                          fillColor: SoloColors.obsidianVoid,
                          prefixIcon: const Icon(Icons.email_outlined, color: SoloColors.neonCyan, size: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: SoloColors.neonCyan.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: SoloColors.neonCyan),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: "SECRET SECURITY KEY",
                          labelStyle: SoloTypography.systemTag.copyWith(fontSize: 10),
                          hintText: "••••••••••••",
                          hintStyle: SoloTypography.bodyMuted.copyWith(fontSize: 11),
                          filled: true,
                          fillColor: SoloColors.obsidianVoid,
                          prefixIcon: const Icon(Icons.lock_outline, color: SoloColors.neonCyan, size: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: SoloColors.neonCyan.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: SoloColors.neonCyan),
                          ),
                        ),
                      ),

                      if (_errorMsg != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _errorMsg!,
                          style: SoloTypography.warningText.copyWith(fontSize: 11),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Submit Button
                      GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: SoloColors.buttonCyanGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: SoloColors.neonCyan.withOpacity(0.4),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: SoloColors.obsidianVoid, strokeWidth: 2),
                                  )
                                : Text(
                                    _isSignUp ? "INITIATE AWAKENING" : "ACCESS SYSTEM PROTOCOL",
                                    style: SoloTypography.systemTag.copyWith(
                                      color: SoloColors.obsidianVoid,
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
                  onTap: _isLoading ? null : _guestLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: SoloColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SoloColors.manaViolet.withOpacity(0.5)),
                    ),
                    child: Row(
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
    );
  }
}
