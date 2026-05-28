import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/data/services/sharing_service.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:fit_vis_reminder/shared/widgets/reminder_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

final _selectedCategoryProvider = StateProvider<ReminderCategory?>((ref) => null);
final _searchQueryProvider = StateProvider<String>((ref) => '');
final _onlyHighPriorityProvider = StateProvider<bool>((ref) => false);
final _selectionModeProvider = StateProvider<bool>((ref) => false);
final _selectedIdsProvider = StateProvider<Set<int>>((ref) => {});

class RemindersListPage extends ConsumerWidget {
  const RemindersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final searchQuery = ref.watch(_searchQueryProvider);
    final allAsync = ref.watch(allRemindersProvider);
    final selectionMode = ref.watch(_selectionModeProvider);
    final selectedIds = ref.watch(_selectedIdsProvider);

    return PopScope(
      canPop: !selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selectionMode) {
          ref.read(_selectionModeProvider.notifier).state = false;
          ref.read(_selectedIdsProvider.notifier).state = {};
        }
      },
      child: Scaffold(
        floatingActionButton: selectionMode
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.push(AppRoutes.reminderAdd),
                icon: const Icon(Icons.add_rounded),
                label: Text(l.buttonAdd),
              ),
        bottomNavigationBar: selectionMode
            ? _BulkActionBar(
                selectedIds: selectedIds,
                allAsync: allAsync,
                l: l,
                isDark: isDark,
                ref: ref,
              )
            : null,
        body: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
              surfaceTintColor: Colors.transparent,
              leading: selectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        ref.read(_selectionModeProvider.notifier).state = false;
                        ref.read(_selectedIdsProvider.notifier).state = {};
                      },
                    )
                  : null,
              title: selectionMode
                  ? Text(l.selectionCount(selectedIds.length))
                  : Text(l.remindersTitle),
              actions: selectionMode
                  ? [
                      TextButton(
                        onPressed: () {
                          final all = allAsync.valueOrNull ?? [];
                          final ids = all.map((r) => r.id).toSet();
                          ref.read(_selectedIdsProvider.notifier).state = ids;
                        },
                        child: Text(l.onboardingSelectAll),
                      ),
                    ]
                  : const [],
            ),

            if (!selectionMode)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchDelegate(
                  isDark: isDark,
                  hint: l.remindersSearchHint,
                  onChanged: (q) => ref.read(_searchQueryProvider.notifier).state = q,
                ),
              ),

            if (!selectionMode)
              SliverPersistentHeader(
                pinned: false,
                delegate: _FilterBarDelegate(
                  selectedCategory: selectedCategory,
                  onlyHighPriority: ref.watch(_onlyHighPriorityProvider),
                  isDark: isDark,
                  onSelectCategory: (cat) =>
                      ref.read(_selectedCategoryProvider.notifier).state =
                          selectedCategory == cat ? null : cat,
                  onTogglePriority: () =>
                      ref.read(_onlyHighPriorityProvider.notifier).state =
                          !ref.read(_onlyHighPriorityProvider),
                ),
              ),

            allAsync.when(
              data: (all) {
                var filtered = all;
                if (selectedCategory != null) {
                  filtered = filtered.where((r) => r.category == selectedCategory).toList();
                }
                if (ref.watch(_onlyHighPriorityProvider)) {
                  filtered = filtered.where((r) => r.priority == ReminderPriority.high).toList();
                }
                if (searchQuery.isNotEmpty) {
                  final q = searchQuery.toLowerCase();
                  filtered = filtered
                      .where((r) =>
                          r.title.toLowerCase().contains(q) ||
                          (r.description?.toLowerCase().contains(q) ?? false))
                      .toList();
                }

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      hasFilters: selectedCategory != null || searchQuery.isNotEmpty,
                      l: l,
                    ),
                  );
                }

                final overdue = filtered.where((r) => r.isOverdue).toList();
                final upcoming = filtered.where((r) => !r.isOverdue).toList();

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 100),
                  sliver: SliverList.builder(
                    itemCount: (overdue.isNotEmpty ? overdue.length + 1 : 0) +
                        (upcoming.isNotEmpty ? upcoming.length + 1 : 0),
                    itemBuilder: (context, index) {
                      int i = index;

                      if (overdue.isNotEmpty) {
                        if (i == 0) {
                          return _GroupHeader(
                            title: l.remindersOverdue,
                            count: overdue.length,
                            color: AppColors.accentRed,
                            icon: Icons.warning_amber_rounded,
                          );
                        }
                        if (i <= overdue.length) {
                          final r = overdue[i - 1];
                          return _SelectableCard(
                            reminder: r,
                            selectionMode: selectionMode,
                            isSelected: selectedIds.contains(r.id),
                            animationDelay: Duration(milliseconds: (i - 1) * 40),
                            onTap: () => context.push(AppRoutes.reminderDetailPath(r.id)),
                            onDone: () => _markDoneWithUndo(context, ref, r, l),
                            onDelete: () => ref.read(reminderNotifierProvider.notifier).deleteReminder(r.id),
                            onLongPress: selectionMode
                                ? () => _enterSelection(ref, r.id)
                                : () => _showSnoozeMenu(context, ref, r, l),
                            onToggle: () => _toggleSelection(ref, r.id, selectedIds),
                          );
                        }
                        i -= overdue.length + 1;
                      }

                      if (upcoming.isNotEmpty) {
                        if (i == 0) {
                          return _GroupHeader(
                            title: l.remindersUpcoming,
                            count: upcoming.length,
                            color: AppColors.primary,
                            icon: Icons.schedule_rounded,
                          );
                        }
                        final r = upcoming[i - 1];
                        return _SelectableCard(
                          reminder: r,
                          selectionMode: selectionMode,
                          isSelected: selectedIds.contains(r.id),
                          animationDelay: Duration(milliseconds: (i - 1) * 40),
                          onTap: () => context.push(AppRoutes.reminderDetailPath(r.id)),
                          onDone: () => _markDoneWithUndo(context, ref, r, l),
                          onDelete: () => ref.read(reminderNotifierProvider.notifier).deleteReminder(r.id),
                          onLongPress: selectionMode
                              ? () => _enterSelection(ref, r.id)
                              : () => _showSnoozeMenu(context, ref, r, l),
                          onToggle: () => _toggleSelection(ref, r.id, selectedIds),
                        );
                      }

                      return null;
                    },
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
              error: (_, __) => const SliverFillRemaining(
                child: _ErrorState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markDoneWithUndo(BuildContext context, WidgetRef ref, Reminder reminder, AppLocalizations l) async {
    final original = reminder; // capture state before mutation
    await ref.read(reminderNotifierProvider.notifier).markDone(reminder, l);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.reminderDetailMarkDone),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        action: SnackBarAction(
          label: l.buttonCancel.toUpperCase(),
          onPressed: () {
            ref.read(reminderNotifierProvider.notifier).undoMarkDone(original, l);
          },
        ),
      ),
    );
  }

  void _showSnoozeMenu(BuildContext context, WidgetRef ref, Reminder reminder, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.check_box_outline_blank_rounded),
              title: Text(l.reminderListContextSelect),
              onTap: () {
                Navigator.pop(ctx);
                _enterSelection(ref, reminder.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.snooze_rounded),
              title: Text(l.reminderDetailSnooze),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(reminderNotifierProvider.notifier).snoozeReminder(reminder, l, days: 7);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(l.reminderSnoozeMonth),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(reminderNotifierProvider.notifier).snoozeReminder(reminder, l, days: 30);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _enterSelection(WidgetRef ref, int id) {
    ref.read(_selectionModeProvider.notifier).state = true;
    ref.read(_selectedIdsProvider.notifier).state = {id};
  }

  void _toggleSelection(WidgetRef ref, int id, Set<int> current) {
    final updated = Set<int>.from(current);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    ref.read(_selectedIdsProvider.notifier).state = updated;
    if (updated.isEmpty) {
      ref.read(_selectionModeProvider.notifier).state = false;
    }
  }
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.reminder,
    required this.selectionMode,
    required this.isSelected,
    required this.animationDelay,
    required this.onTap,
    required this.onDone,
    required this.onLongPress,
    required this.onToggle,
    required this.onDelete,
  });

  final Reminder reminder;
  final bool selectionMode;
  final bool isSelected;
  final Duration animationDelay;
  final VoidCallback onTap;
  final VoidCallback onDone;
  final VoidCallback onLongPress;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    Widget card = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Stack(
          children: [
            ReminderCard(
              reminder: reminder,
              animationDelay: animationDelay,
              onTap: selectionMode ? onToggle : onTap,
              onDone: selectionMode ? null : onDone,
            ),
            if (selectionMode)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.borderLight,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1)),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (selectionMode) return card;

    return Dismissible(
      key: Key('rem_${reminder.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: AppColors.accentGreen.withOpacity(0.85),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.accentRed.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onDone();
        } else {
          onDelete();
        }
      },
      child: card,
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.selectedIds,
    required this.allAsync,
    required this.l,
    required this.isDark,
    required this.ref,
  });

  final Set<int> selectedIds;
  final AsyncValue<List<Reminder>> allAsync;
  final AppLocalizations l;
  final bool isDark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final count = selectedIds.length;

    return AnimatedSlide(
      offset: count > 0 ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: count == 0
                    ? null
                    : () async {
                        final ok = await _confirmDelete(context, count, l);
                        if (ok == true && context.mounted) {
                          await ref.read(reminderNotifierProvider.notifier).deleteMultiple(selectedIds);
                          ref.read(_selectionModeProvider.notifier).state = false;
                          ref.read(_selectedIdsProvider.notifier).state = {};
                        }
                      },
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(l.selectionDelete(count)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  side: const BorderSide(color: AppColors.accentRed),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: count == 0
                  ? null
                  : () async {
                      final all = allAsync.valueOrNull ?? [];
                      final selected = all.where((r) => selectedIds.contains(r.id)).toList();
                      await SharingService().shareReminders(selected);
                    },
              icon: const Icon(Icons.ios_share_rounded, size: 20),
              tooltip: l.buttonShare,
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: count == 0
                    ? null
                    : () async {
                        final all = allAsync.valueOrNull ?? [];
                        final selected = all.where((r) => selectedIds.contains(r.id)).toList();
                        await ref.read(reminderNotifierProvider.notifier).markDoneMultiple(selected, l);
                        ref.read(_selectionModeProvider.notifier).state = false;
                        ref.read(_selectedIdsProvider.notifier).state = {};
                      },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(l.selectionMarkDone(count)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, int count, AppLocalizations l) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text(l.selectionDeleteConfirm(count)),
        content: Text(l.selectionDeleteHint),
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

class _SearchDelegate extends SliverPersistentHeaderDelegate {
  _SearchDelegate({required this.isDark, required this.hint, required this.onChanged});

  final bool isDark;
  final String hint;
  final void Function(String) onChanged;

  // 8 top-padding + 48 SearchField + 8 bottom-padding = 64 px
  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.sm),
      child: _SearchField(hint: hint, onChanged: onChanged, isDark: isDark),
    );
  }

  @override
  bool shouldRebuild(_SearchDelegate old) => old.isDark != isDark;
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.hint, required this.onChanged, required this.isDark});

  final String hint;
  final void Function(String) onChanged;
  final bool isDark;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.cardDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: widget.isDark ? AppColors.borderDark : AppColors.borderLight.withOpacity(0.5),
        ),
        boxShadow: cardShadow(widget.isDark),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: (value) {
                widget.onChanged(value);
                setState(() {});
              },
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textTertiary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                filled: false,
                isDense: true,
              ),
            ),
          ),
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
              onPressed: () {
                _ctrl.clear();
                widget.onChanged('');
                setState(() {});
              },
            ),
        ],
      ),
    );
  }
}

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  _FilterBarDelegate({
    required this.selectedCategory,
    required this.onlyHighPriority,
    required this.isDark,
    required this.onSelectCategory,
    required this.onTogglePriority,
  });

  final ReminderCategory? selectedCategory;
  final bool onlyHighPriority;
  final bool isDark;
  final void Function(ReminderCategory) onSelectCategory;
  final VoidCallback onTogglePriority;

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final l = AppLocalizations.of(context)!;
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.sm),
        children: [
          FilterChip(
            label: Text(l.filterHighPriority),
            selected: onlyHighPriority,
            onSelected: (_) => onTogglePriority(),
            selectedColor: AppColors.accentRed.withOpacity(0.15),
            checkmarkColor: AppColors.accentRed,
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: onlyHighPriority ? AppColors.accentRed : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const VerticalDivider(width: 24, indent: 8, endIndent: 8),
          ...ReminderCategory.values.map((cat) {
            final isSelected = selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${cat.emoji} ${cat.localizedLabel(l)}'),
                selected: isSelected,
                onSelected: (_) => onSelectCategory(cat),
                selectedColor: cat.color.withOpacity(0.12),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? cat.color : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.selectedCategory != selectedCategory ||
      old.onlyHighPriority != onlyHighPriority ||
      old.isDark != isDark;
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, required this.count, required this.color, required this.icon});

  final String title;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters, required this.l});
  final bool hasFilters;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(hasFilters ? '🔎' : '📋', style: const TextStyle(fontSize: 36)),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              hasFilters ? l.remindersFilterNoResults : l.remindersEmpty,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              hasFilters ? l.remindersFilterNoResultsHint : l.remindersEmptyHint,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 160.ms),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

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
