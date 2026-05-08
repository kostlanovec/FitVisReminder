import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/templates/domain/entities/reminder_template.dart';

final allTemplatesProvider = Provider<List<ReminderTemplate>>((ref) {
  return ref.watch(templateDatasourceProvider).getAll();
});

final templatesByCategoryProvider =
    Provider.family<List<ReminderTemplate>, ReminderCategory>((ref, category) {
  return ref.watch(templateDatasourceProvider).getByCategory(category);
});

final popularTemplatesProvider = Provider<List<ReminderTemplate>>((ref) {
  return ref.watch(allTemplatesProvider).where((t) => t.isPopular).toList();
});

final templateByIdProvider = Provider.family<ReminderTemplate?, String>((ref, id) {
  return ref.watch(templateDatasourceProvider).findById(id);
});

// ── Onboarding template selection ──────────────────────────────────────────

class OnboardingSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String templateId) {
    if (state.contains(templateId)) {
      state = {...state}..remove(templateId);
    } else {
      state = {...state, templateId};
    }
  }

  void selectAll(List<ReminderTemplate> templates) {
    state = templates.map((t) => t.id).toSet();
  }

  void clear() => state = {};

  bool isSelected(String templateId) => state.contains(templateId);
}

final onboardingSelectionProvider =
    NotifierProvider<OnboardingSelectionNotifier, Set<String>>(
  OnboardingSelectionNotifier.new,
);
