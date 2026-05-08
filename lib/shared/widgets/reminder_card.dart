import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:intl/intl.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onDone,
    this.showCategory = true,
    this.animationDelay = Duration.zero,
  });

  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onDone;
  final bool showCategory;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;
    final daysLeft = reminder.daysUntilDue;
    final cat = reminder.category;

    Color accentColor;
    if (isOverdue) {
      accentColor = AppColors.accentRed;
    } else if (isDueToday || daysLeft <= 3) {
      accentColor = AppColors.accentAmber;
    } else if (daysLeft <= 14) {
      accentColor = AppColors.accentGreen;
    } else {
      accentColor = cat.color;
    }

    return Animate(
      delay: animationDelay,
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 280)),
        SlideEffect(
          begin: Offset(0, 0.04),
          end: Offset.zero,
          duration: Duration(milliseconds: 280),
          curve: Curves.easeOut,
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOverdue
                ? AppColors.accentRed.withOpacity(0.3)
                : isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: cardShadow(isDark),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: cat.color.withOpacity(0.06),
            highlightColor: cat.color.withOpacity(0.04),
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 4,
                  height: 72,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                ),

                // Category emoji
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        cat.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reminder.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _DateChip(
                              daysLeft: daysLeft,
                              isOverdue: isOverdue,
                              isDueToday: isDueToday,
                              dueDate: reminder.dueDate,
                            ),
                            if (reminder.recurrenceRule.isRecurring) ...[
                              const SizedBox(width: 6),
                              _PillBadge(
                                icon: Icons.repeat_rounded,
                                label: reminder.recurrenceRule.humanLabel,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Done button
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _DoneButton(onDone: onDone, color: accentColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.daysLeft,
    required this.isOverdue,
    required this.isDueToday,
    required this.dueDate,
  });

  final int daysLeft;
  final bool isOverdue;
  final bool isDueToday;
  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    if (isOverdue) {
      color = AppColors.accentRed;
      label = '${daysLeft.abs()}d po termínu';
    } else if (isDueToday) {
      color = AppColors.accentAmber;
      label = 'Dnes';
    } else if (daysLeft == 1) {
      color = AppColors.accentAmber;
      label = 'Zítra';
    } else if (daysLeft <= 7) {
      color = AppColors.accentAmber;
      label = 'Za ${daysLeft}d';
    } else {
      color = AppColors.textTertiary;
      label = DateFormat('d. MMM', 'cs').format(dueDate);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue
                ? Icons.warning_amber_rounded
                : Icons.calendar_today_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({this.onDone, required this.color});
  final VoidCallback? onDone;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDone,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(
          Icons.check_rounded,
          size: 17,
          color: color.withOpacity(0.7),
        ),
      ),
    );
  }
}
