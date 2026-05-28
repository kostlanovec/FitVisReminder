import 'package:flutter/material.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.showLabel = false});

  final ReminderCategory category;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: showLabel
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
          : const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 14)),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              category.localizedLabel(l),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: category.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
