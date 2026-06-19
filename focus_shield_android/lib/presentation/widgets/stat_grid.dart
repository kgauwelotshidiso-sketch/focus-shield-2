import 'package:flutter/material.dart';

class StatGrid extends StatelessWidget {
  const StatGrid({
    super.key,
    required this.items,
  });

  final Map<String, String> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: items.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(entry.key),
            ],
          ),
        );
      }).toList(),
    );
  }
}
