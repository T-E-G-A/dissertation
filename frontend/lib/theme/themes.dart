import 'package:flutter/material.dart';

const String primaryFont = 'SegoeUI';
const String fancyFont = 'RomelyPersonal';

TextStyle customTextStyle({
  String fontFamily = primaryFont,
  double fontSize = 16.0,
  FontStyle fontStyle = FontStyle.normal,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.black,
}) {
  return TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontStyle: fontStyle,
    fontWeight: fontWeight,
    color: color,
  );
}