import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => const FeaturePage(title: 'Weather Info', icon: Icons.cloud);
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
