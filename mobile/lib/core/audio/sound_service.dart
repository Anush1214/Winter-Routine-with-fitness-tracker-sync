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
    if (_isSoundEnabled) {
      playRobotClick();
    }
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
    playRobotClick();
    if (onStart != null) onStart();

    if (kIsWeb) {
      try {
        final cleanText = text.replaceAll(RegExp(r'''[「」“”"']'''), '');
        final lang = isJapanese ? 'ja-JP' : 'en-US';
        final pitch = isJinwoo ? 0.82 : 1.15;
        final rate = isJinwoo ? 0.90 : 1.02;
        final clipUrl = 'audio/sung_jinwoo_voice$clipIndex.mp3';

        js.context.callMethod('eval', [
          '''
          (function() {
            var isJp = $isJapanese;
            var isJin = $isJinwoo;
            var cleanText = ${jsonEncode(cleanText)};
            var lang = "$lang";
            var pitch = $pitch;
            var rate = $rate;

            function _tryAudio() {
              if (isJp && isJin && typeof Audio !== 'undefined') {
                try {
                  var audio = new Audio("$clipUrl");
                  audio.volume = 0.95;
                  var played = audio.play();
                  if (played !== undefined) {
                    played.catch(function(err) {
                      console.log("Audio clip play fallback to speech:", err);
                      _fallbackSpeech();
                    });
                  }
                  return;
                } catch(e) {
                  _fallbackSpeech();
                }
              } else {
                _fallbackSpeech();
              }
            }

            function _fallbackSpeech() {
              if ('speechSynthesis' in window) {
                window.speechSynthesis.cancel();
                var msg = new SpeechSynthesisUtterance(cleanText);
                msg.lang = lang;
                msg.pitch = pitch;
                msg.rate = rate;

                // Pick Japanese voice if available
                if (isJp) {
                  var voices = window.speechSynthesis.getVoices();
                  for (var i = 0; i < voices.length; i++) {
                    if (voices[i].lang && voices[i].lang.indexOf('ja') !== -1) {
                      msg.voice = voices[i];
                      break;
                    }
                  }
                }
                window.speechSynthesis.speak(msg);
              }
            }

            _tryAudio();
          })();
          '''
        ]);
      } catch (e) {
        debugPrint("Speech synthesis error: $e");
      }
    }
  }

  /// 1. Custom Click Sound (`mixkit-select-click-1109.wav`)
  void playClick() {
    if (!_isSoundEnabled) return;
    _playLocalAudio(url: 'sounds/click.wav', fallbackTone: 180);
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  /// 2. Custom Win / Quest Complete Sound (`mixkit-quick-win-video-game-notification-269.wav`)
  void playVictory() {
    if (!_isSoundEnabled) return;
    _playLocalAudio(url: 'sounds/win.wav', fallbackTone: 320);
    HapticFeedback.heavyImpact();
  }

  void playLevelUp() {
    playVictory();
  }

  /// 3. Custom Sci-Fi Robot Click Sound (`mixkit-sci-fi-interface-robot-click-901.wav`)
  void playRobotClick() {
    if (!_isSoundEnabled) return;
    _playLocalAudio(url: 'sounds/robot_click.wav', fallbackTone: 240);
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
    _playLocalAudio(url: 'sounds/robot_click.wav', fallbackTone: 90);
    HapticFeedback.vibrate();
  }

  /// Play audio with HTML5 Audio element on Web, or fallback to Web Audio oscillator
  void _playLocalAudio({required String url, required double fallbackTone}) {
    if (kIsWeb) {
      try {
        js.context.callMethod('eval', [
          '''
          (function() {
            try {
              var a = new Audio("$url");
              a.volume = 0.85;
              var p = a.play();
              if (p !== undefined) {
                p.catch(function() { _synthTone(); });
              }
            } catch(e) {
              _synthTone();
            }

            function _synthTone() {
              try {
                var ctx = new (window.AudioContext || window.webkitAudioContext)();
                var osc = ctx.createOscillator();
                var gain = ctx.createGain();
                osc.type = 'triangle';
                osc.frequency.setValueAtTime($fallbackTone, ctx.currentTime);
                gain.gain.setValueAtTime(0.2, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.12);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start();
                osc.stop(ctx.currentTime + 0.12);
              } catch(e){}
            }
          })();
          '''
        ]);
      } catch (_) {}
    }
  }
}
