import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

/// Widget to generate app icon
class AppIconGenerator extends StatelessWidget {
  const AppIconGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1024,
      height: 1024,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFE9ECEF),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFDEE2E6),
          width: 8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // "Hello" text
          Positioned(
            top: 320,
            left: 0,
            right: 0,
            child: Transform.rotate(
              angle: -0.15, // ~8 degrees
              child: Text(
                'Hello',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 140,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF3B30), // Red
                  fontFamily: 'Arial',
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(4, 6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // "World" text
          Positioned(
            top: 480,
            left: 0,
            right: 0,
            child: Transform.rotate(
              angle: 0.08, // ~5 degrees
              child: Text(
                'World',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 140,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF007AFF), // Blue
                  fontFamily: 'Arial',
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(4, 6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sparkles
          Positioned(
            top: 180,
            left: 160,
            child: Transform.rotate(
              angle: 0.3,
              child: const Icon(
                Icons.auto_awesome,
                size: 40,
                color: Color(0xFFFFD700),
              ),
            ),
          ),
          Positioned(
            top: 160,
            right: 160,
            child: Transform.rotate(
              angle: -0.4,
              child: const Icon(
                Icons.auto_awesome,
                size: 35,
                color: Color(0xFFFFD700),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: 140,
            child: Transform.rotate(
              angle: 0.5,
              child: const Icon(
                Icons.auto_awesome,
                size: 30,
                color: Color(0xFFFFD700),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            right: 140,
            child: Transform.rotate(
              angle: -0.3,
              child: const Icon(
                Icons.auto_awesome,
                size: 38,
                color: Color(0xFFFFD700),
              ),
            ),
          ),
          // Hearts
          Positioned(
            top: 300,
            left: 200,
            child: Transform.rotate(
              angle: 0.2,
              child: Icon(
                Icons.favorite,
                size: 25,
                color: Colors.pink.withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            bottom: 280,
            right: 200,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.favorite,
                size: 30,
                color: Colors.pink.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generate PNG from this widget
  static Future<Uint8List> generatePng() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);
    
    // Paint background
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      480,
      paint,
    );
    
    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFDEE2E6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      480,
      borderPaint,
    );
    
    // Draw "Hello" text
    final helloTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Hello',
        style: TextStyle(
          fontSize: 140,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF3B30),
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    helloTextPainter.layout();
    
    canvas.save();
    canvas.translate(size.width / 2, 390);
    canvas.rotate(-0.15);
    helloTextPainter.paint(canvas, Offset(-helloTextPainter.width / 2, -helloTextPainter.height / 2));
    canvas.restore();
    
    // Draw "World" text
    final worldTextPainter = TextPainter(
      text: const TextSpan(
        text: 'World',
        style: TextStyle(
          fontSize: 140,
          fontWeight: FontWeight.bold,
          color: Color(0xFF007AFF),
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    worldTextPainter.layout();
    
    canvas.save();
    canvas.translate(size.width / 2, 580);
    canvas.rotate(0.08);
    worldTextPainter.paint(canvas, Offset(-worldTextPainter.width / 2, -worldTextPainter.height / 2));
    canvas.restore();
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
