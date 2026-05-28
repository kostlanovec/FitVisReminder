import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
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

// ── Per-entity state configuration during onboarding ───────────────────────

class _OnboardingEntityState {
  final TextEditingController nameController;
  final Set<String> selectedTemplateIds;
  final Map<String, DateTime> lastDoneDates;
  final Map<String, RecurrenceRule> customRecurrences;

  _OnboardingEntityState({
    required String name,
    Set<String>? selectedTemplateIds,
    Map<String, DateTime>? lastDoneDates,
    Map<String, RecurrenceRule>? customRecurrences,
  })  : nameController = TextEditingController(text: name),
        selectedTemplateIds = selectedTemplateIds ?? {},
        lastDoneDates = lastDoneDates ?? {},
        customRecurrences = customRecurrences ?? {};

  void dispose() {
    nameController.dispose();
  }
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
  final Map<String, RecurrenceRule> _customRecurrences = {};
  final Map<String, int> _templateCounts = {};  // How many of each template to create
  final Map<String, List<TextEditingController>> _nameControllers = {};
  final List<_CustomEntry> _customEntries = [];

  // Entity-based categories: user defines named entities once; every selected
  // template in that category creates one reminder per entity.
  static const _entityCategories = {
    ReminderCategory.car,
    ReminderCategory.pets,
    ReminderCategory.home,   // každá nemovitost dostane vlastní sadu připomínek
  };

  // State for entity-based categories (Car, Pets, Home)
  final Map<ReminderCategory, List<_OnboardingEntityState>> _categoryEntities = {
    ReminderCategory.car: [_OnboardingEntityState(name: '')],
    ReminderCategory.pets: [_OnboardingEntityState(name: '')],
    ReminderCategory.home: [_OnboardingEntityState(name: '')],
  };

