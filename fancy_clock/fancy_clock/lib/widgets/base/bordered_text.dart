import 'package:flutter/material.dart';

///Bordered Text is a widget which draws text with border and shadow optionally
///All properties are like the original [Text] widget except the border and
///shadow properties

class BorderedText extends StatelessWidget {
  final String text;

  final TextStyle style;

  final StrutStyle strutStyle;

  final TextAlign textAlign;

  final TextDirection textDirection;

  final Locale locale;

  final bool softWrap;

  final TextOverflow overflow;

  final double textScaleFactor;

  final int maxLines;

  final String semanticsLabel;

  final TextWidthBasis textWidthBasis;

  ///The border width of the text the default is 1.
  final double borderWidth;

  ///The border color of the text the default is [Colors.black]
  final Color borderColor;

  ///To cast or not to cast shadows the default is false
  final bool castShadow;

  const BorderedText(
    this.text, {
    Key key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.borderWidth = 1,
    this.borderColor = Colors.black,
    this.castShadow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: _getStyle(context).copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = borderWidth
                ..color = borderColor),
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
        ),
        Text(
          text,
          style: castShadow
              ? _getStyle(context).copyWith(
                  shadows: [
                    Shadow(
                      offset: Offset(
                        1,
                        1,
                      ),
                      blurRadius: 5,
                    ),
                  ],
                )
              : _getStyle(context),
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
        ),
      ],
    );
  }

  ///if the text style is not defined get the default text style
  TextStyle _getStyle(BuildContext context) =>
      style ?? DefaultTextStyle.of(context).style;
}
