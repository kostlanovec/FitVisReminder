import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final allAsync = ref.watch(allRemindersProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.reminderAdd),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.dashboardAddButton),
        elevation: 3,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          _DashboardHeader(isDark: isDark, l: l, statsAsync: statsAsync),

          // ── Permission banner ──────────────────────────────────────────
          if (!kIsWeb)
            const SliverToBoxAdapter(child: _PermissionBanner()),

          // ── Main content (time-bucketed) ────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, 0, AppSpacing.page, 120,
            ),
            sliver: SliverToBoxAdapter(
              child: allAsync.when(
                data: (reminders) => _DashboardContent(
                  reminders: reminders,
                  isDark: isDark,
                  l: l,
                  onTap: (r) => context.push(AppRoutes.reminderDetailPath(r.id)),
                  onDone: (r) => ref
                      .read(reminderNotifierProvider.notifier)
                      .markDone(r, l),
                  onShowAll: () => context.go(AppRoutes.remindersList),
                  onAddNew: () => context.push(AppRoutes.reminderAdd),
                ),
                loading: () => const _HeroSkeleton(),
                error: (e, _) => _ErrorCard(message: e.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard content (time-bucketed) ────────────────────────────────────────

/// Splits reminders into time buckets and renders them:
///   • Overdue
///   • This week (≤7 days)  — hero card for the first item
///   • This month (8–31 days) — slim list
///   • Calm state if nothing within 31 days
///   • "Show all" link when items exist beyond the 31-day window
class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.reminders,
    required this.isDark,
    required this.l,
    required this.onTap,
    required this.onDone,
    required this.onShowAll,
    required this.onAddNew,
  });

  final List<Reminder> reminders;
  final bool isDark;
  final AppLocalizations l;
  final void Function(Reminder) onTap;
  final void Function(Reminder) onDone;
  final VoidCallback onShowAll;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) return _EmptyDashboard(isDark: isDark, l: l);

    // Sort by date first — used for calm-state "next" hint and laterCount
    final byDate = [...reminders]
      ..sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));

    // Within each time bucket: high priority first, then closest date.
    List<Reminder> _prioritySort(List<Reminder> bucket) =>
        [...bucket]..sort((a, b) {
          final pa = a.priority == ReminderPriority.high ? 0 : 1;
          final pb = b.priority == ReminderPriority.high ? 0 : 1;
          if (pa != pb) return pa.compareTo(pb);
          return a.daysUntilDue.compareTo(b.daysUntilDue);
        });

    final overdue    = _prioritySort(byDate.where((r) => r.isOverdue).toList());
    final thisWeek   = _prioritySort(byDate.where((r) => !r.isOverdue && r.daysUntilDue <= 7).toList());
    final thisMonth  = _prioritySort(byDate.where((r) => !r.isOverdue && r.daysUntilDue > 7 && r.daysUntilDue <= 31).toList());
    final laterCount = byDate.where((r) => r.daysUntilDue > 31).length;

    // Hero = most urgent item within 7 days (overdue first, then this week)
    final Reminder? hero = overdue.isNotEmpty ? overdue.first
        : thisWeek.isNotEmpty ? thisWeek.first
        : null;

    final sections = <Widget>[];

    // ── Hero card ──────────────────────────────────────────────────────────
    if (hero != null) {
      sections.add(
        _NextDueHeroCard(
          reminder: hero,
          isDark: isDark,
          l: l,
          onTap: () => onTap(hero),
          onDone: () => onDone(hero),
        ),
      );
      sections.add(const SizedBox(height: AppSpacing.xxl));
    }

    // ── Overdue list (excluding hero) ──────────────────────────────────────
    final overdueRest = overdue.skip(hero != null && overdue.isNotEmpty ? 1 : 0).toList();
    if (overdueRest.isNotEmpty) {
      sections.add(_SectionLabel(l.dashboardSectionOverdue));
      sections.add(const SizedBox(height: AppSpacing.sm));
      sections.add(_SlimSection(
        items: overdueRest,
        isDark: isDark,
        onTap: onTap,
        onDone: onDone,
      ));
      sections.add(const SizedBox(height: AppSpacing.xxl));
    }

    // ── This week list (excluding hero) ───────────────────────────────────
    final weekRest = thisWeek.skip(hero != null && thisWeek.isNotEmpty ? 1 : 0).toList();
    if (weekRest.isNotEmpty) {
      sections.add(_SectionLabel(l.dashboardSectionThisWeek));
      sections.add(const SizedBox(height: AppSpacing.sm));
      sections.add(_SlimSection(
        items: weekRest,
        isDark: isDark,
        onTap: onTap,
        onDone: onDone,
      ));
      sections.add(const SizedBox(height: AppSpacing.xxl));
    }

    // ── This month ─────────────────────────────────────────────────────────
    if (thisMonth.isNotEmpty) {
      // If there's no hero at all, show a soft hero for the nearest this-month item
      if (hero == null) {
        final softHero = thisMonth.first;
        sections.add(
          _NextDueHeroCard(
            reminder: softHero,
            isDark: isDark,
            l: l,
            onTap: () => onTap(softHero),
            onDone: () => onDone(softHero),
          ),
        );
        sections.add(const SizedBox(height: AppSpacing.xxl));
        final monthRest = thisMonth.skip(1).toList();
        if (monthRest.isNotEmpty) {
          sections.add(_SectionLabel(l.dashboardSectionThisMonth));
          sections.add(const SizedBox(height: AppSpacing.sm));
          sections.add(_SlimSection(
            items: monthRest,
            isDark: isDark,
            onTap: onTap,
            onDone: onDone,
          ));
          sections.add(const SizedBox(height: AppSpacing.xxl));
        }
      } else {
        sections.add(_SectionLabel(l.dashboardSectionThisMonth));
        sections.add(const SizedBox(height: AppSpacing.sm));
        sections.add(_SlimSection(
          items: thisMonth,
          isDark: isDark,
          onTap: onTap,
          onDone: onDone,
        ));
        sections.add(const SizedBox(height: AppSpacing.xxl));
      }
    }

    // ── Calm state (nothing within 31 days) ────────────────────────────────
    if (hero == null && thisMonth.isEmpty) {
      final next = byDate.first; // exists — we checked reminders.isEmpty above
      sections.add(
        _CalmState(isDark: isDark, l: l, next: next, onTap: () => onTap(next), onAddNew: onAddNew),
      );
      sections.add(const SizedBox(height: AppSpacing.xxl));
    }

    // ── Show all button ────────────────────────────────────────────────────
    if (laterCount > 0) {
      sections.add(
        Center(
          child: TextButton.icon(
            onPressed: onShowAll,
            icon: const Icon(Icons.list_rounded, size: 16),
            label: Text(l.dashboardShowAll(laterCount)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }
}

/// Renders a section of slim reminder rows with dividers.
class _SlimSection extends StatelessWidget {
  const _SlimSection({
    required this.items,
    required this.isDark,
    required this.onTap,
    required this.onDone,
  });

  final List<Reminder> items;
  final bool isDark;
  final void Function(Reminder) onTap;
  final void Function(Reminder) onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _SlimReminderRow(
                reminder: items[i],
                isDark: isDark,
                onTap: () => onTap(items[i]),
                onDone: () => onDone(items[i]),
              ),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 44),
          ],
        ],
      ),
    );
  }
}

