enum ReminderPriority {
  /// Regular notification that doesn't repeat aggressively.
  normal,

  /// High importance notification that repeats frequently until acknowledged.
  high;

  bool get isHigh => this == ReminderPriority.high;
}
