import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_vis_reminder/core/extensions/datetime_extensions.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
import 'package:fit_vis_reminder/features/reminders/data/services/sharing_service.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ReminderDetailPage extends ConsumerWidget {
  const ReminderDetailPage({super.key, required this.reminderId});

  final int reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(reminderByIdProvider(reminderId));

    return reminderAsync.when(
      data: (reminder) {
        if (reminder == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(AppLocalizations.of(context)!.reminderNotFound)),
          );
        }
        return _DetailContent(reminder: reminder);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: const _DetailErrorState(),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOverdue = reminder.isOverdue;
    final cat = reminder.category;

    Color urgencyColor;
    if (isOverdue) {
      urgencyColor = AppColors.accentRed;
    } else if (reminder.isDueToday || reminder.daysUntilDue <= 3) {
      urgencyColor = AppColors.accentAmber;
    } else if (reminder.daysUntilDue <= 14) {
      urgencyColor = AppColors.accentGreen;
    } else {
      urgencyColor = cat.color;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: l.buttonShare,
                onPressed: () => SharingService().shareReminders([reminder]),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l.buttonEdit,
                onPressed: () => context.push(AppRoutes.reminderEditPath(reminder.id)),
              ),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 20),
                        const SizedBox(width: 10),
                        Text(l.buttonDelete, style: const TextStyle(color: AppColors.accentRed)),
                      ],
                    ),
                  ),
                ],
                onSelected: (v) async {
                  if (v == 'delete') {
                    final ok = await _confirmDelete(context, l);
                    if (ok == true && context.mounted) {
                      await ref.read(reminderNotifierProvider.notifier).deleteReminder(reminder.id);
                      if (context.mounted) context.pop();
                    }
                  }
                },
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _HeroHeader(
                reminder: reminder,
                urgencyColor: urgencyColor,
                isDark: isDark,
                locale: locale,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                _QuickActions(reminder: reminder, l: l, locale: locale),

                const SizedBox(height: 28),

                _SectionHeader(title: l.reminderDetailLastCompleted),
                const SizedBox(height: 10),
                _LastCompletedCard(reminder: reminder, l: l, isDark: isDark, locale: locale),

                const SizedBox(height: 28),

                if (reminder.triggers.isNotEmpty) ...[
                  _SectionHeader(title: l.reminderDetailSectionSchedule),
                  const SizedBox(height: 10),
                  _ScheduleCard(reminder: reminder, isDark: isDark, locale: locale),
                  const SizedBox(height: 28),
                ],

                if (reminder.recurrenceRule.isRecurring) ...[
                  _SectionHeader(title: l.reminderDetailSectionUpcoming),
                  const SizedBox(height: 10),
                  _UpcomingDatesCard(reminder: reminder, isDark: isDark, locale: locale),
                  const SizedBox(height: 28),
                ],

                _SectionHeader(title: l.reminderDetailSectionInfo),
                const SizedBox(height: 10),
                _InfoCard(reminder: reminder, l: l, isDark: isDark, locale: locale),

              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, AppLocalizations l) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text(l.reminderDetailDeleteConfirm),
        content: Text('"${reminder.title}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.buttonCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.accentRed),
            child: Text(l.buttonDelete),
          ),
        ],
      ),
    );
  }
}


class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.reminder, required this.urgencyColor, required this.isDark, required this.locale});

  final Reminder reminder;
  final Color urgencyColor;
  final bool isDark;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final cat = reminder.category;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cat.color.withOpacity(isDark ? 0.25 : 0.12),
            cat.color.withOpacity(isDark ? 0.05 : 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Center(
                      child: Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.localizedLabel(AppLocalizations.of(context)!),
                          style: TextStyle(fontSize: 13, color: cat.color, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _UrgencyBadge(reminder: reminder, color: urgencyColor, locale: locale),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _UrgencyBadge extends StatelessWidget {
  const _UrgencyBadge({required this.reminder, required this.color, required this.locale});

  final Reminder reminder;
  final Color color;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final daysLeft = reminder.daysUntilDue;
    final String label;
    if (reminder.isOverdue) {
      label = AppLocalizations.of(context)!.reminderDetailOverdueCount(daysLeft.abs());
    } else if (reminder.isDueToday) {
      label = AppLocalizations.of(context)!.reminderDetailDueToday;
    } else if (daysLeft == 1) {
      label = AppLocalizations.of(context)!.reminderDetailDueTomorrow;
    } else {
      label = AppLocalizations.of(context)!.reminderDetailDueInDays(daysLeft);
    }

    final dateStr = DateFormat('d. MMMM yyyy', locale).format(reminder.dueDate);

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _Chip(
          icon: reminder.isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
          label: label,
          color: color,
        ),
        _Chip(
          icon: Icons.event_rounded,
          label: dateStr,
          color: color.withOpacity(0.7),
        ),
        if (reminder.recurrenceRule.isRecurring)
          _Chip(
            icon: Icons.repeat_rounded,
            label: reminder.recurrenceRule.humanLabelLocalized(AppLocalizations.of(context)!),
            color: AppColors.textSecondary,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}


class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.reminder, required this.l, required this.locale});

  final Reminder reminder;
  final AppLocalizations l;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: FilledButton.icon(
            onPressed: () async {
              await ref.read(reminderNotifierProvider.notifier).markDone(reminder, l);
              if (context.mounted) context.pop();
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(l.reminderDetailMarkDone),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () async {
              await ref.read(reminderNotifierProvider.notifier).snoozeReminder(reminder, l);
              if (context.mounted) {
                final newDate = reminder.dueDate.add(const Duration(days: 7));
                final formatted = DateFormat('d. M. yyyy', locale).format(newDate);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.reminderDetailSnoozed(formatted)),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                );
                context.pop();
              }
            },
            icon: const Icon(Icons.snooze_rounded, size: 18),
            label: Text(l.reminderDetailSnooze),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, duration: 280.ms, curve: Curves.easeOut);
  }
}


