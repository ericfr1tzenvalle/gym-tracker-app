import 'package:flutter/material.dart';

enum _SessionAction { finish, cancel }

class WorkoutSessionActions extends StatelessWidget {
  final bool canFinish;
  final VoidCallback onFinish;
  final VoidCallback onCancel;

  const WorkoutSessionActions({
    super.key,
    required this.canFinish,
    required this.onFinish,
    required this.onCancel,
  });

  Future<void> _confirm(BuildContext context, _SessionAction action) async {
    final cancel = action == _SessionAction.cancel;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cancel ? 'Cancel this workout?' : 'Finish workout early?'),
        content: Text(
          cancel
              ? 'This session will be marked cancelled, even if you registered sets. You can then start a new workout.'
              : 'Your registered sets will be kept and this session will be marked completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep training'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(cancel ? 'Cancel workout' : 'Finish workout'),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    if (cancel) {
      onCancel();
    } else {
      onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SessionAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Workout options',
      onSelected: (action) => _confirm(context, action),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _SessionAction.finish,
          enabled: canFinish,
          child: const Text('Finish workout early'),
        ),
        const PopupMenuItem(
          value: _SessionAction.cancel,
          child: Text('Cancel workout'),
        ),
      ],
    );
  }
}
