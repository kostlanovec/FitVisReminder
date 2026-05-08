import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:fit_vis_reminder/shared/widgets/reminder_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

final _selectedCategoryProvider = StateProvider<ReminderCategory?>((ref) => null);
final _searchQueryProvider = StateProvider<String>((ref) => '');
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
                onPressed: () => context.push('/reminders/add'),
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
          slivers: [
            // ── App bar ─────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 110,
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
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                title: selectionMode
                    ? Text(
                        l.selectionCount(selectedIds.length),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      )
                    : Text(
                        l.remindersTitle,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                expandedTitleScale: 1.0,
              ),
              actions: selectionMode
                  ? [
                      TextButton(
                        onPressed: () {
                          final all = allAsync.valueOrNull ?? [];
                          final ids = all.map((r) => r.id).toSet();
                          ref.read(_selectedIdsProvider.notifier).state = ids;
                        },
                        child: const Text('Vybrat vše'),
                      ),
                    ]
                  : const [],
            ),

            // ── Search bar ──────────────────────────────────────────────
            if (!selectionMode)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchDelegate(
                  isDark: isDark,
                  hint: l.remindersSearchHint,
                  onChanged: (q) => ref.read(_searchQueryProvider.notifier).state = q,
                ),
              ),

            // ── Category chips ──────────────────────────────────────────
            if (!selectionMode)
              SliverPersistentHeader(
                pinned: false,
                delegate: _CategoryFilterDelegate(
                  selected: selectedCategory,
                  isDark: isDark,
                  onSelect: (cat) =>
                      ref.read(_selectedCategoryProvider.notifier).state =
                          selectedCategory == cat ? null : cat,
                ),
              ),

            // ── List ────────────────────────────────────────────────────
            allAsync.when(
              data: (all) {
                var filtered = all;
                if (selectedCategory != null) {
                  filtered = filtered.where((r) => r.category == selectedCategory).toList();
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
                            onTap: () => context.push('/reminders/${r.id}'),
                            onDone: () => ref.read(reminderNotifierProvider.notifier).markDone(r),
                            onLongPress: () => _enterSelection(ref, r.id),
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
                          onTap: () => context.push('/reminders/${r.id}'),
                          onDone: () => ref.read(reminderNotifierProvider.notifier).markDone(r),
                          onLongPress: () => _enterSelection(ref, r.id),
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
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Chyba: $e')),
              ),
            ),
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

// ── Selectable card wrapper ────────────────────────────────────────────────

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
  });

  final Reminder reminder;
  final bool selectionMode;
  final bool isSelected;
  final Duration animationDelay;
  final VoidCallback onTap;
  final VoidCallback onDone;
  final VoidCallback onLongPress;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            // Selection overlay
            if (selectionMode)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
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
  }
}

// ── Bulk action bar ────────────────────────────────────────────────────────

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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: count == 0
                    ? null
                    : () async {
                        final all = allAsync.valueOrNull ?? [];
                        final selected = all.where((r) => selectedIds.contains(r.id)).toList();
                        await ref.read(reminderNotifierProvider.notifier).markDoneMultiple(selected);
                        ref.read(_selectionModeProvider.notifier).state = false;
                        ref.read(_selectedIdsProvider.notifier).state = {};
                      },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(l.selectionMarkDone(count)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

// ── Search persistent header ───────────────────────────────────────────────

class _SearchDelegate extends SliverPersistentHeaderDelegate {
  _SearchDelegate({required this.isDark, required this.hint, required this.onChanged});

  final bool isDark;
  final String hint;
  final void Function(String) onChanged;

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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
        color: widget.isDark ? AppColors.cardDark : AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 15),
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
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                widget.onChanged('');
                setState(() {});
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.close_rounded, size: 18, color: AppColors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Category filter persistent header ─────────────────────────────────────

class _CategoryFilterDelegate extends SliverPersistentHeaderDelegate {
  _CategoryFilterDelegate({required this.selected, required this.isDark, required this.onSelect});

  final ReminderCategory? selected;
  final bool isDark;
  final void Function(ReminderCategory) onSelect;

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        itemCount: ReminderCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = ReminderCategory.values[i];
          final isSelected = selected == cat;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? cat.color : isDark ? AppColors.cardDark : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? cat.color : isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: InkWell(
              onTap: () => onSelect(cat),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryFilterDelegate old) => old.selected != selected || old.isDark != isDark;
}

// ── Group header ───────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, required this.count, required this.color, required this.icon});

  final String title;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.2)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

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
                child: Text(hasFilters ? '🔍' : '📋', style: const TextStyle(fontSize: 36)),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'Žádné výsledky' : l.remindersEmpty,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              hasFilters ? 'Zkuste jiný filtr nebo vyhledávání' : l.remindersEmptyHint,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 160.ms),
          ],
        ),
      ),
    );
  }
}
