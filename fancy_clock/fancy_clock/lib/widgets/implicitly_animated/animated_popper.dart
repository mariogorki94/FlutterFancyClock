import 'package:fancy_clock/utils/utils.dart';
import 'package:fancy_clock/widgets/base/circle_painter.dart';
import 'package:fancy_clock/widgets/base/widget_circle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///implicitly animates between list of widget with popping animation, internally
///uses [WidgetCircle] so the widgets are drawn around circle.
class AnimatedPopper extends StatefulWidget {
  ///the options for the [CircleWidget]
  final CircleOptions circleOptions;

  ///the dividers for the [CircleWidget]
  final List<CircleDivider> dividers;

  ///to rotate the widgets relative to their angle or not
  final bool rotateWidgets;

  ///the min angle the widgets to start from layout the default angle is 0
  final double minAngle;

  ///the max angle the widgets to end to layout the default angle is 90
  final double maxAngle;

  ///the widgets to be placed between [minAngle] and [maxAngle]
  final List<Widget> widgets;

  ///duration of the animation
  final Duration animDuration;

  ///animation curve for the entry animation the default curve is
  ///[Curves.linear]
  final Curve inCurve;

  ///animation curve for the exit animation if not specified [inCurve] is used
  final Curve outCurve;

  const AnimatedPopper({
    Key key,
    @required this.widgets,
    @required this.circleOptions,
    this.rotateWidgets,
    this.dividers,
    this.minAngle = 0,
    this.maxAngle = 90,
    this.animDuration = const Duration(seconds: 1),
    this.inCurve = Curves.linear,
    this.outCurve,
  })  : assert(widgets != null),
        assert(circleOptions != null),
        super(key: key);

  @override
  _AnimatedPopperState createState() => _AnimatedPopperState();
}

class _AnimatedPopperState extends State<AnimatedPopper>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _anim;

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
  void didUpdateWidget(AnimatedPopper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!compareWidgetList(oldWidget.widgets, widget.widgets)) {
      _pending.clear();
      _pending.addAll(widget.widgets);
      if (_controller.isCompleted) _startAnimation();
    }
  }

  void _startAnimation() {
    final c = _controller.isCompleted
        ? widget.outCurve ?? widget.inCurve
        : widget.inCurve;

    _anim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: c));

    _controller.isCompleted ? _controller.reverse() : _controller.forward();
  }

  void _onStatusChange(AnimationStatus status) async {
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed) return;

    ///if the animation is at the invisible state swap the current widgets
    ///with the pending
    if (_pending.isNotEmpty) {
      if (_controller.isDismissed) {
        _current.clear();
        _current.addAll(_pending);
        _pending.clear();

        setState(() {});
      }

      _startAnimation();
    }
  }

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
            ),
            widget: _wrapWithTransition(w),
          )))
      .values
      .toList();

  ///wrap every widget with [ScaleTransition] to be animated with the controller
  Widget _wrapWithTransition(Widget w) => ScaleTransition(
        scale: _anim,
        child: w,
      );

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
