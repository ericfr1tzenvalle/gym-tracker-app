import 'package:flutter/material.dart';

class ThemePreviewPage extends StatelessWidget {
  const ThemePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Preview'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Typography', style: textTheme.headlineLarge),
          const SizedBox(height: 16),
          Text('Headline Large', style: textTheme.headlineLarge),
          Text('Body large', style: textTheme.bodyLarge),
          Text('Body medium', style: textTheme.bodyMedium),
          Text('Label large', style: textTheme.labelLarge),
          const SizedBox(height: 32),

          Text('Buttons', style: textTheme.headlineLarge),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: const Text('Enabled button')),
          const ElevatedButton(onPressed: null, child: Text('Disabled button')),

          const SizedBox(height: 32),
          Text('Inputs', style: textTheme.headlineLarge),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Workout name',
              hintText: 'Example: Push Workout',
              icon: Icon(Icons.arrow_right),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Disabled input',
              icon: Icon(Icons.block),

            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Input with error',
              errorText: 'This field is required',
              icon: Icon(Icons.error),
            ),
          ),
          const SizedBox(height: 32),
          Text('Cards', style: textTheme.headlineLarge),
          Card(
            color: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            child: Padding(padding: EdgeInsetsGeometry.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Push day', style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Workout description', style: textTheme.bodyMedium),

                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
