class Hourly {
  final List<HourlyData> hourly;

  Hourly({required this.hourly});

  factory Hourly.fromJson(Map<String, dynamic> json) {
    List<dynamic> hourlyList = json['hourly'];
    List<HourlyData> hourlyData =
        hourlyList.map((json) => HourlyData.fromJson(json)).toList();

    return Hourly(hourly: hourlyData);
  }
}

class HourlyData {
  final int dt;
  final double temp;
  final double feelsLike;
  final int pressure;
  final int humidity;
  final double dewPoint;
  final double uvi;
  final int clouds;
  final int visibility;
  final double windSpeed;
  final int windDeg;
  final double windGust;
  final List<WeatherHr> weather;
  final double pop;

  HourlyData({
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.dewPoint,
    required this.uvi,
    required this.clouds,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    required this.windGust,
    required this.weather,
    required this.pop,
  });

  factory HourlyData.fromJson(Map<String, dynamic> json) {
    List<dynamic> weatherList = json['weather'];
    List<WeatherHr> weatherData =
        weatherList.map((json) => WeatherHr.fromJson(json)).toList();

    return HourlyData(
      dt: json['dt'],
      temp: json['temp'].toDouble(),
      feelsLike: json['feels_like'].toDouble(),
      pressure: json['pressure'],
      humidity: json['humidity'],
      dewPoint: json['dew_point'].toDouble(),
      uvi: json['uvi'].toDouble(),
      clouds: json['clouds'],
      visibility: json['visibility'],
      windSpeed: json['wind_speed'].toDouble(),
      windDeg: json['wind_deg'],
      windGust: json['wind_gust'].toDouble(),
      weather: weatherData,
      pop: json['pop'].toDouble(),
    );
  }
}

class WeatherHr {
  int id;
  String main;
  String description;
  String icon;

  WeatherHr({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherHr.fromJson(Map<String, dynamic> json) {
    return WeatherHr(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}
