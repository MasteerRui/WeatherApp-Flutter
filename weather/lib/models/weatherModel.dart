import 'dart:ffi';

import 'package:flutter/material.dart';

class Weather {
  Weather(
      {required this.cityId,
      required this.cityName,
      required this.cityTemp,
      required this.cityHtemp,
      required this.cityLtemp,
      required this.cityHour,
      required this.cityTimezone,
      required this.cityTempDesc});
  num cityId;
  String cityName;
  num cityHour;
  num cityTimezone;
  String cityTempDesc;
  num cityTemp;
  num cityHtemp;
  num cityLtemp;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityId: json['id'] ?? 0,
      cityName: json['name'] ?? '',
      cityHour: json['dt'] ?? 0,
      cityTimezone: json['sys']['timezone'] ?? 0,
      cityTempDesc: json['weather'][0]['description'] ?? '',
      cityTemp: json['main']['temp'] ?? 0,
      cityHtemp: json['main']['temp_max'] ?? 0,
      cityLtemp: json['main']['temp_min'] ?? 0,
    );
  }
}

List<Weather> WeatherList = [];