class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.3),
    );
  }
}


class _LastCompletedCard extends StatelessWidget {
  const _LastCompletedCard({required this.reminder, required this.l, required this.isDark, required this.locale});

  final Reminder reminder;
  final AppLocalizations l;
  final bool isDark;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final completed = reminder.lastCompletedAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed != null
                  ? AppColors.accentGreen.withOpacity(0.12)
                  : AppColors.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              completed != null ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: completed != null ? AppColors.accentGreen : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: completed != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('d. MMMM yyyy', locale).format(completed),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        completed.relativeLabel,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  )
                : Text(
                    l.reminderDetailNeverCompleted,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }
}


class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.reminder, required this.isDark, required this.locale});

  final Reminder reminder;
  final bool isDark;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: reminder.triggers.asMap().entries.map((entry) {
          final i = entry.key;
          final trigger = entry.value;
          final scheduledAt = trigger.scheduledFor(reminder.dueDate);
          final isPast = scheduledAt.isBefore(DateTime.now());
          final isLast = i == reminder.triggers.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPast ? AppColors.textTertiary : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        trigger.label ?? l.reminderTriggerCustomDays(trigger.offsetDays),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isPast ? AppColors.textSecondary : null,
                          decoration: isPast ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('d. M. yyyy', locale).format(scheduledAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isPast ? AppColors.textTertiary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isPast ? Icons.check_rounded : Icons.notifications_outlined,
                      size: 14,
                      color: isPast ? AppColors.accentGreen : AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  indent: 36,
                ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}


class _UpcomingDatesCard extends StatelessWidget {
  const _UpcomingDatesCard({required this.reminder, required this.isDark, required this.locale});

  final Reminder reminder;
  final bool isDark;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final occurrences = <DateTime>[];
    var date = reminder.dueDate;
    final now = DateTime.now();
    final limit = now.add(const Duration(days: 730));

    while (date.isBefore(now) && date.isBefore(limit)) {
      date = reminder.recurrenceRule.nextOccurrence(date);
    }
    for (int i = 0; i < 4 && date.isBefore(limit); i++) {
      occurrences.add(date);
      date = reminder.recurrenceRule.nextOccurrence(date);
    }

    if (occurrences.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: occurrences.asMap().entries.map((entry) {
          final i = entry.key;
          final occ = entry.value;
          final isFirst = i == 0;
          final isLast = i == occurrences.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isFirst ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.backgroundAlt),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: isFirst ? Colors.white : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('d. MMMM yyyy', locale).format(occ),
                        style: TextStyle(
                          fontWeight: isFirst ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      occ.relativeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isFirst ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isFirst ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 250.ms);
  }
}


class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.reminder, required this.l, required this.isDark, required this.locale});

  final Reminder reminder;
  final AppLocalizations l;
  final bool isDark;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final cat = reminder.category;
    final rows = <(IconData, String, String)>[
      (Icons.label_outline_rounded, l.reminderFormFieldCategory, '${cat.emoji} ${cat.localizedLabel(l)}'),
      (Icons.repeat_rounded, l.reminderFormFieldRecurrence, reminder.recurrenceRule.humanLabelLocalized(l)),
      if (reminder.description != null && reminder.description!.isNotEmpty)
        (Icons.notes_rounded, l.reminderFormFieldDescription, reminder.description!),
      if (reminder.createdAt != null)
        (Icons.add_circle_outline_rounded, l.reminderDetailCreatedAt,
            DateFormat('d. MMMM yyyy', locale).format(reminder.createdAt!)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final i = entry.key;
          final (icon, label, value) = entry.value;
          final isLast = i == rows.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: 12),
                    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const Spacer(),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  indent: 46,
                ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.accentRed, size: 36),
            const SizedBox(height: 10),
            Text(
              l.errorTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              l.errorSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

