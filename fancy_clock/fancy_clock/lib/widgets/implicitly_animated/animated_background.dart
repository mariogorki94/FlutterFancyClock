import 'package:flutter/material.dart';

///Implicitly animated widget which animates between images, and blends between
///images.
class AnimatedBackground extends StatefulWidget {
  ///the asset path of the image
  final String asset;

  ///the color to be blended into the image
  final Color blend;

  ///the blend mode of the interpolation
  final BlendMode mode;

  ///duration of the animation the default is 1 second
  final Duration duration;

  ///curve of the animation the default is [Curves.linear]
  final Curve curve;

  const AnimatedBackground({
    Key key,
    @required this.asset,
    this.blend,
    this.mode = BlendMode.color,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.linear,
  })  : assert(asset != null),
        super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> _colorAnim;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(_onAnimChange);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onAnimChange);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    _colorAnim = ColorTween(
            begin: oldWidget.blend ?? Colors.transparent, end: widget.blend)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.reset();
    _controller.forward();
  }

  void _onAnimChange() {
    setState(() {});
  }

  Color get _overlay => _colorAnim?.value ?? widget.blend;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      switchInCurve: widget.curve,
      switchOutCurve: widget.curve,
      child: Image.asset(
        widget.asset,
        key: ValueKey(widget.asset),
        width: double.maxFinite,
        height: double.maxFinite,
        fit: BoxFit.cover,
        color: _overlay,
        colorBlendMode: widget.mode,
      ),
    );
  }
}
