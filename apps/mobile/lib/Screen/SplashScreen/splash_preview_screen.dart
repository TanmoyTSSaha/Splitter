import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_stroke_wordmark.dart';

/// Debug-only full-screen splash loop (draw → hold → repeat).
class SplashPreviewScreen extends StatelessWidget {
  const SplashPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: const Text('Splash preview'),
      ),
      body: const Center(
        child: SplitrStrokeWordmark(loop: true),
      ),
    );
  }
}
