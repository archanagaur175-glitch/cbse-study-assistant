import 'dart:math';
import '../models/chapter.dart';
import '../models/learner_model.dart';

class AiGeneratedQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  AiGeneratedQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class SummaryResult {
  final String keyPoints;
  final String keyFormulas;
  final String keyTerms;

  SummaryResult({
    required this.keyPoints,
    required this.keyFormulas,
    required this.keyTerms,
  });
}

class AIService {
  static SummaryResult summarizeChapter(Chapter chapter) {
    final lines = chapter.detailedNotes
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final firstSentences = lines.length <= 2
        ? chapter.detailedNotes
        : lines.take(3).join('\n');

    final formulas = chapter.keyFormulas
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final formulaSummary = formulas.length <= 3
        ? formulas.join('\n')
        : formulas.take(3).join('\n') +
            '\n...and ${formulas.length - 3} more';

    final termPatterns = [
      r"Law", r"Theorem", r"Principle", r"Effect",
      r"Equation", r"Rule", r"Property",
    ];
    final keyTerms = <String>{};
    for (final line in lines) {
      for (final pattern in termPatterns) {
        final idx = line.indexOf(pattern);
        if (idx >= 0) {
          final start = line.substring(0, idx).lastIndexOf(' ') + 1;
          final phrase = line.substring(start, idx + pattern.length);
          if (phrase.length < 50) keyTerms.add(phrase);
        }
      }
    }

    return SummaryResult(
      keyPoints: firstSentences,
      keyFormulas: formulaSummary,
      keyTerms: keyTerms.isEmpty ? 'None identified' : keyTerms.join(', '),
    );
  }

  static List<AiGeneratedQuestion> generateQuestions(
    Chapter chapter, {
    int count = 3,
  }) {
    final rng = Random(chapter.id);
    final questions = <AiGeneratedQuestion>[];

    final rawProblems =
        chapter.practiceProblems.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final rawExamples =
        chapter.examples.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final rawNotes =
        chapter.detailedNotes.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final rawFormulas =
        chapter.keyFormulas.split('\n').where((l) => l.trim().isNotEmpty).toList();

    for (int i = 0; i < count; i++) {
      final sourceType = rng.nextInt(4);
      switch (sourceType) {
        case 0:
          if (rawFormulas.isNotEmpty) {
            final f = rawFormulas[rng.nextInt(rawFormulas.length)];
            final parts = f.split(':');
            final q = parts.isNotEmpty
                ? 'What is the formula for ${parts[0].trim()}?'
                : 'Write the correct formula from this chapter.';
            questions.add(AiGeneratedQuestion(
              question: q,
              options: [
                parts.length > 1 ? parts.sublist(1).join(':').trim() : f,
                _distractor(rawFormulas, rng),
                _distractor(rawFormulas, rng),
                _distractor(rawFormulas, rng),
              ]..shuffle(rng),
              correctIndex: 0,
              explanation: 'From chapter formulas: $f',
            ));
          }
          break;
        case 1:
          if (rawNotes.length >= 3) {
            final start = rng.nextInt(rawNotes.length - 2);
            final snippet = rawNotes[start];
            final q = snippet.contains(',')
                ? 'Which concept is described as: "${snippet.split(',').first}..."?'
                : 'What does this describe: "${snippet.substring(0, snippet.length.clamp(0, 60))}..."?';
            final subject = chapter.subject;
            questions.add(AiGeneratedQuestion(
              question: q,
              options: _shuffled([
                chapter.name,
                _otherChapterName(chapter, subject),
                _otherChapterName(chapter, subject),
                _otherChapterName(chapter, subject),
              ], rng),
              correctIndex: 0,
              explanation: 'This relates to ${chapter.name}',
            ));
          }
          break;
        case 2:
          if (rawExamples.length >= 3) {
            final ex = rawExamples[rng.nextInt(rawExamples.length)];
            final qLine = ex.contains('Solution')
                ? ex.split('Solution').first.trim()
                : ex;
            questions.add(AiGeneratedQuestion(
              question: qLine.length > 80
                  ? 'Solve: ${qLine.substring(0, 80)}...'
                  : 'Solve: $qLine',
              options: [
                'Apply the formula from this chapter',
                'Use dimensional analysis',
                'Refer to solved examples',
                'Check the practice problems',
              ],
              correctIndex: 0,
              explanation: 'This type of problem is covered in the examples section.',
            ));
          }
          break;
        case 3:
          final weight = chapter.weightage;
          final pages = chapter.pages;
          questions.add(AiGeneratedQuestion(
            question: 'What is the weightage of ${chapter.name} in the CBSE exam?',
            options: _shuffled([
              '$weight%',
              '${weight + rng.nextInt(6) - 3}%',
              '${weight + rng.nextInt(8) - 4}%',
              '${(weight / 2).round()}%',
            ], rng),
            correctIndex: 0,
            explanation: '${chapter.name} carries $weight% weightage and spans $pages pages.',
          ));
          break;
      }
    }

    return questions;
  }

