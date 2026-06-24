import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        Text('$count items',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
