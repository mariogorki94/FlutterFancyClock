import 'package:fancy_clock/utils/utils.dart';
import 'package:fancy_clock/widgets/base/circle_painter.dart';
import 'package:fancy_clock/widgets/base/widget_circle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///implicitly animates between list of widget with rotating animation around
///the circle, internally uses [WidgetCircle].
class AnimatedRotator extends StatefulWidget {
  ///the dividers for the [CircleWidget]
  final List<CircleDivider> dividers;

  ///the options for the [CircleWidget]
  final CircleOptions circleOptions;

  ///to rotate the widgets relative to their angle or not
  final bool rotateWidgets;

  ///the min angle the widgets to start from layout the default angle is 0
  final double minAngle;

  ///the max angle the widgets to end to layout the default angle is 90
  final double maxAngle;

  ///the widgets to be placed between [minAngle] and [maxAngle]
  final List<Widget> widgets;

  ///duration of the rotation animation the default is 1 second
  final Duration animDuration;

  ///animation curve for the entry animation the default curve is
  ///[Curves.linear]
  final Curve inCurve;

  ///animation curve for the exit animation if not specified [inCurve] is used
  final Curve outCurve;

  ///animated clockwise or anticlockwise the default is clockwise
  final bool clockwise;

  const AnimatedRotator({
    Key key,
    @required this.circleOptions,
    @required this.widgets,
    this.rotateWidgets,
    this.dividers,
    this.minAngle = 0,
    this.maxAngle = 90,
    this.animDuration = const Duration(seconds: 1),
    this.inCurve = Curves.linear,
    this.outCurve,
    this.clockwise = true,
  })  : assert(circleOptions != null),
        assert(widgets != null),
        super(key: key);

  @override
  _AnimatedRotatorState createState() => _AnimatedRotatorState();
}

class _AnimatedRotatorState extends State<AnimatedRotator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _widgetAnim;
  bool areVisible = false;

  List<Widget> _current = [];
  List<Widget> _pending = [];

  @override
  void initState() {
    _current.addAll(widget.widgets);
    _controller =
        AnimationController(vsync: this, duration: widget.animDuration);

    _controller.addStatusListener(_onStatusChange);
    _startAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.removeStatusListener(_onStatusChange);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedRotator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!compareWidgetList(oldWidget.widgets, widget.widgets)) {
      _pending.clear();
      _pending.addAll(widget.widgets);
      if (_controller.isCompleted) _startAnimation();
    }
  }

  void _startAnimation() {
    final b = areVisible ? 0.0 : 1.0;
    final e = areVisible ? -1.0 : 0.0;

    final c = areVisible ? widget.outCurve ?? widget.inCurve : widget.inCurve;

    _widgetAnim?.removeListener(_onAnimChange);
    _controller?.reset();

    _widgetAnim = Tween<double>(begin: b, end: e)
        .animate(CurvedAnimation(parent: _controller, curve: c));
    _widgetAnim.addListener(_onAnimChange);

    _controller.forward();
  }

  void _onAnimChange() {
    setState(() {});
  }

  void _onStatusChange(AnimationStatus status) async {
    if (status != AnimationStatus.completed) return;

    areVisible = !areVisible;

    ///if the animation is at the invisible state swap the current widgets
    ///with the pending

    if (_pending.isNotEmpty) {
      if (!areVisible) {
        _current.clear();
        _current.addAll(_pending);
        _pending.clear();
      }

      _startAnimation();
    }
  }

  double get _calculateOffset =>
      (widget.clockwise ? -180 : 180) * _widgetAnim.value;

  ///maps the list of widgets to [CircleItem] wrapper which is required
  ///for the [WidgetCircle] calculates the angle of the item to be on equal
  ///distance from the [widget.minAngle] and [widget.maxAngle] and the other
  ///items from the list.
  _mapToItems() => _current
      .asMap()
      .map((i, w) => MapEntry(
          i,
          CircleItem(
            angle: calculateAngle(
                  widget.minAngle,
                  widget.maxAngle,
                  i,
                  _current.length,
                ) +
                _calculateOffset,
            widget: w,
          )))
      .values
      .toList();

  @override
  Widget build(BuildContext context) {
    return WidgetCircle(
      options: widget.circleOptions,
      items: _mapToItems(),
      dividers: widget.dividers,
      rotateWidgets: widget.rotateWidgets,
    );
  }
}
