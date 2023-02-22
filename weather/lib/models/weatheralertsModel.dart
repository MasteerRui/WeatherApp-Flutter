class Alerts {
  final List<AlertsData> alerts;

  Alerts({required this.alerts});

  factory Alerts.fromJson(Map<String, dynamic> json) {
    List<dynamic> alertsList = json['alerts'] ?? '';
    List<AlertsData> alertsData =
        alertsList.map((json) => AlertsData.fromJson(json)).toList();

    return Alerts(alerts: alertsData);
  }
}

class AlertsData {
  final String sender_name;
  final String description;

  AlertsData({
    required this.sender_name,
    required this.description,
  });

  factory AlertsData.fromJson(Map<String, dynamic> json) {
    return AlertsData(
        sender_name: json['event'] ?? 'No Sender Name Available',
        description: json['description'] ?? 'No Description Available');
  }
}

class AlertsY {
  int id;
  String main;
  String description;
  String icon;

  AlertsY({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory AlertsY.fromJson(Map<String, dynamic> json) {
    return AlertsY(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}
