import 'dart:math' as math;
import 'dart:typed_data';

/// Generates a seamless-loop pink-noise "wind" sample entirely on-device,
/// so no audio asset needs to ship with the app.
///
/// Runs white noise through Paul Kellett's classic pink-noise filter,
/// softens it with a light low-pass so it reads as airy wind rather than
/// static hiss, adds a slow amplitude wobble for organic movement, and
/// crossfades the tail into the head so the result loops without a click.
/// Returned as a minimal 16-bit PCM mono WAV byte buffer, ready for
/// SoLoud (or any other decoder) to load from memory.
///
/// This is a pure function with no Flutter/SoLoud dependency, so it's
/// meant to be run off the UI isolate (e.g. `Isolate.run(generatePinkNoiseWav)`)
/// — the generation itself is cheap (a few hundred thousand samples,
/// comfortably under a second) but there's no reason to block the UI
/// isolate for it.
Uint8List generatePinkNoiseWav({
  int sampleRate = 44100,
  double loopSeconds = 6,
  double crossfadeSeconds = 1,
  double lowpassCutoffHz = 1200,
  double peakAmplitude = 0.55,
  int seed = 42,
}) {
  final loopSamples = (sampleRate * loopSeconds).round();
  final crossfadeSamples = (sampleRate * crossfadeSeconds).round();
  final totalSamples = loopSamples + crossfadeSamples;
  final random = math.Random(seed);

  // Paul Kellett's refined pink-noise filter: a cheap IIR approximation of
  // a 1/f spectrum from white noise.
  var b0 = 0.0;
  var b1 = 0.0;
  var b2 = 0.0;
  var b3 = 0.0;
  var b4 = 0.0;
  var b5 = 0.0;
  var b6 = 0.0;
  final pink = Float64List(totalSamples);
  for (var i = 0; i < totalSamples; i++) {
    final w = random.nextDouble() * 2 - 1;
    b0 = 0.99886 * b0 + w * 0.0555179;
    b1 = 0.99332 * b1 + w * 0.0750759;
    b2 = 0.96900 * b2 + w * 0.1538520;
    b3 = 0.86650 * b3 + w * 0.3104856;
    b4 = 0.55000 * b4 + w * 0.5329522;
    b5 = -0.7616 * b5 - w * 0.0168980;
    pink[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362;
    b6 = w * 0.115926;
  }

  // Soften into a "wind" character: a one-pole low-pass, cascaded twice
  // for a steeper, gentler roll-off than a single pole gives.
  final dt = 1 / sampleRate;
  final rc = 1 / (2 * math.pi * lowpassCutoffHz);
  final alpha = dt / (rc + dt);
  final wind = Float64List(totalSamples);
  var stage1 = 0.0;
  var stage2 = 0.0;
  for (var i = 0; i < totalSamples; i++) {
    stage1 += alpha * (pink[i] - stage1);
    stage2 += alpha * (stage1 - stage2);
    wind[i] = stage2;
  }

  // Slow amplitude "breathiness" wobble — subtle, organic, and
  // independent of the breath-driven volume envelope applied at
  // playback time.
  for (var i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final wobble =
        1.0 +
        0.06 * math.sin(2 * math.pi * 0.13 * t) +
        0.03 * math.sin(2 * math.pi * 0.29 * t + 1.0);
    wind[i] *= wobble;
  }

  var peak = 0.0;
  for (final s in wind) {
    if (s.abs() > peak) peak = s.abs();
  }
  final scale = peak > 0 ? peakAmplitude / peak : 1.0;

  // Seamless loop: crossfade the tail (crossfadeSeconds) into the head so
  // there's no click at the loop point.
  final looped = Int16List(loopSamples);
  for (var i = 0; i < loopSamples; i++) {
    var value = wind[i] * scale;
    if (i < crossfadeSamples) {
      final fadeIn = i / crossfadeSamples;
      final tailValue = wind[loopSamples + i] * scale;
      value = value * (1 - fadeIn) + tailValue * fadeIn;
    }
    looped[i] = (value.clamp(-1.0, 1.0) * 32767).round();
  }

  return _pcm16ToWav(looped, sampleRate: sampleRate, channels: 1);
}

/// Wraps raw 16-bit PCM samples in a minimal (44-byte header) WAV
/// container so a standard decoder can read them.
Uint8List _pcm16ToWav(
  Int16List samples, {
  required int sampleRate,
  required int channels,
}) {
  const bitsPerSample = 16;
  final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final dataSize = samples.length * 2;

  final bytes = ByteData(44 + dataSize);

  void writeString(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  writeString(0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  bytes
    ..setUint32(16, 16, Endian.little) // fmt chunk size
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, channels, Endian.little)
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, byteRate, Endian.little)
    ..setUint16(32, blockAlign, Endian.little)
    ..setUint16(34, bitsPerSample, Endian.little);
  writeString(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    bytes.setInt16(44 + i * 2, samples[i], Endian.little);
  }

  return bytes.buffer.asUint8List();
}
