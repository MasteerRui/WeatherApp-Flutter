class Daily {
  final List<DailyData> daily;

  Daily({required this.daily});

  factory Daily.fromJson(Map<String, dynamic> json) {
    List<dynamic> dailyList = json['daily'];
    List<DailyData> dailyData =
        dailyList.map((json) => DailyData.fromJson(json)).toList();

    return Daily(daily: dailyData);
  }
}

class DailyData {
  final int dt;
  final double tempmax;
  final double tempmin;
  final List<WeatherDy> weather;

  DailyData(
      {required this.dt,
      required this.tempmax,
      required this.tempmin,
      required this.weather});

  factory DailyData.fromJson(Map<String, dynamic> json) {
    List<dynamic> weatherList = json['weather'];
    List<WeatherDy> weatherData =
        weatherList.map((json) => WeatherDy.fromJson(json)).toList();

    return DailyData(
      dt: json['dt'],
      tempmax: json['temp']['max'].toDouble(),
      tempmin: json['temp']['min'].toDouble(),
      weather: weatherData,
    );
  }
}

class WeatherDy {
  int id;
  String main;
  String description;
  String icon;

  WeatherDy({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherDy.fromJson(Map<String, dynamic> json) {
    return WeatherDy(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}
