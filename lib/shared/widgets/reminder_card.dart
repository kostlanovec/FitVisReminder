import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';

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
    final locale = Localizations.localeOf(context).toLanguageTag();

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
                ? AppColors.accentRed.withValues(alpha: 0.3)
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
            splashColor: cat.color.withValues(alpha: 0.06),
            highlightColor: cat.color.withValues(alpha: 0.04),
            child: Row(
              children: [
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: isDark ? 0.15 : 0.1),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reminder.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            letterSpacing: -0.2,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (reminder.priority == ReminderPriority.high) ...[
                          const SizedBox(height: 3),
                          _PriorityBadge(isDark: isDark),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _DateChip(
                              daysLeft: daysLeft,
                              isOverdue: isOverdue,
                              isDueToday: isDueToday,
                              dueDate: reminder.dueDate,
                              locale: locale,
                            ),
                            if (reminder.recurrenceRule.isRecurring) ...[
                              const SizedBox(width: 8),
                              _PillBadge(
                                icon: Icons.repeat_rounded,
                                label: reminder.recurrenceRule.humanLabel,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
    required this.locale,
  });

  final int daysLeft;
  final bool isOverdue;
  final bool isDueToday;
  final DateTime dueDate;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    final l = AppLocalizations.of(context)!;
    if (isOverdue) {
      color = AppColors.accentRed;
      label = l.reminderDetailOverdueCount(daysLeft.abs());
    } else if (isDueToday) {
      color = AppColors.accentAmber;
      label = l.reminderDetailDueToday;
    } else if (daysLeft == 1) {
      color = AppColors.accentAmber;
      label = l.reminderDetailDueTomorrow;
    } else if (daysLeft <= 7) {
      color = AppColors.accentAmber;
      label = l.reminderDetailDueInDays(daysLeft);
    } else {
      color = AppColors.textTertiary;
      label = DateFormat('d. MMM', locale).format(dueDate);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
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

class _DoneButton extends StatefulWidget {
  const _DoneButton({this.onDone, required this.color});
  final VoidCallback? onDone;
  final Color color;

  @override
  State<_DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<_DoneButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.reminderMarkDoneAction,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onDone,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.color.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 18,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.priority_high_rounded, size: 10, color: AppColors.accentRed),
          const SizedBox(width: 2),
          Text(
            AppLocalizations.of(context)!.priorityHigh,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.accentRed,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
