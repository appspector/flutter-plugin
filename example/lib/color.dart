import 'package:flutter/material.dart';

const _primaryColor = 0xFF424250;
const _accentColor = 0xFFF6637D;

const MaterialAccentColor appSpectorAccent = MaterialAccentColor(
  _accentColor,
  <int, Color>{},
);

const appSpectorPrimary = MaterialColor(_primaryColor, <int, Color>{
  50: Color(_primaryColor),
  100: Color(_primaryColor),
  200: Color(_primaryColor),
  300: Color(_primaryColor),
  400: Color(_primaryColor),
  500: Color(_primaryColor),
  600: Color(_primaryColor),
  700: Color(_primaryColor),
  800: Color(_primaryColor),
  900: Color(_primaryColor),
});
