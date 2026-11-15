import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const sampleRate = 44100;

typedef Composer = void Function(Float64List out);

/// Renders every feedback cue into assets/audio as 16-bit mono WAV.
void main() {
  final cues = <String, (double, double, Composer)>{
    'correct': (0.7, 0.5, composeCorrect),
    'incorrect': (0.6, 0.42, composeIncorrect),
    'hint': (0.9, 0.4, composeHint),
    'codePassed': (1.2, 0.6, composeCodePassed),
    'complete': (1.8, 0.7, composeComplete),
    'reward': (1.0, 0.6, composeReward),
    'purchase': (0.9, 0.85, composePurchase),
    'achievement': (2.0, 0.75, composeAchievement),
    'level': (2.6, 0.8, composeLevel),
  };
  for (final MapEntry(key: name, value: (seconds, peak, compose))
      in cues.entries) {
    final samples = Float64List((seconds * sampleRate).round());
    compose(samples);
    File(
      'assets/audio/$name.wav',
    ).writeAsBytesSync(encodeWav(master(samples, peak)));
    stdout.writeln('assets/audio/$name.wav');
  }
}

void composeCorrect(Float64List out) {
  marimba(out, 0, 81, 0.8);
  marimba(out, 0.07, 86, 0.9);
  glass(out, 0.07, 90, 0.12);
}

void composeIncorrect(Float64List out) {
  mutedTone(out, 0, 66, 0.8);
  mutedTone(out, 0.11, 62, 0.9);
}

void composeHint(Float64List out) {
  sweep(out, 0, 81, 86, 0.09, 0.5);
  bell(out, 0.08, 93, 0.18, decay: 0.35);
  sparkle(out, 0.1, 0.2, 3, 0.08, 11);
}

void composeCodePassed(Float64List out) {
  for (final (index, note) in [74, 78, 81, 86].indexed) {
    marimba(out, index * 0.06, note, 0.7 + index * 0.08);
  }
  bell(out, 0.18, 86, 0.25, decay: 0.5);
  sparkle(out, 0.2, 0.35, 5, 0.1, 23);
}

void composeComplete(Float64List out) {
  for (final (index, note) in [74, 78, 81].indexed) {
    marimba(out, index * 0.08, note, 0.75);
  }
  for (final note in [74, 78, 81, 86]) {
    bell(out, 0.26, note, 0.22, decay: 0.7);
  }
  pad(out, 0.24, 1.2, [62, 69, 74, 78], 0.06);
  sparkle(out, 0.3, 0.6, 7, 0.1, 37);
}

void composeReward(Float64List out) {
  bell(out, 0, 83, 0.45, decay: 0.45);
  bell(out, 0.09, 88, 0.55, decay: 0.6);
  sparkle(out, 0.12, 0.4, 6, 0.12, 41);
}

void composePurchase(Float64List out) {
  pluck(out, 0, 81, 0.7, 5);
  pluck(out, 0.05, 86, 0.8, 9);
  shimmer(out, 0.05, 0.25, 0.12);
  glass(out, 0.08, 93, 0.12);
}

void composeAchievement(Float64List out) {
  bell(out, 0, 81, 0.4, decay: 0.6);
  bell(out, 0, 88, 0.3, decay: 0.6);
  for (final (index, note) in [86, 88, 90, 93, 95, 98].indexed) {
    glass(out, 0.08 + index * 0.035, note, 0.16);
  }
  for (final note in [86, 90, 93]) {
    bell(out, 0.32, note, 0.24, decay: 0.8);
  }
  pad(out, 0.3, 1.3, [62, 69, 74, 78], 0.07);
  sparkle(out, 0.4, 0.8, 9, 0.09, 53);
}

void composeLevel(Float64List out) {
  for (final (index, note) in [74, 76, 78, 81, 83, 86].indexed) {
    marimba(out, index * 0.05, note, 0.6 + index * 0.05);
  }
  boom(out, 0.34, 50, 0.55);
  pad(out, 0.32, 1.8, [50, 62, 69, 74, 78], 0.08);
  for (final note in [86, 90, 93, 98]) {
    bell(out, 0.34, note, 0.2, decay: 0.9);
  }
  sparkle(out, 0.4, 1.1, 14, 0.09, 67);
}

