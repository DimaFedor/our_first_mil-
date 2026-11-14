import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../features/progress/domain/learning_data.dart';

enum FeedbackCue { correct, incorrect, complete, level, reward }

class FeedbackService {
  final AudioPlayer player = AudioPlayer();
  DateTime lastPlayed = DateTime.fromMillisecondsSinceEpoch(0);
  bool disposed = false;

  Future<void> play(FeedbackCue cue, Preferences preferences) async {
    if (disposed ||
        DateTime.now().difference(lastPlayed).inMilliseconds < 120) {
      return;
    }
    lastPlayed = DateTime.now();
    try {
      if (preferences.haptics) await HapticFeedback.lightImpact();
      if (!preferences.sound) return;
      await player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      if (disposed) return;
      await player.stop();
      await player.setVolume(preferences.volume);
      await player.play(AssetSource('audio/${cue.name}.wav'));
    } on Exception catch (error) {
      debugPrint('Audio feedback unavailable: $error');
    }
  }

  Future<void> stop() => player.stop();
  Future<void> dispose() async {
    disposed = true;
    await player.dispose();
  }
}
