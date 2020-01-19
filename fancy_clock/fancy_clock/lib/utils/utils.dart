import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

///Compares a list of widget to be identical looks for the keys of the widget
bool compareWidgetList(List<Widget> a, List<Widget> b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index].key != b[index].key) return false;
  }
  return true;
}

///Calculates the distance between the items in a list described by [length]
/// in a circle in specific range of degrees [minAngle], [maxAngle]
double calculateDistance(double minAngle, double maxAngle, int length) {
  final range = (maxAngle - minAngle).abs();
  return range / (length == 1 ? 2 : length - 1);
}

///Calculates the angle of item in list of items described by [index]
///and [length] to be on equal distances from the ends and the other items.
///THe range of angles the items will be populated is described
///by [minAngle] and [maxAngle]
double calculateAngle(double minAngle, double maxAngle, int index, int length) {
  final distance = calculateDistance(minAngle, maxAngle, length);

  return minAngle + distance * (length == 1 ? 1 : index);
}

///Gets wrapped value in a range of [min],[max] and passed value
///if the value is bigger than the range it gets wrapped from the [min] and
///vise - versa.
int wrapValue(int min, int max, int v) {
  int range = max - min + 1;
  v = ((v - min) % range) + range;
  return (v % range) + min;
}

///Gets a point in the circle based on the [angle] and [radius]
Offset getPointInCircle(double radius, double angle) {
  final double rad = radians(angle);

  return Offset(-radius * cos(rad), -radius * sin(rad));
}

///Calculates offset factor from the [middle] in current [position]
/// by maximum [factor]

double calculateOffsetFactor(double middle, double position, double factor) {
  var d0 = 0.0;
  var d1 = 0.1 * middle;
  var s0 = 1.0;
  var s1 = factor;

  var d = min(d1, (middle - position).abs());
  return s0 + (s1 - s0) * (d - d0) / (d1 - d0);
}

///gets random value in range inclusive [min] and exclusive [max]
double randRange(num min, num max) {
  Random _rand = Random();
  return _rand.nextDouble() * (max - min) + min;
}

///loads ui image from assets provided by [imageAssetPath]
Future<ui.Image> loadUiImage(String imageAssetPath) async {
  if (imageAssetPath == null) return null;
  final ByteData data = await rootBundle.load(imageAssetPath);
  final ui.Codec codec =
      await ui.instantiateImageCodec(data.buffer.asUint8List());
  final ui.FrameInfo fi = await codec.getNextFrame();

  return fi.image;
}
