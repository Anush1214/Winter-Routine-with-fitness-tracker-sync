import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sound_service_stub.dart'
    if (dart.library.js) 'sound_service_web.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    if (_isSoundEnabled) {
      playRobotClick();
    }
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
      fallbackTone: 320,
    );
    HapticFeedback.heavyImpact();
  }

  void playLevelUp() {
    playVictory();
  }

  /// 3. Custom Sci-Fi Robot Click Sound (`mixkit-sci-fi-interface-robot-click-901.wav`)
  void playRobotClick() {
    if (!_isSoundEnabled) return;
    SoundServicePlatform.instance.playLocalAudio(
      webPath: 'sounds/robot_click.wav',
      assetPath: 'sounds/robot_click.wav',
      fallbackTone: 240,
    );
    HapticFeedback.mediumImpact();
  }

  void playChime() {
    playRobotClick();
  }

  void playWaterDrop() {
    playClick();
  }

  void playPenaltyWarning() {
    if (!_isSoundEnabled) return;
    SoundServicePlatform.instance.playLocalAudio(
      webPath: 'sounds/robot_click.wav',
      assetPath: 'sounds/robot_click.wav',
      fallbackTone: 90,
    );
    HapticFeedback.vibrate();
  }
}
