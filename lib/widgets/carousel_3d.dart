import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mini_language_cards/widgets/flip_word_card.dart';

class Carousel3D extends StatefulWidget {
  final List<Map<String, String>> items;

  const Carousel3D({super.key, required this.items});

  @override
  State<Carousel3D> createState() => _Carousel3DState();
}

class _Carousel3DState extends State<Carousel3D>
    with SingleTickerProviderStateMixin {
  double _angle = 0;
  AnimationController? _snapController;
  double _snapStart = 0;
  double _snapEnd = 0;
  int? _frontIndexLocked;
  bool _showTurkishAll = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void dispose() {
    _snapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int itemCount = widget.items.length;
        if (itemCount == 0) return const SizedBox.shrink();

        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        // Card size: make square, bigger, and still keep all 5 visible
        const double spacingFactor = 0.6; // radius will be spacingFactor * size
        final double maxSizeByHeight = height * 0.8;
        final double maxSizeByWidth = (width - 16) / (1 + 2 * spacingFactor);
        final double cardSize =
            min(340.0, min(maxSizeByHeight, maxSizeByWidth));
        final double cardWidth = cardSize;
        final double cardHeight = cardSize;

        // Radius ensures side cards remain visible and not overlapping the center
        final double radius = spacingFactor * cardSize;
        final double baseY = 0; // flat circle

        // Precompute positions and sort by depth (z) for correct painting order
        final List<_ItemPose> poses = List.generate(itemCount, (i) {
          final double itemAngle = _angle + (2 * pi * i / itemCount);
          final double x = sin(itemAngle) * radius;
          final double z =
              cos(itemAngle) * radius; // front: z big, back: z negative
          return _ItemPose(index: i, angle: itemAngle, x: x, y: baseY, z: z);
        });

        // Find front-most by min |x| (closest to screen center), unless locked during drag
        int computedFront = poses.first.index;
        double bestCenter = poses.first.x.abs();
        for (final p in poses) {
          final double cx = p.x.abs();
          if (cx < bestCenter) {
            bestCenter = cx;
            computedFront = p.index;
          }
        }
        final int frontIndex = _frontIndexLocked ?? computedFront;

        // Split: paint non-front back->front, then paint front last
        final List<_ItemPose> nonFront = [
          for (final p in poses)
            if (p.index != frontIndex) p
        ]..sort((a, b) {
            final int cmp = a.z.compareTo(b.z); // far to near
            if (cmp != 0) return cmp;
            return a.index.compareTo(b.index); // stable
          });
        _ItemPose? frontPose;
        for (final p in poses) {
          if (p.index == frontIndex) {
            frontPose = p;
            break;
          }
        }

        return GestureDetector(
          onHorizontalDragStart: (_) {
            final c = _snapController;
            if (c != null && c.isAnimating) {
              c.stop();
            }
            setState(() {
              _frontIndexLocked = frontIndex;
            });
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              _angle -= (details.primaryDelta ?? 0) / 200.0;
            });
          },
          onHorizontalDragEnd: (_) {
            final c = _snapController;
            if (c == null) return;
            final double step = 2 * pi / itemCount;
            // Snap to nearest step
            final double target = ((_angle / step).round()) * step;
            _snapStart = _angle;
            _snapEnd = target;
            c
              ..value = 0
              ..removeListener(_tick)
              ..addListener(_tick)
              ..removeStatusListener(_onAnimStatus)
              ..addStatusListener(_onAnimStatus)
              ..animateTo(1, curve: Curves.easeOut);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (final pose in nonFront)
                _buildTransformedItem(
                  width: cardWidth,
                  height: cardHeight,
                  pose: pose,
                  radius: radius,
                  item: widget.items[pose.index],
                ),
              if (frontPose != null)
                _buildTransformedItem(
                  width: cardWidth,
                  height: cardHeight,
                  pose: frontPose,
                  radius: radius,
                  item: widget.items[frontPose.index],
                ),
              // Bottom controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        minimumSize: const Size(180, 56),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => setState(() {
                        _showTurkishAll = !_showTurkishAll;
                      }),
                      child: Text(_showTurkishAll ? 'English' : 'Türkçe'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _tick() {
    final c = _snapController;
    if (c == null) return;
    setState(() {
      _angle = _snapStart + (_snapEnd - _snapStart) * c.value;
    });
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      setState(() {
        _frontIndexLocked = null;
      });
    }
  }

  Widget _buildTransformedItem({
    required double width,
    required double height,
    required _ItemPose pose,
    required double radius,
    required Map<String, String> item,
  }) {
    // Depth-based scale by screen-center proximity: smaller |x| -> larger
    final double proximity =
        1.0 - (pose.x.abs() / (radius + 0.0001)).clamp(0.0, 1.0);
    final double depthFactor = (0.6 + 0.4 * proximity).clamp(0.6, 1.0);
    final double scale = 0.7 + 0.3 * depthFactor;

    // Assign 5 distinct solid colors in order: red, blue, green, orange, yellow
    const List<Color> colors = <Color>[
      Colors.red,
      Colors.blue,
      Colors.pink,
      Colors.green,
      Colors.orange,
    ];
    final Color color = colors[pose.index % colors.length];

    // Back half classification stays geometric
    final bool isBackHalf = pose.z < 0;
    final double yaw = pose.angle + (isBackHalf ? pi : 0);

    return Center(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..translate(pose.x, pose.y, -pose.z)
          ..rotateY(yaw),
        child: Transform.scale(
          scale: scale,
          child: SizedBox(
            width: width,
            height: height,
            child: FlipWordCard(
              word: item['word'] ?? '-',
              meaning: item['meaning'] ?? 'kar',
              width: width,
              height: height,
              color: color,
              outerYaw: yaw,
              forceBackFace: _showTurkishAll,
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemPose {
  final int index;
  final double angle;
  final double x;
  final double y;
  final double z;

  _ItemPose({
    required this.index,
    required this.angle,
    required this.x,
    required this.y,
    required this.z,
  });
}
