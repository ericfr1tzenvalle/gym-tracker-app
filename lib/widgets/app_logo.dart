import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'Lil',
        children: [
          TextSpan(
            text: 'gym',
            style: TextStyle(color: AppColors.crimson),
          ),
        ],
      ),
      style: TextStyle(fontFamily: 'Marola', fontSize: 28),
    );
  }
}
