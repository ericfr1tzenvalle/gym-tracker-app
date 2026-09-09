import 'package:flutter/material.dart';
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
  late double _weight;
  late int _repetitions;
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  @override
  void initState() {
    super.initState();
    _weight = widget.weight;
    _repetitions = widget.repetitions;
    _weightController = TextEditingController(text: '$_weight');
    _repsController = TextEditingController(text: '$_repetitions');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                          onChanged: (text) {
                            final value = double.tryParse(
                              text.replaceAll(',', '.'),
                            );
                            if (value == null || !value.isFinite || value < 0) {
                              return;
                            }
                            setState(() => _weight = value);
                          },
                          onDecrease: _weight >= 2.5
                              ? () => setState(() {
                                  _weight =
                                      ((_weight - 2.5) * 100).round() / 100;
                                  _weightController.text = '$_weight';
                                })
                              : null,
                          onIncrease: _weight + 2.5 <= 999.99
                              ? () => setState(() {
                                  _weight =
                                      ((_weight + 2.5) * 100).round() / 100;
                                  _weightController.text = '$_weight';
                                })
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
                          onChanged: (text) {
                            final value = int.tryParse(text);
                            if (value == null || value < 0) return;
                            setState(() => _repetitions = value);
                          },
                          onDecrease: _repetitions >= 1
                              ? () => setState(() {
                                  _repetitions--;
                                  _repsController.text = '$_repetitions';
                                })
                              : null,
                          onIncrease: _repetitions < 99
                              ? () => setState(() {
                                  _repetitions++;
                                  _repsController.text = '$_repetitions';
                                })
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
            onPressed: () {
              widget.onRegister(_weight, _repetitions);
            },
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
    required ValueChanged<String> onChanged,
    required VoidCallback? onDecrease,
    required VoidCallback? onIncrease,
  }) {
    final theme = Theme.of(context);
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
          onTapAlwaysCalled: true,
          onTap: () {
            controller.clear();
            setState(() {
              if (decimal) {
                _weight = 0;
              } else {
                _repetitions = 0;
              }
            });
          },
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
          onChanged: onChanged,
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
