import 'package:flutter/material.dart';

List<List<Color>> kBgClrs = [
  [Color(0xFF0575e6), Color(0xFF00f260)],
  [Color(0xFFDE00E2), Color(0xFF4A00E0)],
  [Colors.red, Colors.purple],
  [Color(0xFF2C5364), Color(0xFF0f2027)],
  [Color(0xFFf5af19), Color(0xFFf12711)],
  [Color(0xFF1CB5E0), Color(0xFF000046)],
  [Color(0xFF24fe41), Color(0xFFFFFF00)],
];
List<Color> kTxtClrs = [
  Colors.black,
  Colors.white,
  Color(0xFFFF0000),
  Color(0xFF00FF00),
  Color(0xFFFFFF00),
  Color(0xFF097969),
  Color(0xFF0000FF),
  Color(0xFF8B008B),
];

List<String> days = [
  'Monday',
  'Thuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
];

List<String> ayam = [
  'اﻹثنين',
  'الثلاثاء',
  'اﻷربعاء',
  'الخميس',
  'الجمعـة',
  'السبـت',
  'اﻷحـد',
];



String note = '';
bool firstSlide = true,
    showSettings = false,
    showAbout = false,
    closed = false,
    isWalp = true,
    isCenter = true,
    showToast = false;
