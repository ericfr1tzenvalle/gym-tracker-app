import 'package:flutter/material.dart';
import 'glass_surface.dart';
import 'package:flutter/services.dart';

class WorkoutSetCard extends StatefulWidget {
  final int setNumber;
  final int plannedSets;
  final int plannedRepetitions;
  final int numberOfExercises;
  final int exerciseIndex;
  final String exerciseName;
  final double weight;
  final int repetitions;
  final void Function(double weight, int repetitions) onRegister;

  const WorkoutSetCard({
    super.key,
    required this.setNumber,
    required this.plannedSets,
    required this.plannedRepetitions,
    required this.exerciseIndex,
    required this.exerciseName,
    required this.weight,
    required this.repetitions,
    required this.numberOfExercises,
    required this.onRegister,
  });

  @override
  State<WorkoutSetCard> createState() => _WorkoutSetCardState();
}

class _WorkoutSetCardState extends State<WorkoutSetCard> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  double? get _weight =>
      double.tryParse(_weightController.text.replaceAll(',', '.'));

  int? get _repetitions => int.tryParse(_repsController.text);

  bool get _hasValidWeight {
    final weight = _weight;
    return weight != null && weight.isFinite && weight > 0;
  }

  bool get _hasValidRepetitions {
    final repetitions = _repetitions;
    return repetitions != null && repetitions > 0;
  }

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '${widget.weight}');
    _repsController = TextEditingController(text: '${widget.repetitions}');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _updateValue(TextEditingController controller, String text) {
    setState(() {
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  void _registerSet() {
    if (!_hasValidWeight || !_hasValidRepetitions) {
      final messages = [
        if (!_hasValidWeight) 'Enter a weight greater than 0.',
        if (!_hasValidRepetitions) 'Enter repetitions greater than 0.',
      ];
      FocusManager.instance.primaryFocus?.unfocus();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(messages.join('\n')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      return;
    }

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    widget.onRegister(_weight!, _repetitions!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weight = _weight;
    final adjustableWeight = weight != null && weight.isFinite ? weight : 0.0;
    final repetitions = _repetitions ?? 0;
    final valueStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 40,
    );
    final unitStyle = theme.textTheme.labelMedium?.copyWith(
      fontSize: 14,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise ${widget.exerciseIndex + 1} of ${widget.numberOfExercises}',
          style: unitStyle,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (widget.exerciseIndex + 1) / widget.numberOfExercises,
          backgroundColor: Colors.grey.shade800,
          minHeight: 8,
          borderRadius: BorderRadius.circular(16),
        ),
        const SizedBox(height: 16),
        Text(
          widget.exerciseName,
          style: TextStyle(
            fontFamily: 'MatchaMint',
            fontSize: 32,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            Text('${widget.plannedSets} sets • '),
            Text('${widget.plannedRepetitions} reps'),
          ],
        ),
        const SizedBox(height: 24),
        GlassSurface(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'SET ${widget.setNumber} OF ${widget.plannedSets}',
                    style: unitStyle?.copyWith(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildInput(
                          label: 'Weight (kg)',
                          controller: _weightController,
                          valueStyle: valueStyle,
                          decimal: true,
                          onDecrease: adjustableWeight >= 2.5
                              ? () => _updateValue(
                                  _weightController,
                                  '${((adjustableWeight - 2.5) * 100).round() / 100}',
                                )
                              : null,
                          onIncrease: adjustableWeight + 2.5 <= 999.99
                              ? () => _updateValue(
                                  _weightController,
                                  '${((adjustableWeight + 2.5) * 100).round() / 100}',
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInput(
                          label: 'Repetitions',
                          controller: _repsController,
                          valueStyle: valueStyle,
                          decimal: false,
                          onDecrease: repetitions >= 1
                              ? () => _updateValue(
                                  _repsController,
                                  '${repetitions - 1}',
                                )
                              : null,
                          onIncrease: repetitions < 99
                              ? () => _updateValue(
                                  _repsController,
                                  '${repetitions + 1}',
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _registerSet,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              textStyle: theme.textTheme.titleMedium,
              disabledBackgroundColor: theme.colorScheme.primary,
              disabledForegroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.check),
            label: const Text('Register set'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            widget.setNumber < widget.plannedSets
                ? 'Up next: set ${widget.setNumber + 1} of ${widget.plannedSets}'
                : 'Last planned set',
            style: unitStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required TextStyle? valueStyle,
    required bool decimal,
    required VoidCallback? onDecrease,
    required VoidCallback? onIncrease,
  }) {
    final theme = Theme.of(context);
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: const Color(0x10FFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(48, 56),
      iconSize: 28,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: controller,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final pattern = decimal
                  ? RegExp(r'^\d{0,3}([.,]\d{0,2})?$')
                  : RegExp(r'^\d{0,2}$');
              return pattern.hasMatch(newValue.text) ? newValue : oldValue;
            }),
          ],
          textAlign: TextAlign.center,
          style: valueStyle,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            semanticCounterText: label,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: IconButton(
                style: buttonStyle,
                onPressed: onDecrease,
                tooltip: decimal ? 'Decrease weight' : 'Decrease repetitions',
                icon: const Icon(Icons.remove),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: IconButton(
                style: buttonStyle,
                onPressed: onIncrease,
                tooltip: decimal ? 'Increase weight' : 'Increase repetitions',
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
