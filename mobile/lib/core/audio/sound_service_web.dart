import 'dart:convert';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class SoundServicePlatform {
  static final SoundServicePlatform instance = SoundServicePlatform._internal();
  factory SoundServicePlatform() => instance;
  SoundServicePlatform._internal();

  void playLocalAudio({required String webPath, required String assetPath, required double fallbackTone}) {
    try {
      js.context.callMethod('eval', [
        '''
        (function() {
          try {
            var a = new Audio("$webPath");
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

  void speakCharacter({
    required String text,
    required bool isJapanese,
    required bool isJinwoo,
    int clipIndex = 1,
  }) {
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
      debugPrint("Speech synthesis error on web: $e");
    }
  }
}
