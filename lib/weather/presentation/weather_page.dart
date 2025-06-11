import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/weather_condition.dart';
import 'weather_cubit.dart';
import '../data/weather_api_service.dart';
import '../data/weather_repository.dart';
import '../domain/get_weather_usecase.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return BlocProvider(
      create: (_) => WeatherCubit(
        GetWeatherUseCase(
          WeatherRepository(WeatherApiService()),
        ),
      )..loadWeather(),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final ValueNotifier<bool> _isDark = ValueNotifier(true);

  @override
  void dispose() {
    _isDark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDark,
      builder: (context, isDark, _) {
        final now = DateTime.now();
        final dayOfWeek = DateFormat('EEEE').format(now); // Tuesday
        final hour = DateFormat('HH:mm').format(now); // 10:30
        final ampm = DateFormat('a').format(now).toLowerCase(); // am/pm
        final dayOfMonth = DateFormat('d').format(now); // 21
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _isDark.value = !_isDark.value,
            backgroundColor: isDark ? Colors.white : Colors.black,
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<WeatherCubit, WeatherState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: \u001b[31m[0m${state.error}', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<WeatherCubit>().loadWeather(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                if (state.weather != null) {
                  final weather = state.weather!;
                  final style = _getWeatherStyle(
                    weatherConditionToString(weather.condition),
                    weather.temperature.toInt(),
                    isDark,
                  );
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: style.cardColor,
                      borderRadius: BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Parte superior: Día y hora
                        Positioned(
                          top: 36,
                          left: 28,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayOfWeek,
                                style: TextStyle(
                                  color: style.textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    hour,
                                    style: TextStyle(
                                      color: style.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 44,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      ampm,
                                      style: TextStyle(
                                        color: style.textColor.withOpacity(0.8),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Ícono grande centrado
                        Center(
                          child: Icon(
                            style.icon,
                            size: 200,
                            color: style.iconColor,
                          ),
                        ),
                        // Parte inferior: Temperatura, condición y ciudad
                        Positioned(
                          left: 28,
                          bottom: 90,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${weather.temperature.toStringAsFixed(0)}°',
                                      style: TextStyle(
                                        color: style.textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 70,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'C',
                                      style: TextStyle(
                                        color: style.textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Línea divisoria vertical
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                width: 2,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: style.textColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weatherConditionToString(weather.condition),
                                    style: TextStyle(
                                      color: style.textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    weather.city ?? '',
                                    style: TextStyle(
                                      color: style.textColor.withOpacity(0.7),
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}

class _WeatherStyle {
  final Color backgroundColor;
  final Color cardColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _WeatherStyle({
    required this.backgroundColor,
    required this.cardColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}

_WeatherStyle _getWeatherStyle(String weather, int temp, bool isDark) {
  switch (weather) {
    case 'Sunny':
      return isDark
          ? _WeatherStyle(
              backgroundColor: const Color(0xFF3E2723),
              cardColor: const Color(0xFF795548),
              iconColor: Colors.amber.shade200,
              textColor: Colors.amber.shade100,
              icon: Icons.wb_sunny_outlined,
            )
          : _WeatherStyle(
              backgroundColor: const Color(0xFFFFE066),
              cardColor: const Color(0xFFFFC300),
              iconColor: Colors.white,
              textColor: Colors.white,
              icon: Icons.wb_sunny_outlined,
            );
    case 'Cloudy':
      return isDark
          ? _WeatherStyle(
              backgroundColor: const Color(0xFF263238),
              cardColor: const Color(0xFF37474F),
              iconColor: Colors.blueGrey.shade100,
              textColor: Colors.white70,
              icon: Icons.cloud_outlined,
            )
          : _WeatherStyle(
              backgroundColor: const Color(0xFFB2F7EF),
              cardColor: const Color(0xFF4CAF50),
              iconColor: Colors.white,
              textColor: Colors.white,
              icon: Icons.cloud_outlined,
            );
    case 'Rainy':
      return isDark
          ? _WeatherStyle(
              backgroundColor: const Color(0xFF263238),
              cardColor: const Color(0xFF455A64),
              iconColor: Colors.blueGrey.shade200,
              textColor: Colors.white70,
              icon: Icons.grain,
            )
          : _WeatherStyle(
              backgroundColor: const Color(0xFFB0BEC5),
              cardColor: const Color(0xFFE0E0E0),
              iconColor: Colors.blueGrey,
              textColor: Colors.black87,
              icon: Icons.grain,
            );
    case 'Snow':
      return isDark
          ? _WeatherStyle(
              backgroundColor: const Color(0xFF263238),
              cardColor: const Color(0xFF607D8B),
              iconColor: Colors.white70,
              textColor: Colors.white,
              icon: Icons.ac_unit,
            )
          : _WeatherStyle(
              backgroundColor: const Color(0xFFB3E5FC),
              cardColor: const Color(0xFF00B4D8),
              iconColor: Colors.white,
              textColor: Colors.white,
              icon: Icons.ac_unit,
            );
    case 'Storm':
      return isDark
          ? _WeatherStyle(
              backgroundColor: const Color(0xFF311B92),
              cardColor: const Color(0xFF512DA8),
              iconColor: Colors.deepPurpleAccent.shade100,
              textColor: Colors.white,
              icon: Icons.flash_on,
            )
          : _WeatherStyle(
              backgroundColor: const Color(0xFFD1B3C4),
              cardColor: const Color(0xFF8F3B76),
              iconColor: Colors.white,
              textColor: Colors.white,
              icon: Icons.flash_on,
            );
    default:
      // Por defecto, nublado
      return isDark
          ? _WeatherStyle(
              backgroundColor: const Color(0xFF263238),
              cardColor: const Color(0xFF37474F),
              iconColor: Colors.blueGrey.shade100,
              textColor: Colors.white70,
              icon: Icons.cloud_outlined,
            )
          : _WeatherStyle(
              backgroundColor: const Color(0xFFB2F7EF),
              cardColor: const Color(0xFF4CAF50),
              iconColor: Colors.white,
              textColor: Colors.white,
              icon: Icons.cloud_outlined,
            );
  }
} 