import '../data/weather_repository.dart';
import 'weather_entity.dart';

class GetWeatherUseCase {
  final WeatherRepository repository;
  GetWeatherUseCase(this.repository);

  Future<Weather> call(double lat, double lon) {
    return repository.getWeather(lat, lon);
  }
} 