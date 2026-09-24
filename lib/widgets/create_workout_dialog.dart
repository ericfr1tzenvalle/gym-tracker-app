import 'package:flutter/material.dart';
import 'glass_surface.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassSurface(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontFamily: 'MatchaMint', fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name of workout',
                  hintText: 'Push',
                  errorText: _errorText,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _create,
                    child: Text(widget.actionLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
