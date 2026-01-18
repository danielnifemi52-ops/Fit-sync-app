import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E1A47), // Deep Purple
                Color(0xFF1A1A2E), // Near black/Indigo
                Color(0xFF0F3460), // Deep Blue
              ],
            ),
          ),
        ),

        // Abstract floating shapes for texture
        Positioned(
          top: -100,
          right: -50,
          child: _BackgroundBlob(
            size: 300,
            color: Colors.deepPurple.withOpacity(0.2),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: _BackgroundBlob(
            size: 400,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
        Positioned(
          top: 300,
          right: 100,
          child: _BackgroundBlob(
            size: 200,
            color: Colors.purpleAccent.withOpacity(0.05),
          ),
        ),

        // The actual content
        child,
      ],
    );
  }
}

class _BackgroundBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: size / 2, spreadRadius: size / 4),
        ],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15,
    this.opacity = 0.1,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