  // Currently active entity index for each category page
  final Map<ReminderCategory, int> _activeEntityIndices = {
    ReminderCategory.car: 0,
    ReminderCategory.pets: 0,
    ReminderCategory.home: 0,
  };

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
    for (final ctrls in _nameControllers.values) {
      for (final c in ctrls) c.dispose();
    }
    for (final list in _categoryEntities.values) {
      for (final entity in list) {
        entity.dispose();
      }
    }
    super.dispose();
  }

  void _onTemplateCountChanged(String id, int newCount) {
    setState(() {
      _templateCounts[id] = newCount;
      final tpl = ref.read(templateDatasourceProvider).findById(id);
      if (tpl?.supportsMultiple == true) {
        final baseTitle = tpl!.title;
        final existing = _nameControllers.putIfAbsent(
          id,
          () => [TextEditingController(text: baseTitle)],
        );
        // Grow the list if needed
        while (existing.length < newCount) {
          existing.add(TextEditingController(
            text: '$baseTitle ${existing.length + 1}',
          ));
        }
        // Don't shrink — keep controllers alive in case user goes back up
      }
    });
  }

  void _goNext() {
    if (_isLast) { _finish(); return; }
    _pageController.animateToPage(
      _currentPage + 1,
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

    // 1. Notification permission — must come first so the system dialog appears
    //    before we attempt to schedule anything.
    final notifService = ref.read(notificationServiceProvider);
    final alreadyAllowed = await notifService.isAllowed();
    if (!alreadyAllowed) {
      await notifService.requestPermission();
    }

    // 2. Precise alarms (Android 12+) — required for on-time delivery.
    //    Request silently; the system will show a dialog or open Special App Access.
    try {
      final exactStatus = await Permission.scheduleExactAlarm.status;
      if (!exactStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (_) {}

    // 3. Battery optimization exemption — prevents the OS from delaying
    //    background reschedules on aggressive-power-saving devices.
    try {
      final battStatus = await Permission.ignoreBatteryOptimizations.status;
      if (!battStatus.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (_) {}

    final l = AppLocalizations.of(context)!;
    final selectedIds = ref.read(onboardingSelectionProvider);
    final templateDs = ref.read(templateDatasourceProvider);
    final notifier = ref.read(reminderNotifierProvider.notifier);

    // Save non-entity template-based reminders
    for (final id in selectedIds) {
      final tpl = templateDs.findById(id);
      if (tpl == null) continue;

      final isEntityCat = _entityCategories.contains(tpl.category);
      if (isEntityCat) continue; // Handled separately below

      final lastDone = _lastDoneDates[id];
      final baseDueDate = (lastDone != null && tpl.defaultRecurrence.isRecurring)
          ? tpl.defaultRecurrence.nextOccurrence(lastDone)
          : DateTime.now().add(Duration(days: tpl.recommendedIntervalDays ?? 365));
      // Standard categories: use per-template count / name controllers
      final count = _templateCounts[id] ?? 1;
      final controllers = _nameControllers[id];

      for (int idx = 0; idx < count; idx++) {
        final rawName = (count > 1 && controllers != null && idx < controllers.length)
            ? controllers[idx].text.trim()
            : '';
        final title = rawName.isNotEmpty
            ? rawName
            : (idx == 0 ? tpl.title : '${tpl.title} ${idx + 1}');
        final dueDate = idx == 0
            ? baseDueDate
            : DateTime.now().add(Duration(days: tpl.recommendedIntervalDays ?? 365));

        await notifier.saveReminder(Reminder(
          id: 0,
          title: title,
          category: tpl.category,
          dueDate: dueDate,
          recurrenceRule: _customRecurrences[id] ?? tpl.defaultRecurrence,
          triggers: tpl.defaultTriggers,
          priority: tpl.priority,
          description: tpl.description,
          templateId: tpl.id,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ), l);
      }
    }

    // Save entity-based reminders
    for (final cat in _entityCategories) {
      final entities = _categoryEntities[cat] ?? [];
      for (int i = 0; i < entities.length; i++) {
        final entity = entities[i];
        final rawEntityName = entity.nameController.text.trim();
        final entityName = rawEntityName.isNotEmpty
            ? rawEntityName
            : _entityFallbackLabel(cat, i, l.localeName == 'cs');

        // Only save if the user selected at least one template for this entity
        if (entity.selectedTemplateIds.isEmpty) continue;

        for (final tplId in entity.selectedTemplateIds) {
          final tpl = templateDs.findById(tplId);
          if (tpl == null) continue;

          final lastDone = entity.lastDoneDates[tplId];
          final recurrence = entity.customRecurrences[tplId] ?? tpl.defaultRecurrence;
          final dueDate = (lastDone != null && recurrence.isRecurring)
              ? recurrence.nextOccurrence(lastDone)
              : DateTime.now().add(Duration(days: tpl.recommendedIntervalDays ?? 365));

          await notifier.saveReminder(Reminder(
            id: 0,
            title: '${tpl.title} – $entityName',
            category: cat,
            dueDate: dueDate,
            recurrenceRule: recurrence,
            triggers: tpl.defaultTriggers,
            priority: tpl.priority,
            description: tpl.description,
            templateId: tpl.id,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ), l);
        }
      }
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
      ), l);
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
                      customRecurrences: _customRecurrences,
                      templateCounts: _templateCounts,
                      nameControllers: _nameControllers,
                      onTemplateCountChanged: _onTemplateCountChanged,
                      onDatePicked: (id, date) =>
                          setState(() => _lastDoneDates[id] = date),
                      onRecurrencePicked: (id, rule) =>
                          setState(() => _customRecurrences[id] = rule),
                      entities: _entityCategories.contains(cat) ? _categoryEntities[cat] : null,
                      activeIndex: _entityCategories.contains(cat) ? _activeEntityIndices[cat] : null,
                      onEntityNameChanged: () => setState(() {}),
                      onActiveIndexChanged: _entityCategories.contains(cat)
                          ? (idx) => setState(() => _activeEntityIndices[cat] = idx)
                          : null,
                      onEntityAdded: _entityCategories.contains(cat)
                          ? () {
                              setState(() {
                                final list = _categoryEntities[cat]!;
                                list.add(_OnboardingEntityState(name: ''));
                                _activeEntityIndices[cat] = list.length - 1;
                              });
                            }
                          : null,
                      onEntityRemoved: _entityCategories.contains(cat)
                          ? (idx) {
                              setState(() {
                                final list = _categoryEntities[cat]!;
                                if (list.length > 1) {
                                  list[idx].dispose();
                                  list.removeAt(idx);
                                  final currentActive = _activeEntityIndices[cat] ?? 0;
                                  if (currentActive >= list.length) {
                                    _activeEntityIndices[cat] = list.length - 1;
                                  } else if (currentActive > 0 && idx <= currentActive) {
                                    _activeEntityIndices[cat] = currentActive - 1;
                                  }
                                }
                              });
                            }
                          : null,
                      onEntityTemplateToggled: _entityCategories.contains(cat)
                          ? (tplId) {
                              setState(() {
                                final activeIdx = _activeEntityIndices[cat] ?? 0;
                                final entity = _categoryEntities[cat]![activeIdx];
                                if (entity.selectedTemplateIds.contains(tplId)) {
                                  entity.selectedTemplateIds.remove(tplId);
                                } else {
                                  entity.selectedTemplateIds.add(tplId);
                                }
                              });
                            }
                          : null,
                      onEntityDatePicked: _entityCategories.contains(cat)
                          ? (tplId, date) {
                              setState(() {
                                final activeIdx = _activeEntityIndices[cat] ?? 0;
                                final entity = _categoryEntities[cat]![activeIdx];
                                entity.lastDoneDates[tplId] = date;
                              });
                            }
                          : null,
                      onEntityRecurrencePicked: _entityCategories.contains(cat)
                          ? (tplId, rule) {
                              setState(() {
                                final activeIdx = _activeEntityIndices[cat] ?? 0;
                                final entity = _categoryEntities[cat]![activeIdx];
                                entity.customRecurrences[tplId] = rule;
                              });
                            }
                          : null,
                      onEntityAllTemplatesCleared: _entityCategories.contains(cat)
                          ? () {
                              setState(() {
                                final activeIdx = _activeEntityIndices[cat] ?? 0;
                                final entity = _categoryEntities[cat]![activeIdx];
                                entity.selectedTemplateIds.clear();
                              });
                            }
                          : null,
                      onEntityAllTemplatesSelected: _entityCategories.contains(cat)
                          ? () {
                              setState(() {
                                final activeIdx = _activeEntityIndices[cat] ?? 0;
                                final entity = _categoryEntities[cat]![activeIdx];
                                for (final t in grouped[cat] ?? <ReminderTemplate>[]) {
                                  entity.selectedTemplateIds.add(t.id);
                                }
                              });
                            }
                          : null,
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
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
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
                  borderRadius: BorderRadius.circular(AppRadius.xs),
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
    required this.l,
  });

  final bool isWelcome;
  final bool isLast;
  final bool isSaving;
  final ReminderCategory? currentCategory;
  final VoidCallback onNext;
  final AppLocalizations l;

  String _nextLabel() {
    if (isWelcome) return l.onboardingStart;
    if (isLast) return l.onboardingFinish;
    return l.onboardingNext;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: isSaving ? null : onNext,
          style: FilledButton.styleFrom(
            backgroundColor: currentCategory?.color ?? AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            elevation: 0,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  _nextLabel(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
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
              borderRadius: BorderRadius.circular(AppRadius.xl),
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
        borderRadius: BorderRadius.circular(AppRadius.md),
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
    required this.customRecurrences,
    required this.onDatePicked,
    required this.onRecurrencePicked,
    required this.templateCounts,
    required this.nameControllers,
    required this.onTemplateCountChanged,
    this.entities,
    this.activeIndex,
    this.onEntityNameChanged,
    this.onActiveIndexChanged,
    this.onEntityAdded,
    this.onEntityRemoved,
    this.onEntityTemplateToggled,
    this.onEntityDatePicked,
    this.onEntityRecurrencePicked,
    this.onEntityAllTemplatesCleared,
    this.onEntityAllTemplatesSelected,
  });

  final ReminderCategory category;
  final List<ReminderTemplate> templates;
  final Map<String, DateTime> lastDoneDates;
  final Map<String, RecurrenceRule> customRecurrences;
  final void Function(String id, DateTime date) onDatePicked;
  final void Function(String id, RecurrenceRule rule) onRecurrencePicked;
  final Map<String, int> templateCounts;
  final Map<String, List<TextEditingController>> nameControllers;
  final void Function(String id, int count) onTemplateCountChanged;

  // New parameters for entity configuration
  final List<_OnboardingEntityState>? entities;
  final int? activeIndex;
  final VoidCallback? onEntityNameChanged;
  final void Function(int)? onActiveIndexChanged;
  final VoidCallback? onEntityAdded;
  final void Function(int)? onEntityRemoved;
  final void Function(String)? onEntityTemplateToggled;
  final void Function(String, DateTime)? onEntityDatePicked;
  final void Function(String, RecurrenceRule)? onEntityRecurrencePicked;
  final VoidCallback? onEntityAllTemplatesCleared;
  final VoidCallback? onEntityAllTemplatesSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final selection = ref.watch(onboardingSelectionProvider);
    final notifier = ref.read(onboardingSelectionProvider.notifier);

    final isEntityCat = entities != null && activeIndex != null;
    final activeEntity = isEntityCat ? entities![activeIndex!] : null;

    final selectedInCat = templates.where((t) {
      if (isEntityCat) {
        return activeEntity!.selectedTemplateIds.contains(t.id);
      } else {
        return selection.contains(t.id);
      }
    }).length;

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
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 28))),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.localizedLabel(l),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: category.color, fontWeight: FontWeight.w700,
                            ),
                          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                          Text(
                            category.localizedDescription(l),
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
                        if (isEntityCat) {
                          final allSelected = selectedInCat == templates.length;
                          if (allSelected) {
                            onEntityAllTemplatesCleared?.call();
                          } else {
                            onEntityAllTemplatesSelected?.call();
                          }
                        } else {
                          if (selectedInCat == templates.length) {
                            for (final t in templates) {
                              if (selection.contains(t.id)) notifier.toggle(t.id);
                            }
                          } else {
                            for (final t in templates) {
                              if (!selection.contains(t.id)) notifier.toggle(t.id);
                            }
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
        // Entity section — active entity card
        if (isEntityCat)
          SliverToBoxAdapter(
            child: _ActiveEntityCard(
              category: category,
              entity: activeEntity!,
              activeIndex: activeIndex!,
              totalEntities: entities!.length,
              onNameChanged: onEntityNameChanged,
              onNavigate: onActiveIndexChanged,
              onAdd: onEntityAdded,
              onRemove: onEntityRemoved != null ? () => onEntityRemoved!(activeIndex!) : null,
            ),
          ),

        SliverList.builder(
          itemCount: templates.length,
          itemBuilder: (context, i) {
            final tpl = templates[i];
            final isSelected = isEntityCat
                ? activeEntity!.selectedTemplateIds.contains(tpl.id)
                : selection.contains(tpl.id);
            final count = templateCounts[tpl.id] ?? 1;
            final ctrls = nameControllers[tpl.id];
            final isCs = Localizations.localeOf(context).languageCode == 'cs';
            final showQuantity = !isEntityCat;

            return Column(
              children: [
                _TemplateTile(
                  template: tpl,
                  isSelected: isSelected,
                  lastDoneDate: isEntityCat ? activeEntity!.lastDoneDates[tpl.id] : lastDoneDates[tpl.id],
                  customRecurrence: isEntityCat ? activeEntity!.customRecurrences[tpl.id] : customRecurrences[tpl.id],
                  onToggle: isEntityCat
                      ? () => onEntityTemplateToggled?.call(tpl.id)
                      : () => notifier.toggle(tpl.id),
                  onDatePicked: isEntityCat
                      ? (date) => onEntityDatePicked?.call(tpl.id, date)
                      : (date) => onDatePicked(tpl.id, date),
                  onRecurrencePicked: isEntityCat
                      ? (rule) => onEntityRecurrencePicked?.call(tpl.id, rule)
                      : (rule) => onRecurrencePicked(tpl.id, rule),
                ).animate(delay: Duration(milliseconds: 40 + i * 40)).fadeIn().slideY(begin: 0.08),
                // Only show quantity row for non-entity templates that support multiple instances
                if (isSelected && tpl.supportsMultiple && showQuantity)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuantityRow(
                          count: count,
                          onChanged: (newCount) => onTemplateCountChanged(tpl.id, newCount),
                        ),
                        if (count > 1 && ctrls != null) ...[
                          const SizedBox(height: 4),
                          for (int idx = 0; idx < count && idx < ctrls.length; idx++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextField(
                                controller: ctrls[idx],
                                decoration: InputDecoration(
                                  labelText: isCs
                                      ? 'Název ${idx + 1}'
                                      : 'Name ${idx + 1}',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
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
                        borderRadius: BorderRadius.circular(AppRadius.card),
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
                subtitle: Text(e.recurrence.humanLabelLocalized(AppLocalizations.of(context)!), style: const TextStyle(fontSize: 12)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
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
                    label: Text('${cat.emoji} ${cat.localizedLabel(l)}', style: const TextStyle(fontSize: 11)),
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

// ── Entity section (Car / Pets / Home / …) ────────────────────────────────

class _ActiveEntityCard extends StatelessWidget {
  const _ActiveEntityCard({
    required this.category,
    required this.entity,
    required this.activeIndex,
    required this.totalEntities,
    this.onNameChanged,
    this.onNavigate,
    this.onAdd,
    this.onRemove,
  });

  final ReminderCategory category;
  final _OnboardingEntityState entity;
  final int activeIndex;
  final int totalEntities;
  final VoidCallback? onNameChanged;
  final void Function(int)? onNavigate;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCs = Localizations.localeOf(context).languageCode == 'cs';

    final (label, hint, navLabel, icon) = switch (category) {
      ReminderCategory.car => (
          isCs ? 'Název vozidla' : 'Vehicle name',
          isCs ? 'např. Škoda Octavia' : 'e.g. Toyota Camry',
          isCs ? 'Auto' : 'Vehicle',
          Icons.directions_car_rounded,
        ),
      ReminderCategory.pets => (
          isCs ? 'Jméno mazlíčka' : 'Pet name',
          isCs ? 'např. Max' : 'e.g. Buddy',
          isCs ? 'Mazlíček' : 'Pet',
          Icons.pets_rounded,
        ),
      ReminderCategory.home => (
          isCs ? 'Název nemovitosti' : 'Property name',
          isCs ? 'např. Byt Praha 2' : 'e.g. Main apartment',
          isCs ? 'Nemovitost' : 'Property',
          Icons.home_rounded,
        ),
      _ => (
          isCs ? 'Název' : 'Name',
          isCs ? 'např. Položka 1' : 'e.g. Item 1',
          isCs ? 'Položka' : 'Item',
          Icons.info_outline_rounded,
        ),
    };

    final isCs_z = isCs ? 'z' : 'of';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: category.color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: category.color),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: category.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (totalEntities > 1 && onRemove != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.accentRed),
                  onPressed: onRemove,
                  tooltip: isCs ? 'Odstranit' : 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: entity.nameController,
            onChanged: (_) => onNameChanged?.call(),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: category.color.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: category.color, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14,
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: activeIndex > 0 ? () => onNavigate?.call(activeIndex - 1) : null,
                style: IconButton.styleFrom(
                  foregroundColor: category.color,
                  disabledForegroundColor: AppColors.textSecondary.withOpacity(0.3),
                  backgroundColor: category.color.withOpacity(0.08),
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
              Text(
                '$navLabel ${activeIndex + 1} $isCs_z $totalEntities',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: category.color,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activeIndex < totalEntities - 1)
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onPressed: () => onNavigate?.call(activeIndex + 1),
                      style: IconButton.styleFrom(
                        foregroundColor: category.color,
                        backgroundColor: category.color.withOpacity(0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    )
                  else if (onAdd != null)
                    TextButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(
                        isCs ? 'Přidat' : 'Add',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: category.color,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Template tile ──────────────────────────────────────────────────────────

/// Fallback label for an entity when the user hasn't typed a name yet.
String _entityFallbackLabel(ReminderCategory cat, int idx, bool isCs) {
  return switch (cat) {
    ReminderCategory.car  => isCs ? 'Vozidlo ${idx + 1}'    : 'Vehicle ${idx + 1}',
    ReminderCategory.pets => isCs ? 'Mazlíček ${idx + 1}'   : 'Pet ${idx + 1}',
    ReminderCategory.home => isCs ? 'Nemovitost ${idx + 1}' : 'Property ${idx + 1}',
    _                     => isCs ? 'Položka ${idx + 1}'    : 'Item ${idx + 1}',
  };
}

int _ruleToMonths(RecurrenceRule rule) {
  if (rule.intervalMonths != null) return rule.intervalMonths!;
  if (rule.intervalYears != null) return rule.intervalYears! * 12;
  if (rule.intervalDays != null) return (rule.intervalDays! / 30).round().clamp(1, 999);
  return 12;
}

String _monthLabel(int m, bool isCs) {
  final years = m / 12;
  if (m % 12 == 0) {
    if (isCs) {
      if (years == 1) return '1 rok';
      if (years < 5) return '${years.toInt()} roky';
      return '${years.toInt()} let';
    }
    return years == 1 ? '1 year' : '${years.toInt()} years';
  }
  if (isCs) {
    if (m == 1) return '1 měsíc';
    if (m < 5) return '$m měsíce';
    return '$m měsíců';
  }
  return m == 1 ? '1 month' : '$m months';
}

class _TemplateTile extends StatefulWidget {
  const _TemplateTile({
    required this.template,
    required this.isSelected,
    required this.lastDoneDate,
    required this.customRecurrence,
    required this.onToggle,
    required this.onDatePicked,
    required this.onRecurrencePicked,
  });

  final ReminderTemplate template;
  final bool isSelected;
  final DateTime? lastDoneDate;
  final RecurrenceRule? customRecurrence;
  final VoidCallback onToggle;
  final void Function(DateTime) onDatePicked;
  final void Function(RecurrenceRule) onRecurrencePicked;

  @override
  State<_TemplateTile> createState() => _TemplateTileState();
}

class _TemplateTileState extends State<_TemplateTile> {
  late final TextEditingController _customCtrl;
  bool _showCustomInput = false;
  RecurrenceUnit _customUnit = RecurrenceUnit.months;

  @override
  void initState() {
    super.initState();
    final months = _ruleToMonths(widget.customRecurrence ?? widget.template.defaultRecurrence);
    _customCtrl = TextEditingController(text: months.toString());
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  List<int> _buildOptions() {
    final defaultM = _ruleToMonths(widget.template.defaultRecurrence);
    final options = [6, 12, 24, 36, 60];
    if (!options.contains(defaultM)) {
      options.add(defaultM);
      options.sort();
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final cat = widget.template.category;
    final isCs = Localizations.localeOf(context).languageCode == 'cs';

    final currentRule = widget.customRecurrence ?? widget.template.defaultRecurrence;
    final currentMonths = _ruleToMonths(currentRule);
    final options = _buildOptions();
    final isCustomSelected = !options.contains(currentMonths);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: widget.isSelected ? cat.color.withOpacity(isDark ? 0.12 : 0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: widget.isSelected ? cat.color.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: widget.onToggle,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Text(widget.template.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.template.title,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text(widget.template.defaultRecurrence.humanLabelLocalized(AppLocalizations.of(context)!),
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: widget.isSelected ? cat.color : Colors.transparent,
                        border: Border.all(
                          color: widget.isSelected ? cat.color : AppColors.borderLight,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: widget.isSelected
                          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.isSelected)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.template.onboardingQuestion != null) ...[
                      Text(widget.template.onboardingQuestion!,
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      _DateButton(selectedDate: widget.lastDoneDate, color: cat.color, onPick: widget.onDatePicked),
                      const SizedBox(height: 12),
                    ],
                    Text(l.onboardingFrequencyLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    ...options.map((m) {
                      final isSel = currentMonths == m && !isCustomSelected;
                      return InkWell(
                        onTap: () {
                          setState(() => _showCustomInput = false);
                          widget.onRecurrencePicked(RecurrenceRule.customMonths(months: m));
                        },
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _monthLabel(m, isCs),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                    color: isSel ? cat.color : null,
                                  ),
                                ),
                              ),
                              if (isSel) Icon(Icons.check_rounded, size: 18, color: cat.color),
                            ],
                          ),
                        ),
                      );
                    }),
                    InkWell(
                      onTap: () {
                        setState(() => _showCustomInput = true);
                        if (isCustomSelected) {
                          _customCtrl.text = currentMonths.toString();
                        } else {
                          _customCtrl.text = '';
                        }
                      },
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.reminderCustomLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isCustomSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isCustomSelected ? cat.color : null,
                                ),
                              ),
                            ),
                            if (isCustomSelected) Icon(Icons.check_rounded, size: 18, color: cat.color),
                          ],
                        ),
                      ),
                    ),
                    if (_showCustomInput || isCustomSelected) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: isCs ? 'Počet' : 'Count',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                              ),
                              onChanged: (v) {
                                final n = int.tryParse(v) ?? 1;
                                if (n > 0) {
                                  widget.onRecurrencePicked(
                                    RecurrenceRule.custom(frequency: n, unit: _customUnit),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<RecurrenceUnit>(
                            value: _customUnit,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            items: [
                              DropdownMenuItem(
                                value: RecurrenceUnit.days,
                                child: Text(isCs ? 'Dny' : 'Days'),
                              ),
                              DropdownMenuItem(
                                value: RecurrenceUnit.weeks,
                                child: Text(isCs ? 'Týdny' : 'Weeks'),
                              ),
                              DropdownMenuItem(
                                value: RecurrenceUnit.months,
                                child: Text(isCs ? 'Měsíce' : 'Months'),
                              ),
                              DropdownMenuItem(
                                value: RecurrenceUnit.years,
                                child: Text(isCs ? 'Roky' : 'Years'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _customUnit = v);
                                final n = int.tryParse(_customCtrl.text) ?? 1;
                                widget.onRecurrencePicked(
                                  RecurrenceRule.custom(frequency: n, unit: v),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Quantity row (for multiple instances of same template) ──────────────────

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({required this.count, required this.onChanged});
  final int count;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final isCs = Localizations.localeOf(context).languageCode == 'cs';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            isCs ? 'Počet' : 'Quantity',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton.filled(
            icon: const Icon(Icons.remove_rounded, size: 18),
            onPressed: count > 1 ? () => onChanged(count - 1) : null,
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: count > 1 ? AppColors.primary : AppColors.borderLight,
              minimumSize: const Size(36, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton.filled(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: count < 5 ? () => onChanged(count + 1) : null,
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: count < 5 ? AppColors.primary : AppColors.borderLight,
              minimumSize: const Size(36, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
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
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
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
      lastDate: DateTime.now().add(const Duration(days: 18250)),
    );
    if (picked != null) onPick(picked);
  }
}
