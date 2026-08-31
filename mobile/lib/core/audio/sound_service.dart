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

  /// Synthesize character voice dialogue with anime audio clips and Web Speech API
  void speakCharacter({
    required String text,
    required bool isJapanese,
    required bool isJinwoo,
    int clipIndex = 1,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) {
    if (!_isSoundEnabled) return;
    playDemonicExtraction();
    if (onStart != null) onStart();

    if (kIsWeb) {
      try {
        final cleanText = text.replaceAll(RegExp(r'''[「」“”"']'''), '');
        final lang = isJapanese ? 'ja-JP' : 'en-US';
        final pitch = isJinwoo ? 0.82 : 1.15;
        final rate = isJinwoo ? 0.90 : 1.02;
        final clipUrl = '/audio/sung_jinwoo_voice$clipIndex.mp3';

        js.context.callMethod('eval', [
          '''
          (function() {
            var isJp = $isJapanese;
            var isJin = $isJinwoo;

            if (isJp && isJin && typeof Audio !== 'undefined') {
              try {
                var audio = new Audio("$clipUrl");
                audio.volume = 0.9;
                audio.onended = function() {
                  // Fallback completion
                };
                audio.play().catch(function() {
                  _fallbackSpeech();
                });
                return;
              } catch(e) {
                _fallbackSpeech();
              }
            } else {
              _fallbackSpeech();
            }

            function _fallbackSpeech() {
              if ('speechSynthesis' in window) {
                window.speechSynthesis.cancel();
                var msg = new SpeechSynthesisUtterance(${jsonEncode(cleanText)});
                msg.lang = "$lang";
                msg.pitch = $pitch;
                msg.rate = $rate;
                window.speechSynthesis.speak(msg);
              }
            }
          })();
          '''
        ]);
      } catch (e) {
        debugPrint("Speech synthesis error: $e");
      }
    }
  }

  /// Demonic Shadow Click - Deep Sub-Bass & Mana Resonance
  void playClick() {
    if (!_isSoundEnabled) return;
    _playDemonicSubTone(startFreq: 180, endFreq: 45, duration: 0.12, type: 'sawtooth');
    HapticFeedback.lightImpact();
  }

  /// Demonic Mana Chime - Sharp Shadow Pulse
  void playChime() {
    if (!_isSoundEnabled) return;
    _playDemonicSubTone(startFreq: 240, endFreq: 60, duration: 0.18, type: 'triangle');
    HapticFeedback.mediumImpact();
  }

  /// Demonic Water Mana Drop - Resonant Dark Hydration
  void playWaterDrop() {
    if (!_isSoundEnabled) return;
    _playDemonicSubTone(startFreq: 380, endFreq: 90, duration: 0.15, type: 'sine');
    HapticFeedback.selectionClick();
  }

  /// Demonic Shadow Extraction (Quest Checked / Objective Succeeded)
  void playVictory() {
    if (!_isSoundEnabled) return;
    _playDemonicAriseChord();
    HapticFeedback.heavyImpact();
  }

  /// Demonic Awakening / Arise (Level Up & S-Rank Promotion)
  void playLevelUp() {
    if (!_isSoundEnabled) return;
    _playDemonicAriseChord();
    HapticFeedback.heavyImpact();
  }

  /// Demonic Penalty Warhorn (Warning & Danger Zone)
  void playPenaltyWarning() {
    if (!_isSoundEnabled) return;
    _playDemonicWarhorn();
    HapticFeedback.vibrate();
  }

  /// Custom Demonic Shadow Frequency Synth (Web Audio API)
  void _playDemonicSubTone({
    required double startFreq,
    required double endFreq,
    required double duration,
    required String type,
  }) {
    if (kIsWeb) {
      try {
        js.context.callMethod('eval', [
          '''
          try {
            var ctx = new (window.AudioContext || window.webkitAudioContext)();
            var osc = ctx.createOscillator();
            var subOsc = ctx.createOscillator();
            var gain = ctx.createGain();
            var filter = ctx.createBiquadFilter();

            filter.type = 'lowpass';
            filter.frequency.setValueAtTime(800, ctx.currentTime);
            filter.frequency.exponentialRampToValueAtTime(120, ctx.currentTime + $duration);

            osc.type = '$type';
            osc.frequency.setValueAtTime($startFreq, ctx.currentTime);
            osc.frequency.exponentialRampToValueAtTime($endFreq, ctx.currentTime + $duration);

            subOsc.type = 'sine';
            subOsc.frequency.setValueAtTime(${startFreq / 2}, ctx.currentTime);
            subOsc.frequency.exponentialRampToValueAtTime(${endFreq / 2}, ctx.currentTime + $duration);

            gain.gain.setValueAtTime(0.28, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + $duration);

            osc.connect(filter);
            subOsc.connect(filter);
            filter.connect(gain);
            gain.connect(ctx.destination);

            osc.start();
            subOsc.start();
            osc.stop(ctx.currentTime + $duration);
            subOsc.stop(ctx.currentTime + $duration);
          } catch(e){}
          '''
        ]);
      } catch (_) {}
    }
  }

  /// Demonic "ARISE" Multi-Harmonic Shadow Chord Synth
  void _playDemonicAriseChord() {
    if (kIsWeb) {
      try {
        js.context.callMethod('eval', [
          '''
          try {
            var ctx = new (window.AudioContext || window.webkitAudioContext)();
            var freqs = [65.41, 130.81, 196.00, 392.00];
            var duration = 0.55;

            freqs.forEach(function(f, i) {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              var filter = ctx.createBiquadFilter();

              filter.type = 'lowpass';
              filter.frequency.setValueAtTime(1200, ctx.currentTime);
              filter.frequency.exponentialRampToValueAtTime(200, ctx.currentTime + duration);

              osc.type = i === 0 ? 'sawtooth' : 'triangle';
              osc.frequency.setValueAtTime(f, ctx.currentTime);
              osc.frequency.exponentialRampToValueAtTime(f * 1.5, ctx.currentTime + duration);

              gain.gain.setValueAtTime(0.18 / (i + 1), ctx.currentTime);
              gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);

              osc.connect(filter);
              filter.connect(gain);
              gain.connect(ctx.destination);

              osc.start();
              osc.stop(ctx.currentTime + duration);
            });
          } catch(e){}
          '''
        ]);
      } catch (_) {}
    }
  }

  /// Demonic Low Warhorn Rumble
  void _playDemonicWarhorn() {
    if (kIsWeb) {
      try {
        js.context.callMethod('eval', [
          '''
          try {
            var ctx = new (window.AudioContext || window.webkitAudioContext)();
            var osc1 = ctx.createOscillator();
            var osc2 = ctx.createOscillator();
            var gain = ctx.createGain();
            var duration = 0.6;

            osc1.type = 'sawtooth';
            osc1.frequency.setValueAtTime(55, ctx.currentTime);
            osc2.type = 'sawtooth';
            osc2.frequency.setValueAtTime(58.5, ctx.currentTime); // Ominous detune beat

            gain.gain.setValueAtTime(0.25, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);

            osc1.connect(gain);
            osc2.connect(gain);
            gain.connect(ctx.destination);

            osc1.start();
            osc2.start();
            osc1.stop(ctx.currentTime + duration);
            osc2.stop(ctx.currentTime + duration);
          } catch(e){}
          '''
        ]);
      } catch (_) {}
    }
  }

  void playDemonicExtraction() {
    _playDemonicSubTone(startFreq: 220, endFreq: 55, duration: 0.25, type: 'sawtooth');
  }
}
