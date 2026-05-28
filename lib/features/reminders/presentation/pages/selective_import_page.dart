import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:fit_vis_reminder/shared/widgets/reminder_card.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';

class SelectiveImportPage extends StatefulWidget {
  const SelectiveImportPage({super.key, required this.reminders});

  final List<Reminder> reminders;

  @override
  State<SelectiveImportPage> createState() => _SelectiveImportPageState();
}

class _SelectiveImportPageState extends State<SelectiveImportPage> {
  late Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices = Set.from(Iterable.generate(widget.reminders.length));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.importSelectTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l.importSelectRemindersHint,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.reminders.length,
              itemBuilder: (context, index) {
                final reminder = widget.reminders[index];
                final isSelected = _selectedIndices.contains(index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedIndices.add(index);
                            } else {
                              _selectedIndices.remove(index);
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: AbsorbPointer(
                          child: ReminderCard(reminder: reminder),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: Text(l.buttonCancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _selectedIndices.isEmpty ? null : () => _onImport(context),
                    child: Text(l.importAction(_selectedIndices.length)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onImport(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    final notifier = container.read(reminderNotifierProvider.notifier);
    final l = AppLocalizations.of(context)!;

    int imported = 0;
    for (final index in _selectedIndices) {
      await notifier.saveReminder(widget.reminders[index], l);
      imported++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.importSuccess(imported))),
      );
      context.go('/');
    }
  }
}
