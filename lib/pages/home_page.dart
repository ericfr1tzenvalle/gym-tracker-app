import 'package:flutter/material.dart';
import 'package:gym_tracker_app/dev/theme_preview_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('LilGym', style: TextStyle(
          fontFamily: 'SacredHertz',
          fontSize: 24,
        )),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi Eric !',
                          style: textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your workout for today is',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ThemePreviewPage(),
                        ),
                      );
                    },
                    tooltip: 'See theme preview',
                    icon: const Icon(Icons.info_outline),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    20,
                    10,
                    20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '# 1 - Back Day',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                fontFamily: 'SacredHertz',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Back + Biceps + Shoulders',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, size: 26),
                            SizedBox(height: 1),
                            Text(
                              'Start',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 2),
                    Text('Add Workout', style: textTheme.labelLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
