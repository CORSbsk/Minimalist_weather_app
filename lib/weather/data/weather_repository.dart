import '../domain/weather_entity.dart';
import '../domain/weather_condition.dart';
import 'weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService api;
  WeatherRepository(this.api);

  Future<Weather> getWeather(double lat, double lon) async {
    final result = await api.fetchWeather(lat, lon);
    final condition = mapWeatherCodeToCondition(result.weatherCode);
    return Weather(
      temperature: result.temperature,
      condition: condition,
      city: result.city,
    );
  }
} 