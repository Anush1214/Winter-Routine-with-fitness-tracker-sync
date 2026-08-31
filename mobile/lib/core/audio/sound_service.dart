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
    HapticFeedback.lightImpact();
  }

  void playChime() {
    HapticFeedback.mediumImpact();
  }

  void playWaterDrop() {
    HapticFeedback.selectionClick();
  }

  void playVictory() {
    HapticFeedback.heavyImpact();
  }

  void playPenaltyWarning() {
    HapticFeedback.vibrate();
  }
}
