import '../models/progress_entry.dart';

class SpacedRepetition {
  static const _minEf = 1.3;

  static void scheduleReview({
    required ProgressEntry entry,
    required int quality,
  }) {
    final q = quality.clamp(0, 5);

    if (q >= 3) {
      if (entry.repetitions == 0) {
        entry.interval = 1;
      } else if (entry.repetitions == 1) {
        entry.interval = 6;
      } else {
        entry.interval = (entry.interval * entry.easinessFactor).round();
      }
      entry.repetitions++;
    } else {
      entry.repetitions = 0;
      entry.interval = 1;
    }

    entry.easinessFactor =
        (entry.easinessFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))
            .clamp(_minEf, 3.0);

    entry.nextReviewDue = DateTime.now().add(Duration(days: entry.interval));
    entry.lastReviewed = DateTime.now();
  }

  static int qualityFromPerformance({
    required bool correct,
    required double responseTimeSeconds,
  }) {
    if (!correct) return 0;
    if (responseTimeSeconds < 10) return 5;
    if (responseTimeSeconds < 20) return 4;
    if (responseTimeSeconds < 40) return 3;
    return 2;
  }

  static bool isDue(ProgressEntry entry) {
    if (entry.nextReviewDue == null) return false;
    return entry.nextReviewDue!.isBefore(DateTime.now());
  }

  static List<ProgressEntry> dueItems(List<ProgressEntry> entries) {
    return entries.where(isDue).toList()
      ..sort((a, b) => (a.nextReviewDue ?? DateTime.now())
          .compareTo(b.nextReviewDue ?? DateTime.now()));
  }
}
