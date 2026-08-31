import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
  }

  void playClick() {
    if (!_isSoundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  void playChime() {
    if (!_isSoundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  void playWaterDrop() {
    if (!_isSoundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  void playVictory() {
    if (!_isSoundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  void playLevelUp() {
    if (!_isSoundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  void playPenaltyWarning() {
    if (!_isSoundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
  }
}
