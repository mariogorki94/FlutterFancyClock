import 'package:fancy_clock/constants/app_colors.dart';
import 'package:fancy_clock/widgets/base/bordered_text.dart';
import 'package:fancy_clock/widgets/implicitly_animated/animated_child.dart';
import 'package:fancy_clock/widgets/ui/clock_widget.dart';
import 'package:fancy_clock/widgets/ui/weather_background_widget.dart';
import 'package:fancy_clock/widgets/ui/weather_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/time_model.dart';

class FancyClock extends StatelessWidget {
  final ClockModel clockModel;

  const FancyClock({Key key, this.clockModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///override the default text font
    return DefaultTextStyle(
      style: TextStyle(fontFamily: 'Lato'),

      ///create providers for the widgets beneath it to listen and update
      child: MultiProvider(
        providers: [
          ///The Clock Model which provides weather, location, and config data
          ChangeNotifierProvider.value(value: clockModel),

          ///The Timer Model which provides accurate date and time
          ChangeNotifierProvider(
            create: (_) => TimeModel(),
          )
        ],
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildBackground(),
            _buildClock(),
            _buildWeather(),
            _buildDate(),
            _buildLocation(),
          ],
        ),
      ),
    );
  }

  ///builds the background and the weather effect which are provided by the
  ///[ClockModel]
  _buildBackground() => Consumer<ClockModel>(
        builder: (context, cm, _) =>
            WeatherBackgroundWidget(condition: cm.weatherCondition),
      );

  ///builds the time information of the clock provided by the [TimeModel] and
  ///[ClockModel]
  _buildClock() => Align(
        alignment: Alignment.bottomRight,
        child: FractionallySizedBox(
          heightFactor: 0.75,
          child: Consumer2<ClockModel, TimeModel>(
            builder: (_, cm, tm, __) => ClockWidget(
              is24Hour: cm.is24HourFormat,
              time: tm.current,
            ),
          ),
        ),
      );

  ///builds the weather information of the clock provided by the [ClockModel]
  _buildWeather() => Align(
        alignment: Alignment.topLeft,
        child: FractionallySizedBox(
            heightFactor: 0.6,
            child: Consumer<ClockModel>(
              builder: (_, cm, __) => WeatherWidget(
                condition: cm.weatherCondition,
                temperature: cm.temperatureString,
                lowTemp: cm.lowString,
                highTemp: cm.highString,
              ),
            )),
      );

  ///builds the location of the clock provided by the [ClockModel]
  _buildLocation() => Align(
        alignment: Alignment.topRight,
        child: FractionallySizedBox(
          widthFactor: 0.6,
          heightFactor: 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Selector<ClockModel, String>(
              selector: (_, cm) => cm.location,
              builder: (_, loc, __) => AnimatedChild(
                child: BorderedText(
                  loc,
                  key: ValueKey(loc),
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 42,
                  ),
                  borderColor: AppColors.textBorderColor,
                  castShadow: true,
                ),
              ),
            ),
          ),
        ),
      );

  ///builds the date of the clock provided by the [TimeModel]
  _buildDate() => Align(
        alignment: Alignment.bottomLeft,
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Selector<TimeModel, String>(
              selector: (_, tm) => DateFormat.yMMMd().format(tm.current),
              builder: (_, date, __) => AnimatedChild(
                child: BorderedText(
                  date,
                  key: ValueKey(date),
                  maxLines: 1,
                  style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 42,
                      fontFamily: 'Lato'),
                  borderColor: AppColors.textBorderColor,
                  castShadow: true,
                ),
              ),
            ),
          ),
        ),
      );
}
