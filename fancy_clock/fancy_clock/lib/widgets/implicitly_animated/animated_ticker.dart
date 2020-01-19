import 'package:fancy_clock/utils/utils.dart';
import 'package:fancy_clock/widgets/base/circle_painter.dart';
import 'package:fancy_clock/widgets/base/widget_circle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///options class for the divider for the ticker
class DividerOptions {
  ///to show dividers or not the default is true
  final bool showDividers;

  ///color of the dividers the default is [Colors.black]
  final Color color;

  ///the width of the dividers the default is 3
  final double width;

  const DividerOptions({
    this.showDividers = true,
    this.color = Colors.black,
    this.width = 3,
  });
}

///Animated ticker implicitly animated between consequence numbers in defined
///range. Internally uses [CircleWidget] to lay out the items in a circle.If
///the next item passed is in neighbour to the current shown it animates by
///sliding the items, if the next item is not neighbour or [minTick], [maxTick]
///is changed it pops the current widgets and shows the new one.
class AnimatedTicker extends StatefulWidget {
  ///the options for the [CircleWidget]
  final CircleOptions circleOptions;

  ///to rotate the widgets relative to their angle or not
  final bool rotateWidgets;

  ///the min angle the widgets to start from layout the default angle is 0
  final double minAngle;

  ///the max angle the widgets to end to layout the default angle is 90
  final double maxAngle;

  ///the divider options for the ticker if not specified the default
  ///[DividerOptions] is used.
  final DividerOptions dividerOptions;

  ///The animation duration if not specified its 300 milliseconds
  final Duration animDuration;

  ///The curve for the animation if not specified [Curves.linear] is used.
  final Curve curve;

  ///The text style for the numbers
  final TextStyle textStyle;

  ///The scale factor for the other numbers which are not the [currentTick]
  ///the default is 0.5
  final double scaleFactor;

  ///The opacity factor for the other numbers which are not the [currentTick]
  ///the default is 0.6
  final double opacityFactor;

  ///how much items to show in the range
  final int itemCount;

  ///the minimum possible number of the ticker
  final int minTick;

  ///the maximum possible number of the ticker
  final int maxTick;

  ///the current number which is focused
  final int currentTick;

  const AnimatedTicker({
    Key key,
    @required this.circleOptions,
    @required this.minTick,
    @required this.maxTick,
    @required this.currentTick,
    this.dividerOptions = const DividerOptions(),
    this.rotateWidgets,
    this.textStyle,
    this.scaleFactor = 0.5,
    this.opacityFactor = 0.6,
    this.itemCount = 3,
    this.minAngle = 0,
    this.maxAngle = 90,
    this.animDuration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
  })  : assert(circleOptions != null),
        assert(minTick != null),
        assert(maxTick != null),
        assert(currentTick != null),
        super(key: key);

  @override
  _AnimatedTickerState createState() => _AnimatedTickerState();
}

