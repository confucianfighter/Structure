// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'src/data_types/object_box_types/category.dart';
import 'src/data_types/object_box_types/countdown.dart';
import 'src/data_types/object_box_types/flash_card.dart';
import 'src/data_types/object_box_types/flash_card_sequence.dart';
import 'src/data_types/object_box_types/sequence_item.dart';
import 'src/data_types/object_box_types/subject.dart';
import 'src/data_types/object_box_types/writing_prompt.dart';
import 'src/data_types/object_box_types/writing_prompt_answer.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 146195575595869195),
      name: 'Countdown',
      lastPropertyId: const obx_int.IdUid(2, 4543042334429189001),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5203136631529040311),
            name: 'id',
            type: 6,
            flags: 129),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 4543042334429189001),
            name: 'remainingSeconds',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 4562760401703630193),
      name: 'WritingPrompt',
      lastPropertyId: const obx_int.IdUid(9, 5420318153679335413),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 7069261292951093926),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 7821508857526449903),
            name: 'prompt',
            type: 9,
            flags: 2080,
            indexId: const obx_int.IdUid(4, 2350582702432164612)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 4192646412743095980),
            name: 'lastTimeAnswered',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 3903436709462758320),
            name: 'lastEdited',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 5420318153679335413),
            name: 'categoryId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(5, 8106221824084237315),
            relationTarget: 'Category')
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[
        obx_int.ModelBacklink(
            name: 'answers',
            srcEntity: 'WritingPromptAnswer',
            srcField: 'writingPrompt')
      ]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(3, 8016132364118866485),
      name: 'WritingPromptAnswer',
      lastPropertyId: const obx_int.IdUid(4, 3456486402785270961),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 3949528071363160509),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 6631672326208742983),
            name: 'answer',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 1855726055833227939),
            name: 'dateAnswered',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 3456486402785270961),
            name: 'writingPromptId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(1, 868981703487449150),
            relationTarget: 'WritingPrompt')
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(4, 8031683048514304163),
      name: 'Category',
      lastPropertyId: const obx_int.IdUid(2, 5294113057338185632),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5502069285358560879),
            name: 'id',
            type: 6,
            flags: 129),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 5294113057338185632),
            name: 'name',
            type: 9,
            flags: 2080,
            indexId: const obx_int.IdUid(2, 8807564465112648040))
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(5, 5068284084408045983),
      name: 'Sequence',
      lastPropertyId: const obx_int.IdUid(3, 9148759602975562326),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 1453121725179244857),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 4205037057387307521),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 9148759602975562326),
            name: 'description',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[
        obx_int.ModelBacklink(
            name: 'slots', srcEntity: 'SequenceItem', srcField: '')
      ]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(7, 2020180581908519582),
      name: 'FlashCard',
      lastPropertyId: const obx_int.IdUid(7, 3832174913847307587),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 4749978696193239874),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 3784553455054995023),
            name: 'question',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 4483919900487948709),
            name: 'answer',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 3274326393137651722),
            name: 'timesCorrect',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 3917552731831000198),
            name: 'timesIncorrect',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 1924135883995477663),
            name: 'userRating',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 3832174913847307587),
            name: 'subjectId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(10, 6888978690879247321),
            relationTarget: 'Subject')
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(8, 3684946452892985486),
      name: 'SequenceItem',
      lastPropertyId: const obx_int.IdUid(7, 646008176532535316),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5632928414777226730),
            name: 'id',
            type: 6,
            flags: 129),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 7014212585881900785),
            name: 'index',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 6169072553113434335),
            name: 'entityId',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 7821170781216320390),
            name: 'sequenceId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(8, 1652350237717642594),
            relationTarget: 'Sequence'),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 646008176532535316),
            name: 'type',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(9, 3518682031366318632),
      name: 'Subject',
      lastPropertyId: const obx_int.IdUid(4, 6046915051004450969),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 6149063534090813934),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1290040545491520401),
            name: 'name',
            type: 9,
            flags: 2080,
            indexId: const obx_int.IdUid(9, 2249157558307694662)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 2141324371269352130),
            name: 'description',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 6046915051004450969),
            name: 'color',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(10, 4887035928040764209),
      name: 'FlashCardSequence',
      lastPropertyId: const obx_int.IdUid(5, 2351647733983166443),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5233234839710568956),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1964265748702605284),
            name: 'number_of_cards',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 2351647733983166443),
            name: 'subjectId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(11, 1402608994932849385),
            relationTarget: 'Subject')
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(10, 4887035928040764209),
      lastIndexId: const obx_int.IdUid(11, 1402608994932849385),
      lastRelationId: const obx_int.IdUid(1, 2382961371279645997),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [4113595854453584037],
      retiredIndexUids: const [2601898366546795901, 1127005364175938284],
      retiredPropertyUids: const [
        4490942566436496262,
        1643685379610388084,
        1576598753525470887,
        6675773488354720603,
        5633534938073970032,
        6329965284889014362,
        7240077867940477600,
        8364044782680838125,
        4011602275894529467,
        5824347107063604006,
        1356691746063744145,
        7496608828734208995,
        3027987310927362070,
        1084116758278597434
      ],
      retiredRelationUids: const [2382961371279645997],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    Countdown: obx_int.EntityDefinition<Countdown>(
        model: _entities[0],
        toOneRelations: (Countdown object) => [],
        toManyRelations: (Countdown object) => {},
        getId: (Countdown object) => object.id,
        setId: (Countdown object, int id) {
          object.id = id;
        },
        objectToFB: (Countdown object, fb.Builder fbb) {
          fbb.startTable(3);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.remainingSeconds);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final remainingSecondsParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final object =
              Countdown(id: idParam, remainingSeconds: remainingSecondsParam);

          return object;
        }),
    WritingPrompt: obx_int.EntityDefinition<WritingPrompt>(
        model: _entities[1],
        toOneRelations: (WritingPrompt object) => [object.category],
        toManyRelations: (WritingPrompt object) => {
              obx_int.RelInfo<WritingPromptAnswer>.toOneBacklink(
                  4,
                  object.id,
                  (WritingPromptAnswer srcObject) =>
                      srcObject.writingPrompt): object.answers
            },
        getId: (WritingPrompt object) => object.id,
        setId: (WritingPrompt object, int id) {
          object.id = id;
        },
        objectToFB: (WritingPrompt object, fb.Builder fbb) {
          final promptOffset = fbb.writeString(object.prompt);
          fbb.startTable(10);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, promptOffset);
          fbb.addInt64(3, object.lastTimeAnswered?.millisecondsSinceEpoch);
          fbb.addInt64(5, object.lastEdited.millisecondsSinceEpoch);
          fbb.addInt64(8, object.category.targetId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final lastTimeAnsweredValue =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 10);
          final promptParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final lastEditedParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0));
          final lastTimeAnsweredParam = lastTimeAnsweredValue == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(lastTimeAnsweredValue);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final object = WritingPrompt(
              prompt: promptParam,
              lastEdited: lastEditedParam,
              lastTimeAnswered: lastTimeAnsweredParam,
              id: idParam);
          object.category.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 20, 0);
          object.category.attach(store);
          obx_int.InternalToManyAccess.setRelInfo<WritingPrompt>(
              object.answers,
              store,
              obx_int.RelInfo<WritingPromptAnswer>.toOneBacklink(4, object.id,
                  (WritingPromptAnswer srcObject) => srcObject.writingPrompt));
          return object;
        }),
    WritingPromptAnswer: obx_int.EntityDefinition<WritingPromptAnswer>(
        model: _entities[2],
        toOneRelations: (WritingPromptAnswer object) => [object.writingPrompt],
        toManyRelations: (WritingPromptAnswer object) => {},
        getId: (WritingPromptAnswer object) => object.id,
        setId: (WritingPromptAnswer object, int id) {
          object.id = id;
        },
        objectToFB: (WritingPromptAnswer object, fb.Builder fbb) {
          final answerOffset = fbb.writeString(object.answer);
          fbb.startTable(5);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, answerOffset);
          fbb.addInt64(2, object.dateAnswered.millisecondsSinceEpoch);
          fbb.addInt64(3, object.writingPrompt.targetId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final answerParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final dateAnsweredParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0));
          final object = WritingPromptAnswer(
              answer: answerParam, dateAnswered: dateAnsweredParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          object.writingPrompt.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0);
          object.writingPrompt.attach(store);
          return object;
        }),
    Category: obx_int.EntityDefinition<Category>(
        model: _entities[3],
        toOneRelations: (Category object) => [],
        toManyRelations: (Category object) => {},
        getId: (Category object) => object.id,
        setId: (Category object, int id) {
          object.id = id;
        },
        objectToFB: (Category object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          fbb.startTable(3);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final object = Category(id: idParam, name: nameParam);

          return object;
        }),
    Sequence: obx_int.EntityDefinition<Sequence>(
        model: _entities[4],
        toOneRelations: (Sequence object) => [],
        toManyRelations: (Sequence object) => {
              obx_int.RelInfo<SequenceItem>.toOneBacklink(6, object.id,
                  (SequenceItem srcObject) => srcObject.sequence): object.slots
            },
        getId: (Sequence object) => object.id,
        setId: (Sequence object, int id) {
          object.id = id;
        },
        objectToFB: (Sequence object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          final descriptionOffset = fbb.writeString(object.description);
          fbb.startTable(4);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addOffset(2, descriptionOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final descriptionParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, '');
          final object = Sequence(
              id: idParam, name: nameParam, description: descriptionParam);
          obx_int.InternalToManyAccess.setRelInfo<Sequence>(
              object.slots,
              store,
              obx_int.RelInfo<SequenceItem>.toOneBacklink(6, object.id,
                  (SequenceItem srcObject) => srcObject.sequence));
          return object;
        }),
    FlashCard: obx_int.EntityDefinition<FlashCard>(
        model: _entities[5],
        toOneRelations: (FlashCard object) => [object.subject],
        toManyRelations: (FlashCard object) => {},
        getId: (FlashCard object) => object.id,
        setId: (FlashCard object, int id) {
          object.id = id;
        },
        objectToFB: (FlashCard object, fb.Builder fbb) {
          final questionOffset = fbb.writeString(object.question);
          final answerOffset = fbb.writeString(object.answer);
          fbb.startTable(8);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, questionOffset);
          fbb.addOffset(2, answerOffset);
          fbb.addInt64(3, object.timesCorrect);
          fbb.addInt64(4, object.timesIncorrect);
          fbb.addInt64(5, object.userRating);
          fbb.addInt64(6, object.subject.targetId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final questionParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final answerParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final object = FlashCard(
              id: idParam, question: questionParam, answer: answerParam)
            ..timesCorrect =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0)
            ..timesIncorrect =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0)
            ..userRating =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0);
          object.subject.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0);
          object.subject.attach(store);
          return object;
        }),
    SequenceItem: obx_int.EntityDefinition<SequenceItem>(
        model: _entities[6],
        toOneRelations: (SequenceItem object) => [object.sequence],
        toManyRelations: (SequenceItem object) => {},
        getId: (SequenceItem object) => object.id,
        setId: (SequenceItem object, int id) {
          object.id = id;
        },
        objectToFB: (SequenceItem object, fb.Builder fbb) {
          final typeOffset = fbb.writeString(object.type);
          fbb.startTable(8);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.index);
          fbb.addInt64(4, object.entityId);
          fbb.addInt64(5, object.sequence.targetId);
          fbb.addOffset(6, typeOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final indexParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final typeParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 16, '');
          final entityIdParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0);
          final sequenceParam = obx.ToOne<Sequence>(
              targetId:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0));
          final object = SequenceItem(
              id: idParam,
              index: indexParam,
              type: typeParam,
              entityId: entityIdParam,
              sequence: sequenceParam);
          object.sequence.attach(store);
          return object;
        }),
    Subject: obx_int.EntityDefinition<Subject>(
        model: _entities[7],
        toOneRelations: (Subject object) => [],
        toManyRelations: (Subject object) => {},
        getId: (Subject object) => object.id,
        setId: (Subject object, int id) {
          object.id = id;
        },
        objectToFB: (Subject object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          final descriptionOffset = fbb.writeString(object.description);
          final colorOffset = fbb.writeString(object.color);
          fbb.startTable(5);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addOffset(2, descriptionOffset);
          fbb.addOffset(3, colorOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final descriptionParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, '');
          final colorParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final object = Subject(
              id: idParam,
              name: nameParam,
              description: descriptionParam,
              color: colorParam);

          return object;
        }),
    FlashCardSequence: obx_int.EntityDefinition<FlashCardSequence>(
        model: _entities[8],
        toOneRelations: (FlashCardSequence object) => [object.subject],
        toManyRelations: (FlashCardSequence object) => {},
        getId: (FlashCardSequence object) => object.id,
        setId: (FlashCardSequence object, int id) {
          object.id = id;
        },
        objectToFB: (FlashCardSequence object, fb.Builder fbb) {
          fbb.startTable(6);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.number_of_cards);
          fbb.addInt64(4, object.subject.targetId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final subjectParam = obx.ToOne<Subject>(
              targetId:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0));
          final number_of_cardsParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final object = FlashCardSequence(
              id: idParam,
              subject: subjectParam,
              number_of_cards: number_of_cardsParam);
          object.subject.attach(store);
          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [Countdown] entity fields to define ObjectBox queries.
class Countdown_ {
  /// See [Countdown.id].
  static final id =
      obx.QueryIntegerProperty<Countdown>(_entities[0].properties[0]);

  /// See [Countdown.remainingSeconds].
  static final remainingSeconds =
      obx.QueryIntegerProperty<Countdown>(_entities[0].properties[1]);
}

/// [WritingPrompt] entity fields to define ObjectBox queries.
class WritingPrompt_ {
  /// See [WritingPrompt.id].
  static final id =
      obx.QueryIntegerProperty<WritingPrompt>(_entities[1].properties[0]);

  /// See [WritingPrompt.prompt].
  static final prompt =
      obx.QueryStringProperty<WritingPrompt>(_entities[1].properties[1]);

  /// See [WritingPrompt.lastTimeAnswered].
  static final lastTimeAnswered =
      obx.QueryDateProperty<WritingPrompt>(_entities[1].properties[2]);

  /// See [WritingPrompt.lastEdited].
  static final lastEdited =
      obx.QueryDateProperty<WritingPrompt>(_entities[1].properties[3]);

  /// See [WritingPrompt.category].
  static final category = obx.QueryRelationToOne<WritingPrompt, Category>(
      _entities[1].properties[4]);

  /// see [WritingPrompt.answers]
  static final answers =
      obx.QueryBacklinkToMany<WritingPromptAnswer, WritingPrompt>(
          WritingPromptAnswer_.writingPrompt);
}

/// [WritingPromptAnswer] entity fields to define ObjectBox queries.
class WritingPromptAnswer_ {
  /// See [WritingPromptAnswer.id].
  static final id =
      obx.QueryIntegerProperty<WritingPromptAnswer>(_entities[2].properties[0]);

  /// See [WritingPromptAnswer.answer].
  static final answer =
      obx.QueryStringProperty<WritingPromptAnswer>(_entities[2].properties[1]);

  /// See [WritingPromptAnswer.dateAnswered].
  static final dateAnswered =
      obx.QueryDateProperty<WritingPromptAnswer>(_entities[2].properties[2]);

  /// See [WritingPromptAnswer.writingPrompt].
  static final writingPrompt =
      obx.QueryRelationToOne<WritingPromptAnswer, WritingPrompt>(
          _entities[2].properties[3]);
}

/// [Category] entity fields to define ObjectBox queries.
class Category_ {
  /// See [Category.id].
  static final id =
      obx.QueryIntegerProperty<Category>(_entities[3].properties[0]);

  /// See [Category.name].
  static final name =
      obx.QueryStringProperty<Category>(_entities[3].properties[1]);
}

/// [Sequence] entity fields to define ObjectBox queries.
class Sequence_ {
  /// See [Sequence.id].
  static final id =
      obx.QueryIntegerProperty<Sequence>(_entities[4].properties[0]);

  /// See [Sequence.name].
  static final name =
      obx.QueryStringProperty<Sequence>(_entities[4].properties[1]);

  /// See [Sequence.description].
  static final description =
      obx.QueryStringProperty<Sequence>(_entities[4].properties[2]);

  /// see [Sequence.slots]
  static final slots =
      obx.QueryBacklinkToMany<SequenceItem, Sequence>(SequenceItem_.sequence);
}

/// [FlashCard] entity fields to define ObjectBox queries.
class FlashCard_ {
  /// See [FlashCard.id].
  static final id =
      obx.QueryIntegerProperty<FlashCard>(_entities[5].properties[0]);

  /// See [FlashCard.question].
  static final question =
      obx.QueryStringProperty<FlashCard>(_entities[5].properties[1]);

  /// See [FlashCard.answer].
  static final answer =
      obx.QueryStringProperty<FlashCard>(_entities[5].properties[2]);

  /// See [FlashCard.timesCorrect].
  static final timesCorrect =
      obx.QueryIntegerProperty<FlashCard>(_entities[5].properties[3]);

  /// See [FlashCard.timesIncorrect].
  static final timesIncorrect =
      obx.QueryIntegerProperty<FlashCard>(_entities[5].properties[4]);

  /// See [FlashCard.userRating].
  static final userRating =
      obx.QueryIntegerProperty<FlashCard>(_entities[5].properties[5]);

  /// See [FlashCard.subject].
  static final subject =
      obx.QueryRelationToOne<FlashCard, Subject>(_entities[5].properties[6]);
}

/// [SequenceItem] entity fields to define ObjectBox queries.
class SequenceItem_ {
  /// See [SequenceItem.id].
  static final id =
      obx.QueryIntegerProperty<SequenceItem>(_entities[6].properties[0]);

  /// See [SequenceItem.index].
  static final index =
      obx.QueryIntegerProperty<SequenceItem>(_entities[6].properties[1]);

  /// See [SequenceItem.entityId].
  static final entityId =
      obx.QueryIntegerProperty<SequenceItem>(_entities[6].properties[2]);

  /// See [SequenceItem.sequence].
  static final sequence = obx.QueryRelationToOne<SequenceItem, Sequence>(
      _entities[6].properties[3]);

  /// See [SequenceItem.type].
  static final type =
      obx.QueryStringProperty<SequenceItem>(_entities[6].properties[4]);
}

/// [Subject] entity fields to define ObjectBox queries.
class Subject_ {
  /// See [Subject.id].
  static final id =
      obx.QueryIntegerProperty<Subject>(_entities[7].properties[0]);

  /// See [Subject.name].
  static final name =
      obx.QueryStringProperty<Subject>(_entities[7].properties[1]);

  /// See [Subject.description].
  static final description =
      obx.QueryStringProperty<Subject>(_entities[7].properties[2]);

  /// See [Subject.color].
  static final color =
      obx.QueryStringProperty<Subject>(_entities[7].properties[3]);
}

/// [FlashCardSequence] entity fields to define ObjectBox queries.
class FlashCardSequence_ {
  /// See [FlashCardSequence.id].
  static final id =
      obx.QueryIntegerProperty<FlashCardSequence>(_entities[8].properties[0]);

  /// See [FlashCardSequence.number_of_cards].
  static final number_of_cards =
      obx.QueryIntegerProperty<FlashCardSequence>(_entities[8].properties[1]);

  /// See [FlashCardSequence.subject].
  static final subject = obx.QueryRelationToOne<FlashCardSequence, Subject>(
      _entities[8].properties[2]);
}
