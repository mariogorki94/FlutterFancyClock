import 'dart:math';

import 'package:fancy_clock/constants/app_colors.dart';
import 'package:fancy_clock/models/time_model.dart';
import 'package:fancy_clock/widgets/base/widget_circle.dart';
import 'package:fancy_clock/widgets/implicitly_animated/animated_popper.dart';
import 'package:fancy_clock/widgets/implicitly_animated/animated_ticker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _positionDuration = const Duration(milliseconds: 600);
const _positionCurve = Curves.easeInOut;

///Creates a widget which displays [DateTime] in a 24 hour or 12 hour format.
///This widget is only to not flood [FancyClock] which much code.
class ClockWidget extends StatelessWidget {
  final DateTime time;
  final bool is24Hour;

  const ClockWidget({
    Key key,
    this.time,
    this.is24Hour = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final maxRadius = min(c.maxWidth, c.maxHeight);
        final itemCount = is24Hour ? 3.0 : 4.0;
        final part = maxRadius / itemCount;
        final secondsRadius = is24Hour ? part : part * 2;
        final minutesRadius = is24Hour ? part * 2 : part * 3;
        final hourRadius = is24Hour ? part * 3 : part * 4;

        return SizedBox(
          width: maxRadius,
          height: maxRadius,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedPositioned(
                bottom: -hourRadius,
                right: -hourRadius,
                duration: _positionDuration,
                curve: _positionCurve,
                child: _buildHours(hourRadius * 2, hourRadius - minutesRadius),
              ),
              AnimatedPositioned(
                bottom: -minutesRadius,
                right: -minutesRadius,
                duration: _positionDuration,
                curve: _positionCurve,
                child: _buildMinutes(
                    minutesRadius * 2, minutesRadius - secondsRadius),
              ),
              AnimatedPositioned(
                bottom: -secondsRadius,
                right: -secondsRadius,
                duration: _positionDuration,
                curve: _positionCurve,
                child: _buildSeconds(secondsRadius * 2,
                    is24Hour ? secondsRadius / 1.5 : secondsRadius - part),
              ),
              Positioned(
                bottom: -part,
                right: -part,
                child: AnimatedCrossFade(
                  duration: _positionDuration,
                  sizeCurve: _positionCurve,
                  firstChild: SizedBox.shrink(),
                  secondChild: _buildIsAmPm(part * 2, part),
                  crossFadeState: is24Hour
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildSeconds(
    double diam,
    double width,
  ) =>
      AnimatedTicker(
        circleOptions: CircleOptions(
          diameter: diam,
          width: width,
          color: AppColors.dashColor,
        ),
        animDuration: Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
        dividerOptions: DividerOptions(color: AppColors.dividerColor, width: 2),
        minAngle: 10,
        maxAngle: 80,
        minTick: 0,
        maxTick: 59,
        currentTick: time.second,
        textStyle: TextStyle(color: AppColors.textColor, fontSize: width / 2),
      );

  _buildMinutes(double diam, double width) => AnimatedTicker(
        circleOptions: CircleOptions(
          diameter: diam,
          width: width,
          color: AppColors.dashColor,
        ),
        animDuration: Duration(seconds: 1),
        curve: Curves.elasticInOut,
        dividerOptions: DividerOptions(color: AppColors.dividerColor, width: 2),
        minAngle: 10,
        maxAngle: 80,
        minTick: 0,
        maxTick: 59,
        itemCount: 5,
        currentTick: time.minute,
        textStyle: TextStyle(color: AppColors.textColor, fontSize: width / 2),
      );

  _buildHours(double diam, double width) => AnimatedTicker(
        circleOptions: CircleOptions(
          diameter: diam,
          width: width,
          separatorColor: AppColors.separatorColor,
          color: AppColors.dashColor,
        ),
        animDuration: Duration(seconds: 1),
        curve: Curves.elasticInOut,
        dividerOptions: DividerOptions(color: AppColors.dividerColor, width: 2),
        minAngle: 10,
        maxAngle: 80,
        minTick: is24Hour ? 0 : 1,
        maxTick: is24Hour ? 23 : 12,
        itemCount: 7,
        currentTick:
            is24Hour ? time.hour : TimeOfDay.fromDateTime(time).hourOfPeriod,
        textStyle: TextStyle(color: AppColors.textColor, fontSize: width / 2),
      );

  _buildIsAmPm(double diam, double width) => Consumer<TimeModel>(
        builder: (_, tm, __) => AnimatedPopper(
          circleOptions: CircleOptions(
              diameter: diam,
              width: width,
              color: AppColors.dashColor,
              itemPadding: 14),
          minAngle: 0,
          maxAngle: 90,
          inCurve: Curves.elasticIn,
          outCurve: Curves.elasticOut,
          widgets: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              key: ValueKey(TimeOfDay.fromDateTime(tm.current).period),
              child: Text(
                TimeOfDay.fromDateTime(tm.current).period == DayPeriod.am
                    ? 'AM'
                    : 'PM',
                style:
                    TextStyle(color: AppColors.textColor, fontSize: width / 2),
              ),
            )
          ],
        ),
      );
}
