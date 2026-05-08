import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/recurrence_rule.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/features/templates/domain/entities/reminder_template.dart';
import 'package:fit_vis_reminder/features/templates/presentation/providers/template_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

// ── Custom reminder added during onboarding ────────────────────────────────

class _CustomEntry {
  final String title;
  final ReminderCategory category;
  final RecurrenceRule recurrence;
  _CustomEntry({required this.title, required this.category, required this.recurrence});
}

// ── Onboarding page ────────────────────────────────────────────────────────
// Flow: Welcome → one page per category → Custom page

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  final Map<String, DateTime> _lastDoneDates = {};
  final List<_CustomEntry> _customEntries = [];

  static const _categories = ReminderCategory.values;
  // pages: welcome + 8 categories + 1 custom page
  int get _totalPages => 1 + _categories.length + 1;
  bool get _isWelcome => _currentPage == 0;
  bool get _isCustomPage => _currentPage == _totalPages - 1;
  bool get _isLast => _isCustomPage;
  ReminderCategory? get _currentCategory =>
      (_currentPage >= 1 && _currentPage <= _categories.length)
          ? _categories[_currentPage - 1]
          : null;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_isLast) { _finish(); return; }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final selectedIds = ref.read(onboardingSelectionProvider);
    final templateDs = ref.read(templateDatasourceProvider);
    final notifier = ref.read(reminderNotifierProvider.notifier);

    // Save template-based reminders
    for (final id in selectedIds) {
      final tpl = templateDs.findById(id);
      if (tpl == null) continue;

      final lastDone = _lastDoneDates[id];
      final dueDate = (lastDone != null && tpl.defaultRecurrence.isRecurring)
          ? tpl.defaultRecurrence.nextOccurrence(lastDone)
          : DateTime.now().add(Duration(days: tpl.recommendedIntervalDays ?? 365));

      await notifier.saveReminder(Reminder(
        id: 0,
        title: tpl.title,
        category: tpl.category,
        dueDate: dueDate,
        recurrenceRule: tpl.defaultRecurrence,
        triggers: tpl.defaultTriggers,
        description: tpl.description,
        templateId: tpl.id,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    // Save custom reminders
    for (final entry in _customEntries) {
      await notifier.saveReminder(Reminder(
        id: 0,
        title: entry.title,
        category: entry.category,
        dueDate: DateTime.now().add(const Duration(days: 365)),
        recurrenceRule: entry.recurrence,
        triggers: const [
          NotificationTrigger.weekBefore(),
          NotificationTrigger.dayBefore(),
          NotificationTrigger.sameDay(),
        ],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    await completeOnboarding(ref);
    if (mounted) context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final allTemplates = ref.watch(allTemplatesProvider);
    final grouped = <ReminderCategory, List<ReminderTemplate>>{};
    for (final t in allTemplates) {
      (grouped[t.category] ??= []).add(t);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onBack: _currentPage > 0 ? _goBack : null,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _WelcomePage(),
                  for (final cat in _categories)
                    _CategoryPage(
                      category: cat,
                      templates: grouped[cat] ?? [],
                      lastDoneDates: _lastDoneDates,
                      onDatePicked: (id, date) =>
                          setState(() => _lastDoneDates[id] = date),
                    ),
                  _CustomPage(
                    entries: _customEntries,
                    onAdd: (e) => setState(() => _customEntries.add(e)),
                    onRemove: (i) => setState(() => _customEntries.removeAt(i)),
                  ),
                ],
              ),
            ),
            _BottomBar(
              isWelcome: _isWelcome,
              isLast: _isLast,
              isSaving: _isSaving,
              currentCategory: _currentCategory,
              onNext: _goNext,
              onSkip: (!_isWelcome && !_isLast) ? _goNext : null,
              l: l,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.currentPage, required this.totalPages, required this.onBack});
  final int currentPage;
  final int totalPages;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final progress = (currentPage + 1) / totalPages;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: onBack != null
                ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBack)
                : null,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${currentPage + 1} / $totalPages',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.borderLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar ─────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isWelcome,
    required this.isLast,
    required this.isSaving,
    required this.currentCategory,
    required this.onNext,
    required this.onSkip,
    required this.l,
  });

  final bool isWelcome;
  final bool isLast;
  final bool isSaving;
  final ReminderCategory? currentCategory;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final AppLocalizations l;

  String _nextLabel() {
    if (isWelcome) return l.onboardingStart;
    if (isLast) return l.onboardingFinish;
    return l.onboardingNext;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          if (onSkip != null)
            TextButton(
              onPressed: onSkip,
              child: Text(l.onboardingSkip),
            ),
          const Spacer(),
          FilledButton(
            onPressed: isSaving ? null : onNext,
            style: FilledButton.styleFrom(
              backgroundColor: currentCategory?.color ?? AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_nextLabel(),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ── Welcome page ───────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.verified_rounded, color: Colors.white, size: 52),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          Text(l.onboardingWelcomeTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center)
              .animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: 12),

          Text(
            l.onboardingWelcomeSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: 32),

          ...[
            (Icons.notifications_active_rounded, l.onboardingFeatureNotifications),
            (Icons.repeat_rounded, l.onboardingFeatureRecurring),
            (Icons.battery_saver_rounded, l.onboardingFeatureBattery),
            (Icons.offline_bolt_rounded, l.onboardingFeatureOffline),
          ].map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FeaturePill(icon: e.$1, text: e.$2),
              )),

          const SizedBox(height: 24),

          Text(
            l.onboardingWelcomeHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ── Category page ──────────────────────────────────────────────────────────

class _CategoryPage extends ConsumerWidget {
  const _CategoryPage({
    required this.category,
    required this.templates,
    required this.lastDoneDates,
    required this.onDatePicked,
  });

  final ReminderCategory category;
  final List<ReminderTemplate> templates;
  final Map<String, DateTime> lastDoneDates;
  final void Function(String id, DateTime date) onDatePicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final selection = ref.watch(onboardingSelectionProvider);
    final notifier = ref.read(onboardingSelectionProvider.notifier);
    final selectedInCat = templates.where((t) => selection.contains(t.id)).length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 28))),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.label,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: category.color, fontWeight: FontWeight.w700,
                            ),
                          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                          Text(
                            category.description,
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ).animate().fadeIn(delay: 180.ms),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      selectedInCat == 0
                          ? l.onboardingNothingSelected
                          : l.onboardingSelectedCount(selectedInCat, templates.length),
                      style: TextStyle(
                        fontSize: 13,
                        color: selectedInCat > 0 ? category.color : AppColors.textSecondary,
                        fontWeight: selectedInCat > 0 ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (selectedInCat == templates.length) {
                          for (final t in templates) {
                            if (selection.contains(t.id)) notifier.toggle(t.id);
                          }
                        } else {
                          for (final t in templates) {
                            if (!selection.contains(t.id)) notifier.toggle(t.id);
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: category.color,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        selectedInCat == templates.length
                            ? l.onboardingDeselectAll
                            : l.onboardingSelectAll,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                Divider(color: category.color.withOpacity(0.2)),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: templates.length,
          itemBuilder: (context, i) {
            final tpl = templates[i];
            final isSelected = selection.contains(tpl.id);
            return _TemplateTile(
              template: tpl,
              isSelected: isSelected,
              lastDoneDate: lastDoneDates[tpl.id],
              onToggle: () => notifier.toggle(tpl.id),
              onDatePicked: (date) => onDatePicked(tpl.id, date),
            ).animate(delay: Duration(milliseconds: 40 + i * 40)).fadeIn().slideY(begin: 0.08);
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

// ── Custom page ────────────────────────────────────────────────────────────

class _CustomPage extends StatelessWidget {
  const _CustomPage({required this.entries, required this.onAdd, required this.onRemove});

  final List<_CustomEntry> entries;
  final void Function(_CustomEntry) onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Icon(Icons.add_rounded, size: 30, color: AppColors.primary)),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.onboardingCustomCard,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            l.onboardingCustomHint,
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.primary.withOpacity(0.2)),
              ],
            ),
          ),
        ),

        // Existing custom entries
        if (entries.isNotEmpty)
          SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final e = entries[i];
              return ListTile(
                leading: Text(e.category.emoji, style: const TextStyle(fontSize: 22)),
                title: Text(e.title),
                subtitle: Text(e.recurrence.humanLabel, style: const TextStyle(fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => onRemove(i),
                ),
              );
            },
          ),

        // Add button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: OutlinedButton.icon(
              onPressed: () => _showAddDialog(context, l),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.onboardingCustomAdd),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext context, AppLocalizations l) async {
    final titleCtrl = TextEditingController();
    ReminderCategory selectedCat = ReminderCategory.documents;
    RecurrenceRule selectedRecurrence = const RecurrenceRule.yearly();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(l.onboardingCustomTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.onboardingCustomNameLabel,
                  hintText: l.onboardingCustomNameHint,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Text(l.onboardingCustomCategoryLabel,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ReminderCategory.values.map((cat) {
                  final sel = selectedCat == cat;
                  return FilterChip(
                    label: Text('${cat.emoji} ${cat.label}', style: const TextStyle(fontSize: 11)),
                    selected: sel,
                    onSelected: (_) => setDlgState(() => selectedCat = cat),
                    selectedColor: cat.color.withOpacity(0.15),
                    checkmarkColor: cat.color,
                    labelStyle: TextStyle(color: sel ? cat.color : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(l.onboardingCustomRecurrenceLabel,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  (l.recurrenceOnce, const RecurrenceRule.once()),
                  (l.recurrenceWeekly, const RecurrenceRule.weekly()),
                  (l.recurrenceMonthly, const RecurrenceRule.monthly()),
                  (l.recurrenceYearly, const RecurrenceRule.yearly()),
                ].map((pair) {
                  final sel = selectedRecurrence.type == pair.$2.type;
                  return ChoiceChip(
                    label: Text(pair.$1, style: const TextStyle(fontSize: 12)),
                    selected: sel,
                    onSelected: (_) => setDlgState(() => selectedRecurrence = pair.$2),
                    selectedColor: AppColors.primary.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: sel ? AppColors.primary : null,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.onboardingCustomCancel),
            ),
            FilledButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                onAdd(_CustomEntry(
                  title: title,
                  category: selectedCat,
                  recurrence: selectedRecurrence,
                ));
                Navigator.pop(ctx);
              },
              child: Text(l.onboardingCustomAdd),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Template tile ──────────────────────────────────────────────────────────

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.isSelected,
    required this.lastDoneDate,
    required this.onToggle,
    required this.onDatePicked,
  });

  final ReminderTemplate template;
  final bool isSelected;
  final DateTime? lastDoneDate;
  final VoidCallback onToggle;
  final void Function(DateTime) onDatePicked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cat = template.category;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? cat.color.withOpacity(isDark ? 0.12 : 0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? cat.color.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Text(template.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(template.title,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text(template.defaultRecurrence.humanLabel,
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? cat.color : AppColors.borderLight,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected && template.onboardingQuestion != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 0, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.onboardingQuestion!,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    _DateButton(selectedDate: lastDoneDate, color: cat.color, onPick: onDatePicked),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Date picker button ─────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  const _DateButton({required this.selectedDate, required this.color, required this.onPick});
  final DateTime? selectedDate;
  final Color color;
  final void Function(DateTime) onPick;

  String get _label {
    if (selectedDate == null) return 'Vybrat datum...';
    final d = selectedDate!;
    return '${d.day}.${d.month}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: color),
            const SizedBox(width: 8),
            Text(_label,
                style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final initial = selectedDate ?? DateTime(DateTime.now().year - 1, DateTime.now().month, 1);
    final picked = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.year,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) onPick(picked);
  }
}
