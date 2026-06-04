import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

// ── بەجەی ئەنجام (R / H / N) ──
class ResultBadge extends StatelessWidget {
  final String result;
  const ResultBadge(this.result, {super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (result.contains('R') && result.contains('H')) {
      color = AppColors.cyan;
    } else if (result.contains('R')) {
      color = AppColors.rBadge;
    } else if (result.contains('H')) {
      color = AppColors.hBadge;
    } else {
      color = AppColors.nBadge;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        result,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          fontFamily: 'Orbitron',
        ),
      ),
    );
  }
}

// ── ڕیزی مەزندەکردن ──
class GuessRow extends StatelessWidget {
  final String number;
  final String result;
  final int index;
  const GuessRow({super.key, required this.number, required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${index + 1}.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          Text(
            number.split('').join(' '),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              fontFamily: 'Orbitron',
            ),
          ),
          ResultBadge(result),
        ],
      ),
    );
  }
}

// ── دوگمەی ئەکتیڤی ──
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;
  const PrimaryButton({super.key, required this.label, required this.onTap, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color ?? AppColors.accent, (color ?? AppColors.accent).withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (color ?? AppColors.accent).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── کیبۆردی ژمارە ──
class NumberKeyboard extends StatelessWidget {
  final List<int> selected;
  final Function(int) onTap;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;

  const NumberKeyboard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (int col = 0; col < 3; col++)
                  _buildKey(row * 3 + col + 1),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _buildAction(Icons.backspace_outlined, AppColors.error, onDelete),
              _buildKey(null), // placeholder
              _buildAction(Icons.check_rounded, AppColors.success, onSubmit),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKey(int? n) {
    if (n == null) return const Expanded(child: SizedBox());
    final isSelected = selected.contains(n);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(n);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.all(4),
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              '$n',
              style: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