/// Calm state: no reminders within 31 days.
class _CalmState extends StatelessWidget {
  const _CalmState({
    required this.isDark,
    required this.l,
    required this.next,
    required this.onTap,
    required this.onAddNew,
  });

  final bool isDark;
  final AppLocalizations l;
  final Reminder next;
  final VoidCallback onTap;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateStr = DateFormat('d. MMMM', locale).format(next.dueDate);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 38)),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.dashboardCalmTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l.dashboardCalmHint,
            style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onAddNew,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(l.dashboardAddButton),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    next.category.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l.dashboardCalmNext}: ',
                    style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      next.title,
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.isDark,
    required this.l,
    required this.statsAsync,
  });

  final bool isDark;
  final AppLocalizations l;
  final AsyncValue<DashboardStats> statsAsync;

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.greetingMorning;
    if (h < 18) return l.greetingAfternoon;
    return l.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateStr =
        DateFormat('EEEE d. MMMM', locale).format(DateTime.now());

    final stats = statsAsync.valueOrNull;

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 0.2,
                      ),
                    ).animate().fadeIn(delay: 40.ms),
                    const SizedBox(height: 3),
                    Text(
                      _greeting(l),
                      style: theme.textTheme.headlineMedium,
                    ).animate().fadeIn(delay: 80.ms),
                  ],
                ),
              ),
              // Inline stats — no card containers
              if (stats != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (stats.overdue > 0) ...[
                      _InlineStat(
                        value: stats.overdue,
                        label: l.dashboardStatOverdue,
                        color: AppColors.accentRed,
                      ).animate().fadeIn(delay: 120.ms),
                      const SizedBox(width: AppSpacing.lg),
                    ],
                    _InlineStat(
                      value: stats.total,
                      label: l.dashboardStatTotal,
                      color: AppColors.textSecondary,
                    ).animate().fadeIn(delay: 160.ms),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ── Next due hero card ───────────────────────────────────────────────────────

class _NextDueHeroCard extends StatelessWidget {
  const _NextDueHeroCard({
    required this.reminder,
    required this.isDark,
    required this.l,
    required this.onTap,
    required this.onDone,
  });

  final Reminder reminder;
  final bool isDark;
  final AppLocalizations l;
  final VoidCallback onTap;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final cat = reminder.category;
    final daysLeft = reminder.daysUntilDue;
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;

    // Date label
    final String dateLabel;
    if (isOverdue) {
      dateLabel = l.reminderDetailOverdueCount(daysLeft.abs());
    } else if (isDueToday) {
      dateLabel = l.reminderDetailDueToday;
    } else if (daysLeft == 1) {
      dateLabel = l.reminderDetailDueTomorrow;
    } else {
      dateLabel = l.reminderDetailDueInDays(daysLeft);
    }

    // Progress within the recurrence cycle
    final rule = reminder.recurrenceRule;
    double? progress;
    if (rule.isRecurring) {
      final cycleDays = rule.intervalDays ??
          (rule.intervalMonths != null ? rule.intervalMonths! * 30 : null) ??
          (rule.intervalYears != null ? rule.intervalYears! * 365 : null) ??
          365;
      final elapsed = cycleDays - daysLeft.clamp(-cycleDays, cycleDays);
      progress = (elapsed / cycleDays).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isOverdue ? AppColors.accentRed : cat.color,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: (isOverdue ? AppColors.accentRed : cat.color)
                  .withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: emoji (+ priority badge) + date badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 34)),
                    if (reminder.priority == ReminderPriority.high) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.priority_high_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                _HeroBadge(label: dateLabel),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Title
            Text(
              reminder.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              cat.localizedLabel(l),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Progress bar (only for recurring)
            if (progress != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor:
                      Colors.white.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            // Done button
            SizedBox(
              width: double.infinity,
              child: _HeroDoneButton(onDone: onDone, l: l),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.06, curve: Curves.easeOut);
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _HeroDoneButton extends StatefulWidget {
  const _HeroDoneButton({required this.onDone, required this.l});
  final VoidCallback onDone;
  final AppLocalizations l;

  @override
  State<_HeroDoneButton> createState() => _HeroDoneButtonState();
}

class _HeroDoneButtonState extends State<_HeroDoneButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onDone,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_rounded,
                  color: Colors.white, size: 17),
              const SizedBox(width: 6),
              Text(
                widget.l.reminderDetailMarkDone,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Slim reminder row (upcoming list) ────────────────────────────────────────

class _SlimReminderRow extends StatelessWidget {
  const _SlimReminderRow({
    required this.reminder,
    required this.isDark,
    required this.onTap,
    required this.onDone,
  });

  final Reminder reminder;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final daysLeft = reminder.daysUntilDue;
    final isOverdue = reminder.isOverdue;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l = AppLocalizations.of(context)!;

    final Color dateColor = isOverdue
        ? AppColors.accentRed
        : daysLeft <= 7
            ? AppColors.accentAmber
            : AppColors.textTertiary;

    final String dateLabel;
    if (isOverdue) {
      dateLabel = l.reminderDetailOverdueCount(daysLeft.abs());
    } else if (daysLeft == 0) {
      dateLabel = l.reminderDetailDueToday;
    } else if (daysLeft == 1) {
      dateLabel = l.reminderDetailDueTomorrow;
    } else if (daysLeft <= 60) {
      dateLabel = l.reminderDetailDueInDays(daysLeft);
    } else {
      dateLabel = DateFormat('d. MMM', locale).format(reminder.dueDate);
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            // Emoji
            SizedBox(
              width: 28,
              child: Text(
                reminder.category.emoji,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Title + optional priority dot
            Expanded(
              child: Row(
                children: [
                  if (reminder.priority == ReminderPriority.high)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? AppColors.accentRed : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Date
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: dateColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Done icon
            GestureDetector(
              onTap: onDone,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.isDark, required this.l});
  final bool isDark;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.remindersEmpty,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.remindersEmptyHint,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.reminderAdd),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(l.dashboardAddButton),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

// ── Skeletons ─────────────────────────────────────────────────────────────────

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                  width: 28,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  )),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Container(
                width: 40,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.borderLighter,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accentRedSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
      ),
    );
  }
}

// ── Permission banner ────────────────────────────────────────────────────────

/// Shows a dismissible warning card when critical permissions are missing.
/// Refreshes on every app resume. Auto-hides when all permissions are granted.
class _PermissionBanner extends ConsumerStatefulWidget {
  const _PermissionBanner();

  @override
  ConsumerState<_PermissionBanner> createState() => _PermissionBannerState();
}

class _PermissionBannerState extends ConsumerState<_PermissionBanner>
    with WidgetsBindingObserver {
  bool _hasNotif = true;
  bool _hasExactAlarm = true;
  bool _hasBattery = true;
  bool _dismissed = false;

  bool get _anyMissing => !_hasNotif || !_hasExactAlarm || !_hasBattery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reset dismiss so re-check is visible after user returns from system settings
      setState(() => _dismissed = false);
      _check();
    }
  }

  Future<void> _check() async {
    try {
      final notif = await ref.read(notificationServiceProvider).isAllowed();
      final exact = await Permission.scheduleExactAlarm.isGranted;
      final battery = await Permission.ignoreBatteryOptimizations.isGranted;
      if (mounted) {
        setState(() {
          _hasNotif = notif;
          _hasExactAlarm = exact;
          _hasBattery = battery;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_anyMissing || _dismissed) return const SizedBox.shrink();

    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, 8, AppSpacing.page, 0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRoutes.settings),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accentAmber.withOpacity(0.12)
                    : AppColors.accentAmber.withOpacity(0.10),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.accentAmber.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.accentAmber, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.permissionBannerTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentAmber,
                          ),
                        ),
                        Text(
                          l.permissionBannerBody,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l.permissionBannerFix,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentAmber,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    color: AppColors.accentAmber,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => setState(() => _dismissed = true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
    );
  }
}
