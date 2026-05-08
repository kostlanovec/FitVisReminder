extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    return difference(now).inDays <= 7 && isAfter(now);
  }

  bool get isOverdue => isBefore(DateTime.now());

  int get daysUntil => difference(DateTime.now()).inDays;

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  String get relativeLabel {
    final days = daysUntil;
    if (days < 0) return '${days.abs()} dní po termínu';
    if (days == 0) return 'Dnes';
    if (days == 1) return 'Zítra';
    if (days < 7) return 'Za $days dní';
    if (days < 30) return 'Za ${(days / 7).floor()} týdnů';
    if (days < 365) return 'Za ${(days / 30).floor()} měsíců';
    return 'Za ${(days / 365).floor()} let';
  }
}
