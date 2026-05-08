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
import 'package:intl/intl.dart';

class ReminderFormPage extends ConsumerStatefulWidget {
  const ReminderFormPage({super.key, this.reminderId});

  final int? reminderId;

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
    _load();
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
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      templateId: _selectedTemplate?.id ?? _original?.templateId,
      isActive: true,
      createdAt: _original?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(reminderNotifierProvider.notifier).saveReminder(reminder);

    setState(() => _isLoading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Upravit připomínku' : 'Nová připomínka'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Zavřít',
          onPressed: () => context.pop(),
        ),
        actions: [
          FilledButton(
            onPressed: _isLoading ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Uložit', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Template picker (only for new reminders)
            if (!_isEditing) ...[
              _SectionLabel(label: 'Šablona (volitelné)'),
              _TemplatePicker(
                selectedTemplate: _selectedTemplate,
                onPick: (tpl) => setState(() {
                  _selectedTemplate = tpl;
                  if (tpl != null) {
                    _titleController.text = tpl.title;
                    _descController.text = tpl.description;
                    _category = tpl.category;
                    _recurrence = tpl.defaultRecurrence;
                    _triggers = tpl.defaultTriggers;
                  }
                }),
              ),
              const SizedBox(height: 20),
            ],

            _SectionLabel(label: 'Název *'),
            TextFormField(
              controller: _titleController,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Název je povinný' : null,
              decoration: const InputDecoration(hintText: 'např. STK, Zubař, Pas...'),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),
            _SectionLabel(label: 'Popis'),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(hintText: 'Volitelný popis...'),
              maxLines: 2,
            ),

            const SizedBox(height: 20),
            _SectionLabel(label: 'Kategorie'),
            _CategoryPicker(
              selected: _category,
              onSelect: (cat) => setState(() => _category = cat),
            ),

            const SizedBox(height: 20),
            _SectionLabel(label: 'Termín'),
            _DateField(
              date: _dueDate,
              onPick: (d) => setState(() => _dueDate = d),
            ),

            const SizedBox(height: 20),
            _SectionLabel(label: 'Opakování'),
            _RecurrencePicker(
              selected: _recurrence,
              onSelect: (r) => setState(() => _recurrence = r),
            ),

            const SizedBox(height: 20),
            _SectionLabel(label: 'Upozornění'),
            _TriggersPicker(
              selected: _triggers,
              onChanged: (triggers) => setState(() => _triggers = triggers),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
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
        return FilterChip(
          label: Text('${cat.emoji} ${cat.label}'),
          selected: isSelected,
          onSelected: (_) => onSelect(cat),
          selectedColor: cat.color.withOpacity(0.15),
          checkmarkColor: cat.color,
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

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onPick});

  final DateTime date;
  final void Function(DateTime) onPick;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (picked != null) onPick(picked);
      },
      icon: const Icon(Icons.calendar_today_rounded, size: 18),
      label: Text(DateFormat('d. MMMM yyyy', 'cs').format(date)),
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

  static const _presets = [
    (label: 'Jednorázově', rule: RecurrenceRule.once()),
    (label: 'Každý týden', rule: RecurrenceRule.weekly()),
    (label: 'Každý měsíc', rule: RecurrenceRule.monthly()),
    (label: 'Každý rok', rule: RecurrenceRule.yearly()),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presets.map((preset) {
        final isSelected = selected.type == preset.rule.type;
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
      }).toList(),
    );
  }
}

class _TriggersPicker extends StatelessWidget {
  const _TriggersPicker({required this.selected, required this.onChanged});

  final List<NotificationTrigger> selected;
  final void Function(List<NotificationTrigger>) onChanged;

  static const _options = [
    (trigger: NotificationTrigger.monthBefore(), label: 'Měsíc předem'),
    (trigger: NotificationTrigger.weekBefore(), label: 'Týden předem'),
    (trigger: NotificationTrigger.dayBefore(), label: 'Den předem'),
    (trigger: NotificationTrigger.sameDay(), label: 'V den termínu'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options.map((opt) {
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
      }).toList(),
    );
  }
}

class _TemplatePicker extends ConsumerWidget {
  const _TemplatePicker({required this.selectedTemplate, required this.onPick});

  final ReminderTemplate? selectedTemplate;
  final void Function(ReminderTemplate?) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              label: const Text('Všechny šablony', style: TextStyle(fontSize: 12)),
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
              const Text('Vyberte šablonu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
