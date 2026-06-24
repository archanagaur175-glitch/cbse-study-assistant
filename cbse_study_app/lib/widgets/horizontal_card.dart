import 'package:flutter/material.dart';

class HorizontalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const HorizontalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: color),
                  maxLines: 2),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }
}
