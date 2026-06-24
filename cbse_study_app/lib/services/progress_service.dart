import '../models/progress_entry.dart';
import 'spaced_repetition.dart';

class ProgressService {
  static void recordAttempt({
    required ProgressEntry entry,
    required bool correct,
    required double responseTimeSeconds,
  }) {
    entry.accuracyHistory.add(correct ? 1.0 : 0.0);
    if (entry.accuracyHistory.length > 20) {
      entry.accuracyHistory = entry.accuracyHistory.sublist(entry.accuracyHistory.length - 20);
    }
    final total = entry.accuracyHistory.length;
    final sum = entry.accuracyHistory.fold(0.0, (a, b) => a + b);
    entry.masteryScore = total > 0 ? sum / total : 0.0;

    if (entry.averageResponseTime == 0.0) {
      entry.averageResponseTime = responseTimeSeconds;
    } else {
      entry.averageResponseTime =
          (entry.averageResponseTime * 0.7) + (responseTimeSeconds * 0.3);
    }
    if (!correct) entry.retryCount++;
    entry.lastReviewed = DateTime.now();
    entry.difficultyRating = 1.0 - entry.masteryScore;

    final quality = SpacedRepetition.qualityFromPerformance(
      correct: correct,
      responseTimeSeconds: responseTimeSeconds,
    );
    SpacedRepetition.scheduleReview(entry: entry, quality: quality);
  }
}
