import 'dart:ui' as ui;

import 'package:fancy_clock/utils/animation_progress.dart';
import 'package:fancy_clock/utils/utils.dart';
import 'package:fancy_clock/widgets/base/particle_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart';

final double _kStart = -0.4;
final double _kEnd = 1.4;

///Definition of the particle generation and movement
enum ParticleDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

///Class which is used [AnimatedParticleGenerator] to draw particles from images
class _ImageParticle extends Particle {
  ///the image to be drawn
  ui.Image image;

  @override
  void draw(
      Canvas canvas, Paint p, double x, double y, double size, double rot) {
    final rad = radians(rot);

    ///center the x and y in the center of the image because its drawn from the
    ///top left corner
    x -= size / 2;
    y -= size / 2;

    ///rotate the canvas to apply rotation for the image
    canvas.translate(x, y);
    canvas.rotate(rad);
    canvas.translate(-x, -y);

    ///paint the image
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTRB(x, y, x + size, y + size),
        image: image);

    ///rotate the canvas again in the opposite direction to be used from
    /// other particles
    canvas.translate(x, y);
    canvas.rotate(-rad);
    canvas.translate(-x, -y);
  }
}

///Implicitly animated particle generator which animates smoothly between
///different particles if no image or no particle count is provided it stops
/// smoothly when all particles have completed their animations
class AnimatedParticleGenerator extends StatefulWidget {
  ///the image for the particle
  final ui.Image asset;

  ///the min duration in milliseconds for the animation of single particle
  final int minDurationMillis;

  ///the max duration in milliseconds for the animation of single particle
  final int maxDurationMillis;

  ///the minimum size of single particle
  final int minSize;

  ///the maximum size of single particle
  final int maxSize;

  ///minimum rotation during animation
  final int minRotation;

  ///maximum rotation during animation
  final int maxRotation;

  ///the direction the particles are spawned and animated
  final ParticleDirection direction;

  ///particle count to be generated and animated
  final int particleCount;

  const AnimatedParticleGenerator(
      {Key key,
      this.asset,
      this.direction = ParticleDirection.topToBottom,
      this.particleCount = 0,
      @required this.minDurationMillis,
      @required this.maxDurationMillis,
      @required this.minSize,
      @required this.maxSize,
      @required this.minRotation,
      @required this.maxRotation})
      : assert(minDurationMillis != null),
        assert(maxDurationMillis != null),
        assert(minSize != null),
        assert(maxSize != null),
        assert(minRotation != null),
        assert(maxRotation != null),
        super(key: key);

  @override
  _AnimatedParticleGeneratorState createState() =>
      _AnimatedParticleGeneratorState();
}

class _AnimatedParticleGeneratorState extends State<AnimatedParticleGenerator>
    with SingleTickerProviderStateMixin {
  Duration _elapsed;
  Ticker _ticker;
  List<_ImageParticle> _particles = [];

  @override
  void initState() {
    _ticker = createTicker(_onTick);
    super.initState();
  }

  @override
  void dispose() {
    _ticker?.stop(canceled: true);
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedParticleGenerator oldWidget) {
    ///if the particle image is different remove all particles which are not
    ///started yet to be replaced
    if (oldWidget.asset != widget.asset)
      _particles.removeWhere((p) => !p.progress.started(_elapsedTime));

    super.didUpdateWidget(oldWidget);
  }

  ///updates the emitter state every frame during animation
  void _updateEmitterState() {
    ///remove the particles which are completed
    _particles.removeWhere((p) => p.progress.completed(_elapsedTime));

    ///if no particles left and no need of generation stop the ticker to stop
    ///rebuilding the widget
    if (widget.asset == null || widget.particleCount == 0) {
      if (_ticker.isActive && _particles.length == 0) _ticker?.stop();
      return;
    }

    ///check how many particles are missing and fill the particle list
    final count = widget.particleCount - _particles.length;
    for (var i = 0; i < count; i++) {
      _particles.add(_createParticle());
    }

    ///if the ticker is stopped start it again
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  ///creates particle using random generated values in range
  _ImageParticle _createParticle() {
    final dur = Duration(
        milliseconds:
            randRange(widget.minDurationMillis, widget.maxDurationMillis)
                .toInt());

    final start = Duration(
        milliseconds: randRange(_elapsedTime.inMilliseconds,
                _elapsedTime.inMilliseconds + widget.minDurationMillis)
            .toInt());

    final startPos = Offset(_getX(start: true), _getY(start: true));

    final endPos = Offset(_getX(start: false), _getY(start: false));

    return _ImageParticle()
      ..image = widget.asset
      ..rot = Tween<double>(
          begin: randRange(widget.minRotation, widget.maxRotation),
          end: randRange(widget.minRotation, widget.maxRotation))
      ..x = Tween<double>(begin: startPos.dx, end: endPos.dx)
      ..y = Tween<double>(begin: startPos.dy, end: endPos.dy)
      ..size = randRange(widget.minSize, widget.maxSize)
      ..progress = AnimationProgress(duration: dur, startTime: start);
  }

  ///gets the x relative position for the particle depending on the direction
  double _getX({bool start = true}) {
    switch (widget.direction) {
      case ParticleDirection.leftToRight:
        return start ? _kStart : _kEnd;
      case ParticleDirection.rightToLeft:
        return start ? _kEnd : _kStart;
      case ParticleDirection.topToBottom:
        return randRange(0, 1);
      case ParticleDirection.bottomToTop:
        return randRange(0, 1);
    }
  }

  ///gets the y relative position for the particle depending on the direction
  double _getY({bool start = true}) {
    switch (widget.direction) {
      case ParticleDirection.leftToRight:
        return randRange(0, 1);
      case ParticleDirection.rightToLeft:
        return randRange(0, 1);
      case ParticleDirection.topToBottom:
        return start ? _kStart : _kEnd;
      case ParticleDirection.bottomToTop:
        return start ? _kEnd : _kStart;
    }
  }

  ///every tick update the current time
  void _onTick(Duration tick) {
    setState(() {
      _elapsed = tick;
    });
  }

  Duration get _elapsedTime => _elapsed ?? Duration.zero;

  @override
  Widget build(BuildContext context) {
    _updateEmitterState();

    return SizedBox.expand(
      child: CustomPaint(
        painter: ParticlePainter(
          time: _elapsedTime,
          particles: _particles,
        ),
      ),
    );
  }
}
