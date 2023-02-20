class WeatherInfo {
  final String description;
  final String icon;

  WeatherInfo({required this.description, required this.icon});

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final description = json['main'];
    final icon = json['icon'];
    return WeatherInfo(description: description, icon: icon);
  }
}

class TemperatureInfo {
  final num temperature;
  final num humidity;

  TemperatureInfo({required this.temperature, required this.humidity});

  factory TemperatureInfo.fromJson(Map<String, dynamic> json) {
    final temperature = json['temp'];
    final humidity = json['humidity'];
    return TemperatureInfo(temperature: temperature, humidity: humidity);
  }
}

class WindInfo {
  final num windspeed;
  final num winddeg;

  WindInfo({required this.windspeed, required this.winddeg});

  factory WindInfo.fromJson(Map<String, dynamic> json) {
    final windspeed = json['speed'] * 3.6;
    final winddeg = json['deg'];
    return WindInfo(windspeed: windspeed, winddeg: winddeg);
  }
}

class WeatherResponse {
  final String cityName;
  final num timezone;
  final TemperatureInfo tempInfo;
  final WindInfo windInfo;
  final WeatherInfo weatherInfo;

  String get iconUrl {
    return 'https://openweathermap.org/img/wn/${weatherInfo.icon}@2x.png';
  }

  WeatherResponse(
      {required this.cityName,
      required this.tempInfo,
      required this.windInfo,
      required this.weatherInfo,
      required this.timezone});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final cityName = json['name'] ?? '';
    final timezone = json['timezone'] ?? 0;

    final tempInfoJson = json['main'];
    final tempInfo = TemperatureInfo.fromJson(tempInfoJson);

    final windInfoJson = json['wind'];
    final windInfo = WindInfo.fromJson(windInfoJson);

    final weatherInfoJson = json['weather'][0];
    final weatherInfo = WeatherInfo.fromJson(weatherInfoJson);

    return WeatherResponse(
        cityName: cityName,
        timezone: timezone,
        tempInfo: tempInfo,
        windInfo: windInfo,
        weatherInfo: weatherInfo);
  }
}
