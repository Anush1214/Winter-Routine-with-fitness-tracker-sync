import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundServicePlatform {
  static final SoundServicePlatform instance = SoundServicePlatform._internal();
  factory SoundServicePlatform() => instance;
  SoundServicePlatform._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  void playLocalAudio({required String webPath, required String assetPath, required double fallbackTone}) {
    try {
      _audioPlayer.stop();
      _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Audio play error on native: $e");
    }
  }

  void speakCharacter({
    required String text,
    required bool isJapanese,
    required bool isJinwoo,
    int clipIndex = 1,
  }) {
    try {
      final clipPath = 'audio/sung_jinwoo_voice$clipIndex.mp3';
      _audioPlayer.stop();
      _audioPlayer.play(AssetSource(clipPath));
    } catch (e) {
      debugPrint("Voice clip play error on native: $e");
    }
  }
}