double hz(num note) => 440 * pow(2, (note - 69) / 12).toDouble();

void addVoice(
  Float64List out,
  double at,
  double seconds,
  double Function(double time) wave,
) {
  final start = (at * sampleRate).round();
  final length = min((seconds * sampleRate).round(), out.length - start);
  for (var index = 0; index < length; index++) {
    out[start + index] += wave(index / sampleRate);
  }
}

void marimba(Float64List out, double at, int note, double gain) {
  final frequency = hz(note);
  final noise = Random(note);
  addVoice(
    out,
    at,
    2.5,
    (time) =>
        gain *
        min(1.0, time / 0.002) *
        (sin(2 * pi * frequency * time) * exp(-time / 0.32) +
            0.3 * sin(2 * pi * frequency * 3.93 * time) * exp(-time / 0.06) +
            0.07 * sin(2 * pi * frequency * 9.2 * time) * exp(-time / 0.02) +
            0.18 * (noise.nextDouble() * 2 - 1) * exp(-time / 0.0015)),
  );
}

void mutedTone(Float64List out, double at, int note, double gain) {
  final frequency = hz(note);
  addVoice(
    out,
    at,
    0.8,
    (time) =>
        gain *
        min(1.0, time / 0.004) *
        exp(-time / 0.1) *
        (sin(2 * pi * frequency * time) +
            0.15 * sin(4 * pi * frequency * time)),
  );
}

void bell(
  Float64List out,
  double at,
  int note,
  double gain, {
  required double decay,
}) {
  final frequency = hz(note);
  addVoice(
    out,
    at,
    decay * 7,
    (time) =>
        gain *
        min(1.0, time / 0.003) *
        exp(-time / decay) *
        (sin(
              2 * pi * frequency * time +
                  1.6 *
                      exp(-time / (decay * 0.3)) *
                      sin(4 * pi * frequency * time),
            ) +
            0.12 *
                sin(2 * pi * frequency * 2.76 * time) *
                exp(-time / (decay * 0.4))),
  );
}

void glass(Float64List out, double at, int note, double gain) {
  final frequency = hz(note);
  addVoice(
    out,
    at,
    1.4,
    (time) =>
        gain *
        min(1.0, time / 0.001) *
        exp(-time / 0.18) *
        (sin(2 * pi * frequency * time) + 0.2 * sin(4 * pi * frequency * time)),
  );
}

void sweep(
  Float64List out,
  double at,
  int from,
  int to,
  double glide,
  double gain,
) {
  var phase = 0.0;
  addVoice(out, at, 1.2, (time) {
    phase +=
        2 * pi * hz(from + (to - from) * min(1.0, time / glide)) / sampleRate;
    return gain *
        min(1.0, time / 0.005) *
        exp(-time / 0.16) *
        (sin(phase) + 0.1 * sin(2 * phase));
  });
}

void pad(
  Float64List out,
  double at,
  double seconds,
  List<int> notes,
  double gain,
) {
  for (final note in notes) {
    for (final detune in [-0.035, 0.035]) {
      final frequency = hz(note + detune);
      addVoice(
        out,
        at,
        seconds,
        (time) =>
            gain *
            min(1.0, time / 0.09) *
            min(1.0, max(0.0, seconds - time) / 0.5) *
            (sin(2 * pi * frequency * time) +
                0.2 * sin(4 * pi * frequency * time) +
                0.06 * sin(6 * pi * frequency * time)),
      );
    }
  }
}

void boom(Float64List out, double at, int note, double gain) {
  var phase = 0.0;
  addVoice(out, at, 1.5, (time) {
    phase += 2 * pi * hz(note) * (1 + 0.5 * exp(-time / 0.03)) / sampleRate;
    return gain * min(1.0, time / 0.004) * exp(-time / 0.22) * sin(phase);
  });
}

