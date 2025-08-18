import 'dart:math';

import 'package:flutter/material.dart';

class FlipWordCard extends StatefulWidget {
  final String word;
  final String meaning;
  final double width;
  final double height;
  final Color color;
  final double outerYaw; // parent yaw in radians
  final bool forceBackFace; // when true, show Turkish side for all

  const FlipWordCard({
    super.key,
    required this.word,
    required this.meaning,
    required this.width,
    required this.height,
    required this.color,
    this.outerYaw = 0,
    this.forceBackFace = false,
  });

  @override
  State<FlipWordCard> createState() => _FlipWordCardState();
}

class _FlipWordCardState extends State<FlipWordCard> {
  bool _isFlipped = false;

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
            begin: 0, end: (widget.forceBackFace || _isFlipped) ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        builder: (context, t, _) {
          final double angle = t * pi; // 0 -> pi
          final bool showFront = angle <= pi / 2;

          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Front
                IgnorePointer(
                  ignoring: !showFront,
                  child: Opacity(
                    opacity: showFront ? 1 : 0,
                    child: _buildSide(isFront: true, angle: angle),
                  ),
                ),
                // Back
                IgnorePointer(
                  ignoring: showFront,
                  child: Opacity(
                    opacity: showFront ? 0 : 1,
                    child: _buildSide(isFront: false, angle: angle),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSide({required bool isFront, required double angle}) {
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0015)
      ..rotateY(isFront ? angle : angle + pi);

    Widget content = isFront
        ? _CardFace(
            title: widget.word,
            subtitle: 'English',
            backgroundColor: widget.color,
          )
        : _CardFace(
            title: widget.meaning,
            subtitle: 'Türkçe',
            backgroundColor: widget.color,
          );

    // Counter-rotate when net rotation makes the face appear mirrored
    final double netYaw = widget.outerYaw + (isFront ? angle : angle + pi);
    final bool shouldCounterRotate = cos(netYaw) < 0;
    if (shouldCounterRotate) {
      content = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(pi),
        child: content,
      );
    }

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: content,
    );
  }
}

class _CardFace extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const _CardFace({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
