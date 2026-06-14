import '../models/chapter.dart';
import '../models/profile.dart';

class Recommender {
  final List<Chapter> chapters;
  final Profile profile;

  Recommender({required this.chapters, required this.profile});

  List<_ScoredChapter> _scoreChapters() {
    final weakLower = profile.weakSubjects.map((s) => s.toLowerCase()).toSet();
    final strongLower = profile.strongSubjects.map((s) => s.toLowerCase()).toSet();
    final favoriteLower = <String>{};

    final diffMap = {'easy': 1.0, 'medium': 0.65, 'hard': 0.3};
    final diffScore = diffMap[profile.difficulty] ?? 0.65;

    final noteMap = {'short': 1.3, 'medium': 1.0, 'long': 0.7};
    final noteScore = noteMap[profile.noteLength] ?? 1.0;

    final goalMap = {'competitive': 1.2, 'board': 0.8, 'foundation': 0.5};
    final goalScore = goalMap[profile.examGoal] ?? 0.8;

    return chapters.map((ch) {
      final subj = ch.subject.toLowerCase();
      double score = 0;

      if (weakLower.contains(subj)) score += 25;
      if (strongLower.contains(subj)) score += 5;
      if (favoriteLower.contains(subj)) score += 10;

      score += (ch.weightage / 16.0) * 20;

      score += (15 - ch.pages.abs() - 20).clamp(0, 15) * diffScore;

      score += (ch.pages <= 18 ? 10 : ch.pages <= 24 ? 5 : 0) * noteScore;

      if (profile.dailyStudyMinutes >= 120) score += 10;
      else if (profile.dailyStudyMinutes >= 60) score += 5;

      score *= goalScore;

      return _ScoredChapter(chapter: ch, score: score);
    }).toList();
  }

  List<Chapter> getTopRecommendations({int count = 5}) {
    final scored = _scoreChapters();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(count).map((s) => s.chapter).toList();
  }

  List<Chapter> search(String query) {
    final q = query.toLowerCase();
    return chapters.where((ch) {
      return ch.name.toLowerCase().contains(q) ||
          ch.subject.toLowerCase().contains(q) ||
          ch.keyFormulas.toLowerCase().contains(q) ||
          ch.detailedNotes.toLowerCase().contains(q);
    }).toList();
  }

  int calculateRecoveryTime(Chapter chapter) {
    return (chapter.pages * 0.12 * 8).round();
  }

  double getCompletionPercentage(Chapter chapter) {
    return 0.0;
  }
}

class _ScoredChapter {
  final Chapter chapter;
  final double score;
  _ScoredChapter({required this.chapter, required this.score});
}
