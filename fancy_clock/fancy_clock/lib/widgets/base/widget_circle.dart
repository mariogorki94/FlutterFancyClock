import 'package:fancy_clock/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'circle_painter.dart';

const _animDuration = Duration(milliseconds: 200);

///Wrapper class for the items to be drawn around the circle
class CircleItem {
  ///the angle the item to be drawn
  final double angle;

  ///the widget to be drawn at the specified angle
  final Widget widget;

  CircleItem({
    @required this.angle,
    @required this.widget,
  })  : assert(angle != null),
        assert(widget != null);
}

///Wrapper class for the options for the circle
class CircleOptions {
  ///the diameter of the circle
  final double diameter;

  ///the width of the circle
  final double width;

  ///padding for the items around the border of the circle
  final double itemPadding;

  ///color of the circle
  final Color color;

  ///separator color for the end of the circle
  final Color separatorColor;

  CircleOptions(
      {this.diameter,
      this.width,
      this.itemPadding = 0,
      this.color,
      this.separatorColor})
      : assert(diameter != null),
        assert(width != null),
        assert(color != null);
}

///Widget which wraps the [CirclePainter] , [CircleDivider] and [CircleItem]
/// to draw a circle with items around its radius. It implicitly animates the
/// circle [color], [diameter] and [width]
class WidgetCircle extends StatefulWidget {
  ///options for the circle
  final CircleOptions options;

  ///dividers for the circle
  final List<CircleDivider> dividers;

  ///items around the circle
  final List<CircleItem> items;

  /// to rotate the widgets relative to their angle or not
  final bool rotateWidgets;

  const WidgetCircle({
    Key key,
    @required this.options,
    this.items,
    this.dividers,
    this.rotateWidgets,
  })  : assert(options != null),
        super(key: key);

  @override
  _WidgetCircleState createState() => _WidgetCircleState();
}

class _WidgetCircleState extends State<WidgetCircle>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<Color> _colorAnim;

  Animation<double> _widthAnim;

  Animation<double> _diameterAnim;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: _animDuration);
    _controller.addListener(_onAnimChange);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WidgetCircle oldWidget) {
    super.didUpdateWidget(oldWidget);

    _colorAnim =
        ColorTween(begin: oldWidget.options.color, end: widget.options.color)
            .animate(_controller);

    _widthAnim =
        Tween<double>(begin: oldWidget.options.width, end: widget.options.width)
            .animate(_controller);

    _diameterAnim = Tween<double>(
            begin: oldWidget.options.diameter, end: widget.options.diameter)
        .animate(_controller);

    _controller.reset();
    _controller.forward();
  }

  Color get _color => _colorAnim?.value ?? widget.options.color;

  double get _width => _widthAnim?.value ?? widget.options.width;

  double get _diameter => _diameterAnim?.value ?? widget.options.diameter;

  void _onAnimChange() {
    setState(() {});
  }

  ///creates list of wrapped item from the [widget.items] with a matrix
  ///of transformations
  List<Widget> _createMatrixWrappers() =>
      widget?.items
          ?.map((i) => _calculateMatrix(i.angle, i.widget))
          ?.toList() ??
      [];

  ///calculates and creates a matrix for wrapper for a widget
  Widget _calculateMatrix(double angle, Widget w) {
    final double rotRad =
        radians((widget.rotateWidgets ?? true) ? angle % 180 : angle / 180);
    final middleRadius = (_diameter / 2 - _width / 2);
    final coordinates = getPointInCircle(middleRadius, angle);
    final size = _width - widget.options.itemPadding * 2;
    return Transform(
      origin: Offset(size / 2, size / 2),
      transform: Matrix4.identity()
        ..translate(coordinates.dx, coordinates.dy)
        ..rotate(Vector3(0, 0, 1), rotRad),
      child: Container(
        constraints: BoxConstraints.loose(Size(size, size)),
        alignment: Alignment.center,
        child: w,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: _diameter,
        height: _diameter,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              width: _diameter,
              height: _diameter,
              child: CustomPaint(
                painter: CirclePainter(
                  color: _color,
                  width: _width,
                  separatorColor: widget.options.separatorColor,
                  dividers: widget.dividers,
                ),
              ),
            ),
            ..._createMatrixWrappers(),
          ],
        ),
      ),
    );
  }
}
