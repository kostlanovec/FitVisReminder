import 'package:flutter/material.dart';
import 'package:fit_vis_reminder/core/extensions/datetime_extensions.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';

class UrgencyChip extends StatelessWidget {
  const UrgencyChip({super.key, required this.dueDate});

  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    final days = dueDate.daysUntil;
    final (color, label) = _resolve(days);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (Color, String) _resolve(int days) {
    if (days < 0) return (AppColors.accentRed, 'Po termínu');
    if (days == 0) return (AppColors.accentRed, 'Dnes');
    if (days == 1) return (AppColors.accentAmber, 'Zítra');
    if (days <= 7) return (AppColors.accentAmber, 'Za $days dní');
    if (days <= 30) return (AppColors.accent, 'Za $days dní');
    if (days <= 90) return (AppColors.accentGreen, dueDate.relativeLabel);
    return (AppColors.textSecondary, dueDate.relativeLabel);
  }
}
