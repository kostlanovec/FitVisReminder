// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIndexMeta =
      const VerificationMeta('categoryIndex');
  @override
  late final GeneratedColumn<int> categoryIndex = GeneratedColumn<int>(
      'category_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _recurrenceRuleJsonMeta =
      const VerificationMeta('recurrenceRuleJson');
  @override
  late final GeneratedColumn<String> recurrenceRuleJson =
      GeneratedColumn<String>('recurrence_rule_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggersJsonMeta =
      const VerificationMeta('triggersJson');
  @override
  late final GeneratedColumn<String> triggersJson = GeneratedColumn<String>(
      'triggers_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastCompletedAtMeta =
      const VerificationMeta('lastCompletedAt');
  @override
  late final GeneratedColumn<DateTime> lastCompletedAt =
      GeneratedColumn<DateTime>('last_completed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _customIconCodeMeta =
      const VerificationMeta('customIconCode');
  @override
  late final GeneratedColumn<int> customIconCode = GeneratedColumn<int>(
      'custom_icon_code', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _calendarEventIdMeta =
      const VerificationMeta('calendarEventId');
  @override
  late final GeneratedColumn<String> calendarEventId = GeneratedColumn<String>(
      'calendar_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        categoryIndex,
        dueDate,
        recurrenceRuleJson,
        triggersJson,
        description,
        templateId,
        isActive,
        lastCompletedAt,
        createdAt,
        updatedAt,
        customIconCode,
        calendarEventId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<ReminderRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category_index')) {
      context.handle(
          _categoryIndexMeta,
          categoryIndex.isAcceptableOrUnknown(
              data['category_index']!, _categoryIndexMeta));
    } else if (isInserting) {
      context.missing(_categoryIndexMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('recurrence_rule_json')) {
      context.handle(
          _recurrenceRuleJsonMeta,
          recurrenceRuleJson.isAcceptableOrUnknown(
              data['recurrence_rule_json']!, _recurrenceRuleJsonMeta));
    } else if (isInserting) {
      context.missing(_recurrenceRuleJsonMeta);
    }
    if (data.containsKey('triggers_json')) {
      context.handle(
          _triggersJsonMeta,
          triggersJson.isAcceptableOrUnknown(
              data['triggers_json']!, _triggersJsonMeta));
    } else if (isInserting) {
      context.missing(_triggersJsonMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_completed_at')) {
      context.handle(
          _lastCompletedAtMeta,
          lastCompletedAt.isAcceptableOrUnknown(
              data['last_completed_at']!, _lastCompletedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('custom_icon_code')) {
      context.handle(
          _customIconCodeMeta,
          customIconCode.isAcceptableOrUnknown(
              data['custom_icon_code']!, _customIconCodeMeta));
    }
    if (data.containsKey('calendar_event_id')) {
      context.handle(
          _calendarEventIdMeta,
          calendarEventId.isAcceptableOrUnknown(
              data['calendar_event_id']!, _calendarEventIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      categoryIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_index'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      recurrenceRuleJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurrence_rule_json'])!,
      triggersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}triggers_json'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastCompletedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      customIconCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}custom_icon_code']),
      calendarEventId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}calendar_event_id']),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final int id;
  final String title;
  final int categoryIndex;
  final DateTime dueDate;
  final String recurrenceRuleJson;
  final String triggersJson;
  final String? description;
  final String? templateId;
  final bool isActive;
  final DateTime? lastCompletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? customIconCode;
  final String? calendarEventId;
  const ReminderRow(
      {required this.id,
      required this.title,
      required this.categoryIndex,
      required this.dueDate,
      required this.recurrenceRuleJson,
      required this.triggersJson,
      this.description,
      this.templateId,
      required this.isActive,
      this.lastCompletedAt,
      this.createdAt,
      this.updatedAt,
      this.customIconCode,
      this.calendarEventId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['category_index'] = Variable<int>(categoryIndex);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['recurrence_rule_json'] = Variable<String>(recurrenceRuleJson);
    map['triggers_json'] = Variable<String>(triggersJson);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastCompletedAt != null) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || customIconCode != null) {
      map['custom_icon_code'] = Variable<int>(customIconCode);
    }
    if (!nullToAbsent || calendarEventId != null) {
      map['calendar_event_id'] = Variable<String>(calendarEventId);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      categoryIndex: Value(categoryIndex),
      dueDate: Value(dueDate),
      recurrenceRuleJson: Value(recurrenceRuleJson),
      triggersJson: Value(triggersJson),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      isActive: Value(isActive),
      lastCompletedAt: lastCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      customIconCode: customIconCode == null && nullToAbsent
          ? const Value.absent()
          : Value(customIconCode),
      calendarEventId: calendarEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarEventId),
    );
  }

  factory ReminderRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      categoryIndex: serializer.fromJson<int>(json['categoryIndex']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      recurrenceRuleJson:
          serializer.fromJson<String>(json['recurrenceRuleJson']),
      triggersJson: serializer.fromJson<String>(json['triggersJson']),
      description: serializer.fromJson<String?>(json['description']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastCompletedAt: serializer.fromJson<DateTime?>(json['lastCompletedAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      customIconCode: serializer.fromJson<int?>(json['customIconCode']),
      calendarEventId: serializer.fromJson<String?>(json['calendarEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'categoryIndex': serializer.toJson<int>(categoryIndex),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'recurrenceRuleJson': serializer.toJson<String>(recurrenceRuleJson),
      'triggersJson': serializer.toJson<String>(triggersJson),
      'description': serializer.toJson<String?>(description),
      'templateId': serializer.toJson<String?>(templateId),
      'isActive': serializer.toJson<bool>(isActive),
      'lastCompletedAt': serializer.toJson<DateTime?>(lastCompletedAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'customIconCode': serializer.toJson<int?>(customIconCode),
      'calendarEventId': serializer.toJson<String?>(calendarEventId),
    };
  }

  ReminderRow copyWith(
          {int? id,
          String? title,
          int? categoryIndex,
          DateTime? dueDate,
          String? recurrenceRuleJson,
          String? triggersJson,
          Value<String?> description = const Value.absent(),
          Value<String?> templateId = const Value.absent(),
          bool? isActive,
          Value<DateTime?> lastCompletedAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<int?> customIconCode = const Value.absent(),
          Value<String?> calendarEventId = const Value.absent()}) =>
      ReminderRow(
        id: id ?? this.id,
        title: title ?? this.title,
        categoryIndex: categoryIndex ?? this.categoryIndex,
        dueDate: dueDate ?? this.dueDate,
        recurrenceRuleJson: recurrenceRuleJson ?? this.recurrenceRuleJson,
        triggersJson: triggersJson ?? this.triggersJson,
        description: description.present ? description.value : this.description,
        templateId: templateId.present ? templateId.value : this.templateId,
        isActive: isActive ?? this.isActive,
        lastCompletedAt: lastCompletedAt.present
            ? lastCompletedAt.value
            : this.lastCompletedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        customIconCode:
            customIconCode.present ? customIconCode.value : this.customIconCode,
        calendarEventId: calendarEventId.present
            ? calendarEventId.value
            : this.calendarEventId,
      );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      categoryIndex: data.categoryIndex.present
          ? data.categoryIndex.value
          : this.categoryIndex,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      recurrenceRuleJson: data.recurrenceRuleJson.present
          ? data.recurrenceRuleJson.value
          : this.recurrenceRuleJson,
      triggersJson: data.triggersJson.present
          ? data.triggersJson.value
          : this.triggersJson,
      description:
          data.description.present ? data.description.value : this.description,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastCompletedAt: data.lastCompletedAt.present
          ? data.lastCompletedAt.value
          : this.lastCompletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      customIconCode: data.customIconCode.present
          ? data.customIconCode.value
          : this.customIconCode,
      calendarEventId: data.calendarEventId.present
          ? data.calendarEventId.value
          : this.calendarEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('categoryIndex: $categoryIndex, ')
          ..write('dueDate: $dueDate, ')
          ..write('recurrenceRuleJson: $recurrenceRuleJson, ')
          ..write('triggersJson: $triggersJson, ')
          ..write('description: $description, ')
          ..write('templateId: $templateId, ')
          ..write('isActive: $isActive, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('customIconCode: $customIconCode, ')
          ..write('calendarEventId: $calendarEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      categoryIndex,
      dueDate,
      recurrenceRuleJson,
      triggersJson,
      description,
      templateId,
      isActive,
      lastCompletedAt,
      createdAt,
      updatedAt,
      customIconCode,
      calendarEventId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.categoryIndex == this.categoryIndex &&
          other.dueDate == this.dueDate &&
          other.recurrenceRuleJson == this.recurrenceRuleJson &&
          other.triggersJson == this.triggersJson &&
          other.description == this.description &&
          other.templateId == this.templateId &&
          other.isActive == this.isActive &&
          other.lastCompletedAt == this.lastCompletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.customIconCode == this.customIconCode &&
          other.calendarEventId == this.calendarEventId);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> categoryIndex;
  final Value<DateTime> dueDate;
  final Value<String> recurrenceRuleJson;
  final Value<String> triggersJson;
  final Value<String?> description;
  final Value<String?> templateId;
  final Value<bool> isActive;
  final Value<DateTime?> lastCompletedAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int?> customIconCode;
  final Value<String?> calendarEventId;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.categoryIndex = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.recurrenceRuleJson = const Value.absent(),
    this.triggersJson = const Value.absent(),
    this.description = const Value.absent(),
    this.templateId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.customIconCode = const Value.absent(),
    this.calendarEventId = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int categoryIndex,
    required DateTime dueDate,
    required String recurrenceRuleJson,
    required String triggersJson,
    this.description = const Value.absent(),
    this.templateId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.customIconCode = const Value.absent(),
    this.calendarEventId = const Value.absent(),
  })  : title = Value(title),
        categoryIndex = Value(categoryIndex),
        dueDate = Value(dueDate),
        recurrenceRuleJson = Value(recurrenceRuleJson),
        triggersJson = Value(triggersJson);
  static Insertable<ReminderRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? categoryIndex,
    Expression<DateTime>? dueDate,
    Expression<String>? recurrenceRuleJson,
    Expression<String>? triggersJson,
    Expression<String>? description,
    Expression<String>? templateId,
    Expression<bool>? isActive,
    Expression<DateTime>? lastCompletedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? customIconCode,
    Expression<String>? calendarEventId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (categoryIndex != null) 'category_index': categoryIndex,
      if (dueDate != null) 'due_date': dueDate,
      if (recurrenceRuleJson != null)
        'recurrence_rule_json': recurrenceRuleJson,
      if (triggersJson != null) 'triggers_json': triggersJson,
      if (description != null) 'description': description,
      if (templateId != null) 'template_id': templateId,
      if (isActive != null) 'is_active': isActive,
      if (lastCompletedAt != null) 'last_completed_at': lastCompletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (customIconCode != null) 'custom_icon_code': customIconCode,
      if (calendarEventId != null) 'calendar_event_id': calendarEventId,
    });
  }

  RemindersCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<int>? categoryIndex,
      Value<DateTime>? dueDate,
      Value<String>? recurrenceRuleJson,
      Value<String>? triggersJson,
      Value<String?>? description,
      Value<String?>? templateId,
      Value<bool>? isActive,
      Value<DateTime?>? lastCompletedAt,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int?>? customIconCode,
      Value<String?>? calendarEventId}) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      dueDate: dueDate ?? this.dueDate,
      recurrenceRuleJson: recurrenceRuleJson ?? this.recurrenceRuleJson,
      triggersJson: triggersJson ?? this.triggersJson,
      description: description ?? this.description,
      templateId: templateId ?? this.templateId,
      isActive: isActive ?? this.isActive,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customIconCode: customIconCode ?? this.customIconCode,
      calendarEventId: calendarEventId ?? this.calendarEventId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (categoryIndex.present) {
      map['category_index'] = Variable<int>(categoryIndex.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (recurrenceRuleJson.present) {
      map['recurrence_rule_json'] = Variable<String>(recurrenceRuleJson.value);
    }
    if (triggersJson.present) {
      map['triggers_json'] = Variable<String>(triggersJson.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastCompletedAt.present) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (customIconCode.present) {
      map['custom_icon_code'] = Variable<int>(customIconCode.value);
    }
    if (calendarEventId.present) {
      map['calendar_event_id'] = Variable<String>(calendarEventId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('categoryIndex: $categoryIndex, ')
          ..write('dueDate: $dueDate, ')
          ..write('recurrenceRuleJson: $recurrenceRuleJson, ')
          ..write('triggersJson: $triggersJson, ')
          ..write('description: $description, ')
          ..write('templateId: $templateId, ')
          ..write('isActive: $isActive, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('customIconCode: $customIconCode, ')
          ..write('calendarEventId: $calendarEventId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [reminders];
}

typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required String title,
  required int categoryIndex,
  required DateTime dueDate,
  required String recurrenceRuleJson,
  required String triggersJson,
  Value<String?> description,
  Value<String?> templateId,
  Value<bool> isActive,
  Value<DateTime?> lastCompletedAt,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int?> customIconCode,
  Value<String?> calendarEventId,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<int> categoryIndex,
  Value<DateTime> dueDate,
  Value<String> recurrenceRuleJson,
  Value<String> triggersJson,
  Value<String?> description,
  Value<String?> templateId,
  Value<bool> isActive,
  Value<DateTime?> lastCompletedAt,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int?> customIconCode,
  Value<String?> calendarEventId,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get categoryIndex => $composableBuilder(
      column: $table.categoryIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceRuleJson => $composableBuilder(
      column: $table.recurrenceRuleJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggersJson => $composableBuilder(
      column: $table.triggersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastCompletedAt => $composableBuilder(
      column: $table.lastCompletedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get customIconCode => $composableBuilder(
      column: $table.customIconCode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get calendarEventId => $composableBuilder(
      column: $table.calendarEventId,
      builder: (column) => ColumnFilters(column));
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get categoryIndex => $composableBuilder(
      column: $table.categoryIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceRuleJson => $composableBuilder(
      column: $table.recurrenceRuleJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggersJson => $composableBuilder(
      column: $table.triggersJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastCompletedAt => $composableBuilder(
      column: $table.lastCompletedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get customIconCode => $composableBuilder(
      column: $table.customIconCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get calendarEventId => $composableBuilder(
      column: $table.calendarEventId,
      builder: (column) => ColumnOrderings(column));
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get categoryIndex => $composableBuilder(
      column: $table.categoryIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRuleJson => $composableBuilder(
      column: $table.recurrenceRuleJson, builder: (column) => column);

  GeneratedColumn<String> get triggersJson => $composableBuilder(
      column: $table.triggersJson, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCompletedAt => $composableBuilder(
      column: $table.lastCompletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get customIconCode => $composableBuilder(
      column: $table.customIconCode, builder: (column) => column);

  GeneratedColumn<String> get calendarEventId => $composableBuilder(
      column: $table.calendarEventId, builder: (column) => column);
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    ReminderRow,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (ReminderRow, BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>),
    ReminderRow,
    PrefetchHooks Function()> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> categoryIndex = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<String> recurrenceRuleJson = const Value.absent(),
            Value<String> triggersJson = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> templateId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastCompletedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int?> customIconCode = const Value.absent(),
            Value<String?> calendarEventId = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            title: title,
            categoryIndex: categoryIndex,
            dueDate: dueDate,
            recurrenceRuleJson: recurrenceRuleJson,
            triggersJson: triggersJson,
            description: description,
            templateId: templateId,
            isActive: isActive,
            lastCompletedAt: lastCompletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            customIconCode: customIconCode,
            calendarEventId: calendarEventId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required int categoryIndex,
            required DateTime dueDate,
            required String recurrenceRuleJson,
            required String triggersJson,
            Value<String?> description = const Value.absent(),
            Value<String?> templateId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastCompletedAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int?> customIconCode = const Value.absent(),
            Value<String?> calendarEventId = const Value.absent(),
          }) =>
              RemindersCompanion.insert(
            id: id,
            title: title,
            categoryIndex: categoryIndex,
            dueDate: dueDate,
            recurrenceRuleJson: recurrenceRuleJson,
            triggersJson: triggersJson,
            description: description,
            templateId: templateId,
            isActive: isActive,
            lastCompletedAt: lastCompletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            customIconCode: customIconCode,
            calendarEventId: calendarEventId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    ReminderRow,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (ReminderRow, BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>),
    ReminderRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
