import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class MasteryBanner extends StatelessWidget {
  const MasteryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final overall = state.overallMastery;
    final started = state.totalChaptersStarted;
    final mastered = state.totalChaptersCompleted;
    final sessions = state.learner.totalStudySessions;
    final minutes = state.learner.totalMinutesStudied;
    final color = overall >= 0.7
        ? Colors.green
        : overall >= 0.4
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overall Mastery',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${(overall * 100).round()}%',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: color)),
                          const Spacer(),
                          _stat('$started', 'Started'),
                          _stat('$mastered', 'Mastered'),
                          _stat('$sessions', 'Sessions'),
                          _stat('${minutes}m', 'Time'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: overall,
                minHeight: 8,
                color: color,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
