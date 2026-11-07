import 'dart:math';

class RandomUtil {
  static final _rng = Random();

  static double nextDouble() => _rng.nextDouble();

  static int nextInt(int max) => _rng.nextInt(max);

  static int nextIntRange(int min, int max) =>
      min + _rng.nextInt(max - min + 1);

  static bool bernoulli(double p) => _rng.nextDouble() < p;

  static T pick<T>(List<T> items) => items[_rng.nextInt(items.length)];

  static List<T> shuffle<T>(List<T> items) {
    final copy = List<T>.from(items);
    copy.shuffle(_rng);
    return copy;
  }

  static List<T> sample<T>(List<T> items, int k) {
    final shuffled = shuffle(items);
    return shuffled.take(k.clamp(0, items.length)).toList();
  }
}

class MathUtil {
  static double clamp(double v, double lo, double hi) =>
      v.clamp(lo, hi) as double;

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static double sigmoid(double x) => 1 / (1 + exp(-x));

  static double logisticGrowth(double x, double midpoint, double rate) =>
      1 / (1 + exp(-rate * (x - midpoint)));

  static double weightedAverage(List<double> values, List<double> weights) {
    double sum = 0;
    double weightSum = 0;
    for (int i = 0; i < values.length; i++) {
      sum += values[i] * weights[i];
      weightSum += weights[i];
    }
    return weightSum > 0 ? sum / weightSum : 0;
  }

  static double softmaxWeight(int index, List<double> scores, double temperature) {
    final expValues = scores.map((s) => exp(s / temperature)).toList();
    final sum = expValues.fold(0.0, (a, b) => a + b);
    return sum > 0 ? expValues[index] / sum : 1.0 / scores.length;
  }

  static double bayesianUpdate(double prior, double likelihood, double evidence) {
    if (evidence <= 0) return prior;
    return (prior * likelihood) / evidence;
  }

  static double decayedValue(double initial, double decayRate, int steps) {
    return initial * pow(decayRate, steps).toDouble();
  }
}

class TimeUtil {
  static String formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  static String formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}
