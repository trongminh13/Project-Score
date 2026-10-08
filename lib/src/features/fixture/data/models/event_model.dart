import '../../../../core/constants/parsers.dart';
import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.teamId,
    required super.playerId,
    required super.order,
    required super.gameTime,
    required super.addedTime,
    required super.gameTimeDisplay,
    required super.gameTimeAndStatusDisplayType,
    required super.type,
    super.extraPlayers,
    super.player,
    super.team,
  });

  factory EventModel.fromApiFootball(Map<String, dynamic> json, int orderIndex) {
    final typeStr = json['type']?.toString().toLowerCase() ?? '';
    final detailStr = json['detail']?.toString().toLowerCase() ?? '';
    
    int typeId = -1;
    String typeName = '';
    
    if (typeStr == 'goal') {
      if (detailStr.contains('missed penalty')) {
        typeId = 6;
        typeName = 'Missed Penalty';
      } else {
        typeId = 1;
        typeName = 'Goal';
      }
    } else if (typeStr == 'card') {
      if (detailStr.contains('yellow')) {
        typeId = 2;
        typeName = 'Yellow Card';
      } else if (detailStr.contains('red')) {
        typeId = 3;
        typeName = 'Red Card';
      }
    } else if (typeStr == 'subst') {
      typeId = 1000;
      typeName = 'Substitute';
    }

    final time = json['time'] ?? {};
    final team = json['team'] ?? {};
    final player = json['player'] ?? {};
    final assist = json['assist'] ?? {};

    return EventModel(
      teamId: team['id'] ?? 0,
      playerId: player['id'] ?? 0,
      order: orderIndex,
      gameTime: time['elapsed'] ?? 0,
      addedTime: time['extra'] ?? 0,
      gameTimeDisplay: "${time['elapsed'] ?? 0}'",
      gameTimeAndStatusDisplayType: 0,
      type: EventTypeModel(
        id: EventId.fromValue(typeId) ?? EventId.none,
        name: typeName,
        subTypeId: -1,
      ),
      extraPlayers: assist['id'] != null ? [assist['id']] : [],
    );
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      teamId: toInt(json['competitorId']) ?? 0,
      playerId: toInt(json['playerId']) ?? 0,
      order: toInt(json['order']) ?? 0,
      gameTime: toInt(json['gameTime']) ?? 0,
      addedTime: toInt(json['addedTime']) ?? 0,
      gameTimeDisplay: json['gameTimeDisplay'] ?? '',
      gameTimeAndStatusDisplayType: json['gameTimeAndStatusDisplayType'] ?? '',
      type: EventTypeModel.fromJson(json['eventType']),
      extraPlayers:
          (json['extraPlayers'] as List<dynamic>?)
              ?.map((e) => toInt(e) ?? 0)
              .toList() ??
          [],
    );
  }
}

class EventTypeModel extends EventType {
  const EventTypeModel({
    required super.id,
    required super.name,
    required super.subTypeId,
    super.subTypeName,
  });

  factory EventTypeModel.fromJson(Map<String, dynamic> json) {
    return EventTypeModel(
      id: EventId.fromValue(toInt(json['id']) ?? -1) ?? EventId.none,
      name: json['name'] ?? '',
      subTypeId: toInt(json['subTypeId']) ?? -1,
      subTypeName: json['subTypeName'],
    );
  }
}
