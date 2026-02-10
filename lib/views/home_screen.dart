import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import '../services/news_service.dart';
import 'feature_pages.dart';
import 'news_details_screen.dart';
import 'symptoms_analysis_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.green.shade50, // Updated to green-tinted background
      appBar: AppBar(
        leading: const Icon(Icons.agriculture, size: 28),
        title: const Text(
          'FarmAI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25), // Slightly more rounded
            bottomRight: Radius.circular(25),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _showProfileDialog(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                backgroundImage: authProvider.user?.photoURL != null
                    ? NetworkImage(authProvider.user!.photoURL!)
                    : null,
                child: authProvider.user?.photoURL == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.green.shade700,
        onRefresh: () async {
          final newsProvider = Provider.of<NewsProvider>(context, listen: false);
          await newsProvider.fetchNews();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Moved Slider slightly down
              const SizedBox(height: 16),

              // News Section Heading
              const _SectionHeader(title: 'সর্বশেষ সংবাদ'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: NewsSlider(),
              ),

              const SizedBox(height: 12),

              // Features Heading
              const _SectionHeader(title: 'আমাদের সেবাসমূহ'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: FeatureGrid(),
              ),
            
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green[50],
              backgroundImage: authProvider.user?.photoURL != null
                  ? NetworkImage(authProvider.user!.photoURL!)
                  : null,
              child: authProvider.user?.photoURL == null
                  ? const Icon(Icons.person, size: 45, color: Colors.green)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              authProvider.user?.displayName ?? 'ব্যবহারকারী',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              authProvider.user?.email ?? 'ইমেইল নেই',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Text('গুগল অ্যাকাউন্ট', style: TextStyle(color: Colors.blue[800])),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  authProvider.signOut();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: BorderSide(color: Colors.red[100]!),
                ),
                label: const Text('লগ আউট করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[900], // Darker green
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class NewsSlider extends StatefulWidget {
  const NewsSlider({super.key});

  @override
  State<NewsSlider> createState() => _NewsSliderState();
}

class _NewsSliderState extends State<NewsSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (newsProvider.articles.isNotEmpty) {
        if (_currentPage < newsProvider.articles.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    if (newsProvider.isLoading) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (newsProvider.error != null || newsProvider.articles.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: Text(newsProvider.error ?? 'খবর পাওয়া যায়নি')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: newsProvider.articles.length,
            itemBuilder: (context, index) {
              final article = newsProvider.articles[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsDetailsScreen(article: article)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.green.withOpacity(0.12), // Slightly more visible
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(Icons.newspaper, size: 120, color: Colors.green[50]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  article.source,
                                  style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                article.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Text(
                                article.pubDate.split(',')[0],
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            min(newsProvider.articles.length, 5),
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPage % 5 == index ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _currentPage % 5 == index ? Colors.green[700] : Colors.green[200],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'title': 'AI উপসর্গ বিশ্লেষণ', 'icon': Icons.health_and_safety, 'page': const SymptomsAnalysisScreen(), 'color': Colors.red},
      {'title': 'AI ভয়েস চ্যাট', 'icon': Icons.mic, 'page': const AIVoiceChatPage(), 'color': Colors.blue},
      {'title': 'হিসাব-নিকাশ', 'icon': Icons.calculate, 'page': const EstimationPage(), 'color': Colors.orange},
      {'title': 'হাসপাতাল', 'icon': Icons.local_hospital, 'page': const VeterinaryHospitalPage(), 'color': Colors.green},
      {'title': 'টেলি-ভেট', 'icon': Icons.videocam, 'page': const TeleVetPage(), 'color': Colors.purple},
      {'title': 'আবহাওয়া', 'icon': Icons.cloud, 'page': const WeatherInfoPage(), 'color': Colors.lightBlue},
      {'title': 'টিকা রিমাইন্ডার', 'icon': Icons.notifications_active, 'page': const VaccineReminderPage(), 'color': Colors.amber},
      {'title': 'বাজার দর', 'icon': Icons.store, 'page': const MarketPricePage(), 'color': Colors.teal},
      {'title': 'কমিউনিটি', 'icon': Icons.groups, 'page': const CommunitySupportPage(), 'color': Colors.indigo},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72, // Reduced aspect ratio to increase height
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _FeatureTile(
          title: features[index]['title'],
          icon: features[index]['icon'],
          color: features[index]['color'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => features[index]['page']),
            );
          },
        );
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.visible, // Changed to visible or ensure enough height
              ),
            ),
          ],
        ),
      ),
    );
  }
}
