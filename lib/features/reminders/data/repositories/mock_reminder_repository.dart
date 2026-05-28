import 'dart:async';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';

class MockReminderRepository implements ReminderRepository {
  final List<Reminder> _reminders = [];
  final _controller = StreamController<List<Reminder>>.broadcast();

  void _notify() {
    _controller.add(List.unmodifiable(_reminders));
  }

  @override
  Stream<List<Reminder>> watchAll() {
    // Delay the first notification by one microtask so that
    // Riverpod's StreamProvider has time to subscribe before we emit.
    Future.microtask(_notify);
    return _controller.stream;
  }

  @override
  Stream<List<Reminder>> watchByCategory(ReminderCategory category) {
    Future.microtask(_notify);
    return _controller.stream.map(
      (list) => list.where((r) => r.category == category).toList(),
    );
  }

  @override
  Stream<List<Reminder>> watchDueSoon({int withinDays = 30}) {
    Future.microtask(_notify);
    final limit = DateTime.now().add(Duration(days: withinDays));
    return _controller.stream.map(
      (list) => list.where((r) => r.dueDate.isBefore(limit)).toList(),
    );
  }

  @override
  Stream<List<Reminder>> watchOverdue() {
    Future.microtask(_notify);
    final now = DateTime.now();
    return _controller.stream.map(
      (list) => list.where((r) => r.dueDate.isBefore(now)).toList(),
    );
  }

  @override
  Future<Reminder?> findById(int id) async {
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Reminder>> getAll() async => List.unmodifiable(_reminders);

  @override
  Future<List<Reminder>> getActive() async => _reminders.where((r) => r.isActive).toList();

  @override
  Future<int> save(Reminder reminder) async {
    if (reminder.id == 0) {
      final newId = _reminders.isEmpty ? 1 : _reminders.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
      final newReminder = reminder.copyWith(id: newId);
      _reminders.add(newReminder);
      _notify();
      return newId;
    } else {
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder;
      } else {
        _reminders.add(reminder);
      }
      _notify();
      return reminder.id;
    }
  }

  @override
  Future<void> saveAll(List<Reminder> reminders) async {
    for (final r in reminders) {
      await save(r);
    }
  }

  @override
  Future<void> replaceAll(List<Reminder> reminders) async {
    _reminders.clear();
    await saveAll(reminders);
  }

  @override
  Future<void> delete(int id) async {
    _reminders.removeWhere((r) => r.id == id);
    _notify();
  }

  @override
  Future<void> markCompleted(int id, DateTime completedAt) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        lastCompletedAt: completedAt,
        updatedAt: DateTime.now(),
      );
      _notify();
    }
  }

  @override
  Future<void> updateDueDate(int id, DateTime newDueDate) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        dueDate: newDueDate,
        updatedAt: DateTime.now(),
      );
      _notify();
    }
  }
}
