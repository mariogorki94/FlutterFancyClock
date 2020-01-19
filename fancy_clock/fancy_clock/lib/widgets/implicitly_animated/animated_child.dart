import 'package:flutter/material.dart';

///Implicitly animated widget which transition from one widget to another.
class AnimatedChild extends StatelessWidget {
  ///the widget to be drawn
  final Widget child;

  ///the animation curve of the transition the default is [Curves.linear]
  final Curve curve;

  ///the duration of the animation the default is 1 second
  final Duration duration;

  const AnimatedChild({
    Key key,
    @required this.child,
    this.curve = Curves.linear,
    this.duration = const Duration(seconds: 1),
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: curve,
        switchOutCurve: curve,
        child: child,
      ),
    );
  }
}