class _AnimatedTickerState extends State<AnimatedTicker>
    with TickerProviderStateMixin {
  static const _offsetItemCount = 2;

  AnimationController _rotController;
  AnimationController _scaleController;
  Animation<double> _rotAnim;
  Animation<double> _scaleAnim;
  final Map<int, double> _current = {};
  final Map<int, double> _pending = {};

  @override
  void initState() {
    _rotController =
        AnimationController(vsync: this, duration: widget.animDuration);
    _rotController.addStatusListener(_onRotationStatusChange);
    _scaleController =
        AnimationController(vsync: this, duration: widget.animDuration);
    _scaleController.addStatusListener(_onScaleStatusChange);
    _current.addAll(_generateNextItems());
    _prepareAndStartPopAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _rotController?.removeStatusListener(_onRotationStatusChange);
    _rotController?.dispose();
    _scaleController?.removeStatusListener(_onScaleStatusChange);
    _scaleController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedTicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentTick != widget.currentTick ||
        oldWidget.minTick != widget.minTick ||
        oldWidget.maxTick != widget.maxTick ||
        oldWidget.itemCount != widget.itemCount ||
        oldWidget.maxAngle != widget.maxAngle ||
        oldWidget.minAngle != widget.minAngle) {
      _pending.clear();
      _pending.addAll(_generateNextItems());
    }

    if (_rotController.isAnimating) {
      return;
    }

    ///check do next value is it neighbour to the current
    if (_pending.isNotEmpty) {
      final cti = wrapValue(
          oldWidget.minTick, oldWidget.maxTick, oldWidget.currentTick + 1);
      final ctd = wrapValue(
          oldWidget.minTick, oldWidget.maxTick, oldWidget.currentTick - 1);
      final nt = wrapValue(widget.minTick, widget.maxTick, widget.currentTick);

      ///if its neighbour rotate
      if (cti == nt) {
        _prepareAndStartRotationAnimation(true);
        return;
      }
      if (ctd == nt) {
        _prepareAndStartRotationAnimation(false);
        return;
      }

      ///if not pop
      _prepareAndStartPopAnimation();
    }
  }

  void _prepareAndStartPopAnimation() {
    _scaleAnim?.removeListener(_onAnimChange);

    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _scaleController, curve: widget.curve));
    _scaleAnim?.addListener(_onAnimChange);

    _scaleController.status == AnimationStatus.dismissed
        ? _scaleController.forward()
        : _scaleController.reverse();
  }

  void _prepareAndStartRotationAnimation(bool forward) {
    _rotAnim?.removeListener(_onAnimChange);
    _rotController?.reset();

    _rotAnim = Tween<double>(begin: 0, end: forward ? 1 : -1)
        .animate(CurvedAnimation(parent: _rotController, curve: widget.curve));
    _rotAnim.addListener(_onAnimChange);

    _rotController.forward();
  }

  void _onAnimChange() {
    setState(() {});
  }

  void _onRotationStatusChange(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    if (_pending.isNotEmpty) {
      _current.clear();
      _current.addAll(_pending);
      _pending.clear();
    }
    _rotAnim?.removeListener(_onAnimChange);
    _rotAnim = null;
    _onAnimChange();
  }

  void _onScaleStatusChange(AnimationStatus status) {
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed) return;

    if (status == AnimationStatus.dismissed && _pending.isNotEmpty) {
      _current.clear();
      _current.addAll(_pending);
      _pending.clear();
      _prepareAndStartPopAnimation();
    }
  }

  ///calculates the offset for the items
  double get _calculateOffset =>
      -calculateDistance(widget.minAngle, widget.maxAngle,
          _current.length - _offsetItemCount) *
      (_rotAnim?.value ?? 0);

  ///calculates the scale factor for a certain angle
  double scaleFactor(double angle) => calculateOffsetFactor(
      widget.minAngle + (widget.maxAngle - widget.minAngle) / 2,
      angle,
      widget.scaleFactor);

  ///calculates the opacity factor for a certain angle
  double opacityFactor(double angle) => calculateOffsetFactor(
      widget.minAngle + (widget.maxAngle - widget.minAngle) / 2,
      angle,
      widget.opacityFactor);

  ///generates numbers based on the [minTick], [maxTick], [currentTick]
  Map<int, double> _generateNextItems() {
    final itemCount = widget.itemCount + _offsetItemCount;
    final middle = itemCount ~/ 2;
    final Map<int, double> map = {};

    for (int i = 0; i < itemCount; i++) {
      int offset = i - middle;
      int number = wrapValue(
          widget.minTick, widget.maxTick, widget.currentTick + offset);
      double angle = calculateAngle(
          widget.minAngle, widget.maxAngle, i - 1, widget.itemCount);

      map[number] = angle;
    }

    return map;
  }

  ///Creates a widget for the number at a certain angle
  _getWidget(double a, int i) => ScaleTransition(
        scale: _scaleAnim,
        child: Transform.scale(
          scale: scaleFactor(a),
          child: Opacity(
            opacity: opacityFactor(a),
            child: Text(
              i.toString().padLeft(2, '0'),
              style: widget.textStyle,
            ),
          ),
        ),
      );

  ///maps the generated items to a [CircleItem] to be used in the [CircleWidget]

  _mapToItems() => _current
      .map((i, a) {
        final angle = a + _calculateOffset;
        return MapEntry(
            i,
            CircleItem(
              angle: angle,
              widget: _getWidget(angle, i),
            ));
      })
      .values
      .toList();

  ///maps the dividers for the [CircleWidget]
  _mapToDividers() => _current
      .map((i, a) {
        return MapEntry(
            i,
            CircleDivider(
                angle: a,
                width: widget.dividerOptions.width,
                color: widget.dividerOptions.color,
                height: 6));
      })
      .values
      .toList();

  @override
  Widget build(BuildContext context) {
    return WidgetCircle(
      options: widget.circleOptions,
      items: _mapToItems(),
      dividers: _mapToDividers(),
      rotateWidgets: widget.rotateWidgets,
    );
  }
}
