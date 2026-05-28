import 'package:equatable/equatable.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

enum RecurrenceUnit { days, weeks, months, years }

enum RecurrenceType { once, daily, weekly, monthly, yearly, custom }

class RecurrenceRule extends Equatable {
  const RecurrenceRule({
    required this.type,
    this.intervalDays,
    this.intervalMonths,
    this.intervalYears,
  });

  const RecurrenceRule.once() : this(type: RecurrenceType.once);
  const RecurrenceRule.daily() : this(type: RecurrenceType.daily, intervalDays: 1);
  const RecurrenceRule.weekly() : this(type: RecurrenceType.weekly, intervalDays: 7);
  const RecurrenceRule.monthly() : this(type: RecurrenceType.monthly, intervalMonths: 1);
  const RecurrenceRule.yearly() : this(type: RecurrenceType.yearly, intervalYears: 1);
  const RecurrenceRule.every2years() : this(type: RecurrenceType.custom, intervalYears: 2);
  const RecurrenceRule.every4years() : this(type: RecurrenceType.custom, intervalYears: 4);
  const RecurrenceRule.every3years() : this(type: RecurrenceType.custom, intervalYears: 3);
  const RecurrenceRule.every5years() : this(type: RecurrenceType.custom, intervalYears: 5);
  const RecurrenceRule.every10years() : this(type: RecurrenceType.custom, intervalYears: 10);

  factory RecurrenceRule.custom({int days = 0, int? frequency, RecurrenceUnit? unit}) {
    final u = unit ?? RecurrenceUnit.days;
    final f = frequency ?? days;
    return switch (u) {
      RecurrenceUnit.days => RecurrenceRule(type: RecurrenceType.custom, intervalDays: f),
      RecurrenceUnit.weeks => RecurrenceRule(type: RecurrenceType.custom, intervalDays: f * 7),
      RecurrenceUnit.months => RecurrenceRule(type: RecurrenceType.custom, intervalMonths: f),
      RecurrenceUnit.years => RecurrenceRule(type: RecurrenceType.custom, intervalYears: f),
    };
  }

  factory RecurrenceRule.customMonths({required int months}) {
    return RecurrenceRule(type: RecurrenceType.custom, intervalMonths: months);
  }

  final RecurrenceType type;
  final int? intervalDays;
  final int? intervalMonths;
  final int? intervalYears;

  bool get isRecurring => type != RecurrenceType.once;

  bool get _isWholeWeeks =>
      intervalDays != null && intervalDays! >= 7 && intervalDays! % 7 == 0;

  /// Returns the numeric value shown to the user (weeks = days÷7, others as-is).
  int get frequency {
    if (_isWholeWeeks) return intervalDays! ~/ 7;
    return intervalDays ?? intervalMonths ?? intervalYears ?? 1;
  }

  RecurrenceUnit get unit {
    if (intervalMonths != null) return RecurrenceUnit.months;
    if (intervalYears != null) return RecurrenceUnit.years;
    if (_isWholeWeeks) return RecurrenceUnit.weeks;
    return RecurrenceUnit.days;
  }

  DateTime nextOccurrence(DateTime from) {
    return switch (type) {
      RecurrenceType.once => from,
      RecurrenceType.daily => from.add(Duration(days: intervalDays ?? 1)),
      RecurrenceType.weekly => from.add(Duration(days: intervalDays ?? 7)),
      RecurrenceType.monthly => DateTime(
          from.year, from.month + (intervalMonths ?? 1), from.day, from.hour, from.minute),
      RecurrenceType.yearly => DateTime(
          from.year + (intervalYears ?? 1), from.month, from.day, from.hour, from.minute),
      RecurrenceType.custom => intervalDays != null
          ? from.add(Duration(days: intervalDays!))
          : intervalMonths != null
              ? DateTime(from.year, from.month + intervalMonths!, from.day, from.hour, from.minute)
              : DateTime(from.year + (intervalYears ?? 1), from.month, from.day, from.hour, from.minute),
    };
  }

  String get humanLabel {
    return switch (type) {
      RecurrenceType.once => 'Jednorázově',
      RecurrenceType.daily => 'Každý den',
      RecurrenceType.weekly => 'Každý týden',
      RecurrenceType.monthly => 'Každý měsíc',
      RecurrenceType.yearly => 'Každý rok',
      RecurrenceType.custom => _customLabel(),
    };
  }

  String humanLabelLocalized(AppLocalizations l) {
    return switch (type) {
      RecurrenceType.once    => l.recurrenceOnce,
      RecurrenceType.daily   => l.recurrenceDaily,
      RecurrenceType.weekly  => l.recurrenceWeekly,
      RecurrenceType.monthly => l.recurrenceMonthly,
      RecurrenceType.yearly  => l.recurrenceYearly,
      RecurrenceType.custom  => _customLabelLocalized(l),
    };
  }

  String _customLabelLocalized(AppLocalizations l) {
    if (intervalYears != null) return l.recurrenceCustomYears(intervalYears!);
    if (_isWholeWeeks) return l.recurrenceCustomWeeks(intervalDays! ~/ 7);
    if (intervalDays != null) return l.recurrenceCustomDays(intervalDays!);
    return l.recurrenceCustomMonths(intervalMonths ?? 1);
  }

  String _customLabel() {
    if (intervalYears != null) {
      final y = intervalYears!;
      if (y == 1) return 'Každý rok';
      if (y < 5) return 'Každé $y roky';
      return 'Každých $y let';
    }
    if (_isWholeWeeks) {
      final w = intervalDays! ~/ 7;
      if (w == 1) return 'Každý týden';
      if (w < 5) return 'Každé $w týdny';
      return 'Každých $w týdnů';
    }
    if (intervalDays != null) {
      final d = intervalDays!;
      if (d == 1) return 'Každý den';
      if (d < 5) return 'Každé $d dny';
      return 'Každých $d dní';
    }
    final m = intervalMonths ?? 1;
    if (m == 1) return 'Každý měsíc';
    if (m < 5) return 'Každé $m měsíce';
    return 'Každých $m měsíců';
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'intervalDays': intervalDays,
    'intervalMonths': intervalMonths,
    'intervalYears': intervalYears,
  };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      type: RecurrenceType.values.byName(json['type'] as String),
      intervalDays: json['intervalDays'] as int?,
      intervalMonths: json['intervalMonths'] as int?,
      intervalYears: json['intervalYears'] as int?,
    );
  }

  @override
  List<Object?> get props => [type, intervalDays, intervalMonths, intervalYears];
}
