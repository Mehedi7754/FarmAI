import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';

class FeaturePage extends StatelessWidget {
  final String title;
  final IconData icon;

  const FeaturePage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              // ignore: deprecated_member_use
              color: Colors.green.shade700.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to $title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'This feature is currently under development. Stay tuned for updates!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Concrete pages for each feature
class AISymptomsAnalysisPage extends StatelessWidget {
  const AISymptomsAnalysisPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePage(title: 'AI Symptoms Analysis', icon: Icons.biotech);
}

class AIVoiceChatPage extends StatelessWidget {
  const AIVoiceChatPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePage(title: 'AI Voice Chat', icon: Icons.record_voice_over);
}

class EstimationPage extends StatelessWidget {
  const EstimationPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePage(title: 'Estimation', icon: Icons.calculate);
}

class VeterinaryHospitalPage extends StatelessWidget {
  const VeterinaryHospitalPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePage(title: 'Veterinary Hospital', icon: Icons.local_hospital);
}

class TeleVetPage extends StatelessWidget {
  const TeleVetPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePage(title: 'Tele-vet', icon: Icons.video_call);
}

class WeatherInfoPage extends StatelessWidget {
  const WeatherInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('আবহাওয়ার তথ্য'),
        actions: [
          if (weatherProvider.farmLocation != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => weatherProvider.refreshWeather(),
            ),
        ],
      ),
      body: weatherProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : weatherProvider.farmLocation == null
              ? _buildLocationSetup(context, weatherProvider)
              : _buildWeatherContent(context, weatherProvider),
    );
  }

  Widget _buildLocationSetup(BuildContext context, WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 64, color: Colors.green.shade700),
                const SizedBox(height: 16),
                const Text(
                  'খামারের লোকেশন সেট করা হয়নি',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'আবহাওয়ার তথ্য পেতে আপনার খামারের লোকেশন সেট করুন',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.setFarmLocation(),
                  child: const Text('খামারের লোকেশন সেট করুন'),
                ),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherProvider provider) {
    if (provider.weatherData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error ?? 'আবহাওয়ার তথ্য লোড হচ্ছে না'),
            ElevatedButton(
              onPressed: () => provider.refreshWeather(),
              child: const Text('পুনরায় চেষ্টা করুন'),
            ),
          ],
        ),
      );
    }

    final weather = provider.weatherData!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, provider),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'আগামী ২৪ ঘণ্টা',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          _buildHourlyList(weather.hourly),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'আগামী ৭ দিন',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          _buildWeeklyList(weather.daily),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WeatherProvider provider) {
    final weather = provider.weatherData!;
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.farmLocation?['name'] ?? 'আপনার খামার',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    '${weather.currentTemp.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                WeatherUtils.getWeatherIcon(weather.weatherCode),
                size: 64,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderInfo(Icons.water_drop, 'আর্দ্রতা', '${weather.humidity}%'),
              _buildHeaderInfo(Icons.air, 'বাতাস', '${weather.windSpeed} km/h'),
              _buildHeaderInfo(
                Icons.info_outline,
                'অবস্থা',
                WeatherUtils.getWeatherLabel(weather.weatherCode),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => provider.setFarmLocation(),
            icon: const Icon(Icons.edit_location_alt, size: 16, color: Colors.white),
            label: const Text(
              'খামারের লোকেশন পরিবর্তন করুন',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: TextButton.styleFrom(
              // ignore: deprecated_member_use
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHourlyList(List<HourlyWeather> hourly) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hourly.length,
        itemBuilder: (context, index) {
          final item = hourly[index];
          final iconColor = WeatherUtils.getWeatherIconColor(item.weatherCode);
          final bgColor = WeatherUtils.getWeatherIconBgColor(item.weatherCode);

          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35), // Pill shape
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.green.shade50, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(item.time),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    WeatherUtils.getWeatherIcon(item.weatherCode), 
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${item.temp.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyList(List<DailyWeather> daily) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.green.shade50, width: 1),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: daily.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 24),
        itemBuilder: (context, index) {
          final item = daily[index];
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  index == 0 ? 'আজ' : WeatherUtils.getBanglaDay(item.date),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: WeatherUtils.getWeatherIconBgColor(item.weatherCode),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        WeatherUtils.getWeatherIcon(item.weatherCode), 
                        color: WeatherUtils.getWeatherIconColor(item.weatherCode), 
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        WeatherUtils.getWeatherLabel(item.weatherCode),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.maxTemp.toInt()}° / ${item.minTemp.toInt()}°',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'বৃষ্টি: ${item.precipProb}%',
                      style: TextStyle(fontSize: 10, color: Colors.blue.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class VaccineReminderPage extends StatelessWidget {
  const VaccineReminderPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePage(title: 'Vaccine Reminder', icon: Icons.notification_important);
}

class MarketPricePage extends StatelessWidget {
  const MarketPricePage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePage(title: 'Market Price', icon: Icons.attach_money);
}

class CommunitySupportPage extends StatelessWidget {
  const CommunitySupportPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePage(title: 'Community Support', icon: Icons.people);
}
