import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../features/progress/domain/learning_data.dart';

enum FeedbackCue {
  correct(HapticFeedback.selectionClick),
  incorrect(HapticFeedback.mediumImpact),
  hint(HapticFeedback.selectionClick),
  codePassed(HapticFeedback.lightImpact),
  complete(HapticFeedback.mediumImpact),
  reward(HapticFeedback.lightImpact),
  purchase(HapticFeedback.lightImpact),
  achievement(HapticFeedback.heavyImpact),
  level(HapticFeedback.heavyImpact);

  final Future<void> Function() haptic;
  const FeedbackCue(this.haptic);
}

class FeedbackService {
  final Map<FeedbackCue, Future<AudioPlayer>> players = {};
  bool disposed = false;

  Future<void> play(FeedbackCue cue, Preferences preferences) async {
    if (disposed) return;
    try {
      if (preferences.haptics) await cue.haptic();
      if (!preferences.sound || preferences.volume == 0) return;
      final player = await players.putIfAbsent(cue, () => load(cue));
      if (disposed) return;
      await player.setVolume(preferences.volume);
      await player.seek(Duration.zero);
      await player.resume();
    } on Exception catch (error) {
      debugPrint('Audio feedback unavailable: $error');
    }
  }

  Future<AudioPlayer> load(FeedbackCue cue) async {
    final player = AudioPlayer();
    try {
      await player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource('audio/${cue.name}.wav'));
      return player;
    } on Exception {
      players.remove(cue);
      await player.dispose();
      rethrow;
    }
  }

  Future<List<AudioPlayer>> loaded() async => [
    for (final pending in players.values.toList())
      ?await pending.then<AudioPlayer?>(
        (player) => player,
        onError: (Object error) => null,
      ),
  ];

  Future<void> stop() async {
    for (final player in await loaded()) {
      await player.stop();
    }
  }

  Future<void> dispose() async {
    disposed = true;
    final active = await loaded();
    players.clear();
    await Future.wait(active.map((player) => player.dispose()));
  }
}
