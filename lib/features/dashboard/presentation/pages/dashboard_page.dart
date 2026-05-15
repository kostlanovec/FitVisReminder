import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:fit_vis_reminder/shared/widgets/reminder_card.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: statsAsync.when(
              data: (stats) => _HeroHeader(isDark: isDark, l: l, stats: stats),
              loading: () => _HeroHeader(isDark: isDark, l: l),
              error: (_, __) => _HeroHeader(isDark: isDark, l: l),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => _StatsRow(stats: stats, isDark: isDark, l: l),
                loading: () => const _SkeletonStats(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: l.dashboardSectionCategories,
                onSeeAll: () => context.go(AppRoutes.remindersList),
                l: l,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: allAsync.when(
                data: (reminders) =>
                    _CategoryGrid(reminders: reminders, isDark: isDark, l: l),
                loading: () => const _SkeletonGrid(),
                error: (e, _) => _ErrorCard(message: e.toString()),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: l.dashboardSectionAttention,
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.accentAmber,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: allAsync.when(
              data: (reminders) {
                final urgent = reminders
                    .where((r) => r.daysUntilDue <= 7)
                    .toList()
                  ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

                if (urgent.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _AllGoodCard(isDark: isDark, l: l),
                  );
                }
                return SliverList.builder(
                  itemCount: urgent.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ReminderCard(
                      reminder: urgent[i],
                      animationDelay: Duration(milliseconds: i * 60),
                      onTap: () =>
                          context.push(AppRoutes.reminderDetailPath(urgent[i].id)),
                      onDone: () => ref
                          .read(reminderNotifierProvider.notifier)
                          .markDone(urgent[i]),
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: _SkeletonList()),
              error: (e, _) =>
                  SliverToBoxAdapter(child: _ErrorCard(message: e.toString())),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: l.dashboardSectionUpcoming,
                onSeeAll: () => context.go(AppRoutes.remindersList),
                l: l,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: allAsync.when(
              data: (reminders) {
                final upcomingReminders = reminders
                    .where((r) => r.daysUntilDue > 7)
                    .toList()
                  ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

                if (upcomingReminders.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          l.dashboardNothingUpcoming,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: upcomingReminders.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ReminderCard(
                      reminder: upcomingReminders[i],
                      animationDelay: Duration(milliseconds: i * 50),
                      onTap: () =>
                          context.push(AppRoutes.reminderDetailPath(upcomingReminders[i].id)),
                      onDone: () => ref
                          .read(reminderNotifierProvider.notifier)
                          .markDone(upcomingReminders[i]),
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: _SkeletonList()),
              error: (e, _) =>
                  SliverToBoxAdapter(child: _ErrorCard(message: e.toString())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.reminderAdd),
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.dashboardAddButton),
        elevation: 4,
      ),
    );
  }
}


class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.isDark, required this.l, this.stats});
  final bool isDark;
  final AppLocalizations l;
  final DashboardStats? stats;

  String _greeting(BuildContext context, AppLocalizations l) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l.greetingMorning;
    if (hour < 18) return l.greetingAfternoon;
    return l.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateStr = DateFormat('EEEE, d. MMMM', locale).format(now);

    final total = stats?.total ?? 0;
    final overdue = stats?.overdue ?? 0;
    final progress = total == 0 ? 1.0 : (total - overdue) / total;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [AppColors.primary.withOpacity(0.15), AppColors.backgroundDark] 
            : [AppColors.primary.withOpacity(0.08), AppColors.background],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 50.ms),
                    const SizedBox(height: 4),
                    Text(
                      _greeting(context, l),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        height: 1.1,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                    const SizedBox(height: 4),
                    Text(
                      overdue > 0 
                        ? l.dashboardStatusOverdue(overdue)
                        : l.dashboardStatusAllGood,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: overdue > 0 ? AppColors.accentAmber : AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
              if (stats != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: isDark ? Colors.white10 : Colors.black05,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          overdue > 0 ? AppColors.accentAmber : AppColors.accentGreen,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.backOut),
                    Text(
                      overdue == 0 && total > 0 ? '✓' : '${(progress * 100).toInt()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: overdue == 0 && total > 0 ? 14 : 10,
                        color: overdue == 0 && total > 0 ? AppColors.accentGreen : null,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.isDark, required this.l});
  final DashboardStats stats;
  final bool isDark;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: stats.overdue,
            label: l.dashboardStatOverdue,
            color: AppColors.accentRed,
            icon: Icons.warning_amber_rounded,
            isDark: isDark,
            delay: 100.ms,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: stats.dueSoon,
            label: l.dashboardStatSoon,
            color: AppColors.accentAmber,
            icon: Icons.access_time_rounded,
            isDark: isDark,
            delay: 160.ms,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: stats.total,
            label: l.dashboardStatTotal,
            color: AppColors.primary,
            icon: Icons.list_alt_rounded,
            isDark: isDark,
            delay: 220.ms,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
    required this.isDark,
    required this.delay,
  });

  final int value;
  final String label;
  final Color color;
  final IconData icon;
  final bool isDark;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          width: 1,
        ),
        boxShadow: cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: value > 0 ? color : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.1,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.1, curve: Curves.easeOutQuad);
  }
}


