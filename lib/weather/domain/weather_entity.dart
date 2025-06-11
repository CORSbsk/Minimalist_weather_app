import 'weather_condition.dart';

class Weather {
  final double temperature;
  final WeatherCondition condition;
  final String? city;

  Weather({
    required this.temperature,
    required this.condition,
    this.city,
  });
} 