import 'dart:ui';
import 'package:flutter/material.dart';

/// Shared frosted surface for cards, dialogs and navigation.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double radius;
  const GlassSurface({super.key, required this.child, this.radius = 16});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x11FFFFFF), Color(0x06FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0x13FFFFFF)),
        ),
        child: Material(type: MaterialType.transparency, child: child),
      ),
    ),
  );
}

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF21191D), Color(0xFF101216), Color(0xFF080808)],
      ),
    ),
    child: child,
  );
}

class GlassAppBar extends AppBar {
  GlassAppBar({super.key, super.title, super.actions, super.centerTitle = true})
    : super(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      );
}
