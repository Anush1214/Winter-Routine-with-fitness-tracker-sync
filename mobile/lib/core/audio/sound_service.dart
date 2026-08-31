import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
  }

  /// Synthesize real character voice using Web Speech API (Jin-Woo / Hinata)
  void speakCharacter({
    required String text,
    required bool isJapanese,
    required bool isJinwoo,
  }) {
    if (!_isSoundEnabled) return;
    playSynthTone(freq: isJinwoo ? 220 : 440, duration: 0.15);

    if (kIsWeb) {
      try {
        final cleanText = text.replaceAll(RegExp(r'''[「」“”"']'''), '');
        final lang = isJapanese ? 'ja-JP' : 'en-US';
        final pitch = isJinwoo ? 0.85 : 1.25;
        final rate = isJinwoo ? 0.95 : 1.05;

        js.context.callMethod('eval', [
          '''
          if ('speechSynthesis' in window) {
            window.speechSynthesis.cancel();
            var msg = new SpeechSynthesisUtterance(${jsonEncode(cleanText)});
            msg.lang = "$lang";
            msg.pitch = $pitch;
            msg.rate = $rate;
            window.speechSynthesis.speak(msg);
          }
          '''
        ]);
      } catch (e) {
        debugPrint("Speech synthesis error: $e");
      }
    }
  }

  /// Synthesize Sci-Fi Solo Leveling Tone using Web Audio Context
  void playSynthTone({double freq = 587.33, double duration = 0.2}) {
    if (!_isSoundEnabled) return;
    if (kIsWeb) {
      try {
        js.context.callMethod('eval', [
          '''
          try {
            var ctx = new (window.AudioContext || window.webkitAudioContext)();
            var osc = ctx.createOscillator();
            var gain = ctx.createGain();
            osc.type = 'triangle';
            osc.frequency.setValueAtTime($freq, ctx.currentTime);
            gain.gain.setValueAtTime(0.18, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + $duration);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start();
            osc.stop(ctx.currentTime + $duration);
          } catch(e){}
          '''
        ]);
      } catch (_) {}
    }
  }

  void playClick() {
    if (!_isSoundEnabled) return;
    playSynthTone(freq: 880, duration: 0.08);
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  void playChime() {
    if (!_isSoundEnabled) return;
    playSynthTone(freq: 587.33, duration: 0.18);
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  void playWaterDrop() {
    if (!_isSoundEnabled) return;
    playSynthTone(freq: 1046.50, duration: 0.12);
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  void playVictory() {
    if (!_isSoundEnabled) return;
    playSynthTone(freq: 523.25, duration: 0.3);
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  void playLevelUp() {
    if (!_isSoundEnabled) return;
    playSynthTone(freq: 659.25, duration: 0.35);
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  void playPenaltyWarning() {
    if (!_isSoundEnabled) return;
    playSynthTone(freq: 180, duration: 0.45);
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
  }
}
