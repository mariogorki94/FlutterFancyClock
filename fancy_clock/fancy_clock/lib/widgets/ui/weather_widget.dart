import 'dart:math';

import 'package:fancy_clock/constants/app_colors.dart';
import 'package:fancy_clock/widgets/base/circle_painter.dart';
import 'package:fancy_clock/widgets/base/widget_circle.dart';
import 'package:fancy_clock/widgets/implicitly_animated/animated_popper.dart';
import 'package:fancy_clock/widgets/implicitly_animated/animated_rotator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

///Widget which displays [WeatherCondition] and temperatures. This widget is not
///to flood the [FancyClock] with much code.
class WeatherWidget extends StatelessWidget {
  final WeatherCondition condition;
  final String lowTemp;
  final String highTemp;
  final String temperature;

  const WeatherWidget(
      {Key key, this.condition, this.lowTemp, this.highTemp, this.temperature})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final maxRadius = min(c.maxWidth, c.maxHeight);
        final part = maxRadius / 5;
        final conditionRadius = part * 2;
        final tempRadius = part * 5;

        return SizedBox(
          width: maxRadius,
          height: maxRadius,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: -tempRadius,
                left: -tempRadius,
                child: _buildTemperature(
                    tempRadius * 2, tempRadius - conditionRadius),
              ),
              Positioned(
                top: -conditionRadius,
                left: -conditionRadius,
                child: _buildCondition(conditionRadius * 2, conditionRadius),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildCondition(double diam, double width) => AnimatedPopper(
        circleOptions: CircleOptions(
            diameter: diam,
            width: width,
            color: AppColors.dashColor,
            itemPadding: width / 4),
        animDuration: Duration(seconds: 1),
        inCurve: Curves.elasticOut,
        outCurve: Curves.elasticIn,
        minAngle: 180,
        maxAngle: 270,
        rotateWidgets: false,
        widgets: <Widget>[
          Image.asset(
            _mapConditionToAsset(condition),
            key: ValueKey(condition),
          )
        ],
      );

  _buildTemperature(double diam, double width) => AnimatedRotator(
        circleOptions: CircleOptions(
            diameter: diam,
            width: width,
            separatorColor: AppColors.separatorColor,
            color: AppColors.dashColor,
            itemPadding: 16),
        animDuration: Duration(seconds: 2),
        inCurve: Curves.elasticOut,
        outCurve: Curves.elasticIn,
        minAngle: 190,
        maxAngle: 260,
        widgets: <Widget>[
          Padding(
            key: ValueKey(highTemp),
            padding: const EdgeInsets.all(16.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                highTemp ?? '',
                maxLines: 1,
                style: TextStyle(
                    color: AppColors.textSemiTransparent, fontSize: width / 2),
              ),
            ),
          ),
          FittedBox(
            key: ValueKey(temperature),
            fit: BoxFit.scaleDown,
            child: Text(
              temperature ?? '',
              maxLines: 1,
              style: TextStyle(color: AppColors.textColor, fontSize: width / 2),
            ),
          ),
          Padding(
            key: ValueKey(lowTemp),
            padding: const EdgeInsets.all(16.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                lowTemp ?? '',
                maxLines: 1,
                style: TextStyle(
                    color: AppColors.textSemiTransparent, fontSize: width / 2),
              ),
            ),
          )
        ],
        dividers: [
          CircleDivider(
              angle: 190, width: 2, color: AppColors.dividerColor, height: 5),
          CircleDivider(
              angle: 225, width: 2, color: AppColors.dividerColor, height: 10),
          CircleDivider(
              angle: 260, width: 2, color: AppColors.dividerColor, height: 5)
        ],
      );

  String _mapConditionToAsset(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.cloudy:
        return 'assets/res/weather/cloudy.png';
      case WeatherCondition.foggy:
        return 'assets/res/weather/foggy.png';
      case WeatherCondition.rainy:
        return 'assets/res/weather/rainy.png';
      case WeatherCondition.snowy:
        return 'assets/res/weather/snowy.png';
      case WeatherCondition.sunny:
        return 'assets/res/weather/sunny.png';
      case WeatherCondition.thunderstorm:
        return 'assets/res/weather/thunderstorm.png';
      case WeatherCondition.windy:
        return 'assets/res/weather/windy.png';
    }
  }
}
