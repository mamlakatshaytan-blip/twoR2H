import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/prefs.dart';
import '../utils/theme.dart';
import 'game_screen.dart';
import 'online_screen.dart';
import 'local_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = Prefs.username;
    final wins = Prefs.wins;
    final losses = Prefs.losses;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هێدەر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مەرحەبا، $name',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        '2R2H',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.cyan],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(),

              const SizedBox(height: 24),

              // ستاتس
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('بردن', '$wins', AppColors.success),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _statItem('دەستنەگەیشتن', '$losses', AppColors.error),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _statItem('کۆی گشتی', '${wins + losses}', AppColors.accent),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              const Text(
                'دەستپێکە',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // دوگمەکان
              Expanded(
                child: Column(
                  children: [
                    _menuButton(
                      context,
                      icon: Icons.bolt,
                      label: 'یاری خێرا',
                      subtitle: 'ڕاستەوخۆ بەسێرڤەر',
                      color: AppColors.accent,
                      delay: 300,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const OnlineScreen(quickMatch: true))),
                    ),
                    const SizedBox(height: 12),
                    _menuButton(
                      context,
                      icon: Icons.vpn_key_outlined,
                      label: 'کۆدی نهێنی',
                      subtitle: 'بەکۆدی ژووری بەشداری بکە',
                      color: AppColors.cyan,
                      delay: 400,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const OnlineScreen(quickMatch: false))),
                    ),
                    const SizedBox(height: 12),
                    _menuButton(
                      context,
                      icon: Icons.wifi,
                      label: 'ژووری لۆکاڵ',
                      subtitle: 'دوو کەس لەسەر یەک وایفای',
                      color: AppColors.warning,
                      delay: 500,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LocalScreen())),
                    ),
                    const SizedBox(height: 12),
                    _menuButton(
                      context,
                      icon: Icons.smart_toy_outlined,
                      label: 'لەگەڵ بۆت',
                      subtitle: 'یاری تەنیا',
                      color: const Color(0xFF9C27B0),
                      delay: 600,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const GameScreen(mode: GameMode.bot))),
                    ),
                    const SizedBox(height: 12),
                    _menuButton(
                      context,
                      icon: Icons.people_alt_outlined,
                      label: '1 بەرامبەر 1',
                      subtitle: 'دوو کەس لەسەر یەک مۆبایل',
                      color: AppColors.success,
                      delay: 700,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const GameScreen(mode: GameMode.local1v1))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _menuButton(BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1);
  }
}
