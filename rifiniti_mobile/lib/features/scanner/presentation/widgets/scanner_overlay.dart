import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Scanner overlay widget with viewfinder frame.
class ScannerOverlay extends StatelessWidget {
  final double scanAreaSize;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double cornerLength;

  const ScannerOverlay({
    super.key,
    this.scanAreaSize = 280,
    this.borderColor = AppTheme.primaryLight,
    this.borderWidth = 3,
    this.borderRadius = 16,
    this.cornerLength = 30,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final left = (screenWidth - scanAreaSize) / 2;
        final top = (screenHeight - scanAreaSize) / 2 - 50;

        return Stack(
          children: [
            // Dark overlay with cutout
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Corner decorations
            Positioned(
              left: left,
              top: top,
              child: _buildCorner(Alignment.topLeft),
            ),
            Positioned(
              right: left,
              top: top,
              child: _buildCorner(Alignment.topRight),
            ),
            Positioned(
              left: left,
              bottom: screenHeight - top - scanAreaSize,
              child: _buildCorner(Alignment.bottomLeft),
            ),
            Positioned(
              right: left,
              bottom: screenHeight - top - scanAreaSize,
              child: _buildCorner(Alignment.bottomRight),
            ),

            // Animated scan line
            Positioned(
              left: left + 10,
              top: top + 10,
              child: SizedBox(
                width: scanAreaSize - 20,
                height: scanAreaSize - 20,
                child: const _AnimatedScanLine(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return SizedBox(
      width: cornerLength,
      height: cornerLength,
      child: CustomPaint(
        painter: _CornerPainter(
          alignment: alignment,
          color: borderColor,
          strokeWidth: borderWidth,
          radius: borderRadius,
        ),
      ),
    );
  }
}

/// Custom painter for corner decorations.
class _CornerPainter extends CustomPainter {
  final Alignment alignment;
  final Color color;
  final double strokeWidth;
  final double radius;

  _CornerPainter({
    required this.alignment,
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (alignment == Alignment.topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.lineTo(size.width, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - radius);
      path.quadraticBezierTo(0, size.height, radius, size.height);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated scan line widget.
class _AnimatedScanLine extends StatefulWidget {
  const _AnimatedScanLine();

  @override
  State<_AnimatedScanLine> createState() => _AnimatedScanLineState();
}

class _AnimatedScanLineState extends State<_AnimatedScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanLinePainter(
            progress: _animation.value,
            color: AppTheme.primaryLight,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter for the animated scan line.
class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanLinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0),
          color.withOpacity(0.8),
          color.withOpacity(0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromLTWH(0, y - 10, size.width, 20));

    canvas.drawRect(
      Rect.fromLTWH(0, y - 2, size.width, 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
