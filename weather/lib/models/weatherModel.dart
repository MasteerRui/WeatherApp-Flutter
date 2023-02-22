import 'dart:ffi';

import 'package:flutter/material.dart';

class Weather {
  Weather(
      {required this.citylon,
      required this.citylat,
      required this.cityId,
      required this.cityName,
      required this.cityTemp,
      required this.cityHtemp,
      required this.cityLtemp,
      required this.cityHour,
      required this.cityTimezone,
      required this.cityTempDesc,
      required this.cityIcon,
      required this.cityWdeg,
      required this.cityWspeed,
      required this.cityfeelslike,
      required this.cityhumidity,
      required this.citypressure,
      required this.cityVisi});
  num citylon;
  num citylat;
  num cityId;
  String cityName;
  num cityHour;
  num cityTimezone;
  String cityTempDesc;
  String cityIcon;
  num cityTemp;
  num cityHtemp;
  num cityLtemp;
  num cityfeelslike;
  num citypressure;
  num cityhumidity;
  num cityWspeed;
  num cityWdeg;
  num cityVisi;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      citylon: json['coord']['lon'] ?? 0,
      citylat: json['coord']['lat'] ?? 0,
      cityId: json['id'] ?? 0,
      cityName: json['name'] ?? '',
      cityIcon: json['weather'][0]['icon'] ?? '',
      cityHour: json['dt'] ?? 0,
      cityTimezone: json['sys']['timezone'] ?? 0,
      cityTempDesc: json['weather'][0]['description'] ?? '',
      cityTemp: json['main']['temp'] ?? 0,
      cityHtemp: json['main']['temp_max'] ?? 0,
      cityLtemp: json['main']['temp_min'] ?? 0,
      cityfeelslike: json['main']['feels_like'] ?? 0,
      citypressure: json['main']['pressure'] ?? 0,
      cityhumidity: json['main']['humidity'] ?? 0,
      cityWspeed: json['wind']['speed'] ?? 0,
      cityWdeg: json['wind']['deg'] ?? 0,
      cityVisi: json['visibility'] / 1000 ?? 0,
    );
  }
}

List<Weather> WeatherList = [];
