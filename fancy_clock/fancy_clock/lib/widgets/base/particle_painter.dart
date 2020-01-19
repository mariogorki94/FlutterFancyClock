import 'dart:ui';

import 'package:fancy_clock/utils/animation_progress.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

///Abstraction wrapper for the particles which will be drawn in the canvas
///every class which extends it must provide implementation for the
///draw function
abstract class Particle {
  ///the relative x animation of the particle
  Tween<double> x;

  ///the relative y animation of the particle
  Tween<double> y;

  ///the rotation animation of the particle
  Tween<double> rot;

  ///size of the particle in pixels
  double size;

  ///the animation progress of the particle
  AnimationProgress progress;

  ///Draws a particle on [Canvas] with provided [Paint] anc calculated
  ///absolute x, y, size and rotation parameters.
  void draw(
      Canvas canvas, Paint p, double x, double y, double size, double rot);
}

///The Particle painter draws particles in absolute coordinates for a given
///animation time
class ParticlePainter extends CustomPainter {
  ///The list of particles to be drawn
  final List<Particle> particles;

  ///the current frame of time
  final Duration time;

  ParticlePainter({this.particles, this.time}) : assert(time != null);

  @override
  void paint(Canvas canvas, Size size) {
    final p = new Paint();

    ///clip everything outside of the canvas rectangle so no particles are
    ///visible.
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));

    ///draw the particles
    particles?.forEach(
      (par) {
        ///for each particle calculate the absolute coordinates for the current
        ///frame of time
        final pr = par.progress.progress(time);
        final x = par.x.transform(pr) * size.width;
        final y = par.y.transform(pr) * size.height;
        final rot = par.rot.transform(pr);

        ///call the particle to draw itself on the canvas
        par.draw(canvas, p, x, y, par.size, rot);
      },
    );
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return true;
  }
}
