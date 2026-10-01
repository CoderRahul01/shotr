// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ShotsTable extends Shots with TableInfo<$ShotsTable, ShotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>('source', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta = const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageHashMeta = const VerificationMeta('imageHash');
  @override
  late final GeneratedColumn<String> imageHash = GeneratedColumn<String>(
    'image_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractedTextMeta = const VerificationMeta('extractedText');
  @override
  late final GeneratedColumn<String> extractedText = GeneratedColumn<String>(
    'extracted_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>('link', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _categoryCorrectedMeta = const VerificationMeta('categoryCorrected');
  @override
  late final GeneratedColumn<bool> categoryCorrected = GeneratedColumn<bool>(
    'category_corrected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("category_corrected" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _gistMeta = const VerificationMeta('gist');
  @override
  late final GeneratedColumn<String> gist = GeneratedColumn<String>(
    'gist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _suggestedOutputMeta = const VerificationMeta('suggestedOutput');
  @override
  late final GeneratedColumn<String> suggestedOutput = GeneratedColumn<String>(
    'suggested_output',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('post'),
  );
  static const VerificationMeta _expiresMeta = const VerificationMeta('expires');
  @override
  late final GeneratedColumn<bool> expires = GeneratedColumn<bool>(
    'expires',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("expires" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>('note', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aboutMeta = const VerificationMeta('about');
  @override
  late final GeneratedColumn<String> about = GeneratedColumn<String>('about', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lowTextMeta = const VerificationMeta('lowText');
  @override
  late final GeneratedColumn<bool> lowText = GeneratedColumn<bool>(
    'low_text',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("low_text" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sensitiveMeta = const VerificationMeta('sensitive');
  @override
  late final GeneratedColumn<bool> sensitive = GeneratedColumn<bool>(
    'sensitive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("sensitive" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('newShot'),
  );
  static const VerificationMeta _madeAtMeta = const VerificationMeta('madeAt');
  @override
  late final GeneratedColumn<DateTime> madeAt = GeneratedColumn<DateTime>(
    'made_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    source,
    imagePath,
    imageHash,
    extractedText,
    link,
    category,
    categoryCorrected,
    title,
    gist,
    suggestedOutput,
    expires,
    note,
    about,
    lowText,
    sensitive,
    status,
    madeAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shots';
  @override
  VerificationContext validateIntegrity(Insertable<ShotRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta, imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('image_hash')) {
      context.handle(_imageHashMeta, imageHash.isAcceptableOrUnknown(data['image_hash']!, _imageHashMeta));
    }
    if (data.containsKey('extracted_text')) {
      context.handle(_extractedTextMeta, extractedText.isAcceptableOrUnknown(data['extracted_text']!, _extractedTextMeta));
    }
    if (data.containsKey('link')) {
      context.handle(_linkMeta, link.isAcceptableOrUnknown(data['link']!, _linkMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('category_corrected')) {
      context.handle(_categoryCorrectedMeta, categoryCorrected.isAcceptableOrUnknown(data['category_corrected']!, _categoryCorrectedMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('gist')) {
      context.handle(_gistMeta, gist.isAcceptableOrUnknown(data['gist']!, _gistMeta));
    }
    if (data.containsKey('suggested_output')) {
      context.handle(_suggestedOutputMeta, suggestedOutput.isAcceptableOrUnknown(data['suggested_output']!, _suggestedOutputMeta));
    }
    if (data.containsKey('expires')) {
      context.handle(_expiresMeta, expires.isAcceptableOrUnknown(data['expires']!, _expiresMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('about')) {
      context.handle(_aboutMeta, about.isAcceptableOrUnknown(data['about']!, _aboutMeta));
    }
    if (data.containsKey('low_text')) {
      context.handle(_lowTextMeta, lowText.isAcceptableOrUnknown(data['low_text']!, _lowTextMeta));
    }
    if (data.containsKey('sensitive')) {
      context.handle(_sensitiveMeta, sensitive.isAcceptableOrUnknown(data['sensitive']!, _sensitiveMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('made_at')) {
      context.handle(_madeAtMeta, madeAt.isAcceptableOrUnknown(data['made_at']!, _madeAtMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(_archivedAtMeta, archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShotRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      imagePath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      imageHash: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}image_hash']),
      extractedText: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}extracted_text'])!,
      link: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}link']),
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      categoryCorrected: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}category_corrected'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      gist: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}gist'])!,
      suggestedOutput: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}suggested_output'])!,
      expires: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}expires'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      about: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}about']),
      lowText: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}low_text'])!,
      sensitive: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}sensitive'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      madeAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}made_at']),
      archivedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
    );
  }

  @override
  $ShotsTable createAlias(String alias) {
    return $ShotsTable(attachedDatabase, alias);
  }
}

class ShotRow extends DataClass implements Insertable<ShotRow> {
  final String id;
  final DateTime createdAt;
  final String source;
  final String? imagePath;
  final String? imageHash;
  final String extractedText;
  final String? link;
  final String category;
  final bool categoryCorrected;
  final String title;
  final String gist;
  final String suggestedOutput;
  final bool expires;
  final String? note;
  final String? about;
  final bool lowText;
  final bool sensitive;
  final String status;
  final DateTime? madeAt;
  final DateTime? archivedAt;
  const ShotRow({
    required this.id,
    required this.createdAt,
    required this.source,
    this.imagePath,
    this.imageHash,
    required this.extractedText,
    this.link,
    required this.category,
    required this.categoryCorrected,
    required this.title,
    required this.gist,
    required this.suggestedOutput,
    required this.expires,
    this.note,
    this.about,
    required this.lowText,
    required this.sensitive,
    required this.status,
    this.madeAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || imageHash != null) {
      map['image_hash'] = Variable<String>(imageHash);
    }
    map['extracted_text'] = Variable<String>(extractedText);
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    map['category'] = Variable<String>(category);
    map['category_corrected'] = Variable<bool>(categoryCorrected);
    map['title'] = Variable<String>(title);
    map['gist'] = Variable<String>(gist);
    map['suggested_output'] = Variable<String>(suggestedOutput);
    map['expires'] = Variable<bool>(expires);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || about != null) {
      map['about'] = Variable<String>(about);
    }
    map['low_text'] = Variable<bool>(lowText);
    map['sensitive'] = Variable<bool>(sensitive);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || madeAt != null) {
      map['made_at'] = Variable<DateTime>(madeAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ShotsCompanion toCompanion(bool nullToAbsent) {
    return ShotsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      source: Value(source),
      imagePath: imagePath == null && nullToAbsent ? const Value.absent() : Value(imagePath),
      imageHash: imageHash == null && nullToAbsent ? const Value.absent() : Value(imageHash),
      extractedText: Value(extractedText),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      category: Value(category),
      categoryCorrected: Value(categoryCorrected),
      title: Value(title),
      gist: Value(gist),
      suggestedOutput: Value(suggestedOutput),
      expires: Value(expires),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      about: about == null && nullToAbsent ? const Value.absent() : Value(about),
      lowText: Value(lowText),
      sensitive: Value(sensitive),
      status: Value(status),
      madeAt: madeAt == null && nullToAbsent ? const Value.absent() : Value(madeAt),
      archivedAt: archivedAt == null && nullToAbsent ? const Value.absent() : Value(archivedAt),
    );
  }

  factory ShotRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShotRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      source: serializer.fromJson<String>(json['source']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      imageHash: serializer.fromJson<String?>(json['imageHash']),
      extractedText: serializer.fromJson<String>(json['extractedText']),
      link: serializer.fromJson<String?>(json['link']),
      category: serializer.fromJson<String>(json['category']),
      categoryCorrected: serializer.fromJson<bool>(json['categoryCorrected']),
      title: serializer.fromJson<String>(json['title']),
      gist: serializer.fromJson<String>(json['gist']),
      suggestedOutput: serializer.fromJson<String>(json['suggestedOutput']),
      expires: serializer.fromJson<bool>(json['expires']),
      note: serializer.fromJson<String?>(json['note']),
      about: serializer.fromJson<String?>(json['about']),
      lowText: serializer.fromJson<bool>(json['lowText']),
      sensitive: serializer.fromJson<bool>(json['sensitive']),
      status: serializer.fromJson<String>(json['status']),
      madeAt: serializer.fromJson<DateTime?>(json['madeAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'source': serializer.toJson<String>(source),
      'imagePath': serializer.toJson<String?>(imagePath),
      'imageHash': serializer.toJson<String?>(imageHash),
      'extractedText': serializer.toJson<String>(extractedText),
      'link': serializer.toJson<String?>(link),
      'category': serializer.toJson<String>(category),
      'categoryCorrected': serializer.toJson<bool>(categoryCorrected),
      'title': serializer.toJson<String>(title),
      'gist': serializer.toJson<String>(gist),
      'suggestedOutput': serializer.toJson<String>(suggestedOutput),
      'expires': serializer.toJson<bool>(expires),
      'note': serializer.toJson<String?>(note),
      'about': serializer.toJson<String?>(about),
      'lowText': serializer.toJson<bool>(lowText),
      'sensitive': serializer.toJson<bool>(sensitive),
      'status': serializer.toJson<String>(status),
      'madeAt': serializer.toJson<DateTime?>(madeAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ShotRow copyWith({
    String? id,
    DateTime? createdAt,
    String? source,
    Value<String?> imagePath = const Value.absent(),
    Value<String?> imageHash = const Value.absent(),
    String? extractedText,
    Value<String?> link = const Value.absent(),
    String? category,
    bool? categoryCorrected,
    String? title,
    String? gist,
    String? suggestedOutput,
    bool? expires,
    Value<String?> note = const Value.absent(),
    Value<String?> about = const Value.absent(),
    bool? lowText,
    bool? sensitive,
    String? status,
    Value<DateTime?> madeAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ShotRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    source: source ?? this.source,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    imageHash: imageHash.present ? imageHash.value : this.imageHash,
    extractedText: extractedText ?? this.extractedText,
    link: link.present ? link.value : this.link,
    category: category ?? this.category,
    categoryCorrected: categoryCorrected ?? this.categoryCorrected,
    title: title ?? this.title,
    gist: gist ?? this.gist,
    suggestedOutput: suggestedOutput ?? this.suggestedOutput,
    expires: expires ?? this.expires,
    note: note.present ? note.value : this.note,
    about: about.present ? about.value : this.about,
    lowText: lowText ?? this.lowText,
    sensitive: sensitive ?? this.sensitive,
    status: status ?? this.status,
    madeAt: madeAt.present ? madeAt.value : this.madeAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ShotRow copyWithCompanion(ShotsCompanion data) {
    return ShotRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      source: data.source.present ? data.source.value : this.source,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      imageHash: data.imageHash.present ? data.imageHash.value : this.imageHash,
      extractedText: data.extractedText.present ? data.extractedText.value : this.extractedText,
      link: data.link.present ? data.link.value : this.link,
      category: data.category.present ? data.category.value : this.category,
      categoryCorrected: data.categoryCorrected.present ? data.categoryCorrected.value : this.categoryCorrected,
      title: data.title.present ? data.title.value : this.title,
      gist: data.gist.present ? data.gist.value : this.gist,
      suggestedOutput: data.suggestedOutput.present ? data.suggestedOutput.value : this.suggestedOutput,
      expires: data.expires.present ? data.expires.value : this.expires,
      note: data.note.present ? data.note.value : this.note,
      about: data.about.present ? data.about.value : this.about,
      lowText: data.lowText.present ? data.lowText.value : this.lowText,
      sensitive: data.sensitive.present ? data.sensitive.value : this.sensitive,
      status: data.status.present ? data.status.value : this.status,
      madeAt: data.madeAt.present ? data.madeAt.value : this.madeAt,
      archivedAt: data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShotRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('source: $source, ')
          ..write('imagePath: $imagePath, ')
          ..write('imageHash: $imageHash, ')
          ..write('extractedText: $extractedText, ')
          ..write('link: $link, ')
          ..write('category: $category, ')
          ..write('categoryCorrected: $categoryCorrected, ')
          ..write('title: $title, ')
          ..write('gist: $gist, ')
          ..write('suggestedOutput: $suggestedOutput, ')
          ..write('expires: $expires, ')
          ..write('note: $note, ')
          ..write('about: $about, ')
          ..write('lowText: $lowText, ')
          ..write('sensitive: $sensitive, ')
          ..write('status: $status, ')
          ..write('madeAt: $madeAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    source,
    imagePath,
    imageHash,
    extractedText,
    link,
    category,
    categoryCorrected,
    title,
    gist,
    suggestedOutput,
    expires,
    note,
    about,
    lowText,
    sensitive,
    status,
    madeAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShotRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.source == this.source &&
          other.imagePath == this.imagePath &&
          other.imageHash == this.imageHash &&
          other.extractedText == this.extractedText &&
          other.link == this.link &&
          other.category == this.category &&
          other.categoryCorrected == this.categoryCorrected &&
          other.title == this.title &&
          other.gist == this.gist &&
          other.suggestedOutput == this.suggestedOutput &&
          other.expires == this.expires &&
          other.note == this.note &&
          other.about == this.about &&
          other.lowText == this.lowText &&
          other.sensitive == this.sensitive &&
          other.status == this.status &&
          other.madeAt == this.madeAt &&
          other.archivedAt == this.archivedAt);
}

class ShotsCompanion extends UpdateCompanion<ShotRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> source;
  final Value<String?> imagePath;
  final Value<String?> imageHash;
  final Value<String> extractedText;
  final Value<String?> link;
  final Value<String> category;
  final Value<bool> categoryCorrected;
  final Value<String> title;
  final Value<String> gist;
  final Value<String> suggestedOutput;
  final Value<bool> expires;
  final Value<String?> note;
  final Value<String?> about;
  final Value<bool> lowText;
  final Value<bool> sensitive;
  final Value<String> status;
  final Value<DateTime?> madeAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ShotsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.source = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.imageHash = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.link = const Value.absent(),
    this.category = const Value.absent(),
    this.categoryCorrected = const Value.absent(),
    this.title = const Value.absent(),
    this.gist = const Value.absent(),
    this.suggestedOutput = const Value.absent(),
    this.expires = const Value.absent(),
    this.note = const Value.absent(),
    this.about = const Value.absent(),
    this.lowText = const Value.absent(),
    this.sensitive = const Value.absent(),
    this.status = const Value.absent(),
    this.madeAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShotsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String source,
    this.imagePath = const Value.absent(),
    this.imageHash = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.link = const Value.absent(),
    this.category = const Value.absent(),
    this.categoryCorrected = const Value.absent(),
    this.title = const Value.absent(),
    this.gist = const Value.absent(),
    this.suggestedOutput = const Value.absent(),
    this.expires = const Value.absent(),
    this.note = const Value.absent(),
    this.about = const Value.absent(),
    this.lowText = const Value.absent(),
    this.sensitive = const Value.absent(),
    this.status = const Value.absent(),
    this.madeAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       source = Value(source);
  static Insertable<ShotRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? source,
    Expression<String>? imagePath,
    Expression<String>? imageHash,
    Expression<String>? extractedText,
    Expression<String>? link,
    Expression<String>? category,
    Expression<bool>? categoryCorrected,
    Expression<String>? title,
    Expression<String>? gist,
    Expression<String>? suggestedOutput,
    Expression<bool>? expires,
    Expression<String>? note,
    Expression<String>? about,
    Expression<bool>? lowText,
    Expression<bool>? sensitive,
    Expression<String>? status,
    Expression<DateTime>? madeAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (source != null) 'source': source,
      if (imagePath != null) 'image_path': imagePath,
      if (imageHash != null) 'image_hash': imageHash,
      if (extractedText != null) 'extracted_text': extractedText,
      if (link != null) 'link': link,
      if (category != null) 'category': category,
      if (categoryCorrected != null) 'category_corrected': categoryCorrected,
      if (title != null) 'title': title,
      if (gist != null) 'gist': gist,
      if (suggestedOutput != null) 'suggested_output': suggestedOutput,
      if (expires != null) 'expires': expires,
      if (note != null) 'note': note,
      if (about != null) 'about': about,
      if (lowText != null) 'low_text': lowText,
      if (sensitive != null) 'sensitive': sensitive,
      if (status != null) 'status': status,
      if (madeAt != null) 'made_at': madeAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShotsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? source,
    Value<String?>? imagePath,
    Value<String?>? imageHash,
    Value<String>? extractedText,
    Value<String?>? link,
    Value<String>? category,
    Value<bool>? categoryCorrected,
    Value<String>? title,
    Value<String>? gist,
    Value<String>? suggestedOutput,
    Value<bool>? expires,
    Value<String?>? note,
    Value<String?>? about,
    Value<bool>? lowText,
    Value<bool>? sensitive,
    Value<String>? status,
    Value<DateTime?>? madeAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ShotsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      imageHash: imageHash ?? this.imageHash,
      extractedText: extractedText ?? this.extractedText,
      link: link ?? this.link,
      category: category ?? this.category,
      categoryCorrected: categoryCorrected ?? this.categoryCorrected,
      title: title ?? this.title,
      gist: gist ?? this.gist,
      suggestedOutput: suggestedOutput ?? this.suggestedOutput,
      expires: expires ?? this.expires,
      note: note ?? this.note,
      about: about ?? this.about,
      lowText: lowText ?? this.lowText,
      sensitive: sensitive ?? this.sensitive,
      status: status ?? this.status,
      madeAt: madeAt ?? this.madeAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (imageHash.present) {
      map['image_hash'] = Variable<String>(imageHash.value);
    }
    if (extractedText.present) {
      map['extracted_text'] = Variable<String>(extractedText.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (categoryCorrected.present) {
      map['category_corrected'] = Variable<bool>(categoryCorrected.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (gist.present) {
      map['gist'] = Variable<String>(gist.value);
    }
    if (suggestedOutput.present) {
      map['suggested_output'] = Variable<String>(suggestedOutput.value);
    }
    if (expires.present) {
      map['expires'] = Variable<bool>(expires.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (about.present) {
      map['about'] = Variable<String>(about.value);
    }
    if (lowText.present) {
      map['low_text'] = Variable<bool>(lowText.value);
    }
    if (sensitive.present) {
      map['sensitive'] = Variable<bool>(sensitive.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (madeAt.present) {
      map['made_at'] = Variable<DateTime>(madeAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShotsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('source: $source, ')
          ..write('imagePath: $imagePath, ')
          ..write('imageHash: $imageHash, ')
          ..write('extractedText: $extractedText, ')
          ..write('link: $link, ')
          ..write('category: $category, ')
          ..write('categoryCorrected: $categoryCorrected, ')
          ..write('title: $title, ')
          ..write('gist: $gist, ')
          ..write('suggestedOutput: $suggestedOutput, ')
          ..write('expires: $expires, ')
          ..write('note: $note, ')
          ..write('about: $about, ')
          ..write('lowText: $lowText, ')
          ..write('sensitive: $sensitive, ')
          ..write('status: $status, ')
          ..write('madeAt: $madeAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, DraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shotIdMeta = const VerificationMeta('shotId');
  @override
  late final GeneratedColumn<String> shotId = GeneratedColumn<String>(
    'shot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES shots (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _outputMeta = const VerificationMeta('output');
  @override
  late final GeneratedColumn<String> output = GeneratedColumn<String>('output', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>('body', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta = const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>('server_id', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _regenerationsUsedMeta = const VerificationMeta('regenerationsUsed');
  @override
  late final GeneratedColumn<int> regenerationsUsed = GeneratedColumn<int>(
    'regenerations_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, shotId, output, body, serverId, regenerationsUsed, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(Insertable<DraftRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shot_id')) {
      context.handle(_shotIdMeta, shotId.isAcceptableOrUnknown(data['shot_id']!, _shotIdMeta));
    } else if (isInserting) {
      context.missing(_shotIdMeta);
    }
    if (data.containsKey('output')) {
      context.handle(_outputMeta, output.isAcceptableOrUnknown(data['output']!, _outputMeta));
    } else if (isInserting) {
      context.missing(_outputMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta, serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('regenerations_used')) {
      context.handle(_regenerationsUsedMeta, regenerationsUsed.isAcceptableOrUnknown(data['regenerations_used']!, _regenerationsUsedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}shot_id'])!,
      output: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}output'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      serverId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      regenerationsUsed: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}regenerations_used'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class DraftRow extends DataClass implements Insertable<DraftRow> {
  final String id;
  final String shotId;
  final String output;
  final String body;
  final String? serverId;
  final int regenerationsUsed;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DraftRow({
    required this.id,
    required this.shotId,
    required this.output,
    required this.body,
    this.serverId,
    required this.regenerationsUsed,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shot_id'] = Variable<String>(shotId);
    map['output'] = Variable<String>(output);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['regenerations_used'] = Variable<int>(regenerationsUsed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      shotId: Value(shotId),
      output: Value(output),
      body: Value(body),
      serverId: serverId == null && nullToAbsent ? const Value.absent() : Value(serverId),
      regenerationsUsed: Value(regenerationsUsed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DraftRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftRow(
      id: serializer.fromJson<String>(json['id']),
      shotId: serializer.fromJson<String>(json['shotId']),
      output: serializer.fromJson<String>(json['output']),
      body: serializer.fromJson<String>(json['body']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      regenerationsUsed: serializer.fromJson<int>(json['regenerationsUsed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shotId': serializer.toJson<String>(shotId),
      'output': serializer.toJson<String>(output),
      'body': serializer.toJson<String>(body),
      'serverId': serializer.toJson<String?>(serverId),
      'regenerationsUsed': serializer.toJson<int>(regenerationsUsed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DraftRow copyWith({
    String? id,
    String? shotId,
    String? output,
    String? body,
    Value<String?> serverId = const Value.absent(),
    int? regenerationsUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DraftRow(
    id: id ?? this.id,
    shotId: shotId ?? this.shotId,
    output: output ?? this.output,
    body: body ?? this.body,
    serverId: serverId.present ? serverId.value : this.serverId,
    regenerationsUsed: regenerationsUsed ?? this.regenerationsUsed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DraftRow copyWithCompanion(DraftsCompanion data) {
    return DraftRow(
      id: data.id.present ? data.id.value : this.id,
      shotId: data.shotId.present ? data.shotId.value : this.shotId,
      output: data.output.present ? data.output.value : this.output,
      body: data.body.present ? data.body.value : this.body,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      regenerationsUsed: data.regenerationsUsed.present ? data.regenerationsUsed.value : this.regenerationsUsed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftRow(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('output: $output, ')
          ..write('body: $body, ')
          ..write('serverId: $serverId, ')
          ..write('regenerationsUsed: $regenerationsUsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shotId, output, body, serverId, regenerationsUsed, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftRow &&
          other.id == this.id &&
          other.shotId == this.shotId &&
          other.output == this.output &&
          other.body == this.body &&
          other.serverId == this.serverId &&
          other.regenerationsUsed == this.regenerationsUsed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DraftsCompanion extends UpdateCompanion<DraftRow> {
  final Value<String> id;
  final Value<String> shotId;
  final Value<String> output;
  final Value<String> body;
  final Value<String?> serverId;
  final Value<int> regenerationsUsed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.shotId = const Value.absent(),
    this.output = const Value.absent(),
    this.body = const Value.absent(),
    this.serverId = const Value.absent(),
    this.regenerationsUsed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String id,
    required String shotId,
    required String output,
    required String body,
    this.serverId = const Value.absent(),
    this.regenerationsUsed = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shotId = Value(shotId),
       output = Value(output),
       body = Value(body),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DraftRow> custom({
    Expression<String>? id,
    Expression<String>? shotId,
    Expression<String>? output,
    Expression<String>? body,
    Expression<String>? serverId,
    Expression<int>? regenerationsUsed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shotId != null) 'shot_id': shotId,
      if (output != null) 'output': output,
      if (body != null) 'body': body,
      if (serverId != null) 'server_id': serverId,
      if (regenerationsUsed != null) 'regenerations_used': regenerationsUsed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? shotId,
    Value<String>? output,
    Value<String>? body,
    Value<String?>? serverId,
    Value<int>? regenerationsUsed,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DraftsCompanion(
      id: id ?? this.id,
      shotId: shotId ?? this.shotId,
      output: output ?? this.output,
      body: body ?? this.body,
      serverId: serverId ?? this.serverId,
      regenerationsUsed: regenerationsUsed ?? this.regenerationsUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shotId.present) {
      map['shot_id'] = Variable<String>(shotId.value);
    }
    if (output.present) {
      map['output'] = Variable<String>(output.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (regenerationsUsed.present) {
      map['regenerations_used'] = Variable<int>(regenerationsUsed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('output: $output, ')
          ..write('body: $body, ')
          ..write('serverId: $serverId, ')
          ..write('regenerationsUsed: $regenerationsUsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryCorrectionsTable extends CategoryCorrections with TableInfo<$CategoryCorrectionsTable, CorrectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryCorrectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _shotIdMeta = const VerificationMeta('shotId');
  @override
  late final GeneratedColumn<String> shotId = GeneratedColumn<String>('shot_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromCategoryMeta = const VerificationMeta('fromCategory');
  @override
  late final GeneratedColumn<String> fromCategory = GeneratedColumn<String>(
    'from_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toCategoryMeta = const VerificationMeta('toCategory');
  @override
  late final GeneratedColumn<String> toCategory = GeneratedColumn<String>(
    'to_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textSampleMeta = const VerificationMeta('textSample');
  @override
  late final GeneratedColumn<String> textSample = GeneratedColumn<String>(
    'text_sample',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, shotId, fromCategory, toCategory, textSample, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_corrections';
  @override
  VerificationContext validateIntegrity(Insertable<CorrectionRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shot_id')) {
      context.handle(_shotIdMeta, shotId.isAcceptableOrUnknown(data['shot_id']!, _shotIdMeta));
    } else if (isInserting) {
      context.missing(_shotIdMeta);
    }
    if (data.containsKey('from_category')) {
      context.handle(_fromCategoryMeta, fromCategory.isAcceptableOrUnknown(data['from_category']!, _fromCategoryMeta));
    } else if (isInserting) {
      context.missing(_fromCategoryMeta);
    }
    if (data.containsKey('to_category')) {
      context.handle(_toCategoryMeta, toCategory.isAcceptableOrUnknown(data['to_category']!, _toCategoryMeta));
    } else if (isInserting) {
      context.missing(_toCategoryMeta);
    }
    if (data.containsKey('text_sample')) {
      context.handle(_textSampleMeta, textSample.isAcceptableOrUnknown(data['text_sample']!, _textSampleMeta));
    } else if (isInserting) {
      context.missing(_textSampleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CorrectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CorrectionRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      shotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}shot_id'])!,
      fromCategory: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}from_category'])!,
      toCategory: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}to_category'])!,
      textSample: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}text_sample'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CategoryCorrectionsTable createAlias(String alias) {
    return $CategoryCorrectionsTable(attachedDatabase, alias);
  }
}

class CorrectionRow extends DataClass implements Insertable<CorrectionRow> {
  final int id;
  final String shotId;
  final String fromCategory;
  final String toCategory;
  final String textSample;
  final DateTime createdAt;
  const CorrectionRow({
    required this.id,
    required this.shotId,
    required this.fromCategory,
    required this.toCategory,
    required this.textSample,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shot_id'] = Variable<String>(shotId);
    map['from_category'] = Variable<String>(fromCategory);
    map['to_category'] = Variable<String>(toCategory);
    map['text_sample'] = Variable<String>(textSample);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoryCorrectionsCompanion toCompanion(bool nullToAbsent) {
    return CategoryCorrectionsCompanion(
      id: Value(id),
      shotId: Value(shotId),
      fromCategory: Value(fromCategory),
      toCategory: Value(toCategory),
      textSample: Value(textSample),
      createdAt: Value(createdAt),
    );
  }

  factory CorrectionRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CorrectionRow(
      id: serializer.fromJson<int>(json['id']),
      shotId: serializer.fromJson<String>(json['shotId']),
      fromCategory: serializer.fromJson<String>(json['fromCategory']),
      toCategory: serializer.fromJson<String>(json['toCategory']),
      textSample: serializer.fromJson<String>(json['textSample']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shotId': serializer.toJson<String>(shotId),
      'fromCategory': serializer.toJson<String>(fromCategory),
      'toCategory': serializer.toJson<String>(toCategory),
      'textSample': serializer.toJson<String>(textSample),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CorrectionRow copyWith({int? id, String? shotId, String? fromCategory, String? toCategory, String? textSample, DateTime? createdAt}) => CorrectionRow(
    id: id ?? this.id,
    shotId: shotId ?? this.shotId,
    fromCategory: fromCategory ?? this.fromCategory,
    toCategory: toCategory ?? this.toCategory,
    textSample: textSample ?? this.textSample,
    createdAt: createdAt ?? this.createdAt,
  );
  CorrectionRow copyWithCompanion(CategoryCorrectionsCompanion data) {
    return CorrectionRow(
      id: data.id.present ? data.id.value : this.id,
      shotId: data.shotId.present ? data.shotId.value : this.shotId,
      fromCategory: data.fromCategory.present ? data.fromCategory.value : this.fromCategory,
      toCategory: data.toCategory.present ? data.toCategory.value : this.toCategory,
      textSample: data.textSample.present ? data.textSample.value : this.textSample,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CorrectionRow(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('fromCategory: $fromCategory, ')
          ..write('toCategory: $toCategory, ')
          ..write('textSample: $textSample, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shotId, fromCategory, toCategory, textSample, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CorrectionRow &&
          other.id == this.id &&
          other.shotId == this.shotId &&
          other.fromCategory == this.fromCategory &&
          other.toCategory == this.toCategory &&
          other.textSample == this.textSample &&
          other.createdAt == this.createdAt);
}

class CategoryCorrectionsCompanion extends UpdateCompanion<CorrectionRow> {
  final Value<int> id;
  final Value<String> shotId;
  final Value<String> fromCategory;
  final Value<String> toCategory;
  final Value<String> textSample;
  final Value<DateTime> createdAt;
  const CategoryCorrectionsCompanion({
    this.id = const Value.absent(),
    this.shotId = const Value.absent(),
    this.fromCategory = const Value.absent(),
    this.toCategory = const Value.absent(),
    this.textSample = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoryCorrectionsCompanion.insert({
    this.id = const Value.absent(),
    required String shotId,
    required String fromCategory,
    required String toCategory,
    required String textSample,
    required DateTime createdAt,
  }) : shotId = Value(shotId),
       fromCategory = Value(fromCategory),
       toCategory = Value(toCategory),
       textSample = Value(textSample),
       createdAt = Value(createdAt);
  static Insertable<CorrectionRow> custom({
    Expression<int>? id,
    Expression<String>? shotId,
    Expression<String>? fromCategory,
    Expression<String>? toCategory,
    Expression<String>? textSample,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shotId != null) 'shot_id': shotId,
      if (fromCategory != null) 'from_category': fromCategory,
      if (toCategory != null) 'to_category': toCategory,
      if (textSample != null) 'text_sample': textSample,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoryCorrectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? shotId,
    Value<String>? fromCategory,
    Value<String>? toCategory,
    Value<String>? textSample,
    Value<DateTime>? createdAt,
  }) {
    return CategoryCorrectionsCompanion(
      id: id ?? this.id,
      shotId: shotId ?? this.shotId,
      fromCategory: fromCategory ?? this.fromCategory,
      toCategory: toCategory ?? this.toCategory,
      textSample: textSample ?? this.textSample,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shotId.present) {
      map['shot_id'] = Variable<String>(shotId.value);
    }
    if (fromCategory.present) {
      map['from_category'] = Variable<String>(fromCategory.value);
    }
    if (toCategory.present) {
      map['to_category'] = Variable<String>(toCategory.value);
    }
    if (textSample.present) {
      map['text_sample'] = Variable<String>(textSample.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryCorrectionsCompanion(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('fromCategory: $fromCategory, ')
          ..write('toCategory: $toCategory, ')
          ..write('textSample: $textSample, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MakeQueueTable extends MakeQueue with TableInfo<$MakeQueueTable, QueuedMakeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MakeQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _shotIdMeta = const VerificationMeta('shotId');
  @override
  late final GeneratedColumn<String> shotId = GeneratedColumn<String>(
    'shot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES shots (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _outputMeta = const VerificationMeta('output');
  @override
  late final GeneratedColumn<String> output = GeneratedColumn<String>('output', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, shotId, output, attempts, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'make_queue';
  @override
  VerificationContext validateIntegrity(Insertable<QueuedMakeRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shot_id')) {
      context.handle(_shotIdMeta, shotId.isAcceptableOrUnknown(data['shot_id']!, _shotIdMeta));
    } else if (isInserting) {
      context.missing(_shotIdMeta);
    }
    if (data.containsKey('output')) {
      context.handle(_outputMeta, output.isAcceptableOrUnknown(data['output']!, _outputMeta));
    } else if (isInserting) {
      context.missing(_outputMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta, attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuedMakeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuedMakeRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      shotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}shot_id'])!,
      output: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}output'])!,
      attempts: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MakeQueueTable createAlias(String alias) {
    return $MakeQueueTable(attachedDatabase, alias);
  }
}

class QueuedMakeRow extends DataClass implements Insertable<QueuedMakeRow> {
  final int id;
  final String shotId;
  final String output;
  final int attempts;
  final DateTime createdAt;
  const QueuedMakeRow({required this.id, required this.shotId, required this.output, required this.attempts, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shot_id'] = Variable<String>(shotId);
    map['output'] = Variable<String>(output);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MakeQueueCompanion toCompanion(bool nullToAbsent) {
    return MakeQueueCompanion(id: Value(id), shotId: Value(shotId), output: Value(output), attempts: Value(attempts), createdAt: Value(createdAt));
  }

  factory QueuedMakeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueuedMakeRow(
      id: serializer.fromJson<int>(json['id']),
      shotId: serializer.fromJson<String>(json['shotId']),
      output: serializer.fromJson<String>(json['output']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shotId': serializer.toJson<String>(shotId),
      'output': serializer.toJson<String>(output),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  QueuedMakeRow copyWith({int? id, String? shotId, String? output, int? attempts, DateTime? createdAt}) => QueuedMakeRow(
    id: id ?? this.id,
    shotId: shotId ?? this.shotId,
    output: output ?? this.output,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
  );
  QueuedMakeRow copyWithCompanion(MakeQueueCompanion data) {
    return QueuedMakeRow(
      id: data.id.present ? data.id.value : this.id,
      shotId: data.shotId.present ? data.shotId.value : this.shotId,
      output: data.output.present ? data.output.value : this.output,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueuedMakeRow(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('output: $output, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shotId, output, attempts, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueuedMakeRow &&
          other.id == this.id &&
          other.shotId == this.shotId &&
          other.output == this.output &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt);
}

class MakeQueueCompanion extends UpdateCompanion<QueuedMakeRow> {
  final Value<int> id;
  final Value<String> shotId;
  final Value<String> output;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  const MakeQueueCompanion({
    this.id = const Value.absent(),
    this.shotId = const Value.absent(),
    this.output = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MakeQueueCompanion.insert({
    this.id = const Value.absent(),
    required String shotId,
    required String output,
    this.attempts = const Value.absent(),
    required DateTime createdAt,
  }) : shotId = Value(shotId),
       output = Value(output),
       createdAt = Value(createdAt);
  static Insertable<QueuedMakeRow> custom({
    Expression<int>? id,
    Expression<String>? shotId,
    Expression<String>? output,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shotId != null) 'shot_id': shotId,
      if (output != null) 'output': output,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MakeQueueCompanion copyWith({Value<int>? id, Value<String>? shotId, Value<String>? output, Value<int>? attempts, Value<DateTime>? createdAt}) {
    return MakeQueueCompanion(
      id: id ?? this.id,
      shotId: shotId ?? this.shotId,
      output: output ?? this.output,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shotId.present) {
      map['shot_id'] = Variable<String>(shotId.value);
    }
    if (output.present) {
      map['output'] = Variable<String>(output.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MakeQueueCompanion(')
          ..write('id: $id, ')
          ..write('shotId: $shotId, ')
          ..write('output: $output, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShotsTable shots = $ShotsTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final $CategoryCorrectionsTable categoryCorrections = $CategoryCorrectionsTable(this);
  late final $MakeQueueTable makeQueue = $MakeQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [shots, drafts, categoryCorrections, makeQueue];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('shots', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('drafts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('shots', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('make_queue', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ShotsTableCreateCompanionBuilder = ShotsCompanion Function({
  required String id,
  required DateTime createdAt,
  required String source,
  Value<String?> imagePath,
  Value<String?> imageHash,
  Value<String> extractedText,
  Value<String?> link,
  Value<String> category,
  Value<bool> categoryCorrected,
  Value<String> title,
  Value<String> gist,
  Value<String> suggestedOutput,
  Value<bool> expires,
  Value<String?> note,
  Value<String?> about,
  Value<bool> lowText,
  Value<bool> sensitive,
  Value<String> status,
  Value<DateTime?> madeAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$ShotsTableUpdateCompanionBuilder = ShotsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> source,
  Value<String?> imagePath,
  Value<String?> imageHash,
  Value<String> extractedText,
  Value<String?> link,
  Value<String> category,
  Value<bool> categoryCorrected,
  Value<String> title,
  Value<String> gist,
  Value<String> suggestedOutput,
  Value<bool> expires,
  Value<String?> note,
  Value<String?> about,
  Value<bool> lowText,
  Value<bool> sensitive,
  Value<String> status,
  Value<DateTime?> madeAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$ShotsTableReferences extends BaseReferences<_$AppDatabase, $ShotsTable, ShotRow> {
  $$ShotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DraftsTable, List<DraftRow>> _draftsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.drafts, aliasName: 'shots__id__drafts__shot_id');

  $$DraftsTableProcessedTableManager get draftsRefs {
    final manager = $$DraftsTableTableManager($_db, $_db.drafts).filter((f) => f.shotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_draftsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MakeQueueTable, List<QueuedMakeRow>> _makeQueueRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.makeQueue, aliasName: 'shots__id__make_queue__shot_id');

  $$MakeQueueTableProcessedTableManager get makeQueueRefs {
    final manager = $$MakeQueueTableTableManager($_db, $_db.makeQueue).filter((f) => f.shotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_makeQueueRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ShotsTableFilterComposer extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageHash => $composableBuilder(column: $table.imageHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extractedText => $composableBuilder(column: $table.extractedText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get link => $composableBuilder(column: $table.link, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get categoryCorrected => $composableBuilder(column: $table.categoryCorrected, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gist => $composableBuilder(column: $table.gist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedOutput => $composableBuilder(column: $table.suggestedOutput, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get expires => $composableBuilder(column: $table.expires, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get about => $composableBuilder(column: $table.about, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get lowText => $composableBuilder(column: $table.lowText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sensitive => $composableBuilder(column: $table.sensitive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get madeAt => $composableBuilder(column: $table.madeAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> draftsRefs(Expression<bool> Function($$DraftsTableFilterComposer f) f) {
    final $$DraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drafts,
      getReferencedColumn: (t) => t.shotId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$DraftsTableFilterComposer(
        $db: $db,
        $table: $db.drafts,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<bool> makeQueueRefs(Expression<bool> Function($$MakeQueueTableFilterComposer f) f) {
    final $$MakeQueueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.makeQueue,
      getReferencedColumn: (t) => t.shotId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$MakeQueueTableFilterComposer(
        $db: $db,
        $table: $db.makeQueue,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$ShotsTableOrderingComposer extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageHash => $composableBuilder(column: $table.imageHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extractedText => $composableBuilder(column: $table.extractedText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get link => $composableBuilder(column: $table.link, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get categoryCorrected => $composableBuilder(column: $table.categoryCorrected, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gist => $composableBuilder(column: $table.gist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedOutput => $composableBuilder(column: $table.suggestedOutput, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get expires => $composableBuilder(column: $table.expires, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get about => $composableBuilder(column: $table.about, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get lowText => $composableBuilder(column: $table.lowText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sensitive => $composableBuilder(column: $table.sensitive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get madeAt => $composableBuilder(column: $table.madeAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(column: $table.archivedAt, builder: (column) => ColumnOrderings(column));
}

class $$ShotsTableAnnotationComposer extends Composer<_$AppDatabase, $ShotsTable> {
  $$ShotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get source => $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get imagePath => $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get imageHash => $composableBuilder(column: $table.imageHash, builder: (column) => column);

  GeneratedColumn<String> get extractedText => $composableBuilder(column: $table.extractedText, builder: (column) => column);

  GeneratedColumn<String> get link => $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get category => $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get categoryCorrected => $composableBuilder(column: $table.categoryCorrected, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get gist => $composableBuilder(column: $table.gist, builder: (column) => column);

  GeneratedColumn<String> get suggestedOutput => $composableBuilder(column: $table.suggestedOutput, builder: (column) => column);

  GeneratedColumn<bool> get expires => $composableBuilder(column: $table.expires, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get about => $composableBuilder(column: $table.about, builder: (column) => column);

  GeneratedColumn<bool> get lowText => $composableBuilder(column: $table.lowText, builder: (column) => column);

  GeneratedColumn<bool> get sensitive => $composableBuilder(column: $table.sensitive, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get madeAt => $composableBuilder(column: $table.madeAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(column: $table.archivedAt, builder: (column) => column);

  Expression<T> draftsRefs<T extends Object>(Expression<T> Function($$DraftsTableAnnotationComposer a) f) {
    final $$DraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.drafts,
      getReferencedColumn: (t) => t.shotId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$DraftsTableAnnotationComposer(
        $db: $db,
        $table: $db.drafts,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }

  Expression<T> makeQueueRefs<T extends Object>(Expression<T> Function($$MakeQueueTableAnnotationComposer a) f) {
    final $$MakeQueueTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.makeQueue,
      getReferencedColumn: (t) => t.shotId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$MakeQueueTableAnnotationComposer(
        $db: $db,
        $table: $db.makeQueue,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$ShotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShotsTable,
          ShotRow,
          $$ShotsTableFilterComposer,
          $$ShotsTableOrderingComposer,
          $$ShotsTableAnnotationComposer,
          $$ShotsTableCreateCompanionBuilder,
          $$ShotsTableUpdateCompanionBuilder,
          (ShotRow, $$ShotsTableReferences),
          ShotRow,
          PrefetchHooks Function({bool draftsRefs, bool makeQueueRefs})
        > {
  $$ShotsTableTableManager(_$AppDatabase db, $ShotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ShotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ShotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ShotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> imageHash = const Value.absent(),
                Value<String> extractedText = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> categoryCorrected = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> gist = const Value.absent(),
                Value<String> suggestedOutput = const Value.absent(),
                Value<bool> expires = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> about = const Value.absent(),
                Value<bool> lowText = const Value.absent(),
                Value<bool> sensitive = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> madeAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShotsCompanion(
                id: id,
                createdAt: createdAt,
                source: source,
                imagePath: imagePath,
                imageHash: imageHash,
                extractedText: extractedText,
                link: link,
                category: category,
                categoryCorrected: categoryCorrected,
                title: title,
                gist: gist,
                suggestedOutput: suggestedOutput,
                expires: expires,
                note: note,
                about: about,
                lowText: lowText,
                sensitive: sensitive,
                status: status,
                madeAt: madeAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String source,
                Value<String?> imagePath = const Value.absent(),
                Value<String?> imageHash = const Value.absent(),
                Value<String> extractedText = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> categoryCorrected = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> gist = const Value.absent(),
                Value<String> suggestedOutput = const Value.absent(),
                Value<bool> expires = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> about = const Value.absent(),
                Value<bool> lowText = const Value.absent(),
                Value<bool> sensitive = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> madeAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShotsCompanion.insert(
                id: id,
                createdAt: createdAt,
                source: source,
                imagePath: imagePath,
                imageHash: imageHash,
                extractedText: extractedText,
                link: link,
                category: category,
                categoryCorrected: categoryCorrected,
                title: title,
                gist: gist,
                suggestedOutput: suggestedOutput,
                expires: expires,
                note: note,
                about: about,
                lowText: lowText,
                sensitive: sensitive,
                status: status,
                madeAt: madeAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$ShotsTable, ShotRow>(table), $$ShotsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({draftsRefs = false, makeQueueRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (draftsRefs) db.drafts, if (makeQueueRefs) db.makeQueue],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (draftsRefs)
                    await $_getPrefetchedData<ShotRow, $ShotsTable, DraftRow>(
                      currentTable: table,
                      referencedTable: $$ShotsTableReferences._draftsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ShotsTableReferences(db, table, p0).draftsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where((e) => e.shotId == item.id),
                      typedResults: items,
                    ),
                  if (makeQueueRefs)
                    await $_getPrefetchedData<ShotRow, $ShotsTable, QueuedMakeRow>(
                      currentTable: table,
                      referencedTable: $$ShotsTableReferences._makeQueueRefsTable(db),
                      managerFromTypedResult: (p0) => $$ShotsTableReferences(db, table, p0).makeQueueRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where((e) => e.shotId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShotsTable,
      ShotRow,
      $$ShotsTableFilterComposer,
      $$ShotsTableOrderingComposer,
      $$ShotsTableAnnotationComposer,
      $$ShotsTableCreateCompanionBuilder,
      $$ShotsTableUpdateCompanionBuilder,
      (ShotRow, $$ShotsTableReferences),
      ShotRow,
      PrefetchHooks Function({bool draftsRefs, bool makeQueueRefs})
    >;
typedef $$DraftsTableCreateCompanionBuilder = DraftsCompanion Function({
  required String id,
  required String shotId,
  required String output,
  required String body,
  Value<String?> serverId,
  Value<int> regenerationsUsed,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DraftsTableUpdateCompanionBuilder = DraftsCompanion Function({
  Value<String> id,
  Value<String> shotId,
  Value<String> output,
  Value<String> body,
  Value<String?> serverId,
  Value<int> regenerationsUsed,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$DraftsTableReferences extends BaseReferences<_$AppDatabase, $DraftsTable, DraftRow> {
  $$DraftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShotsTable _shotIdTable(_$AppDatabase db) => db.shots.createAlias('drafts__shot_id__shots__id');

  $$ShotsTableProcessedTableManager get shotId {
    final $_column = $_itemColumn<String>('shot_id')!;

    final manager = $$ShotsTableTableManager($_db, $_db.shots).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DraftsTableFilterComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get output => $composableBuilder(column: $table.output, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get regenerationsUsed => $composableBuilder(column: $table.regenerationsUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ShotsTableFilterComposer get shotId {
    final $$ShotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shotId,
      referencedTable: $db.shots,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ShotsTableFilterComposer(
        $db: $db,
        $table: $db.shots,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$DraftsTableOrderingComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get output => $composableBuilder(column: $table.output, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get regenerationsUsed => $composableBuilder(column: $table.regenerationsUsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ShotsTableOrderingComposer get shotId {
    final $$ShotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shotId,
      referencedTable: $db.shots,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ShotsTableOrderingComposer(
        $db: $db,
        $table: $db.shots,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$DraftsTableAnnotationComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get output => $composableBuilder(column: $table.output, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get serverId => $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get regenerationsUsed => $composableBuilder(column: $table.regenerationsUsed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ShotsTableAnnotationComposer get shotId {
    final $$ShotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shotId,
      referencedTable: $db.shots,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ShotsTableAnnotationComposer(
        $db: $db,
        $table: $db.shots,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftsTable,
          DraftRow,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (DraftRow, $$DraftsTableReferences),
          DraftRow,
          PrefetchHooks Function({bool shotId})
        > {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shotId = const Value.absent(),
                Value<String> output = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> regenerationsUsed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion(
                id: id,
                shotId: shotId,
                output: output,
                body: body,
                serverId: serverId,
                regenerationsUsed: regenerationsUsed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shotId,
                required String output,
                required String body,
                Value<String?> serverId = const Value.absent(),
                Value<int> regenerationsUsed = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion.insert(
                id: id,
                shotId: shotId,
                output: output,
                body: body,
                serverId: serverId,
                regenerationsUsed: regenerationsUsed,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$DraftsTable, DraftRow>(table), $$DraftsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({shotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (shotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.shotId,
                        referencedTable: $$DraftsTableReferences._shotIdTable(db),
                        referencedColumn: $$DraftsTableReferences._shotIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftsTable,
      DraftRow,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (DraftRow, $$DraftsTableReferences),
      DraftRow,
      PrefetchHooks Function({bool shotId})
    >;
typedef $$CategoryCorrectionsTableCreateCompanionBuilder = CategoryCorrectionsCompanion Function({
  Value<int> id,
  required String shotId,
  required String fromCategory,
  required String toCategory,
  required String textSample,
  required DateTime createdAt,
});
typedef $$CategoryCorrectionsTableUpdateCompanionBuilder = CategoryCorrectionsCompanion Function({
  Value<int> id,
  Value<String> shotId,
  Value<String> fromCategory,
  Value<String> toCategory,
  Value<String> textSample,
  Value<DateTime> createdAt,
});

class $$CategoryCorrectionsTableFilterComposer extends Composer<_$AppDatabase, $CategoryCorrectionsTable> {
  $$CategoryCorrectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shotId => $composableBuilder(column: $table.shotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromCategory => $composableBuilder(column: $table.fromCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toCategory => $composableBuilder(column: $table.toCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textSample => $composableBuilder(column: $table.textSample, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CategoryCorrectionsTableOrderingComposer extends Composer<_$AppDatabase, $CategoryCorrectionsTable> {
  $$CategoryCorrectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shotId => $composableBuilder(column: $table.shotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromCategory => $composableBuilder(column: $table.fromCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toCategory => $composableBuilder(column: $table.toCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textSample => $composableBuilder(column: $table.textSample, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoryCorrectionsTableAnnotationComposer extends Composer<_$AppDatabase, $CategoryCorrectionsTable> {
  $$CategoryCorrectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shotId => $composableBuilder(column: $table.shotId, builder: (column) => column);

  GeneratedColumn<String> get fromCategory => $composableBuilder(column: $table.fromCategory, builder: (column) => column);

  GeneratedColumn<String> get toCategory => $composableBuilder(column: $table.toCategory, builder: (column) => column);

  GeneratedColumn<String> get textSample => $composableBuilder(column: $table.textSample, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoryCorrectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryCorrectionsTable,
          CorrectionRow,
          $$CategoryCorrectionsTableFilterComposer,
          $$CategoryCorrectionsTableOrderingComposer,
          $$CategoryCorrectionsTableAnnotationComposer,
          $$CategoryCorrectionsTableCreateCompanionBuilder,
          $$CategoryCorrectionsTableUpdateCompanionBuilder,
          (CorrectionRow, BaseReferences<_$AppDatabase, $CategoryCorrectionsTable, CorrectionRow>),
          CorrectionRow,
          PrefetchHooks Function()
        > {
  $$CategoryCorrectionsTableTableManager(_$AppDatabase db, $CategoryCorrectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CategoryCorrectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CategoryCorrectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CategoryCorrectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> shotId = const Value.absent(),
                Value<String> fromCategory = const Value.absent(),
                Value<String> toCategory = const Value.absent(),
                Value<String> textSample = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoryCorrectionsCompanion(
                id: id,
                shotId: shotId,
                fromCategory: fromCategory,
                toCategory: toCategory,
                textSample: textSample,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String shotId,
                required String fromCategory,
                required String toCategory,
                required String textSample,
                required DateTime createdAt,
              }) => CategoryCorrectionsCompanion.insert(
                id: id,
                shotId: shotId,
                fromCategory: fromCategory,
                toCategory: toCategory,
                textSample: textSample,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryCorrectionsTable, CorrectionRow>(table),
                  BaseReferences<_$AppDatabase, $CategoryCorrectionsTable, CorrectionRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryCorrectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryCorrectionsTable,
      CorrectionRow,
      $$CategoryCorrectionsTableFilterComposer,
      $$CategoryCorrectionsTableOrderingComposer,
      $$CategoryCorrectionsTableAnnotationComposer,
      $$CategoryCorrectionsTableCreateCompanionBuilder,
      $$CategoryCorrectionsTableUpdateCompanionBuilder,
      (CorrectionRow, BaseReferences<_$AppDatabase, $CategoryCorrectionsTable, CorrectionRow>),
      CorrectionRow,
      PrefetchHooks Function()
    >;
typedef $$MakeQueueTableCreateCompanionBuilder = MakeQueueCompanion Function({
  Value<int> id,
  required String shotId,
  required String output,
  Value<int> attempts,
  required DateTime createdAt,
});
typedef $$MakeQueueTableUpdateCompanionBuilder = MakeQueueCompanion Function({
  Value<int> id,
  Value<String> shotId,
  Value<String> output,
  Value<int> attempts,
  Value<DateTime> createdAt,
});

final class $$MakeQueueTableReferences extends BaseReferences<_$AppDatabase, $MakeQueueTable, QueuedMakeRow> {
  $$MakeQueueTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShotsTable _shotIdTable(_$AppDatabase db) => db.shots.createAlias('make_queue__shot_id__shots__id');

  $$ShotsTableProcessedTableManager get shotId {
    final $_column = $_itemColumn<String>('shot_id')!;

    final manager = $$ShotsTableTableManager($_db, $_db.shots).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MakeQueueTableFilterComposer extends Composer<_$AppDatabase, $MakeQueueTable> {
  $$MakeQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get output => $composableBuilder(column: $table.output, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ShotsTableFilterComposer get shotId {
    final $$ShotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shotId,
      referencedTable: $db.shots,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ShotsTableFilterComposer(
        $db: $db,
        $table: $db.shots,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$MakeQueueTableOrderingComposer extends Composer<_$AppDatabase, $MakeQueueTable> {
  $$MakeQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get output => $composableBuilder(column: $table.output, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ShotsTableOrderingComposer get shotId {
    final $$ShotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shotId,
      referencedTable: $db.shots,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ShotsTableOrderingComposer(
        $db: $db,
        $table: $db.shots,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$MakeQueueTableAnnotationComposer extends Composer<_$AppDatabase, $MakeQueueTable> {
  $$MakeQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get output => $composableBuilder(column: $table.output, builder: (column) => column);

  GeneratedColumn<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShotsTableAnnotationComposer get shotId {
    final $$ShotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shotId,
      referencedTable: $db.shots,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$ShotsTableAnnotationComposer(
        $db: $db,
        $table: $db.shots,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$MakeQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MakeQueueTable,
          QueuedMakeRow,
          $$MakeQueueTableFilterComposer,
          $$MakeQueueTableOrderingComposer,
          $$MakeQueueTableAnnotationComposer,
          $$MakeQueueTableCreateCompanionBuilder,
          $$MakeQueueTableUpdateCompanionBuilder,
          (QueuedMakeRow, $$MakeQueueTableReferences),
          QueuedMakeRow,
          PrefetchHooks Function({bool shotId})
        > {
  $$MakeQueueTableTableManager(_$AppDatabase db, $MakeQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MakeQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MakeQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MakeQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> shotId = const Value.absent(),
            Value<String> output = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) => MakeQueueCompanion(id: id, shotId: shotId, output: output, attempts: attempts, createdAt: createdAt),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String shotId,
            required String output,
            Value<int> attempts = const Value.absent(),
            required DateTime createdAt,
          }) => MakeQueueCompanion.insert(id: id, shotId: shotId, output: output, attempts: attempts, createdAt: createdAt),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable<$MakeQueueTable, QueuedMakeRow>(table), $$MakeQueueTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({shotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                    if (shotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.shotId,
                        referencedTable: $$MakeQueueTableReferences._shotIdTable(db),
                        referencedColumn: $$MakeQueueTableReferences._shotIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MakeQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MakeQueueTable,
      QueuedMakeRow,
      $$MakeQueueTableFilterComposer,
      $$MakeQueueTableOrderingComposer,
      $$MakeQueueTableAnnotationComposer,
      $$MakeQueueTableCreateCompanionBuilder,
      $$MakeQueueTableUpdateCompanionBuilder,
      (QueuedMakeRow, $$MakeQueueTableReferences),
      QueuedMakeRow,
      PrefetchHooks Function({bool shotId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShotsTableTableManager get shots => $$ShotsTableTableManager(_db, _db.shots);
  $$DraftsTableTableManager get drafts => $$DraftsTableTableManager(_db, _db.drafts);
  $$CategoryCorrectionsTableTableManager get categoryCorrections => $$CategoryCorrectionsTableTableManager(_db, _db.categoryCorrections);
  $$MakeQueueTableTableManager get makeQueue => $$MakeQueueTableTableManager(_db, _db.makeQueue);
}
