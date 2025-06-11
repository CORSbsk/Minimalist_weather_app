enum WeatherCondition {
  sunny,
  cloudy,
  rainy,
  snow,
  storm,
  unknown,
}

String weatherConditionToString(WeatherCondition condition) {
  switch (condition) {
    case WeatherCondition.sunny:
      return 'Sunny';
    case WeatherCondition.cloudy:
      return 'Cloudy';
    case WeatherCondition.rainy:
      return 'Rainy';
    case WeatherCondition.snow:
      return 'Snow';
    case WeatherCondition.storm:
      return 'Storm';
    default:
      return 'Unknown';
  }
}

WeatherCondition mapWeatherCodeToCondition(int code) {
  // Open-Meteo weather codes: https://open-meteo.com/en/docs#api_form
  if (code == 0) return WeatherCondition.sunny;
  if (code == 1 || code == 2 || code == 3) return WeatherCondition.cloudy;
  if (code == 45 || code == 48) return WeatherCondition.cloudy;
  if (code == 51 || code == 53 || code == 55 || code == 56 || code == 57) return WeatherCondition.rainy;
  if (code == 61 || code == 63 || code == 65 || code == 66 || code == 67) return WeatherCondition.rainy;
  if (code == 71 || code == 73 || code == 75 || code == 77 || code == 85 || code == 86) return WeatherCondition.snow;
  if (code == 80 || code == 81 || code == 82) return WeatherCondition.rainy;
  if (code == 95 || code == 96 || code == 99) return WeatherCondition.storm;
  return WeatherCondition.unknown;
} 