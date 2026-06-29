// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LocalGroupsTable extends LocalGroups
    with TableInfo<$LocalGroupsTable, LocalGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupBalanceMeta =
      const VerificationMeta('groupBalance');
  @override
  late final GeneratedColumn<String> groupBalance = GeneratedColumn<String>(
      'group_balance', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedOnMeta =
      const VerificationMeta('updatedOn');
  @override
  late final GeneratedColumn<DateTime> updatedOn = GeneratedColumn<DateTime>(
      'updated_on', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        groupId,
        groupName,
        groupBalance,
        createdBy,
        createdAt,
        updatedOn,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_groups';
  @override
  VerificationContext validateIntegrity(Insertable<LocalGroup> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('group_balance')) {
      context.handle(
          _groupBalanceMeta,
          groupBalance.isAcceptableOrUnknown(
              data['group_balance']!, _groupBalanceMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_on')) {
      context.handle(_updatedOnMeta,
          updatedOn.isAcceptableOrUnknown(data['updated_on']!, _updatedOnMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  LocalGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGroup(
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      groupBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_balance'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_on']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $LocalGroupsTable createAlias(String alias) {
    return $LocalGroupsTable(attachedDatabase, alias);
  }
}

class LocalGroup extends DataClass implements Insertable<LocalGroup> {
  final String groupId;
  final String groupName;
  final String groupBalance;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedOn;
  final String syncStatus;
  const LocalGroup(
      {required this.groupId,
      required this.groupName,
      required this.groupBalance,
      this.createdBy,
      this.createdAt,
      this.updatedOn,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['group_name'] = Variable<String>(groupName);
    map['group_balance'] = Variable<String>(groupBalance);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedOn != null) {
      map['updated_on'] = Variable<DateTime>(updatedOn);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalGroupsCompanion toCompanion(bool nullToAbsent) {
    return LocalGroupsCompanion(
      groupId: Value(groupId),
      groupName: Value(groupName),
      groupBalance: Value(groupBalance),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedOn: updatedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedOn),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalGroup.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGroup(
      groupId: serializer.fromJson<String>(json['groupId']),
      groupName: serializer.fromJson<String>(json['groupName']),
      groupBalance: serializer.fromJson<String>(json['groupBalance']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedOn: serializer.fromJson<DateTime?>(json['updatedOn']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'groupName': serializer.toJson<String>(groupName),
      'groupBalance': serializer.toJson<String>(groupBalance),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedOn': serializer.toJson<DateTime?>(updatedOn),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LocalGroup copyWith(
          {String? groupId,
          String? groupName,
          String? groupBalance,
          Value<String?> createdBy = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedOn = const Value.absent(),
          String? syncStatus}) =>
      LocalGroup(
        groupId: groupId ?? this.groupId,
        groupName: groupName ?? this.groupName,
        groupBalance: groupBalance ?? this.groupBalance,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedOn: updatedOn.present ? updatedOn.value : this.updatedOn,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  LocalGroup copyWithCompanion(LocalGroupsCompanion data) {
    return LocalGroup(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      groupBalance: data.groupBalance.present
          ? data.groupBalance.value
          : this.groupBalance,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedOn: data.updatedOn.present ? data.updatedOn.value : this.updatedOn,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroup(')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('groupBalance: $groupBalance, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedOn: $updatedOn, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, groupName, groupBalance, createdBy,
      createdAt, updatedOn, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGroup &&
          other.groupId == this.groupId &&
          other.groupName == this.groupName &&
          other.groupBalance == this.groupBalance &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedOn == this.updatedOn &&
          other.syncStatus == this.syncStatus);
}

class LocalGroupsCompanion extends UpdateCompanion<LocalGroup> {
  final Value<String> groupId;
  final Value<String> groupName;
  final Value<String> groupBalance;
  final Value<String?> createdBy;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedOn;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalGroupsCompanion({
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.groupBalance = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedOn = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGroupsCompanion.insert({
    required String groupId,
    required String groupName,
    this.groupBalance = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedOn = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : groupId = Value(groupId),
        groupName = Value(groupName);
  static Insertable<LocalGroup> custom({
    Expression<String>? groupId,
    Expression<String>? groupName,
    Expression<String>? groupBalance,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedOn,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (groupName != null) 'group_name': groupName,
      if (groupBalance != null) 'group_balance': groupBalance,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedOn != null) 'updated_on': updatedOn,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGroupsCompanion copyWith(
      {Value<String>? groupId,
      Value<String>? groupName,
      Value<String>? groupBalance,
      Value<String?>? createdBy,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedOn,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return LocalGroupsCompanion(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupBalance: groupBalance ?? this.groupBalance,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedOn: updatedOn ?? this.updatedOn,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (groupBalance.present) {
      map['group_balance'] = Variable<String>(groupBalance.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedOn.present) {
      map['updated_on'] = Variable<DateTime>(updatedOn.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('groupBalance: $groupBalance, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedOn: $updatedOn, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGroupMembersTable extends LocalGroupMembers
    with TableInfo<$LocalGroupMembersTable, LocalGroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [groupId, userId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_group_members';
  @override
  VerificationContext validateIntegrity(Insertable<LocalGroupMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, userId};
  @override
  LocalGroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGroupMember(
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
    );
  }

  @override
  $LocalGroupMembersTable createAlias(String alias) {
    return $LocalGroupMembersTable(attachedDatabase, alias);
  }
}

class LocalGroupMember extends DataClass
    implements Insertable<LocalGroupMember> {
  final String groupId;
  final String userId;
  const LocalGroupMember({required this.groupId, required this.userId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['user_id'] = Variable<String>(userId);
    return map;
  }

  LocalGroupMembersCompanion toCompanion(bool nullToAbsent) {
    return LocalGroupMembersCompanion(
      groupId: Value(groupId),
      userId: Value(userId),
    );
  }

  factory LocalGroupMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGroupMember(
      groupId: serializer.fromJson<String>(json['groupId']),
      userId: serializer.fromJson<String>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'userId': serializer.toJson<String>(userId),
    };
  }

  LocalGroupMember copyWith({String? groupId, String? userId}) =>
      LocalGroupMember(
        groupId: groupId ?? this.groupId,
        userId: userId ?? this.userId,
      );
  LocalGroupMember copyWithCompanion(LocalGroupMembersCompanion data) {
    return LocalGroupMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupMember(')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGroupMember &&
          other.groupId == this.groupId &&
          other.userId == this.userId);
}

class LocalGroupMembersCompanion extends UpdateCompanion<LocalGroupMember> {
  final Value<String> groupId;
  final Value<String> userId;
  final Value<int> rowid;
  const LocalGroupMembersCompanion({
    this.groupId = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGroupMembersCompanion.insert({
    required String groupId,
    required String userId,
    this.rowid = const Value.absent(),
  })  : groupId = Value(groupId),
        userId = Value(userId);
  static Insertable<LocalGroupMember> custom({
    Expression<String>? groupId,
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGroupMembersCompanion copyWith(
      {Value<String>? groupId, Value<String>? userId, Value<int>? rowid}) {
    return LocalGroupMembersCompanion(
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGroupTransactionsTable extends LocalGroupTransactions
    with TableInfo<$LocalGroupTransactionsTable, LocalGroupTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGroupTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionGroupIdMeta =
      const VerificationMeta('transactionGroupId');
  @override
  late final GeneratedColumn<String> transactionGroupId =
      GeneratedColumn<String>('transaction_group_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paidByMeta = const VerificationMeta('paidBy');
  @override
  late final GeneratedColumn<String> paidBy = GeneratedColumn<String>(
      'paid_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sharedWithMeta =
      const VerificationMeta('sharedWith');
  @override
  late final GeneratedColumn<String> sharedWith = GeneratedColumn<String>(
      'shared_with', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalTransactionAmountMeta =
      const VerificationMeta('totalTransactionAmount');
  @override
  late final GeneratedColumn<double> totalTransactionAmount =
      GeneratedColumn<double>('total_transaction_amount', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sharedTransactionAmountMeta =
      const VerificationMeta('sharedTransactionAmount');
  @override
  late final GeneratedColumn<double> sharedTransactionAmount =
      GeneratedColumn<double>('shared_transaction_amount', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sharedPercentageMeta =
      const VerificationMeta('sharedPercentage');
  @override
  late final GeneratedColumn<double> sharedPercentage = GeneratedColumn<double>(
      'shared_percentage', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _selfShareAmountMeta =
      const VerificationMeta('selfShareAmount');
  @override
  late final GeneratedColumn<double> selfShareAmount = GeneratedColumn<double>(
      'self_share_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _selfSharePercentageMeta =
      const VerificationMeta('selfSharePercentage');
  @override
  late final GeneratedColumn<double> selfSharePercentage =
      GeneratedColumn<double>('self_share_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _sharingTypeMeta =
      const VerificationMeta('sharingType');
  @override
  late final GeneratedColumn<String> sharingType = GeneratedColumn<String>(
      'sharing_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('evenly'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionPhotoMeta =
      const VerificationMeta('transactionPhoto');
  @override
  late final GeneratedColumn<String> transactionPhoto = GeneratedColumn<String>(
      'transaction_photo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionNoteMeta =
      const VerificationMeta('transactionNote');
  @override
  late final GeneratedColumn<String> transactionNote = GeneratedColumn<String>(
      'transaction_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSettledUpMeta =
      const VerificationMeta('isSettledUp');
  @override
  late final GeneratedColumn<bool> isSettledUp = GeneratedColumn<bool>(
      'is_settled_up', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_settled_up" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        transactionId,
        transactionGroupId,
        groupId,
        paidBy,
        sharedWith,
        totalTransactionAmount,
        sharedTransactionAmount,
        sharedPercentage,
        selfShareAmount,
        selfSharePercentage,
        sharingType,
        category,
        description,
        transactionPhoto,
        transactionNote,
        isSettledUp,
        transactionDate,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_group_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalGroupTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('transaction_group_id')) {
      context.handle(
          _transactionGroupIdMeta,
          transactionGroupId.isAcceptableOrUnknown(
              data['transaction_group_id']!, _transactionGroupIdMeta));
    } else if (isInserting) {
      context.missing(_transactionGroupIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('paid_by')) {
      context.handle(_paidByMeta,
          paidBy.isAcceptableOrUnknown(data['paid_by']!, _paidByMeta));
    } else if (isInserting) {
      context.missing(_paidByMeta);
    }
    if (data.containsKey('shared_with')) {
      context.handle(
          _sharedWithMeta,
          sharedWith.isAcceptableOrUnknown(
              data['shared_with']!, _sharedWithMeta));
    } else if (isInserting) {
      context.missing(_sharedWithMeta);
    }
    if (data.containsKey('total_transaction_amount')) {
      context.handle(
          _totalTransactionAmountMeta,
          totalTransactionAmount.isAcceptableOrUnknown(
              data['total_transaction_amount']!, _totalTransactionAmountMeta));
    } else if (isInserting) {
      context.missing(_totalTransactionAmountMeta);
    }
    if (data.containsKey('shared_transaction_amount')) {
      context.handle(
          _sharedTransactionAmountMeta,
          sharedTransactionAmount.isAcceptableOrUnknown(
              data['shared_transaction_amount']!,
              _sharedTransactionAmountMeta));
    } else if (isInserting) {
      context.missing(_sharedTransactionAmountMeta);
    }
    if (data.containsKey('shared_percentage')) {
      context.handle(
          _sharedPercentageMeta,
          sharedPercentage.isAcceptableOrUnknown(
              data['shared_percentage']!, _sharedPercentageMeta));
    }
    if (data.containsKey('self_share_amount')) {
      context.handle(
          _selfShareAmountMeta,
          selfShareAmount.isAcceptableOrUnknown(
              data['self_share_amount']!, _selfShareAmountMeta));
    }
    if (data.containsKey('self_share_percentage')) {
      context.handle(
          _selfSharePercentageMeta,
          selfSharePercentage.isAcceptableOrUnknown(
              data['self_share_percentage']!, _selfSharePercentageMeta));
    }
    if (data.containsKey('sharing_type')) {
      context.handle(
          _sharingTypeMeta,
          sharingType.isAcceptableOrUnknown(
              data['sharing_type']!, _sharingTypeMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('transaction_photo')) {
      context.handle(
          _transactionPhotoMeta,
          transactionPhoto.isAcceptableOrUnknown(
              data['transaction_photo']!, _transactionPhotoMeta));
    }
    if (data.containsKey('transaction_note')) {
      context.handle(
          _transactionNoteMeta,
          transactionNote.isAcceptableOrUnknown(
              data['transaction_note']!, _transactionNoteMeta));
    }
    if (data.containsKey('is_settled_up')) {
      context.handle(
          _isSettledUpMeta,
          isSettledUp.isAcceptableOrUnknown(
              data['is_settled_up']!, _isSettledUpMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId};
  @override
  LocalGroupTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGroupTransaction(
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      transactionGroupId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_group_id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      paidBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}paid_by'])!,
      sharedWith: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shared_with'])!,
      totalTransactionAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}total_transaction_amount'])!,
      sharedTransactionAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}shared_transaction_amount'])!,
      sharedPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}shared_percentage'])!,
      selfShareAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}self_share_amount'])!,
      selfSharePercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}self_share_percentage'])!,
      sharingType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sharing_type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      transactionPhoto: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_photo']),
      transactionNote: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_note']),
      isSettledUp: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_settled_up'])!,
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $LocalGroupTransactionsTable createAlias(String alias) {
    return $LocalGroupTransactionsTable(attachedDatabase, alias);
  }
}

class LocalGroupTransaction extends DataClass
    implements Insertable<LocalGroupTransaction> {
  final String transactionId;
  final String transactionGroupId;
  final String groupId;
  final String paidBy;
  final String sharedWith;
  final double totalTransactionAmount;
  final double sharedTransactionAmount;
  final double sharedPercentage;
  final double selfShareAmount;
  final double selfSharePercentage;
  final String sharingType;
  final String? category;
  final String? description;
  final String? transactionPhoto;
  final String? transactionNote;
  final bool isSettledUp;
  final DateTime? transactionDate;
  final String syncStatus;
  const LocalGroupTransaction(
      {required this.transactionId,
      required this.transactionGroupId,
      required this.groupId,
      required this.paidBy,
      required this.sharedWith,
      required this.totalTransactionAmount,
      required this.sharedTransactionAmount,
      required this.sharedPercentage,
      required this.selfShareAmount,
      required this.selfSharePercentage,
      required this.sharingType,
      this.category,
      this.description,
      this.transactionPhoto,
      this.transactionNote,
      required this.isSettledUp,
      this.transactionDate,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    map['transaction_group_id'] = Variable<String>(transactionGroupId);
    map['group_id'] = Variable<String>(groupId);
    map['paid_by'] = Variable<String>(paidBy);
    map['shared_with'] = Variable<String>(sharedWith);
    map['total_transaction_amount'] = Variable<double>(totalTransactionAmount);
    map['shared_transaction_amount'] =
        Variable<double>(sharedTransactionAmount);
    map['shared_percentage'] = Variable<double>(sharedPercentage);
    map['self_share_amount'] = Variable<double>(selfShareAmount);
    map['self_share_percentage'] = Variable<double>(selfSharePercentage);
    map['sharing_type'] = Variable<String>(sharingType);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || transactionPhoto != null) {
      map['transaction_photo'] = Variable<String>(transactionPhoto);
    }
    if (!nullToAbsent || transactionNote != null) {
      map['transaction_note'] = Variable<String>(transactionNote);
    }
    map['is_settled_up'] = Variable<bool>(isSettledUp);
    if (!nullToAbsent || transactionDate != null) {
      map['transaction_date'] = Variable<DateTime>(transactionDate);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalGroupTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalGroupTransactionsCompanion(
      transactionId: Value(transactionId),
      transactionGroupId: Value(transactionGroupId),
      groupId: Value(groupId),
      paidBy: Value(paidBy),
      sharedWith: Value(sharedWith),
      totalTransactionAmount: Value(totalTransactionAmount),
      sharedTransactionAmount: Value(sharedTransactionAmount),
      sharedPercentage: Value(sharedPercentage),
      selfShareAmount: Value(selfShareAmount),
      selfSharePercentage: Value(selfSharePercentage),
      sharingType: Value(sharingType),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      transactionPhoto: transactionPhoto == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionPhoto),
      transactionNote: transactionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionNote),
      isSettledUp: Value(isSettledUp),
      transactionDate: transactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDate),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalGroupTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGroupTransaction(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      transactionGroupId:
          serializer.fromJson<String>(json['transactionGroupId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      paidBy: serializer.fromJson<String>(json['paidBy']),
      sharedWith: serializer.fromJson<String>(json['sharedWith']),
      totalTransactionAmount:
          serializer.fromJson<double>(json['totalTransactionAmount']),
      sharedTransactionAmount:
          serializer.fromJson<double>(json['sharedTransactionAmount']),
      sharedPercentage: serializer.fromJson<double>(json['sharedPercentage']),
      selfShareAmount: serializer.fromJson<double>(json['selfShareAmount']),
      selfSharePercentage:
          serializer.fromJson<double>(json['selfSharePercentage']),
      sharingType: serializer.fromJson<String>(json['sharingType']),
      category: serializer.fromJson<String?>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      transactionPhoto: serializer.fromJson<String?>(json['transactionPhoto']),
      transactionNote: serializer.fromJson<String?>(json['transactionNote']),
      isSettledUp: serializer.fromJson<bool>(json['isSettledUp']),
      transactionDate: serializer.fromJson<DateTime?>(json['transactionDate']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'transactionGroupId': serializer.toJson<String>(transactionGroupId),
      'groupId': serializer.toJson<String>(groupId),
      'paidBy': serializer.toJson<String>(paidBy),
      'sharedWith': serializer.toJson<String>(sharedWith),
      'totalTransactionAmount':
          serializer.toJson<double>(totalTransactionAmount),
      'sharedTransactionAmount':
          serializer.toJson<double>(sharedTransactionAmount),
      'sharedPercentage': serializer.toJson<double>(sharedPercentage),
      'selfShareAmount': serializer.toJson<double>(selfShareAmount),
      'selfSharePercentage': serializer.toJson<double>(selfSharePercentage),
      'sharingType': serializer.toJson<String>(sharingType),
      'category': serializer.toJson<String?>(category),
      'description': serializer.toJson<String?>(description),
      'transactionPhoto': serializer.toJson<String?>(transactionPhoto),
      'transactionNote': serializer.toJson<String?>(transactionNote),
      'isSettledUp': serializer.toJson<bool>(isSettledUp),
      'transactionDate': serializer.toJson<DateTime?>(transactionDate),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LocalGroupTransaction copyWith(
          {String? transactionId,
          String? transactionGroupId,
          String? groupId,
          String? paidBy,
          String? sharedWith,
          double? totalTransactionAmount,
          double? sharedTransactionAmount,
          double? sharedPercentage,
          double? selfShareAmount,
          double? selfSharePercentage,
          String? sharingType,
          Value<String?> category = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> transactionPhoto = const Value.absent(),
          Value<String?> transactionNote = const Value.absent(),
          bool? isSettledUp,
          Value<DateTime?> transactionDate = const Value.absent(),
          String? syncStatus}) =>
      LocalGroupTransaction(
        transactionId: transactionId ?? this.transactionId,
        transactionGroupId: transactionGroupId ?? this.transactionGroupId,
        groupId: groupId ?? this.groupId,
        paidBy: paidBy ?? this.paidBy,
        sharedWith: sharedWith ?? this.sharedWith,
        totalTransactionAmount:
            totalTransactionAmount ?? this.totalTransactionAmount,
        sharedTransactionAmount:
            sharedTransactionAmount ?? this.sharedTransactionAmount,
        sharedPercentage: sharedPercentage ?? this.sharedPercentage,
        selfShareAmount: selfShareAmount ?? this.selfShareAmount,
        selfSharePercentage: selfSharePercentage ?? this.selfSharePercentage,
        sharingType: sharingType ?? this.sharingType,
        category: category.present ? category.value : this.category,
        description: description.present ? description.value : this.description,
        transactionPhoto: transactionPhoto.present
            ? transactionPhoto.value
            : this.transactionPhoto,
        transactionNote: transactionNote.present
            ? transactionNote.value
            : this.transactionNote,
        isSettledUp: isSettledUp ?? this.isSettledUp,
        transactionDate: transactionDate.present
            ? transactionDate.value
            : this.transactionDate,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  LocalGroupTransaction copyWithCompanion(
      LocalGroupTransactionsCompanion data) {
    return LocalGroupTransaction(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      transactionGroupId: data.transactionGroupId.present
          ? data.transactionGroupId.value
          : this.transactionGroupId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      paidBy: data.paidBy.present ? data.paidBy.value : this.paidBy,
      sharedWith:
          data.sharedWith.present ? data.sharedWith.value : this.sharedWith,
      totalTransactionAmount: data.totalTransactionAmount.present
          ? data.totalTransactionAmount.value
          : this.totalTransactionAmount,
      sharedTransactionAmount: data.sharedTransactionAmount.present
          ? data.sharedTransactionAmount.value
          : this.sharedTransactionAmount,
      sharedPercentage: data.sharedPercentage.present
          ? data.sharedPercentage.value
          : this.sharedPercentage,
      selfShareAmount: data.selfShareAmount.present
          ? data.selfShareAmount.value
          : this.selfShareAmount,
      selfSharePercentage: data.selfSharePercentage.present
          ? data.selfSharePercentage.value
          : this.selfSharePercentage,
      sharingType:
          data.sharingType.present ? data.sharingType.value : this.sharingType,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      transactionPhoto: data.transactionPhoto.present
          ? data.transactionPhoto.value
          : this.transactionPhoto,
      transactionNote: data.transactionNote.present
          ? data.transactionNote.value
          : this.transactionNote,
      isSettledUp:
          data.isSettledUp.present ? data.isSettledUp.value : this.isSettledUp,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupTransaction(')
          ..write('transactionId: $transactionId, ')
          ..write('transactionGroupId: $transactionGroupId, ')
          ..write('groupId: $groupId, ')
          ..write('paidBy: $paidBy, ')
          ..write('sharedWith: $sharedWith, ')
          ..write('totalTransactionAmount: $totalTransactionAmount, ')
          ..write('sharedTransactionAmount: $sharedTransactionAmount, ')
          ..write('sharedPercentage: $sharedPercentage, ')
          ..write('selfShareAmount: $selfShareAmount, ')
          ..write('selfSharePercentage: $selfSharePercentage, ')
          ..write('sharingType: $sharingType, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('transactionPhoto: $transactionPhoto, ')
          ..write('transactionNote: $transactionNote, ')
          ..write('isSettledUp: $isSettledUp, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      transactionId,
      transactionGroupId,
      groupId,
      paidBy,
      sharedWith,
      totalTransactionAmount,
      sharedTransactionAmount,
      sharedPercentage,
      selfShareAmount,
      selfSharePercentage,
      sharingType,
      category,
      description,
      transactionPhoto,
      transactionNote,
      isSettledUp,
      transactionDate,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGroupTransaction &&
          other.transactionId == this.transactionId &&
          other.transactionGroupId == this.transactionGroupId &&
          other.groupId == this.groupId &&
          other.paidBy == this.paidBy &&
          other.sharedWith == this.sharedWith &&
          other.totalTransactionAmount == this.totalTransactionAmount &&
          other.sharedTransactionAmount == this.sharedTransactionAmount &&
          other.sharedPercentage == this.sharedPercentage &&
          other.selfShareAmount == this.selfShareAmount &&
          other.selfSharePercentage == this.selfSharePercentage &&
          other.sharingType == this.sharingType &&
          other.category == this.category &&
          other.description == this.description &&
          other.transactionPhoto == this.transactionPhoto &&
          other.transactionNote == this.transactionNote &&
          other.isSettledUp == this.isSettledUp &&
          other.transactionDate == this.transactionDate &&
          other.syncStatus == this.syncStatus);
}

class LocalGroupTransactionsCompanion
    extends UpdateCompanion<LocalGroupTransaction> {
  final Value<String> transactionId;
  final Value<String> transactionGroupId;
  final Value<String> groupId;
  final Value<String> paidBy;
  final Value<String> sharedWith;
  final Value<double> totalTransactionAmount;
  final Value<double> sharedTransactionAmount;
  final Value<double> sharedPercentage;
  final Value<double> selfShareAmount;
  final Value<double> selfSharePercentage;
  final Value<String> sharingType;
  final Value<String?> category;
  final Value<String?> description;
  final Value<String?> transactionPhoto;
  final Value<String?> transactionNote;
  final Value<bool> isSettledUp;
  final Value<DateTime?> transactionDate;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalGroupTransactionsCompanion({
    this.transactionId = const Value.absent(),
    this.transactionGroupId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.paidBy = const Value.absent(),
    this.sharedWith = const Value.absent(),
    this.totalTransactionAmount = const Value.absent(),
    this.sharedTransactionAmount = const Value.absent(),
    this.sharedPercentage = const Value.absent(),
    this.selfShareAmount = const Value.absent(),
    this.selfSharePercentage = const Value.absent(),
    this.sharingType = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.transactionPhoto = const Value.absent(),
    this.transactionNote = const Value.absent(),
    this.isSettledUp = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGroupTransactionsCompanion.insert({
    required String transactionId,
    required String transactionGroupId,
    required String groupId,
    required String paidBy,
    required String sharedWith,
    required double totalTransactionAmount,
    required double sharedTransactionAmount,
    this.sharedPercentage = const Value.absent(),
    this.selfShareAmount = const Value.absent(),
    this.selfSharePercentage = const Value.absent(),
    this.sharingType = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.transactionPhoto = const Value.absent(),
    this.transactionNote = const Value.absent(),
    this.isSettledUp = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : transactionId = Value(transactionId),
        transactionGroupId = Value(transactionGroupId),
        groupId = Value(groupId),
        paidBy = Value(paidBy),
        sharedWith = Value(sharedWith),
        totalTransactionAmount = Value(totalTransactionAmount),
        sharedTransactionAmount = Value(sharedTransactionAmount);
  static Insertable<LocalGroupTransaction> custom({
    Expression<String>? transactionId,
    Expression<String>? transactionGroupId,
    Expression<String>? groupId,
    Expression<String>? paidBy,
    Expression<String>? sharedWith,
    Expression<double>? totalTransactionAmount,
    Expression<double>? sharedTransactionAmount,
    Expression<double>? sharedPercentage,
    Expression<double>? selfShareAmount,
    Expression<double>? selfSharePercentage,
    Expression<String>? sharingType,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? transactionPhoto,
    Expression<String>? transactionNote,
    Expression<bool>? isSettledUp,
    Expression<DateTime>? transactionDate,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (transactionGroupId != null)
        'transaction_group_id': transactionGroupId,
      if (groupId != null) 'group_id': groupId,
      if (paidBy != null) 'paid_by': paidBy,
      if (sharedWith != null) 'shared_with': sharedWith,
      if (totalTransactionAmount != null)
        'total_transaction_amount': totalTransactionAmount,
      if (sharedTransactionAmount != null)
        'shared_transaction_amount': sharedTransactionAmount,
      if (sharedPercentage != null) 'shared_percentage': sharedPercentage,
      if (selfShareAmount != null) 'self_share_amount': selfShareAmount,
      if (selfSharePercentage != null)
        'self_share_percentage': selfSharePercentage,
      if (sharingType != null) 'sharing_type': sharingType,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (transactionPhoto != null) 'transaction_photo': transactionPhoto,
      if (transactionNote != null) 'transaction_note': transactionNote,
      if (isSettledUp != null) 'is_settled_up': isSettledUp,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGroupTransactionsCompanion copyWith(
      {Value<String>? transactionId,
      Value<String>? transactionGroupId,
      Value<String>? groupId,
      Value<String>? paidBy,
      Value<String>? sharedWith,
      Value<double>? totalTransactionAmount,
      Value<double>? sharedTransactionAmount,
      Value<double>? sharedPercentage,
      Value<double>? selfShareAmount,
      Value<double>? selfSharePercentage,
      Value<String>? sharingType,
      Value<String?>? category,
      Value<String?>? description,
      Value<String?>? transactionPhoto,
      Value<String?>? transactionNote,
      Value<bool>? isSettledUp,
      Value<DateTime?>? transactionDate,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return LocalGroupTransactionsCompanion(
      transactionId: transactionId ?? this.transactionId,
      transactionGroupId: transactionGroupId ?? this.transactionGroupId,
      groupId: groupId ?? this.groupId,
      paidBy: paidBy ?? this.paidBy,
      sharedWith: sharedWith ?? this.sharedWith,
      totalTransactionAmount:
          totalTransactionAmount ?? this.totalTransactionAmount,
      sharedTransactionAmount:
          sharedTransactionAmount ?? this.sharedTransactionAmount,
      sharedPercentage: sharedPercentage ?? this.sharedPercentage,
      selfShareAmount: selfShareAmount ?? this.selfShareAmount,
      selfSharePercentage: selfSharePercentage ?? this.selfSharePercentage,
      sharingType: sharingType ?? this.sharingType,
      category: category ?? this.category,
      description: description ?? this.description,
      transactionPhoto: transactionPhoto ?? this.transactionPhoto,
      transactionNote: transactionNote ?? this.transactionNote,
      isSettledUp: isSettledUp ?? this.isSettledUp,
      transactionDate: transactionDate ?? this.transactionDate,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (transactionGroupId.present) {
      map['transaction_group_id'] = Variable<String>(transactionGroupId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (paidBy.present) {
      map['paid_by'] = Variable<String>(paidBy.value);
    }
    if (sharedWith.present) {
      map['shared_with'] = Variable<String>(sharedWith.value);
    }
    if (totalTransactionAmount.present) {
      map['total_transaction_amount'] =
          Variable<double>(totalTransactionAmount.value);
    }
    if (sharedTransactionAmount.present) {
      map['shared_transaction_amount'] =
          Variable<double>(sharedTransactionAmount.value);
    }
    if (sharedPercentage.present) {
      map['shared_percentage'] = Variable<double>(sharedPercentage.value);
    }
    if (selfShareAmount.present) {
      map['self_share_amount'] = Variable<double>(selfShareAmount.value);
    }
    if (selfSharePercentage.present) {
      map['self_share_percentage'] =
          Variable<double>(selfSharePercentage.value);
    }
    if (sharingType.present) {
      map['sharing_type'] = Variable<String>(sharingType.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (transactionPhoto.present) {
      map['transaction_photo'] = Variable<String>(transactionPhoto.value);
    }
    if (transactionNote.present) {
      map['transaction_note'] = Variable<String>(transactionNote.value);
    }
    if (isSettledUp.present) {
      map['is_settled_up'] = Variable<bool>(isSettledUp.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGroupTransactionsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('transactionGroupId: $transactionGroupId, ')
          ..write('groupId: $groupId, ')
          ..write('paidBy: $paidBy, ')
          ..write('sharedWith: $sharedWith, ')
          ..write('totalTransactionAmount: $totalTransactionAmount, ')
          ..write('sharedTransactionAmount: $sharedTransactionAmount, ')
          ..write('sharedPercentage: $sharedPercentage, ')
          ..write('selfShareAmount: $selfShareAmount, ')
          ..write('selfSharePercentage: $selfSharePercentage, ')
          ..write('sharingType: $sharingType, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('transactionPhoto: $transactionPhoto, ')
          ..write('transactionNote: $transactionNote, ')
          ..write('isSettledUp: $isSettledUp, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPersonalTransactionsTable extends LocalPersonalTransactions
    with TableInfo<$LocalPersonalTransactionsTable, LocalPersonalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPersonalTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionDescriptionMeta =
      const VerificationMeta('transactionDescription');
  @override
  late final GeneratedColumn<String> transactionDescription =
      GeneratedColumn<String>('transaction_description', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        transactionId,
        userId,
        amount,
        category,
        transactionDescription,
        currency,
        paymentMethod,
        transactionDate,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_personal_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalPersonalTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('transaction_description')) {
      context.handle(
          _transactionDescriptionMeta,
          transactionDescription.isAcceptableOrUnknown(
              data['transaction_description']!, _transactionDescriptionMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId};
  @override
  LocalPersonalTransaction map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPersonalTransaction(
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      transactionDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transaction_description']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method']),
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $LocalPersonalTransactionsTable createAlias(String alias) {
    return $LocalPersonalTransactionsTable(attachedDatabase, alias);
  }
}

class LocalPersonalTransaction extends DataClass
    implements Insertable<LocalPersonalTransaction> {
  final String transactionId;
  final String userId;
  final double amount;
  final String? category;
  final String? transactionDescription;
  final String currency;
  final String? paymentMethod;
  final DateTime? transactionDate;
  final String syncStatus;
  const LocalPersonalTransaction(
      {required this.transactionId,
      required this.userId,
      required this.amount,
      this.category,
      this.transactionDescription,
      required this.currency,
      this.paymentMethod,
      this.transactionDate,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    map['user_id'] = Variable<String>(userId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || transactionDescription != null) {
      map['transaction_description'] = Variable<String>(transactionDescription);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || transactionDate != null) {
      map['transaction_date'] = Variable<DateTime>(transactionDate);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalPersonalTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalPersonalTransactionsCompanion(
      transactionId: Value(transactionId),
      userId: Value(userId),
      amount: Value(amount),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      transactionDescription: transactionDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDescription),
      currency: Value(currency),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      transactionDate: transactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionDate),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalPersonalTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPersonalTransaction(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      userId: serializer.fromJson<String>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String?>(json['category']),
      transactionDescription:
          serializer.fromJson<String?>(json['transactionDescription']),
      currency: serializer.fromJson<String>(json['currency']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      transactionDate: serializer.fromJson<DateTime?>(json['transactionDate']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'userId': serializer.toJson<String>(userId),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String?>(category),
      'transactionDescription':
          serializer.toJson<String?>(transactionDescription),
      'currency': serializer.toJson<String>(currency),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'transactionDate': serializer.toJson<DateTime?>(transactionDate),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LocalPersonalTransaction copyWith(
          {String? transactionId,
          String? userId,
          double? amount,
          Value<String?> category = const Value.absent(),
          Value<String?> transactionDescription = const Value.absent(),
          String? currency,
          Value<String?> paymentMethod = const Value.absent(),
          Value<DateTime?> transactionDate = const Value.absent(),
          String? syncStatus}) =>
      LocalPersonalTransaction(
        transactionId: transactionId ?? this.transactionId,
        userId: userId ?? this.userId,
        amount: amount ?? this.amount,
        category: category.present ? category.value : this.category,
        transactionDescription: transactionDescription.present
            ? transactionDescription.value
            : this.transactionDescription,
        currency: currency ?? this.currency,
        paymentMethod:
            paymentMethod.present ? paymentMethod.value : this.paymentMethod,
        transactionDate: transactionDate.present
            ? transactionDate.value
            : this.transactionDate,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  LocalPersonalTransaction copyWithCompanion(
      LocalPersonalTransactionsCompanion data) {
    return LocalPersonalTransaction(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      transactionDescription: data.transactionDescription.present
          ? data.transactionDescription.value
          : this.transactionDescription,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPersonalTransaction(')
          ..write('transactionId: $transactionId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('transactionDescription: $transactionDescription, ')
          ..write('currency: $currency, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      transactionId,
      userId,
      amount,
      category,
      transactionDescription,
      currency,
      paymentMethod,
      transactionDate,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPersonalTransaction &&
          other.transactionId == this.transactionId &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.transactionDescription == this.transactionDescription &&
          other.currency == this.currency &&
          other.paymentMethod == this.paymentMethod &&
          other.transactionDate == this.transactionDate &&
          other.syncStatus == this.syncStatus);
}

class LocalPersonalTransactionsCompanion
    extends UpdateCompanion<LocalPersonalTransaction> {
  final Value<String> transactionId;
  final Value<String> userId;
  final Value<double> amount;
  final Value<String?> category;
  final Value<String?> transactionDescription;
  final Value<String> currency;
  final Value<String?> paymentMethod;
  final Value<DateTime?> transactionDate;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalPersonalTransactionsCompanion({
    this.transactionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.transactionDescription = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPersonalTransactionsCompanion.insert({
    required String transactionId,
    required String userId,
    required double amount,
    this.category = const Value.absent(),
    this.transactionDescription = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : transactionId = Value(transactionId),
        userId = Value(userId),
        amount = Value(amount);
  static Insertable<LocalPersonalTransaction> custom({
    Expression<String>? transactionId,
    Expression<String>? userId,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? transactionDescription,
    Expression<String>? currency,
    Expression<String>? paymentMethod,
    Expression<DateTime>? transactionDate,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (transactionDescription != null)
        'transaction_description': transactionDescription,
      if (currency != null) 'currency': currency,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPersonalTransactionsCompanion copyWith(
      {Value<String>? transactionId,
      Value<String>? userId,
      Value<double>? amount,
      Value<String?>? category,
      Value<String?>? transactionDescription,
      Value<String>? currency,
      Value<String?>? paymentMethod,
      Value<DateTime?>? transactionDate,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return LocalPersonalTransactionsCompanion(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      transactionDescription:
          transactionDescription ?? this.transactionDescription,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionDate: transactionDate ?? this.transactionDate,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (transactionDescription.present) {
      map['transaction_description'] =
          Variable<String>(transactionDescription.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPersonalTransactionsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('transactionDescription: $transactionDescription, ')
          ..write('currency: $currency, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFriendsTable extends LocalFriends
    with TableInfo<$LocalFriendsTable, LocalFriend> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFriendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _friendIdMeta =
      const VerificationMeta('friendId');
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
      'friend_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, friendId, status, createdAt, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_friends';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFriend> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(_friendIdMeta,
          friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta));
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFriend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFriend(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      friendId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}friend_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $LocalFriendsTable createAlias(String alias) {
    return $LocalFriendsTable(attachedDatabase, alias);
  }
}

class LocalFriend extends DataClass implements Insertable<LocalFriend> {
  final String id;
  final String userId;
  final String friendId;
  final String status;
  final DateTime? createdAt;
  final String syncStatus;
  const LocalFriend(
      {required this.id,
      required this.userId,
      required this.friendId,
      required this.status,
      this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['friend_id'] = Variable<String>(friendId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalFriendsCompanion toCompanion(bool nullToAbsent) {
    return LocalFriendsCompanion(
      id: Value(id),
      userId: Value(userId),
      friendId: Value(friendId),
      status: Value(status),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalFriend.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFriend(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      friendId: serializer.fromJson<String>(json['friendId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'friendId': serializer.toJson<String>(friendId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LocalFriend copyWith(
          {String? id,
          String? userId,
          String? friendId,
          String? status,
          Value<DateTime?> createdAt = const Value.absent(),
          String? syncStatus}) =>
      LocalFriend(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        friendId: friendId ?? this.friendId,
        status: status ?? this.status,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  LocalFriend copyWithCompanion(LocalFriendsCompanion data) {
    return LocalFriend(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFriend(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('friendId: $friendId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, friendId, status, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFriend &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.friendId == this.friendId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class LocalFriendsCompanion extends UpdateCompanion<LocalFriend> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> friendId;
  final Value<String> status;
  final Value<DateTime?> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalFriendsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.friendId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFriendsCompanion.insert({
    required String id,
    required String userId,
    required String friendId,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        friendId = Value(friendId);
  static Insertable<LocalFriend> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? friendId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (friendId != null) 'friend_id': friendId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFriendsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? friendId,
      Value<String>? status,
      Value<DateTime?>? createdAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return LocalFriendsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFriendsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('friendId: $friendId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUsersCacheTable extends LocalUsersCache
    with TableInfo<$LocalUsersCacheTable, LocalUsersCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _profilePictureUrlMeta =
      const VerificationMeta('profilePictureUrl');
  @override
  late final GeneratedColumn<String> profilePictureUrl =
      GeneratedColumn<String>('profile_picture_url', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, firstName, lastName, email, profilePictureUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalUsersCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('profile_picture_url')) {
      context.handle(
          _profilePictureUrlMeta,
          profilePictureUrl.isAcceptableOrUnknown(
              data['profile_picture_url']!, _profilePictureUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  LocalUsersCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUsersCacheData(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      profilePictureUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}profile_picture_url']),
    );
  }

  @override
  $LocalUsersCacheTable createAlias(String alias) {
    return $LocalUsersCacheTable(attachedDatabase, alias);
  }
}

class LocalUsersCacheData extends DataClass
    implements Insertable<LocalUsersCacheData> {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profilePictureUrl;
  const LocalUsersCacheData(
      {required this.userId,
      this.firstName,
      this.lastName,
      this.email,
      this.profilePictureUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || profilePictureUrl != null) {
      map['profile_picture_url'] = Variable<String>(profilePictureUrl);
    }
    return map;
  }

  LocalUsersCacheCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCacheCompanion(
      userId: Value(userId),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      profilePictureUrl: profilePictureUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePictureUrl),
    );
  }

  factory LocalUsersCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUsersCacheData(
      userId: serializer.fromJson<String>(json['userId']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      email: serializer.fromJson<String?>(json['email']),
      profilePictureUrl:
          serializer.fromJson<String?>(json['profilePictureUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'email': serializer.toJson<String?>(email),
      'profilePictureUrl': serializer.toJson<String?>(profilePictureUrl),
    };
  }

  LocalUsersCacheData copyWith(
          {String? userId,
          Value<String?> firstName = const Value.absent(),
          Value<String?> lastName = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> profilePictureUrl = const Value.absent()}) =>
      LocalUsersCacheData(
        userId: userId ?? this.userId,
        firstName: firstName.present ? firstName.value : this.firstName,
        lastName: lastName.present ? lastName.value : this.lastName,
        email: email.present ? email.value : this.email,
        profilePictureUrl: profilePictureUrl.present
            ? profilePictureUrl.value
            : this.profilePictureUrl,
      );
  LocalUsersCacheData copyWithCompanion(LocalUsersCacheCompanion data) {
    return LocalUsersCacheData(
      userId: data.userId.present ? data.userId.value : this.userId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      email: data.email.present ? data.email.value : this.email,
      profilePictureUrl: data.profilePictureUrl.present
          ? data.profilePictureUrl.value
          : this.profilePictureUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCacheData(')
          ..write('userId: $userId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('profilePictureUrl: $profilePictureUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, firstName, lastName, email, profilePictureUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUsersCacheData &&
          other.userId == this.userId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.email == this.email &&
          other.profilePictureUrl == this.profilePictureUrl);
}

class LocalUsersCacheCompanion extends UpdateCompanion<LocalUsersCacheData> {
  final Value<String> userId;
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String?> email;
  final Value<String?> profilePictureUrl;
  final Value<int> rowid;
  const LocalUsersCacheCompanion({
    this.userId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.profilePictureUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCacheCompanion.insert({
    required String userId,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.profilePictureUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<LocalUsersCacheData> custom({
    Expression<String>? userId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? email,
    Expression<String>? profilePictureUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCacheCompanion copyWith(
      {Value<String>? userId,
      Value<String?>? firstName,
      Value<String?>? lastName,
      Value<String?>? email,
      Value<String?>? profilePictureUrl,
      Value<int>? rowid}) {
    return LocalUsersCacheCompanion(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (profilePictureUrl.present) {
      map['profile_picture_url'] = Variable<String>(profilePictureUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCacheCompanion(')
          ..write('userId: $userId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('profilePictureUrl: $profilePictureUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _targetTableMeta =
      const VerificationMeta('targetTable');
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
      'target_table', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
      'record_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        targetTable,
        operation,
        recordId,
        payload,
        createdAt,
        retryCount,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_table')) {
      context.handle(
          _targetTableMeta,
          targetTable.isAcceptableOrUnknown(
              data['target_table']!, _targetTableMeta));
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      targetTable: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_table'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String targetTable;
  final String operation;
  final String recordId;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final String status;
  const SyncQueueData(
      {required this.id,
      required this.targetTable,
      required this.operation,
      required this.recordId,
      required this.payload,
      required this.createdAt,
      required this.retryCount,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['operation'] = Variable<String>(operation);
    map['record_id'] = Variable<String>(recordId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      operation: Value(operation),
      recordId: Value(recordId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      status: Value(status),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      operation: serializer.fromJson<String>(json['operation']),
      recordId: serializer.fromJson<String>(json['recordId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'operation': serializer.toJson<String>(operation),
      'recordId': serializer.toJson<String>(recordId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? targetTable,
          String? operation,
          String? recordId,
          String? payload,
          DateTime? createdAt,
          int? retryCount,
          String? status}) =>
      SyncQueueData(
        id: id ?? this.id,
        targetTable: targetTable ?? this.targetTable,
        operation: operation ?? this.operation,
        recordId: recordId ?? this.recordId,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        status: status ?? this.status,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      targetTable:
          data.targetTable.present ? data.targetTable.value : this.targetTable,
      operation: data.operation.present ? data.operation.value : this.operation,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('operation: $operation, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, targetTable, operation, recordId, payload,
      createdAt, retryCount, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.operation == this.operation &&
          other.recordId == this.recordId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.status == this.status);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> targetTable;
  final Value<String> operation;
  final Value<String> recordId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String> status;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.operation = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String targetTable,
    required String operation,
    required String recordId,
    required String payload,
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
  })  : targetTable = Value(targetTable),
        operation = Value(operation),
        recordId = Value(recordId),
        payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? targetTable,
    Expression<String>? operation,
    Expression<String>? recordId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (operation != null) 'operation': operation,
      if (recordId != null) 'record_id': recordId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? targetTable,
      Value<String>? operation,
      Value<String>? recordId,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String>? status}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      operation: operation ?? this.operation,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('operation: $operation, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalGroupsTable localGroups = $LocalGroupsTable(this);
  late final $LocalGroupMembersTable localGroupMembers =
      $LocalGroupMembersTable(this);
  late final $LocalGroupTransactionsTable localGroupTransactions =
      $LocalGroupTransactionsTable(this);
  late final $LocalPersonalTransactionsTable localPersonalTransactions =
      $LocalPersonalTransactionsTable(this);
  late final $LocalFriendsTable localFriends = $LocalFriendsTable(this);
  late final $LocalUsersCacheTable localUsersCache =
      $LocalUsersCacheTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localGroups,
        localGroupMembers,
        localGroupTransactions,
        localPersonalTransactions,
        localFriends,
        localUsersCache,
        syncQueue
      ];
}

typedef $$LocalGroupsTableCreateCompanionBuilder = LocalGroupsCompanion
    Function({
  required String groupId,
  required String groupName,
  Value<String> groupBalance,
  Value<String?> createdBy,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedOn,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$LocalGroupsTableUpdateCompanionBuilder = LocalGroupsCompanion
    Function({
  Value<String> groupId,
  Value<String> groupName,
  Value<String> groupBalance,
  Value<String?> createdBy,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedOn,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$LocalGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupBalance => $composableBuilder(
      column: $table.groupBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedOn => $composableBuilder(
      column: $table.updatedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$LocalGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupBalance => $composableBuilder(
      column: $table.groupBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedOn => $composableBuilder(
      column: $table.updatedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$LocalGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGroupsTable> {
  $$LocalGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get groupBalance => $composableBuilder(
      column: $table.groupBalance, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedOn =>
      $composableBuilder(column: $table.updatedOn, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$LocalGroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalGroupsTable,
    LocalGroup,
    $$LocalGroupsTableFilterComposer,
    $$LocalGroupsTableOrderingComposer,
    $$LocalGroupsTableAnnotationComposer,
    $$LocalGroupsTableCreateCompanionBuilder,
    $$LocalGroupsTableUpdateCompanionBuilder,
    (LocalGroup, BaseReferences<_$AppDatabase, $LocalGroupsTable, LocalGroup>),
    LocalGroup,
    PrefetchHooks Function()> {
  $$LocalGroupsTableTableManager(_$AppDatabase db, $LocalGroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> groupId = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<String> groupBalance = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedOn = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalGroupsCompanion(
            groupId: groupId,
            groupName: groupName,
            groupBalance: groupBalance,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedOn: updatedOn,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String groupId,
            required String groupName,
            Value<String> groupBalance = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedOn = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalGroupsCompanion.insert(
            groupId: groupId,
            groupName: groupName,
            groupBalance: groupBalance,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedOn: updatedOn,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalGroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalGroupsTable,
    LocalGroup,
    $$LocalGroupsTableFilterComposer,
    $$LocalGroupsTableOrderingComposer,
    $$LocalGroupsTableAnnotationComposer,
    $$LocalGroupsTableCreateCompanionBuilder,
    $$LocalGroupsTableUpdateCompanionBuilder,
    (LocalGroup, BaseReferences<_$AppDatabase, $LocalGroupsTable, LocalGroup>),
    LocalGroup,
    PrefetchHooks Function()>;
typedef $$LocalGroupMembersTableCreateCompanionBuilder
    = LocalGroupMembersCompanion Function({
  required String groupId,
  required String userId,
  Value<int> rowid,
});
typedef $$LocalGroupMembersTableUpdateCompanionBuilder
    = LocalGroupMembersCompanion Function({
  Value<String> groupId,
  Value<String> userId,
  Value<int> rowid,
});

class $$LocalGroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGroupMembersTable> {
  $$LocalGroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));
}

class $$LocalGroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGroupMembersTable> {
  $$LocalGroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));
}

class $$LocalGroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGroupMembersTable> {
  $$LocalGroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$LocalGroupMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalGroupMembersTable,
    LocalGroupMember,
    $$LocalGroupMembersTableFilterComposer,
    $$LocalGroupMembersTableOrderingComposer,
    $$LocalGroupMembersTableAnnotationComposer,
    $$LocalGroupMembersTableCreateCompanionBuilder,
    $$LocalGroupMembersTableUpdateCompanionBuilder,
    (
      LocalGroupMember,
      BaseReferences<_$AppDatabase, $LocalGroupMembersTable, LocalGroupMember>
    ),
    LocalGroupMember,
    PrefetchHooks Function()> {
  $$LocalGroupMembersTableTableManager(
      _$AppDatabase db, $LocalGroupMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalGroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalGroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalGroupMembersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> groupId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalGroupMembersCompanion(
            groupId: groupId,
            userId: userId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String groupId,
            required String userId,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalGroupMembersCompanion.insert(
            groupId: groupId,
            userId: userId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalGroupMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalGroupMembersTable,
    LocalGroupMember,
    $$LocalGroupMembersTableFilterComposer,
    $$LocalGroupMembersTableOrderingComposer,
    $$LocalGroupMembersTableAnnotationComposer,
    $$LocalGroupMembersTableCreateCompanionBuilder,
    $$LocalGroupMembersTableUpdateCompanionBuilder,
    (
      LocalGroupMember,
      BaseReferences<_$AppDatabase, $LocalGroupMembersTable, LocalGroupMember>
    ),
    LocalGroupMember,
    PrefetchHooks Function()>;
typedef $$LocalGroupTransactionsTableCreateCompanionBuilder
    = LocalGroupTransactionsCompanion Function({
  required String transactionId,
  required String transactionGroupId,
  required String groupId,
  required String paidBy,
  required String sharedWith,
  required double totalTransactionAmount,
  required double sharedTransactionAmount,
  Value<double> sharedPercentage,
  Value<double> selfShareAmount,
  Value<double> selfSharePercentage,
  Value<String> sharingType,
  Value<String?> category,
  Value<String?> description,
  Value<String?> transactionPhoto,
  Value<String?> transactionNote,
  Value<bool> isSettledUp,
  Value<DateTime?> transactionDate,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$LocalGroupTransactionsTableUpdateCompanionBuilder
    = LocalGroupTransactionsCompanion Function({
  Value<String> transactionId,
  Value<String> transactionGroupId,
  Value<String> groupId,
  Value<String> paidBy,
  Value<String> sharedWith,
  Value<double> totalTransactionAmount,
  Value<double> sharedTransactionAmount,
  Value<double> sharedPercentage,
  Value<double> selfShareAmount,
  Value<double> selfSharePercentage,
  Value<String> sharingType,
  Value<String?> category,
  Value<String?> description,
  Value<String?> transactionPhoto,
  Value<String?> transactionNote,
  Value<bool> isSettledUp,
  Value<DateTime?> transactionDate,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$LocalGroupTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGroupTransactionsTable> {
  $$LocalGroupTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionGroupId => $composableBuilder(
      column: $table.transactionGroupId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paidBy => $composableBuilder(
      column: $table.paidBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sharedWith => $composableBuilder(
      column: $table.sharedWith, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalTransactionAmount => $composableBuilder(
      column: $table.totalTransactionAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sharedTransactionAmount => $composableBuilder(
      column: $table.sharedTransactionAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sharedPercentage => $composableBuilder(
      column: $table.sharedPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get selfShareAmount => $composableBuilder(
      column: $table.selfShareAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get selfSharePercentage => $composableBuilder(
      column: $table.selfSharePercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sharingType => $composableBuilder(
      column: $table.sharingType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionPhoto => $composableBuilder(
      column: $table.transactionPhoto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionNote => $composableBuilder(
      column: $table.transactionNote,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSettledUp => $composableBuilder(
      column: $table.isSettledUp, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$LocalGroupTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGroupTransactionsTable> {
  $$LocalGroupTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionGroupId => $composableBuilder(
      column: $table.transactionGroupId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paidBy => $composableBuilder(
      column: $table.paidBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sharedWith => $composableBuilder(
      column: $table.sharedWith, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalTransactionAmount => $composableBuilder(
      column: $table.totalTransactionAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sharedTransactionAmount => $composableBuilder(
      column: $table.sharedTransactionAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sharedPercentage => $composableBuilder(
      column: $table.sharedPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get selfShareAmount => $composableBuilder(
      column: $table.selfShareAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get selfSharePercentage => $composableBuilder(
      column: $table.selfSharePercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sharingType => $composableBuilder(
      column: $table.sharingType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionPhoto => $composableBuilder(
      column: $table.transactionPhoto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionNote => $composableBuilder(
      column: $table.transactionNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSettledUp => $composableBuilder(
      column: $table.isSettledUp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$LocalGroupTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGroupTransactionsTable> {
  $$LocalGroupTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<String> get transactionGroupId => $composableBuilder(
      column: $table.transactionGroupId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get paidBy =>
      $composableBuilder(column: $table.paidBy, builder: (column) => column);

  GeneratedColumn<String> get sharedWith => $composableBuilder(
      column: $table.sharedWith, builder: (column) => column);

  GeneratedColumn<double> get totalTransactionAmount => $composableBuilder(
      column: $table.totalTransactionAmount, builder: (column) => column);

  GeneratedColumn<double> get sharedTransactionAmount => $composableBuilder(
      column: $table.sharedTransactionAmount, builder: (column) => column);

  GeneratedColumn<double> get sharedPercentage => $composableBuilder(
      column: $table.sharedPercentage, builder: (column) => column);

  GeneratedColumn<double> get selfShareAmount => $composableBuilder(
      column: $table.selfShareAmount, builder: (column) => column);

  GeneratedColumn<double> get selfSharePercentage => $composableBuilder(
      column: $table.selfSharePercentage, builder: (column) => column);

  GeneratedColumn<String> get sharingType => $composableBuilder(
      column: $table.sharingType, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get transactionPhoto => $composableBuilder(
      column: $table.transactionPhoto, builder: (column) => column);

  GeneratedColumn<String> get transactionNote => $composableBuilder(
      column: $table.transactionNote, builder: (column) => column);

  GeneratedColumn<bool> get isSettledUp => $composableBuilder(
      column: $table.isSettledUp, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$LocalGroupTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalGroupTransactionsTable,
    LocalGroupTransaction,
    $$LocalGroupTransactionsTableFilterComposer,
    $$LocalGroupTransactionsTableOrderingComposer,
    $$LocalGroupTransactionsTableAnnotationComposer,
    $$LocalGroupTransactionsTableCreateCompanionBuilder,
    $$LocalGroupTransactionsTableUpdateCompanionBuilder,
    (
      LocalGroupTransaction,
      BaseReferences<_$AppDatabase, $LocalGroupTransactionsTable,
          LocalGroupTransaction>
    ),
    LocalGroupTransaction,
    PrefetchHooks Function()> {
  $$LocalGroupTransactionsTableTableManager(
      _$AppDatabase db, $LocalGroupTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalGroupTransactionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalGroupTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalGroupTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> transactionId = const Value.absent(),
            Value<String> transactionGroupId = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> paidBy = const Value.absent(),
            Value<String> sharedWith = const Value.absent(),
            Value<double> totalTransactionAmount = const Value.absent(),
            Value<double> sharedTransactionAmount = const Value.absent(),
            Value<double> sharedPercentage = const Value.absent(),
            Value<double> selfShareAmount = const Value.absent(),
            Value<double> selfSharePercentage = const Value.absent(),
            Value<String> sharingType = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> transactionPhoto = const Value.absent(),
            Value<String?> transactionNote = const Value.absent(),
            Value<bool> isSettledUp = const Value.absent(),
            Value<DateTime?> transactionDate = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalGroupTransactionsCompanion(
            transactionId: transactionId,
            transactionGroupId: transactionGroupId,
            groupId: groupId,
            paidBy: paidBy,
            sharedWith: sharedWith,
            totalTransactionAmount: totalTransactionAmount,
            sharedTransactionAmount: sharedTransactionAmount,
            sharedPercentage: sharedPercentage,
            selfShareAmount: selfShareAmount,
            selfSharePercentage: selfSharePercentage,
            sharingType: sharingType,
            category: category,
            description: description,
            transactionPhoto: transactionPhoto,
            transactionNote: transactionNote,
            isSettledUp: isSettledUp,
            transactionDate: transactionDate,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String transactionId,
            required String transactionGroupId,
            required String groupId,
            required String paidBy,
            required String sharedWith,
            required double totalTransactionAmount,
            required double sharedTransactionAmount,
            Value<double> sharedPercentage = const Value.absent(),
            Value<double> selfShareAmount = const Value.absent(),
            Value<double> selfSharePercentage = const Value.absent(),
            Value<String> sharingType = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> transactionPhoto = const Value.absent(),
            Value<String?> transactionNote = const Value.absent(),
            Value<bool> isSettledUp = const Value.absent(),
            Value<DateTime?> transactionDate = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalGroupTransactionsCompanion.insert(
            transactionId: transactionId,
            transactionGroupId: transactionGroupId,
            groupId: groupId,
            paidBy: paidBy,
            sharedWith: sharedWith,
            totalTransactionAmount: totalTransactionAmount,
            sharedTransactionAmount: sharedTransactionAmount,
            sharedPercentage: sharedPercentage,
            selfShareAmount: selfShareAmount,
            selfSharePercentage: selfSharePercentage,
            sharingType: sharingType,
            category: category,
            description: description,
            transactionPhoto: transactionPhoto,
            transactionNote: transactionNote,
            isSettledUp: isSettledUp,
            transactionDate: transactionDate,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalGroupTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalGroupTransactionsTable,
        LocalGroupTransaction,
        $$LocalGroupTransactionsTableFilterComposer,
        $$LocalGroupTransactionsTableOrderingComposer,
        $$LocalGroupTransactionsTableAnnotationComposer,
        $$LocalGroupTransactionsTableCreateCompanionBuilder,
        $$LocalGroupTransactionsTableUpdateCompanionBuilder,
        (
          LocalGroupTransaction,
          BaseReferences<_$AppDatabase, $LocalGroupTransactionsTable,
              LocalGroupTransaction>
        ),
        LocalGroupTransaction,
        PrefetchHooks Function()>;
typedef $$LocalPersonalTransactionsTableCreateCompanionBuilder
    = LocalPersonalTransactionsCompanion Function({
  required String transactionId,
  required String userId,
  required double amount,
  Value<String?> category,
  Value<String?> transactionDescription,
  Value<String> currency,
  Value<String?> paymentMethod,
  Value<DateTime?> transactionDate,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$LocalPersonalTransactionsTableUpdateCompanionBuilder
    = LocalPersonalTransactionsCompanion Function({
  Value<String> transactionId,
  Value<String> userId,
  Value<double> amount,
  Value<String?> category,
  Value<String?> transactionDescription,
  Value<String> currency,
  Value<String?> paymentMethod,
  Value<DateTime?> transactionDate,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$LocalPersonalTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPersonalTransactionsTable> {
  $$LocalPersonalTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionDescription => $composableBuilder(
      column: $table.transactionDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$LocalPersonalTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPersonalTransactionsTable> {
  $$LocalPersonalTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionDescription => $composableBuilder(
      column: $table.transactionDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$LocalPersonalTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPersonalTransactionsTable> {
  $$LocalPersonalTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get transactionDescription => $composableBuilder(
      column: $table.transactionDescription, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$LocalPersonalTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalPersonalTransactionsTable,
    LocalPersonalTransaction,
    $$LocalPersonalTransactionsTableFilterComposer,
    $$LocalPersonalTransactionsTableOrderingComposer,
    $$LocalPersonalTransactionsTableAnnotationComposer,
    $$LocalPersonalTransactionsTableCreateCompanionBuilder,
    $$LocalPersonalTransactionsTableUpdateCompanionBuilder,
    (
      LocalPersonalTransaction,
      BaseReferences<_$AppDatabase, $LocalPersonalTransactionsTable,
          LocalPersonalTransaction>
    ),
    LocalPersonalTransaction,
    PrefetchHooks Function()> {
  $$LocalPersonalTransactionsTableTableManager(
      _$AppDatabase db, $LocalPersonalTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPersonalTransactionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPersonalTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPersonalTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> transactionId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> transactionDescription = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> paymentMethod = const Value.absent(),
            Value<DateTime?> transactionDate = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPersonalTransactionsCompanion(
            transactionId: transactionId,
            userId: userId,
            amount: amount,
            category: category,
            transactionDescription: transactionDescription,
            currency: currency,
            paymentMethod: paymentMethod,
            transactionDate: transactionDate,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String transactionId,
            required String userId,
            required double amount,
            Value<String?> category = const Value.absent(),
            Value<String?> transactionDescription = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> paymentMethod = const Value.absent(),
            Value<DateTime?> transactionDate = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPersonalTransactionsCompanion.insert(
            transactionId: transactionId,
            userId: userId,
            amount: amount,
            category: category,
            transactionDescription: transactionDescription,
            currency: currency,
            paymentMethod: paymentMethod,
            transactionDate: transactionDate,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalPersonalTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalPersonalTransactionsTable,
        LocalPersonalTransaction,
        $$LocalPersonalTransactionsTableFilterComposer,
        $$LocalPersonalTransactionsTableOrderingComposer,
        $$LocalPersonalTransactionsTableAnnotationComposer,
        $$LocalPersonalTransactionsTableCreateCompanionBuilder,
        $$LocalPersonalTransactionsTableUpdateCompanionBuilder,
        (
          LocalPersonalTransaction,
          BaseReferences<_$AppDatabase, $LocalPersonalTransactionsTable,
              LocalPersonalTransaction>
        ),
        LocalPersonalTransaction,
        PrefetchHooks Function()>;
typedef $$LocalFriendsTableCreateCompanionBuilder = LocalFriendsCompanion
    Function({
  required String id,
  required String userId,
  required String friendId,
  Value<String> status,
  Value<DateTime?> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$LocalFriendsTableUpdateCompanionBuilder = LocalFriendsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> friendId,
  Value<String> status,
  Value<DateTime?> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$LocalFriendsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFriendsTable> {
  $$LocalFriendsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get friendId => $composableBuilder(
      column: $table.friendId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$LocalFriendsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFriendsTable> {
  $$LocalFriendsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get friendId => $composableBuilder(
      column: $table.friendId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$LocalFriendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFriendsTable> {
  $$LocalFriendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get friendId =>
      $composableBuilder(column: $table.friendId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$LocalFriendsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalFriendsTable,
    LocalFriend,
    $$LocalFriendsTableFilterComposer,
    $$LocalFriendsTableOrderingComposer,
    $$LocalFriendsTableAnnotationComposer,
    $$LocalFriendsTableCreateCompanionBuilder,
    $$LocalFriendsTableUpdateCompanionBuilder,
    (
      LocalFriend,
      BaseReferences<_$AppDatabase, $LocalFriendsTable, LocalFriend>
    ),
    LocalFriend,
    PrefetchHooks Function()> {
  $$LocalFriendsTableTableManager(_$AppDatabase db, $LocalFriendsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFriendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFriendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFriendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> friendId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFriendsCompanion(
            id: id,
            userId: userId,
            friendId: friendId,
            status: status,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String friendId,
            Value<String> status = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFriendsCompanion.insert(
            id: id,
            userId: userId,
            friendId: friendId,
            status: status,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFriendsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalFriendsTable,
    LocalFriend,
    $$LocalFriendsTableFilterComposer,
    $$LocalFriendsTableOrderingComposer,
    $$LocalFriendsTableAnnotationComposer,
    $$LocalFriendsTableCreateCompanionBuilder,
    $$LocalFriendsTableUpdateCompanionBuilder,
    (
      LocalFriend,
      BaseReferences<_$AppDatabase, $LocalFriendsTable, LocalFriend>
    ),
    LocalFriend,
    PrefetchHooks Function()>;
typedef $$LocalUsersCacheTableCreateCompanionBuilder = LocalUsersCacheCompanion
    Function({
  required String userId,
  Value<String?> firstName,
  Value<String?> lastName,
  Value<String?> email,
  Value<String?> profilePictureUrl,
  Value<int> rowid,
});
typedef $$LocalUsersCacheTableUpdateCompanionBuilder = LocalUsersCacheCompanion
    Function({
  Value<String> userId,
  Value<String?> firstName,
  Value<String?> lastName,
  Value<String?> email,
  Value<String?> profilePictureUrl,
  Value<int> rowid,
});

class $$LocalUsersCacheTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersCacheTable> {
  $$LocalUsersCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profilePictureUrl => $composableBuilder(
      column: $table.profilePictureUrl,
      builder: (column) => ColumnFilters(column));
}

class $$LocalUsersCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersCacheTable> {
  $$LocalUsersCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profilePictureUrl => $composableBuilder(
      column: $table.profilePictureUrl,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalUsersCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersCacheTable> {
  $$LocalUsersCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get profilePictureUrl => $composableBuilder(
      column: $table.profilePictureUrl, builder: (column) => column);
}

class $$LocalUsersCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUsersCacheTable,
    LocalUsersCacheData,
    $$LocalUsersCacheTableFilterComposer,
    $$LocalUsersCacheTableOrderingComposer,
    $$LocalUsersCacheTableAnnotationComposer,
    $$LocalUsersCacheTableCreateCompanionBuilder,
    $$LocalUsersCacheTableUpdateCompanionBuilder,
    (
      LocalUsersCacheData,
      BaseReferences<_$AppDatabase, $LocalUsersCacheTable, LocalUsersCacheData>
    ),
    LocalUsersCacheData,
    PrefetchHooks Function()> {
  $$LocalUsersCacheTableTableManager(
      _$AppDatabase db, $LocalUsersCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> profilePictureUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUsersCacheCompanion(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profilePictureUrl: profilePictureUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<String?> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> profilePictureUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUsersCacheCompanion.insert(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profilePictureUrl: profilePictureUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUsersCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalUsersCacheTable,
    LocalUsersCacheData,
    $$LocalUsersCacheTableFilterComposer,
    $$LocalUsersCacheTableOrderingComposer,
    $$LocalUsersCacheTableAnnotationComposer,
    $$LocalUsersCacheTableCreateCompanionBuilder,
    $$LocalUsersCacheTableUpdateCompanionBuilder,
    (
      LocalUsersCacheData,
      BaseReferences<_$AppDatabase, $LocalUsersCacheTable, LocalUsersCacheData>
    ),
    LocalUsersCacheData,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String targetTable,
  required String operation,
  required String recordId,
  required String payload,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String> status,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> targetTable,
  Value<String> operation,
  Value<String> recordId,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String> status,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
      column: $table.targetTable, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> targetTable = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> recordId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            targetTable: targetTable,
            operation: operation,
            recordId: recordId,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String targetTable,
            required String operation,
            required String recordId,
            required String payload,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            targetTable: targetTable,
            operation: operation,
            recordId: recordId,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalGroupsTableTableManager get localGroups =>
      $$LocalGroupsTableTableManager(_db, _db.localGroups);
  $$LocalGroupMembersTableTableManager get localGroupMembers =>
      $$LocalGroupMembersTableTableManager(_db, _db.localGroupMembers);
  $$LocalGroupTransactionsTableTableManager get localGroupTransactions =>
      $$LocalGroupTransactionsTableTableManager(
          _db, _db.localGroupTransactions);
  $$LocalPersonalTransactionsTableTableManager get localPersonalTransactions =>
      $$LocalPersonalTransactionsTableTableManager(
          _db, _db.localPersonalTransactions);
  $$LocalFriendsTableTableManager get localFriends =>
      $$LocalFriendsTableTableManager(_db, _db.localFriends);
  $$LocalUsersCacheTableTableManager get localUsersCache =>
      $$LocalUsersCacheTableTableManager(_db, _db.localUsersCache);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
