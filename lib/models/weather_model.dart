import 'package:flutter/material.dart';

class WeatherData {
  final double currentTemp;
  final int humidity;
  final int weatherCode;
  final double windSpeed;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final DateTime lastUpdated;

  WeatherData({
    required this.currentTemp,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.hourly,
    required this.daily,
    required this.lastUpdated,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final hourlyData = json['hourly'];
    final dailyData = json['daily'];

    List<HourlyWeather> hourlyList = [];
    for (int i = 0; i < 24; i++) {
      hourlyList.add(HourlyWeather(
        time: DateTime.parse(hourlyData['time'][i]),
        temp: hourlyData['temperature_2m'][i].toDouble(),
        weatherCode: hourlyData['weather_code'][i],
      ));
    }

    List<DailyWeather> dailyList = [];
    for (int i = 0; i < 7; i++) {
      dailyList.add(DailyWeather(
        date: DateTime.parse(dailyData['time'][i]),
        weatherCode: dailyData['weather_code'][i],
        maxTemp: dailyData['temperature_2m_max'][i].toDouble(),
        minTemp: dailyData['temperature_2m_min'][i].toDouble(),
        precipProb: dailyData['precipitation_probability_max'][i].toInt(),
        precipSum: dailyData['precipitation_sum'][i].toDouble(),
      ));
    }

    return WeatherData(
      currentTemp: current['temperature_2m'].toDouble(),
      humidity: current['relative_humidity_2m'].toInt(),
      weatherCode: current['weather_code'],
      windSpeed: current['wind_speed_10m'].toDouble(),
      hourly: hourlyList,
      daily: dailyList,
      lastUpdated: DateTime.now(),
    );
  }
}

class HourlyWeather {
  final DateTime time;
  final double temp;
  final int weatherCode;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.weatherCode,
  });
}

class DailyWeather {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final int precipProb;
  final double precipSum;

  DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.precipProb,
    required this.precipSum,
  });
}

class WeatherUtils {
  static String getWeatherLabel(int code) {
    switch (code) {
      case 0: return 'পরিষ্কার আকাশ';
      case 1: case 2: case 3: return 'আংশিক মেঘলা';
      case 45: case 48: return 'কুয়াশাচ্ছন্ন';
      case 51: case 53: case 55: return 'হালকা গুঁড়িগুঁড়ি বৃষ্টি';
      case 61: case 63: case 65: return 'বৃষ্টি';
      case 71: case 73: case 75: return 'তুষারপাত';
      case 80: case 81: case 82: return 'প্রবল বৃষ্টি';
      case 95: case 96: case 99: return 'বজ্রবৃষ্টি';
      default: return 'অজানা';
    }
  }

  static IconData getWeatherIcon(int code) {
    switch (code) {
      case 0: return Icons.wb_sunny;
      case 1: case 2: case 3: return Icons.wb_cloudy;
      case 45: case 48: return Icons.cloud;
      case 51: case 53: case 55: return Icons.grain;
      case 61: case 63: case 65: return Icons.umbrella;
      case 71: case 73: case 75: return Icons.ac_unit;
      case 80: case 81: case 82: return Icons.thunderstorm;
      case 95: case 96: case 99: return Icons.flash_on;
      default: return Icons.help_outline;
    }
  }

  static Color getWeatherIconColor(int code) {
    switch (code) {
      case 0: return Colors.orange; // Sunny
      case 1: case 2: case 3: return Colors.blueGrey; // Cloudy
      case 45: case 48: return Colors.grey; // Fog
      case 51: case 53: case 55: return Colors.lightBlue; // Drizzle
      case 61: case 63: case 65: return Colors.blue; // Rain
      case 71: case 73: case 75: return Colors.cyan; // Snow
      case 80: case 81: case 82: return Colors.indigo; // Heavy rain
      case 95: case 96: case 99: return Colors.deepPurple; // Thunderstorm
      default: return Colors.green;
    }
  }

  static Color getWeatherIconBgColor(int code) {
    // ignore: deprecated_member_use
    return getWeatherIconColor(code).withOpacity(0.15);
  }

  static String getBanglaDay(DateTime date) {
    List<String> days = ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'];
    return days[date.weekday - 1];
  }
}
