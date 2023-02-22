import 'dart:ffi';

import 'package:flutter/material.dart';

class WeatherCurrent {
  WeatherCurrent({
    required this.cityUiv,
  });
  num cityUiv;

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) {
    return WeatherCurrent(
      cityUiv: json['current']['uvi'] ?? 0,
    );
  }
}

List<WeatherCurrent> WeatherCurrentList = [];
