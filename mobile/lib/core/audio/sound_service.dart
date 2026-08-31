import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sound_service_stub.dart'
    if (dart.library.js) 'sound_service_web.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal() {
    _initSoundSetting();
  }

  // Default sound effects ON MUTE (false)
  bool _isSoundEnabled = false;
  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> _initSoundSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool('sound_fx_enabled');
      if (saved != null) {
        _isSoundEnabled = saved;
      }
    } catch (_) {}
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('sound_fx_enabled', _isSoundEnabled);
      });
    } catch (_) {}
    if (_isSoundEnabled) {
      playRobotClick();
    }
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('sound_fx_enabled', _isSoundEnabled);
      });
    } catch (_) {}
  }

  /// Synthesize character voice dialogue with anime audio clips
  void speakCharacter({
    required String text,
    required bool isJapanese,
    required bool isJinwoo,
    int clipIndex = 1,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) {
    if (!_isSoundEnabled) return;
    playRobotClick();
    if (onStart != null) onStart();

    SoundServicePlatform.instance.speakCharacter(
      text: text,
      isJapanese: isJapanese,
      isJinwoo: isJinwoo,
      clipIndex: clipIndex,
    );
  }

  /// 1. Custom Click Sound (`mixkit-select-click-1109.wav`)
  void playClick() {
    if (!_isSoundEnabled) return;
    SoundServicePlatform.instance.playLocalAudio(
      webPath: 'sounds/click.wav',
      assetPath: 'sounds/click.wav',
      fallbackTone: 180,
    );
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  /// 2. Custom Win / Quest Complete Sound (`mixkit-quick-win-video-game-notification-269.wav`)
  void playVictory() {
    if (!_isSoundEnabled) return;
    SoundServicePlatform.instance.playLocalAudio(
      webPath: 'sounds/win.wav',
      assetPath: 'sounds/win.wav',
      fallbackTone: 440,
    );
    HapticFeedback.mediumImpact();
  }

  /// 3. Custom Water Drop Sound (`mixkit-water-drop-video-game-sound-234.wav`)
  void playWaterDrop() {
    if (!_isSoundEnabled) return;
    SoundServicePlatform.instance.playLocalAudio(
      webPath: 'sounds/water.wav',
      assetPath: 'sounds/water.wav',
      fallbackTone: 580,
    );
    HapticFeedback.selectionClick();
  }

  /// 4. Level Up / Awakening Sound
  void playLevelUp() {
    if (!_isSoundEnabled) return;
    SoundServicePlatform.instance.playLocalAudio(
      webPath: 'sounds/levelup.wav',
      assetPath: 'sounds/levelup.wav',
      fallbackTone: 880,
    );
    HapticFeedback.heavyImpact();
  }

  /// 5. Chime Sound
  void playChime() {
    if (!_isSoundEnabled) return;
    SoundServicePlatform.instance.playLocalAudio(
      webPath: 'sounds/chime.wav',
      assetPath: 'sounds/chime.wav',
      fallbackTone: 660,
    );
    HapticFeedback.lightImpact();
  }

  /// 6. Robot / System HUD Click
  void playRobotClick() {
    if (!_isSoundEnabled) return;
    SoundServicePlatform.instance.playLocalAudio(
      webPath: 'sounds/click.wav',
      assetPath: 'sounds/click.wav',
      fallbackTone: 320,
    );
  }
}
