import 'package:flutter/material.dart';

class ActionButtonRow extends StatelessWidget {
  final List<ActionButtonItem> items;

  const ActionButtonRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: item.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 18, color: item.color),
                            const SizedBox(width: 6),
                            Text(item.label,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: item.color)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class ActionButtonItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  ActionButtonItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