void pluck(Float64List out, double at, int note, double gain, int seed) {
  final noise = Random(seed);
  final period = (sampleRate / hz(note)).round();
  final line = Float64List.fromList([
    for (var index = 0; index < period; index++) noise.nextDouble() * 2 - 1,
  ]);
  var position = 0;
  addVoice(out, at, 1.0, (time) {
    final current = line[position];
    final next = line[(position + 1) % period];
    line[position] = 0.996 * 0.5 * (current + next);
    position = (position + 1) % period;
    return gain * current;
  });
}

void shimmer(Float64List out, double at, double seconds, double gain) {
  final noise = Random(3);
  var previous = 0.0;
  addVoice(out, at, seconds, (time) {
    final white = noise.nextDouble() * 2 - 1;
    final high = white - previous;
    previous = white;
    return gain * min(1.0, time / 0.01) * exp(-time / (seconds * 0.3)) * high;
  });
}

void sparkle(
  Float64List out,
  double at,
  double spread,
  int count,
  double gain,
  int seed,
) {
  final random = Random(seed);
  const notes = [86, 88, 90, 93, 95, 98, 100];
  for (var index = 0; index < count; index++) {
    glass(
      out,
      at + random.nextDouble() * spread,
      notes[random.nextInt(notes.length)],
      gain * (0.5 + random.nextDouble() * 0.5),
    );
  }
}

Float64List reverb(Float64List dry, double wet) {
  final tail = Float64List(dry.length);
  for (final delay in [1116, 1188, 1277, 1356]) {
    final line = Float64List(delay);
    var filtered = 0.0;
    for (var index = 0; index < dry.length; index++) {
      final delayed = line[index % delay];
      filtered = delayed * 0.75 + filtered * 0.25;
      line[index % delay] = dry[index] + filtered * 0.74;
      tail[index] += delayed / 4;
    }
  }
  for (final delay in [556, 441]) {
    final line = Float64List(delay);
    for (var index = 0; index < tail.length; index++) {
      final delayed = line[index % delay];
      final input = tail[index];
      tail[index] = delayed - input;
      line[index % delay] = input + delayed * 0.5;
    }
  }
  return Float64List.fromList([
    for (var index = 0; index < dry.length; index++)
      dry[index] + wet * tail[index],
  ]);
}

Float64List master(Float64List samples, double peak) {
  final mixed = reverb(samples, 0.22);
  var previousInput = 0.0;
  var previousOutput = 0.0;
  for (var index = 0; index < mixed.length; index++) {
    final input = mixed[index];
    previousOutput = input - previousInput + 0.995 * previousOutput;
    previousInput = input;
    mixed[index] = previousOutput;
  }
  final fade = (0.12 * sampleRate).round();
  for (var index = 0; index < fade; index++) {
    mixed[mixed.length - 1 - index] *= 0.5 - 0.5 * cos(pi * index / fade);
  }
  final loudest = mixed.fold<double>(
    0,
    (current, sample) => max(current, sample.abs()),
  );
  if (loudest == 0) return mixed;
  for (var index = 0; index < mixed.length; index++) {
    mixed[index] *= peak / loudest;
  }
  return mixed;
}

Uint8List encodeWav(Float64List samples) {
  final bytes = ByteData(44 + samples.length * 2)
    ..setUint32(0, 0x52494646)
    ..setUint32(4, 36 + samples.length * 2, Endian.little)
    ..setUint32(8, 0x57415645)
    ..setUint32(12, 0x666d7420)
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little)
    ..setUint16(22, 1, Endian.little)
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461)
    ..setUint32(40, samples.length * 2, Endian.little);
  for (var index = 0; index < samples.length; index++) {
    bytes.setInt16(
      44 + index * 2,
      (samples[index].clamp(-1.0, 1.0) * 32767).round(),
      Endian.little,
    );
  }
  return bytes.buffer.asUint8List();
}
