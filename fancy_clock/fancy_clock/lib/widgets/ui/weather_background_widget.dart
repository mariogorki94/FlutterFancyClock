import 'dart:ui' as ui;

import 'package:fancy_clock/constants/app_colors.dart';
import 'package:fancy_clock/utils/utils.dart';
import 'package:fancy_clock/widgets/implicitly_animated/animated_background.dart';
import 'package:fancy_clock/widgets/implicitly_animated/animated_particle_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

const _changeDuration = const Duration(seconds: 1);

const _effectMap = const {
  WeatherCondition.foggy: EffectData(
    asset: 'assets/res/particles/fog.png',
    minDurationMillis: 15000,
    maxDurationMillis: 20000,
    minSize: 300,
    maxSize: 500,
    minRotation: 0,
    maxRotation: 0,
    direction: ParticleDirection.rightToLeft,
    particleCount: 15,
  ),
  WeatherCondition.rainy: EffectData(
    asset: 'assets/res/particles/water.png',
    minDurationMillis: 1500,
    maxDurationMillis: 2000,
    minSize: 7,
    maxSize: 12,
    minRotation: 0,
    maxRotation: 15,
    direction: ParticleDirection.topToBottom,
    particleCount: 50,
  ),
  WeatherCondition.snowy: EffectData(
    asset: 'assets/res/particles/snow.png',
    minDurationMillis: 3000,
    maxDurationMillis: 7000,
    minSize: 20,
    maxSize: 40,
    minRotation: 0,
    maxRotation: 720,
    direction: ParticleDirection.topToBottom,
    particleCount: 25,
  ),
  WeatherCondition.windy: EffectData(
    asset: 'assets/res/particles/leaf.png',
    minDurationMillis: 1000,
    maxDurationMillis: 5000,
    minSize: 20,
    maxSize: 50,
    minRotation: 0,
    maxRotation: 720,
    direction: ParticleDirection.leftToRight,
    particleCount: 10,
  ),
};

///Widget which creates background and particle effect based on the
///[Theme.brightness] and [WeatherCondition] this which is only to not flood
///[FancyClock] with much code
class WeatherBackgroundWidget extends StatelessWidget {
  final WeatherCondition condition;

  const WeatherBackgroundWidget({Key key, this.condition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effect = _getEffect(condition);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AnimatedBackground(
          duration: _changeDuration,
          asset: Theme.of(context).brightness == Brightness.dark
              ? 'assets/res/bg/night.png'
              : 'assets/res/bg/day.png',
          blend: _mapWeatherConditionToColor(condition),
        ),
        FutureBuilder<ui.Image>(
          future: loadUiImage(effect.asset),
          builder: (_, snap) => AnimatedParticleGenerator(
            asset: snap.data,
            minDurationMillis: effect.minDurationMillis,
            maxDurationMillis: effect.maxDurationMillis,
            minSize: effect.minSize,
            maxSize: effect.maxSize,
            minRotation: effect.minRotation,
            maxRotation: effect.maxRotation,
            particleCount: effect.particleCount,
            direction: effect.direction,
          ),
        ),
      ],
    );
  }

  Color _mapWeatherConditionToColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.cloudy:
        return AppColors.cloudyColor;
      case WeatherCondition.foggy:
        return AppColors.fogColor;
      case WeatherCondition.rainy:
        return AppColors.rainColor;
      case WeatherCondition.snowy:
        return AppColors.snowColor;
      case WeatherCondition.sunny:
        return Colors.transparent;
      case WeatherCondition.thunderstorm:
        return AppColors.thunderstormColor;
      case WeatherCondition.windy:
        return Colors.transparent;
    }
  }

  EffectData _getEffect(WeatherCondition condition) =>
      _effectMap[condition] ?? EffectData();
}

class EffectData {
  final String asset;

  final int minDurationMillis;

  final int maxDurationMillis;

  final int minSize;

  final int maxSize;

  final int minRotation;

  final int maxRotation;

  final ParticleDirection direction;

  final int particleCount;

  const EffectData({
    this.asset,
    this.minDurationMillis = 0,
    this.maxDurationMillis = 0,
    this.minSize = 0,
    this.maxSize = 0,
    this.minRotation = 0,
    this.maxRotation = 0,
    this.direction = ParticleDirection.leftToRight,
    this.particleCount = 0,
  });
}