class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.reminders, required this.isDark, required this.l});
  final List<Reminder> reminders;
  final bool isDark;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final countByCategory = <ReminderCategory, int>{};
    final urgentByCategory = <ReminderCategory, int>{};

    for (final r in reminders) {
      countByCategory[r.category] = (countByCategory[r.category] ?? 0) + 1;
      if (r.daysUntilDue <= 7) {
        urgentByCategory[r.category] =
            (urgentByCategory[r.category] ?? 0) + 1;
      }
    }

    if (countByCategory.isEmpty) return const SizedBox.shrink();

    final categories = countByCategory.keys.toList()
      ..sort((a, b) =>
          (urgentByCategory[b] ?? 0).compareTo(urgentByCategory[a] ?? 0));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.7,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        final count = countByCategory[cat] ?? 0;
        final urgent = urgentByCategory[cat] ?? 0;
        return _CategoryTile(
          category: cat,
          count: count,
          urgentCount: urgent,
          isDark: isDark,
          l: l,
        )
            .animate(delay: Duration(milliseconds: 60 + i * 50))
            .fadeIn()
            .scale(begin: const Offset(0.95, 0.95));
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.count,
    required this.urgentCount,
    required this.isDark,
    required this.l,
  });

  final ReminderCategory category;
  final int count;
  final int urgentCount;
  final bool isDark;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: urgentCount > 0
              ? category.color.withOpacity(0.3)
              : isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
        ),
        boxShadow: cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(category.emoji,
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              if (urgentCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    urgentCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: category.color,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                l.remindersCount(count),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _AllGoodCard extends StatelessWidget {
  const _AllGoodCard({required this.isDark, required this.l});
  final bool isDark;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentGreen.withOpacity(0.1)
            : AppColors.accentGreenSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.accentGreen,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.dashboardAllGood,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.accentGreen,
                ),
              ),
              Text(
                l.dashboardNoUrgent,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.accentGreen.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.97, 0.97));
  }
}


class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.onSeeAll,
    this.icon,
    this.iconColor,
    this.l,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final IconData? icon;
  final Color? iconColor;
  final AppLocalizations? l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l?.dashboardSeeAll ?? 'Vše',
              style: const TextStyle(fontSize: 13),
            ),
          ),
      ],
    );
  }
}


class _SkeletonStats extends StatelessWidget {
  const _SkeletonStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Container(
            height: 96,
            margin: EdgeInsets.only(left: i == 0 ? 0 : 10),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(20),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: Colors.white54),
        ),
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.7,
      ),
      itemCount: 4,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(18),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms, delay: Duration(milliseconds: i * 100)),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (i) => Container(
          height: 72,
          margin: EdgeInsets.only(bottom: 10, top: i == 0 ? 0 : 0),
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(20),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
                duration: 1200.ms,
                delay: Duration(milliseconds: i * 150)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentRedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.accentRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.accentRed, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
