import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/get_weather_usecase.dart';
import '../domain/weather_entity.dart';
import 'package:geolocator/geolocator.dart';

class WeatherState {
  final bool isLoading;
  final Weather? weather;
  final String? error;

  WeatherState({this.isLoading = false, this.weather, this.error});

  WeatherState copyWith({bool? isLoading, Weather? weather, String? error}) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather ?? this.weather,
      error: error,
    );
  }
}

class WeatherCubit extends Cubit<WeatherState> {
  final GetWeatherUseCase getWeatherUseCase;
  WeatherCubit(this.getWeatherUseCase) : super(WeatherState(isLoading: false));

  Future<void> loadWeather() async {
    print('WeatherCubit: Iniciando carga de clima...');
    emit(WeatherState(isLoading: true));
    try {
      final position = await _determinePosition().timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Timeout: No se pudo obtener la ubicación.');
      });
      print('WeatherCubit: Ubicación obtenida: [32m${position.latitude}, ${position.longitude}[0m');
      final weather = await getWeatherUseCase(position.latitude, position.longitude).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Timeout: No se pudo obtener el clima.');
      });
      print('WeatherCubit: Clima obtenido: [34m${weather.temperature}°C, ${weather.condition}[0m');
      emit(WeatherState(weather: weather));
    } catch (e) {
      print('WeatherCubit error: $e');
      emit(WeatherState(error: e.toString()));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el GPS está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('El servicio de ubicación está deshabilitado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('El permiso de ubicación fue denegado.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('El permiso de ubicación está permanentemente denegado.');
    }

    return await Geolocator.getCurrentPosition();
  }

} 