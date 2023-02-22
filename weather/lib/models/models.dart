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
  final num feelslike;
  final num pressure;

  TemperatureInfo(
      {required this.temperature,
      required this.humidity,
      required this.feelslike,
      required this.pressure});

  factory TemperatureInfo.fromJson(Map<String, dynamic> json) {
    final temperature = json['temp'];
    final humidity = json['humidity'];
    final feelslike = json['feels_like'];
    final pressure = json['pressure'];
    return TemperatureInfo(
        temperature: temperature,
        humidity: humidity,
        feelslike: feelslike,
        pressure: pressure);
  }
}

class LocsInfo {
  final num lat;
  final num lon;

  LocsInfo({required this.lat, required this.lon});

  factory LocsInfo.fromJson(Map<String, dynamic> json) {
    final lat = json['lat'];
    final lon = json['lon'];
    return LocsInfo(lat: lat, lon: lon);
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
  final num visibility;
  final TemperatureInfo tempInfo;
  final LocsInfo locsInfo;
  final WindInfo windInfo;
  final WeatherInfo weatherInfo;

  String get iconUrl {
    return 'https://openweathermap.org/img/wn/${weatherInfo.icon}@2x.png';
  }

  WeatherResponse(
      {required this.cityName,
      required this.tempInfo,
      required this.visibility,
      required this.locsInfo,
      required this.windInfo,
      required this.weatherInfo,
      required this.timezone});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final cityName = json['name'] ?? '';
    final timezone = json['timezone'] ?? 0;
    final visibility = json['visibility'] / 1000;

    final tempInfoJson = json['main'];
    final tempInfo = TemperatureInfo.fromJson(tempInfoJson);

    final locsInfoJson = json['coord'];
    final locsInfo = LocsInfo.fromJson(locsInfoJson);

    final windInfoJson = json['wind'];
    final windInfo = WindInfo.fromJson(windInfoJson);

    final weatherInfoJson = json['weather'][0];
    final weatherInfo = WeatherInfo.fromJson(weatherInfoJson);

    return WeatherResponse(
        cityName: cityName,
        timezone: timezone,
        visibility: visibility,
        tempInfo: tempInfo,
        locsInfo: locsInfo,
        windInfo: windInfo,
        weatherInfo: weatherInfo);
  }
}
