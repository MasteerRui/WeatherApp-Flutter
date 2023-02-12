import 'dart:ffi';

import 'package:flutter/material.dart';

class Weather {
  Weather({
    required this.cityId,
    required this.cityName,
  });
  num cityId;
  String cityName;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityId: json['id'] ?? 0,
      cityName: json['name'] ?? '',
    );
  }
}

List<Weather> WeatherList = [];
