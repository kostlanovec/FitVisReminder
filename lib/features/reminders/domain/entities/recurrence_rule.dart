import 'package:equatable/equatable.dart';

enum RecurrenceType {
  once,
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  String get label => switch (this) {
    RecurrenceType.once => 'Jednorázově',
    RecurrenceType.daily => 'Každý den',
    RecurrenceType.weekly => 'Každý týden',
    RecurrenceType.monthly => 'Každý měsíc',
    RecurrenceType.yearly => 'Každý rok',
    RecurrenceType.custom => 'Vlastní interval',
  };
}

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

  factory RecurrenceRule.custom({required int days}) {
    return RecurrenceRule(type: RecurrenceType.custom, intervalDays: days);
  }

  factory RecurrenceRule.customMonths({required int months}) {
    return RecurrenceRule(type: RecurrenceType.custom, intervalMonths: months);
  }

  final RecurrenceType type;
  final int? intervalDays;
  final int? intervalMonths;
  final int? intervalYears;

  bool get isRecurring => type != RecurrenceType.once;

  DateTime nextOccurrence(DateTime from) {
    return switch (type) {
      RecurrenceType.once => from,
      RecurrenceType.daily => from.add(Duration(days: intervalDays ?? 1)),
      RecurrenceType.weekly => from.add(Duration(days: intervalDays ?? 7)),
      RecurrenceType.monthly => DateTime(
          from.year, from.month + (intervalMonths ?? 1), from.day,
          from.hour, from.minute),
      RecurrenceType.yearly => DateTime(
          from.year + (intervalYears ?? 1), from.month, from.day,
          from.hour, from.minute),
      RecurrenceType.custom => intervalDays != null
          ? from.add(Duration(days: intervalDays!))
          : DateTime(from.year, from.month + (intervalMonths ?? 1), from.day,
              from.hour, from.minute),
    };
  }

  String get humanLabel {
    return switch (type) {
      RecurrenceType.once => 'Jednorázově',
      RecurrenceType.daily => 'Každý den',
      RecurrenceType.weekly => 'Každý týden',
      RecurrenceType.monthly => 'Každý měsíc',
      RecurrenceType.yearly => 'Každý rok',
      RecurrenceType.custom => intervalDays != null
          ? 'Každých ${intervalDays} dní'
          : 'Každých ${intervalMonths} měsíců',
    };
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
