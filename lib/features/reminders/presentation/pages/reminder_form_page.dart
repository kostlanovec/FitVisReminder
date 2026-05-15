import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/recurrence_rule.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:fit_vis_reminder/features/templates/domain/entities/reminder_template.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ReminderFormPage extends ConsumerStatefulWidget {
  const ReminderFormPage({super.key, this.reminderId, this.initialTemplate});

  final int? reminderId;
  final ReminderTemplate? initialTemplate;

  @override
  ConsumerState<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends ConsumerState<ReminderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  ReminderCategory _category = ReminderCategory.documents;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 365));
  RecurrenceRule _recurrence = const RecurrenceRule.yearly();
  ReminderPriority _priority = ReminderPriority.normal;
  List<NotificationTrigger> _triggers = const [
    NotificationTrigger.monthBefore(),
    NotificationTrigger.weekBefore(),
    NotificationTrigger.dayBefore(),
    NotificationTrigger.sameDay(),
  ];
  ReminderTemplate? _selectedTemplate;
  bool _isLoading = false;
  bool _isEditing = false;
  Reminder? _original;

  @override
  void initState() {
    super.initState();
    if (widget.initialTemplate != null) {
      _applyTemplate(widget.initialTemplate!);
    }
    _load();
  }

  void _applyTemplate(ReminderTemplate tpl) {
    _selectedTemplate = tpl;
    _titleController.text = tpl.title;
    _descController.text = tpl.description;
    _category = tpl.category;
    _recurrence = tpl.defaultRecurrence;
    _triggers = tpl.defaultTriggers;
    _priority = tpl.priority;
  }

  Future<void> _load() async {
    if (widget.reminderId != null) {
      _isEditing = true;
      final repo = ref.read(reminderRepositoryProvider);
      _original = await repo.findById(widget.reminderId!);
      if (_original != null) {
        setState(() {
          _titleController.text = _original!.title;
          _descController.text = _original!.description ?? '';
          _category = _original!.category;
          _dueDate = _original!.dueDate;
          _recurrence = _original!.recurrenceRule;
          _triggers = _original!.triggers;
          _priority = _original!.priority;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final reminder = Reminder(
      id: _original?.id ?? 0,
      title: _titleController.text.trim(),
      category: _category,
      dueDate: _dueDate,
      recurrenceRule: _recurrence,
      triggers: _triggers,
      priority: _priority,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      templateId: _selectedTemplate?.id ?? _original?.templateId,
      isActive: true,
      createdAt: _original?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final l = AppLocalizations.of(context)!;
    await ref.read(reminderNotifierProvider.notifier).saveReminder(reminder, l);

    setState(() => _isLoading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.reminderFormTitleEdit : l.reminderFormTitleNew),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: l.buttonClose,
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : Text(l.buttonSave, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (!_isEditing) ...[
              _SectionLabel(label: l.reminderFormTemplateSection),
              _FormCard(
                child: _TemplatePicker(
                  selectedTemplate: _selectedTemplate,
                  onPick: (tpl) => setState(() {
                    _selectedTemplate = tpl;
                    if (tpl != null) _applyTemplate(tpl);
                  }),
                ),
              ),
              const SizedBox(height: 16),
            ],

            _SectionLabel(label: l.reminderFormBasicInfo),
            _FormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l.reminderFormFieldTitleRequired : null,
                    decoration: InputDecoration(
                      labelText: l.reminderFormFieldTitle,
                      hintText: l.reminderFormFieldTitleHint,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: l.reminderFormFieldDescription,
                      hintText: l.reminderFormFieldDescriptionHint,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _SectionLabel(label: l.reminderFormFieldCategory),
            _FormCard(
              child: _CategoryPicker(
                selected: _category,
                onSelect: (cat) => setState(() => _category = cat),
              ),
            ),

            const SizedBox(height: 16),
            _SectionLabel(label: l.reminderPriorityLabel),
            _FormCard(
              child: _PriorityPicker(
                selected: _priority,
                onSelect: (p) => setState(() => _priority = p),
              ),
            ),

            const SizedBox(height: 16),
            _SectionLabel(label: l.reminderFormFieldDueDate),
            _FormCard(
              child: _DatePickerButton(
                date: _dueDate,
                onPick: (d) => setState(() => _dueDate = d),
              ),
            ),

            const SizedBox(height: 16),
            _SectionLabel(label: l.reminderFormRecurrenceSection),
            _FormCard(
              child: _RecurrencePicker(
                selected: _recurrence,
                onSelect: (r) => setState(() => _recurrence = r),
              ),
            ),

            const SizedBox(height: 16),
            _SectionLabel(label: l.reminderFormTriggersSection),
            _FormCard(
              child: _TriggersPicker(
                selected: _triggers,
                onChanged: (t) => setState(() => _triggers = t),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary.withOpacity(0.8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight.withOpacity(0.5),
        ),
        boxShadow: cardShadow(isDark),
      ),
      child: child,
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.selected, required this.onSelect});

  final ReminderCategory selected;
  final void Function(ReminderCategory) onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReminderCategory.values.map((cat) {
        final isSelected = selected == cat;
        return ChoiceChip(
          label: Text('${cat.emoji} ${cat.label}'),
          selected: isSelected,
          onSelected: (_) => onSelect(cat),
          selectedColor: cat.color.withOpacity(0.12),
          labelStyle: TextStyle(
            fontSize: 12,
            color: isSelected ? cat.color : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({required this.date, required this.onPick});

  final DateTime date;
  final void Function(DateTime) onPick;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 18250)),
        );
        if (picked != null) onPick(picked);
      },
      icon: const Icon(Icons.calendar_today_rounded, size: 18),
      label: Text(DateFormat('d. MMMM yyyy', locale).format(date)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignment: Alignment.centerLeft,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _RecurrencePicker extends StatelessWidget {
  const _RecurrencePicker({required this.selected, required this.onSelect});

  final RecurrenceRule selected;
  final void Function(RecurrenceRule) onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final presets = [
      (label: l.recurrenceOnce, rule: const RecurrenceRule.once()),
      (label: l.recurrenceWeekly, rule: const RecurrenceRule.weekly()),
      (label: l.recurrenceMonthly, rule: const RecurrenceRule.monthly()),
      (label: l.recurrenceYearly, rule: const RecurrenceRule.yearly()),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...presets.map((preset) {
          final isSelected = selected.type == preset.rule.type &&
              selected.frequency == preset.rule.frequency &&
              selected.unit == preset.rule.unit;
          return ChoiceChip(
            label: Text(preset.label),
            selected: isSelected,
            onSelected: (_) => onSelect(preset.rule),
            selectedColor: AppColors.primary.withOpacity(0.12),
            labelStyle: TextStyle(
              fontSize: 13,
              color: isSelected ? AppColors.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        }),
        ChoiceChip(
          label: Text(l.reminderCustomLabel),
          selected: !presets.any((p) =>
              p.rule.type == selected.type &&
              p.rule.frequency == selected.frequency &&
              p.rule.unit == selected.unit),
          onSelected: (_) => _showCustomRecurrenceDialog(context, l),
          selectedColor: AppColors.primary.withOpacity(0.12),
          labelStyle: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  void _showCustomRecurrenceDialog(BuildContext context, AppLocalizations l) {
    int frequency = selected.frequency;
    RecurrenceUnit unit = selected.unit;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l.reminderCustomRecurrence),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l.onboardingFrequencyLabel),
                      onChanged: (v) => frequency = int.tryParse(v) ?? 1,
                      controller: TextEditingController(text: frequency.toString()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<RecurrenceUnit>(
                    value: unit,
                    items: [
                      DropdownMenuItem(value: RecurrenceUnit.days, child: Text(l.reminderCustomDays)),
                      DropdownMenuItem(value: RecurrenceUnit.months, child: Text(l.reminderCustomMonths)),
                      DropdownMenuItem(value: RecurrenceUnit.years, child: Text(l.reminderCustomYears)),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => unit = v);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.buttonCancel)),
            FilledButton(
              onPressed: () {
                onSelect(RecurrenceRule.custom(frequency: frequency, unit: unit));
                Navigator.pop(ctx);
              },
              child: Text(l.buttonAdd),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriggersPicker extends StatelessWidget {
  const _TriggersPicker({required this.selected, required this.onChanged});

  final List<NotificationTrigger> selected;
  final void Function(List<NotificationTrigger>) onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final options = [
      (trigger: const NotificationTrigger.monthBefore(), label: l.triggerMonthBefore),
      (trigger: const NotificationTrigger.weekBefore(), label: l.triggerWeekBefore),
      (trigger: const NotificationTrigger.dayBefore(), label: l.triggerDayBefore),
      (trigger: const NotificationTrigger.sameDay(), label: l.triggerSameDay),
    ];
    final customTriggers = selected.where((t) => !options.any((opt) => opt.trigger.offsetDays == t.offsetDays)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((opt) {
          final isSelected = selected.any((t) => t.offsetDays == opt.trigger.offsetDays);
          return CheckboxListTile(
            value: isSelected,
            title: Text(opt.label, style: const TextStyle(fontSize: 14)),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onChanged: (_) {
              final updated = List<NotificationTrigger>.from(selected);
              if (isSelected) {
                updated.removeWhere((t) => t.offsetDays == opt.trigger.offsetDays);
              } else {
                updated.add(opt.trigger);
              }
              updated.sort((a, b) => b.offsetDays.compareTo(a.offsetDays));
              onChanged(updated);
            },
          );
        }),
        ...customTriggers.map((t) => CheckboxListTile(
          value: true,
          title: Text('${t.offsetDays} dní předem (Vlastní)', style: const TextStyle(fontSize: 14)),
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
          onChanged: (_) {
            final updated = List<NotificationTrigger>.from(selected);
            updated.removeWhere((tr) => tr.offsetDays == t.offsetDays);
            onChanged(updated);
          },
        )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showCustomTriggerDialog(context, l),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(l.reminderCustomLabel),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(120, 36),
          ),
        ),
      ],
    );
  }

  void _showCustomTriggerDialog(BuildContext context, AppLocalizations l) {
    int days = 1;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.reminderCustomNotification),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.reminderCustomDays),
          autofocus: true,
          onChanged: (v) => days = int.tryParse(v) ?? 1,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.buttonCancel)),
          FilledButton(
            onPressed: () {
              final trigger = NotificationTrigger(offsetDays: days, label: '$days dní předem');
              final updated = List<NotificationTrigger>.from(selected);
              if (!updated.any((t) => t.offsetDays == days)) {
                updated.add(trigger);
                updated.sort((a, b) => b.offsetDays.compareTo(a.offsetDays));
                onChanged(updated);
              }
              Navigator.pop(ctx);
            },
            child: Text(l.buttonAdd),
          ),
        ],
      ),
    );
  }
}

class _TemplatePicker extends ConsumerWidget {
  const _TemplatePicker({required this.selectedTemplate, required this.onPick});

  final ReminderTemplate? selectedTemplate;
  final void Function(ReminderTemplate?) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final templates = ref.watch(templateDatasourceProvider).getAll();
    final popular = templates.where((t) => t.isPopular).take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedTemplate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: selectedTemplate!.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selectedTemplate!.category.color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(selectedTemplate!.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(selectedTemplate!.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                GestureDetector(
                  onTap: () => onPick(null),
                  child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...popular.map((tpl) => ActionChip(
              avatar: Text(tpl.icon, style: const TextStyle(fontSize: 14)),
              label: Text(tpl.title, style: const TextStyle(fontSize: 12)),
              onPressed: () => onPick(tpl),
              backgroundColor: tpl.category.color.withOpacity(0.08),
            )),
            ActionChip(
              avatar: const Icon(Icons.grid_view_rounded, size: 16),
              label: Text(l.reminderFormAllTemplates, style: const TextStyle(fontSize: 12)),
              onPressed: () => _showAllTemplates(context, templates),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAllTemplates(
    BuildContext context,
    List<ReminderTemplate> templates,
  ) async {
    final l = AppLocalizations.of(context)!;
    final grouped = <ReminderCategory, List<ReminderTemplate>>{};
    for (final t in templates) {
      (grouped[t.category] ??= []).add(t);
    }

    final result = await showModalBottomSheet<ReminderTemplate>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.reminderFormPickTemplate,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: grouped.length,
                  itemBuilder: (context, i) {
                    final cat = grouped.keys.elementAt(i);
                    final catTemplates = grouped[cat]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            '${cat.emoji} ${cat.label}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ...catTemplates.map((tpl) => ListTile(
                          leading: Text(tpl.icon, style: const TextStyle(fontSize: 22)),
                          title: Text(tpl.title),
                          subtitle: Text(tpl.defaultRecurrence.humanLabel,
                              style: const TextStyle(fontSize: 12)),
                          onTap: () => Navigator.pop(context, tpl),
                        )),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) onPick(result);
  }
}

class _PriorityPicker extends StatelessWidget {
  const _PriorityPicker({required this.selected, required this.onSelect});

  final ReminderPriority selected;
  final void Function(ReminderPriority) onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SegmentedButton<ReminderPriority>(
      segments: [
        ButtonSegment(
          value: ReminderPriority.normal,
          label: Text(l.reminderPriorityNormal),
          icon: const Icon(Icons.notifications_outlined),
        ),
        ButtonSegment(
          value: ReminderPriority.high,
          label: Text(l.reminderPriorityHigh),
          icon: const Icon(Icons.warning_amber_rounded),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onSelect(set.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: selected == ReminderPriority.high 
            ? AppColors.accentRed.withOpacity(0.2) 
            : null,
        selectedForegroundColor: selected == ReminderPriority.high 
            ? AppColors.accentRed 
            : null,
      ),
    );
  }
}
