import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;
  final Color color;
  final double strokeWidth;

  DrawingPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Draw lines between points
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Check if this is a break point (out of bounds)
      if (p1.offset.dx < 0 || p1.offset.dy < 0) continue;
      if (p2.offset.dx < 0 || p2.offset.dy < 0) continue;

      final paint = Paint()
        ..color = p1.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = p1.strokeWidth;

      canvas.drawLine(p1.offset, p2.offset, paint);
    }

    // Draw current points as dots if only single point
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (p.offset.dx < 0 || p.offset.dy < 0) continue;

      // Don't redraw if already connected to next point
      if (i < points.length - 1) {
        final nextP = points[i + 1];
        if (nextP.offset.dx >= 0 && nextP.offset.dy >= 0) continue;
      }

      final paint = Paint()
        ..color = p.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawCircle(p.offset, p.strokeWidth / 2, paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late List<DrawingPoint> points;
  late Color selectedColor;
  late double strokeWidth;
  final GlobalKey _customPaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    points = [];
    selectedColor = Colors.black;
    strokeWidth = 4.0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      points.add(
        DrawingPoint(
          offset: details.localPosition,
          color: selectedColor,
          strokeWidth: strokeWidth,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Add separator point to break line
    points.add(
      DrawingPoint(
        offset: Offset(-1, -1), // Out of bounds marker
        color: Colors.transparent,
        strokeWidth: 0,
      ),
    );
  }

  _clear() {
    setState(() {
      points.clear();
    });
  }

  Future<Uint8List?> _captureDrawing() async {
    try {
      final renderObj = _customPaintKey.currentContext?.findRenderObject();
      if (renderObj is! RenderRepaintBoundary) return null;
      final image = await renderObj.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Lỗi capture vẽ: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viết Tay/Vẽ'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: FilledButton.tonal(
                onPressed: _clear,
                child: const Text('Xóa'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Drawing canvas
          Expanded(
            child: RepaintBoundary(
              key: _customPaintKey,
              child: Container(
                color: Colors.white,
                child: GestureDetector(
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: DrawingPainter(
                      points: points,
                      color: selectedColor,
                      strokeWidth: strokeWidth,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colorScheme.outline)),
            ),
            child: Column(
              children: [
                // Color picker
                Row(
                  children: [
                    Text(
                      'Màu sắc:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 12),
                    ...[
                      Colors.black,
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.purple,
                      Colors.orange,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 12),
                // Stroke width slider
                Row(
                  children: [
                    Text(
                      'Độ dày:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: strokeWidth,
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: strokeWidth.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            strokeWidth = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (points.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng vẽ cái gì đó'),
                          ),
                        );
                        return;
                      }
                      final drawingBytes = await _captureDrawing();
                      if (drawingBytes != null && mounted) {
                        Navigator.pop(context, drawingBytes);
                      }
                    },
                    child: const Text('Lưu Vẽ'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
