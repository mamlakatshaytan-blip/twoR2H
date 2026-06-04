import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'game_screen.dart';
import '../widgets/common.dart';

class LocalScreen extends StatelessWidget {
  const LocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('ژووری لۆکاڵ', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi, color: AppColors.warning, size: 80),
            const SizedBox(height: 24),
            const Text(
              'ژووری لۆکاڵ',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontFamily: 'Orbitron'),
            ),
            const SizedBox(height: 8),
            const Text(
              'دوو کەس لەسەر یەک وایفای یاری دەکەن\nبەزوانی دێت',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: '1 بەرامبەر 1 لەسەر یەک مۆبایل',
              icon: Icons.people_alt_outlined,
              color: AppColors.success,
              onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const GameScreen(mode: GameMode.local1v1))),
            ),
          ],
        ),
      ),
    );
  }
}
