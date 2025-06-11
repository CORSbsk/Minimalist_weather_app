import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApiService {
  Future<WeatherApiResult> fetchWeather(double lat, double lon) async {
    final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final current = data['current_weather'];
      final temp = current['temperature'] as num;
      final code = current['weathercode'] as int? ?? 0;
      // Obtener ciudad y estado con geocoding inverso
      final place = await fetchPlaceName(lat, lon);
      return WeatherApiResult(
        temperature: temp.toDouble(),
        weatherCode: code,
        city: place,
      );
    } else {
      throw Exception('Error al obtener el clima');
    }
  }

  Future<String?> fetchPlaceName(double lat, double lon) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1';
    final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'FlutterWeatherApp/1.0'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final address = data['address'];
      final city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'];
      final state = address['state'];
      if (city != null && state != null) {
        return '$city, $state';
      } else if (state != null) {
        return state;
      } else if (city != null) {
        return city;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}

class WeatherApiResult {
  final double temperature;
  final int weatherCode;
  final String? city;
  WeatherApiResult({required this.temperature, required this.weatherCode, this.city});
} 