  static String generateHint(String problemText, Chapter chapter) {
    final lowerProblem = problemText.toLowerCase();
    final formulas = chapter.keyFormulas.split('\n');

    for (final f in formulas) {
      final parts = f.split(':');
      if (parts.length >= 2) {
        final term = parts[0].trim().toLowerCase();
        if (lowerProblem.contains(term)) {
          return 'Hint: Use **${parts[0].trim()}** → ${parts.sublist(1).join(':').trim()}';
        }
      }
    }

    final notes = chapter.detailedNotes.split('\n');
    for (final line in notes) {
      final trimmed = line.trim().toLowerCase();
      final words = lowerProblem.split(RegExp(r'\s+'));
      for (final word in words) {
        if (word.length > 4 && trimmed.contains(word)) {
          return 'Review: "$line"';
        }
      }
    }

    if (formulas.isNotEmpty) {
      return 'Start by recalling: ${formulas.first}';
    }

    return 'Try reviewing the examples section for a similar approach.';
  }

  static String generateQuickExplanation(String term, Chapter chapter) {
    final lowerTerm = term.toLowerCase();
    final notes = chapter.detailedNotes.split('\n');

    for (final line in notes) {
      if (line.toLowerCase().contains(lowerTerm)) {
        return line.trim();
      }
    }

    final formulas = chapter.keyFormulas.split('\n');
    for (final f in formulas) {
      if (f.toLowerCase().contains(lowerTerm)) {
        return f.trim();
      }
    }

    final examples = chapter.examples.split('\n');
    for (final ex in examples) {
      if (ex.toLowerCase().contains(lowerTerm)) {
        return ex.trim();
      }
    }

    return '$term is a key concept in ${chapter.name}. Review the detailed notes for more.';
  }

  static String _distractor(List<String> formulas, Random rng) {
    if (formulas.length < 2) return 'None of the above';
    final other = formulas[rng.nextInt(formulas.length)];
    final parts = other.split(':');
    return parts.length > 1
        ? parts.sublist(1).join(':').trim()
        : other;
  }

  static List<String> _shuffled(List<String> items, Random rng) {
    final copy = List<String>.from(items);
    copy.shuffle(rng);
    return copy;
  }

  static String _otherChapterName(Chapter current, String subject) {
    final others = {
      'Physics': [
        'Electric Charges and Fields',
        'Magnetism and Matter',
        'Current Electricity',
      ],
      'Chemistry': ['Solutions', 'Electrochemistry', 'Chemical Kinetics'],
      'Mathematics': ['Matrices', 'Integrals', 'Probability'],
      'Biology': ['Biomolecules', 'Reproduction in Organisms', 'Genetics'],
    };
    final pool = others[subject] ?? ['Another chapter'];
    final rng = Random();
    final chosen = pool[rng.nextInt(pool.length)];
    return chosen == current.name ? 'Another $subject chapter' : chosen;
  }
}
