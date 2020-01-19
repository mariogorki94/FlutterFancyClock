import 'dart:math';

///Wrapper class which holds start time and duration
class AnimationProgress {
  ///the duration of the animation
  final Duration duration;

  ///the start time of the animation
  final Duration startTime;

  AnimationProgress({this.duration, this.startTime})
      : assert(duration != null),
        assert(startTime != null);

  ///calculates the progress of the animation based on [time] passed
  double progress(Duration time) => max(0.0,
      min((time - startTime).inMilliseconds / duration.inMilliseconds, 1.0));

  ///tells is the animation completed based on [time] passed
  bool completed(Duration time) => progress(time) == 1;

  ///tells is the animation started yet based on [time] passed
  bool started(Duration time) => progress(time) > 0;
}
