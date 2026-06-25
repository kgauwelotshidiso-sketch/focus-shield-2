import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/shield_card.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({
    super.key,
    required this.onBack,
    required this.onSaved,
    required this.lastReflectionText,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onSaved;
  final String lastReflectionText;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSaved(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Daily Reflection',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        const Text('Guided prompts, then save your reflection.'),
        const SizedBox(height: 18),
        ShieldCard(
          borderColor: AppTheme.primary,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reflection prompts'),
              SizedBox(height: 12),
              Text('1. What tested my discipline today?'),
              Text('2. What did I do well?'),
              Text('3. What must I improve tomorrow?'),
              Text('4. Which goal am I returning to now?'),
            ],
          ),
        ),
        ShieldCard(
          borderColor: AppTheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Write reflection'),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Today I learned...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Save Reflection',
                subtitle: '+15 XP',
                onPressed: _save,
              ),
            ],
          ),
        ),
        if (widget.lastReflectionText.trim().isNotEmpty)
          ShieldCard(
            borderColor: AppTheme.warning,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Last saved reflection'),
                const SizedBox(height: 8),
                Text(widget.lastReflectionText),
              ],
            ),
          ),
      ],
    );
  }
}
