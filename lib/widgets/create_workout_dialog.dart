import 'package:flutter/material.dart';

class CreateWorkoutDialog extends StatefulWidget {
  final String? Function(String name) onCreate;
  final String actionLabel;
  final String initialName;
  final String title;

  const CreateWorkoutDialog({
    super.key,
    required this.onCreate,
    this.actionLabel = 'Create',
    this.initialName = '',
    this.title = 'Create Workout',
  });

  @override
  State<CreateWorkoutDialog> createState() => _CreateWorkoutDialogState();
}

class _CreateWorkoutDialogState extends State<CreateWorkoutDialog> {
  late final TextEditingController _nameController;
  String? _errorText;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  void _create() {
    if (_submitted) return;
    final error = widget.onCreate(_nameController.text.trim());
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }
    _submitted = true;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        widget.title,
        style: TextStyle(fontFamily: 'MatchaMint', fontSize: 16),
      ),
      content: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Name of workout',
          hintText: 'Push',
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _create, child: Text(widget.actionLabel)),
      ],
    );
  }
}
