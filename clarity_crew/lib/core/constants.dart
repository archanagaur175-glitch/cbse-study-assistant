import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'ClarityCrew';
  static const String appTagline = 'Learn your way';

  // Session limits
  static const int maxSessionMinutes = 45;
  static const int focusSprintMinutes = 10;
  static const int shortSessionMinutes = 5;
  static const int calmRecoverySeconds = 30;

  // Quiz
  static const int quizQuestionCount = 5;
  static const int maxAttempts = 3;

  // Flashcard
  static const int flashcardReviewCount = 10;

  // AI defaults
  static const double defaultLearningRate = 0.15;
  static const double explorationRate = 0.20;
  static const double decayFactor = 0.95;

  // Progress
  static const int streakWindowDays = 7;
  static const int masteryThreshold = 80;

  // Visual
  static const double cardBorderRadius = 20;
  static const double smallBorderRadius = 12;
  static const double standardPadding = 16;
  static const double largePadding = 24;
  static const double maxContentWidth = 420;

  // Animation
  static const Duration fastAnim = Duration(milliseconds: 200);
  static const Duration medAnim = Duration(milliseconds: 350);
  static const Duration slowAnim = Duration(milliseconds: 600);

  // Neurodivergent support
  static const double reducedMotionScale = 0.3;
  static const int maxOptionsPerQuestion = 4;
  static const int visualBreakIntervalSeconds = 120;

  // Learning modes
  static const List<String> learningModes = [
    'micro_lesson',
    'quiz',
    'flashcards',
    'video',
    'guided_practice',
    'visual_summary',
  ];

  static const Map<String, IconData> modeIcons = {
    'micro_lesson': Icons.menu_book_rounded,
    'quiz': Icons.quiz_rounded,
    'flashcards': Icons.style_rounded,
    'video': Icons.play_circle_rounded,
    'guided_practice': Icons.handyman_rounded,
    'visual_summary': Icons.visibility_rounded,
  };

  static const Map<String, String> modeLabels = {
    'micro_lesson': 'Micro Lesson',
    'quiz': 'Quiz',
    'flashcards': 'Flashcards',
    'video': 'Video',
    'guided_practice': 'Guided Practice',
    'visual_summary': 'Visual Summary',
  };
}
