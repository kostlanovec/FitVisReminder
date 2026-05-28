import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

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
    final l = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;
    final daysLeft = reminder.daysUntilDue;
    final cat = reminder.category;
    final locale = Localizations.localeOf(context).toLanguageTag();

    // Card background: subtle tint only when overdue; otherwise plain white/dark
    final Color cardBg = isOverdue
        ? (isDark
            ? AppColors.accentRed.withValues(alpha: 0.09)
            : AppColors.accentRed.withValues(alpha: 0.04))
        : (isDark ? AppColors.cardDark : Colors.white);

    final Color borderColor = isOverdue
        ? AppColors.accentRed.withValues(alpha: isDark ? 0.4 : 0.22)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return Animate(
      delay: animationDelay,
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 220)),
        SlideEffect(
          begin: Offset(0, 0.04),
          end: Offset.zero,
          duration: Duration(milliseconds: 220),
          curve: Curves.easeOut,
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: borderColor, width: isOverdue ? 1.5 : 1),
          boxShadow: cardShadow(isDark),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            splashColor: cat.color.withValues(alpha: 0.06),
            highlightColor: cat.color.withValues(alpha: 0.03),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  // Emoji — large, no container box
                  SizedBox(
                    width: 32,
                    child: Text(
                      cat.emoji,
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reminder.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isOverdue
                                ? AppColors.accentRed
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (reminder.priority == ReminderPriority.high) ...[
                          const SizedBox(height: 2),
                          _PriorityBadge(isDark: isDark),
                        ],
                        const SizedBox(height: 5),
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
                                label: reminder.recurrenceRule.humanLabelLocalized(l),
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Done button — minimal icon, no container
                  if (onDone != null)
                    _DoneButton(onDone: onDone, isOverdue: isOverdue),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Date chip ─────────────────────────────────────────────────────────────

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
    final l = AppLocalizations.of(context)!;
    final Color color;
    final String label;

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
        borderRadius: BorderRadius.circular(AppRadius.chip),
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

// ── Pill badge (recurrence label) ────────────────────────────────────────

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

// ── Priority badge ────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt_rounded,
            size: 11, color: AppColors.accentAmber),
        const SizedBox(width: 3),
        Text(
          AppLocalizations.of(context)!.priorityHigh,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.accentAmber,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Done button ──────────────────────────────────────────────────────────

class _DoneButton extends StatefulWidget {
  const _DoneButton({this.onDone, required this.isOverdue});
  final VoidCallback? onDone;
  final bool isOverdue;

  @override
  State<_DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<_DoneButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isOverdue ? AppColors.accentRed : AppColors.textTertiary;
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
          scale: _pressed ? 0.82 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 22,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
