import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BackgroundCircle(),
      child: Container(),
    );
  }
}

class BackgroundCircle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Color(0xFFFAFAFA);

    // Create a rectangle with size and width same as the canvas
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // draw the rectangle using the paint
    canvas.drawRect(rect, paint);

    // set the color property of the paint
    paint.color = Color(0xFFF2F4FB);

    // center of the canvas is (x,y) => (width/2, height/2)
    var center = Offset(size.width, 0);

    // draw the circle with center having radius 75.0
    canvas.drawCircle(center, size.width * 0.70, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
