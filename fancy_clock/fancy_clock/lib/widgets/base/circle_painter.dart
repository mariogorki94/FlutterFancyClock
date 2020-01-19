import 'dart:math';

import 'package:fancy_clock/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///Class to wrap the properties of divider lines which to be drawn in the circle
class CircleDivider {
  ///the angle the divider to be in the circle the default is 0
  final double angle;

  ///the width of the divider the default is 5
  final double width;

  ///the height of the divider the default is 10.
  final double height;

  ///the color of the divider the default is [Colors.black].
  final Color color;

  const CircleDivider({
    this.angle = 0,
    this.width = 5,
    this.height = 10,
    this.color = Colors.black,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircleDivider &&
          runtimeType == other.runtimeType &&
          angle == other.angle &&
          width == other.width &&
          height == other.height &&
          color == other.color;

  @override
  int get hashCode =>
      angle.hashCode ^ width.hashCode ^ height.hashCode ^ color.hashCode;
}

///Custom Painter to paint a circle with width
class CirclePainter extends CustomPainter {
  ///The color of the circle
  final Color color;

  ///the width of the circle
  final double width;

  ///to draw elevation or not
  final Color separatorColor;

  ///the dividers to draw
  final List<CircleDivider> dividers;

  ///Create [CirclePainter] all [color] and [width] are required
  CirclePainter({
    @required this.color,
    @required this.width,
    this.separatorColor,
    this.dividers,
  })  : assert(color != null),
        assert(width != null);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    ///get the radius based on the width and the size so the circle
    ///don`t draw outside the box

    final outsideRadius = min(size.width, size.height) / 2;
    final middleRadius = outsideRadius - width / 2;
    final innerRadius = outsideRadius - width;

    final Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;

    final Paint dp = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    ///draw the circle
    canvas.drawCircle(center, middleRadius, paint);

    ///draw separator if defined
    if (separatorColor != null) {
      final Paint sp = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = separatorColor;

      canvas.drawCircle(center, outsideRadius, sp);
    }

    ///draw the dividers
    canvas.translate(outsideRadius, outsideRadius);
    dividers?.forEach((di) {
      dp.color = di.color;
      dp.strokeWidth = di.width;

      final c1 = getPointInCircle(innerRadius + di.width / 2, di.angle);
      final c2 = getPointInCircle(innerRadius + di.height, di.angle);
      canvas.drawLine(c1, c2, dp);
    });
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      !listEquals(oldDelegate.dividers, dividers);
}
