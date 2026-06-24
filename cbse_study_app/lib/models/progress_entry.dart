class ProgressEntry {
  final int chapterId;
  double masteryScore;
  List<double> accuracyHistory;
  double averageResponseTime;
  DateTime? lastReviewed;
  int retryCount;
  double difficultyRating;
  double easinessFactor;
  int interval;
  int repetitions;
  DateTime? nextReviewDue;

  ProgressEntry({
    required this.chapterId,
    this.masteryScore = 0.0,
    List<double>? accuracyHistory,
    this.averageResponseTime = 0.0,
    this.lastReviewed,
    this.retryCount = 0,
    this.difficultyRating = 0.5,
    this.easinessFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.nextReviewDue,
  }) : accuracyHistory = accuracyHistory ?? [];

  void recordAttempt({required bool correct, required double responseTime}) {
    accuracyHistory.add(correct ? 1.0 : 0.0);
    if (accuracyHistory.length > 20) {
      accuracyHistory = accuracyHistory.sublist(accuracyHistory.length - 20);
    }
    final total = accuracyHistory.length;
    final sum = accuracyHistory.fold(0.0, (a, b) => a + b);
    masteryScore = total > 0 ? sum / total : 0.0;

    if (averageResponseTime == 0.0) {
      averageResponseTime = responseTime;
    } else {
      averageResponseTime = (averageResponseTime * 0.7) + (responseTime * 0.3);
    }
    if (!correct) retryCount++;
    lastReviewed = DateTime.now();
    difficultyRating = 1.0 - masteryScore;
  }

  int get daysSinceLastReview {
    if (lastReviewed == null) return 999;
    return DateTime.now().difference(lastReviewed!).inDays;
  }

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'masteryScore': masteryScore,
        'accuracyHistory': accuracyHistory,
        'averageResponseTime': averageResponseTime,
        'lastReviewed': lastReviewed?.toIso8601String(),
        'retryCount': retryCount,
        'difficultyRating': difficultyRating,
        'easinessFactor': easinessFactor,
        'interval': interval,
        'repetitions': repetitions,
        'nextReviewDue': nextReviewDue?.toIso8601String(),
      };

  factory ProgressEntry.fromJson(Map<String, dynamic> j) => ProgressEntry(
        chapterId: j['chapterId'] as int,
        masteryScore: (j['masteryScore'] as num?)?.toDouble() ?? 0.0,
        accuracyHistory: (j['accuracyHistory'] as List?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            [],
        averageResponseTime: (j['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
        lastReviewed: j['lastReviewed'] != null
            ? DateTime.tryParse(j['lastReviewed'] as String)
            : null,
        retryCount: j['retryCount'] as int? ?? 0,
        difficultyRating: (j['difficultyRating'] as num?)?.toDouble() ?? 0.5,
        easinessFactor: (j['easinessFactor'] as num?)?.toDouble() ?? 2.5,
        interval: j['interval'] as int? ?? 0,
        repetitions: j['repetitions'] as int? ?? 0,
        nextReviewDue: j['nextReviewDue'] != null
            ? DateTime.tryParse(j['nextReviewDue'] as String)
            : null,
      );
}
