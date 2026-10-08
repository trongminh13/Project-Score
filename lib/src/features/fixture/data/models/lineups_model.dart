import 'package:live_score/src/core/constants/parsers.dart';

import '../../domain/entities/lineups.dart';

class LineupModel extends Lineup {
  const LineupModel({
    required super.status,
    required super.formation,
    required super.members,
  });

  factory LineupModel.fromApiFootball(Map<String, dynamic> json) {
    final startXI = json['startXI'] as List? ?? [];
    final substitutes = json['substitutes'] as List? ?? [];
    
    final members = <LineupMemberModel>[];
    
    for (final p in startXI) {
      if (p['player'] != null) {
        members.add(LineupMemberModel.fromApiFootball(p['player'], statusVal: 1)); // 1 = Starting XI in 365scores
      }
    }
    for (final p in substitutes) {
      if (p['player'] != null) {
        members.add(LineupMemberModel.fromApiFootball(p['player'], statusVal: 2)); // 2 = Substitute
      }
    }

    return LineupModel(
      status: '', // Not used prominently in UI
      formation: json['formation'] ?? '',
      members: members,
    );
  }

  factory LineupModel.fromJson(Map<String, dynamic> json) {
    return LineupModel(
      status: json['status'] ?? '',
      formation: json['formation'] ?? '',
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => LineupMemberModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class YardInfoModel extends YardInfo {
  const YardInfoModel({
    required super.line,
    required super.fieldPosition,
    super.fieldLine,
    super.fieldSide,
  });

  factory YardInfoModel.fromApiFootball(String? grid, String? pos) {
    if (grid == null || grid.isEmpty) return const YardInfoModel(line: 0, fieldPosition: 0);
    
    // grid is like "1:1" for goalie, "2:4" for defender, etc.
    // 365scores 'line' (1=GK, 2=DEF, 3=MID, 4=FWD)
    // 365scores 'fieldPosition' (left to right index)
    final parts = grid.split(':');
    if (parts.length == 2) {
      final lineStr = parts[0];
      final posStr = parts[1];
      
      int line = int.tryParse(lineStr) ?? 0;
      // In 365scores, Goalkeeper is line 0. API-Football line 1 is Goalkeeper.
      if (line > 0) line = line - 1; 
      
      int position = int.tryParse(posStr) ?? 0;
      
      return YardInfoModel(
        line: line,
        fieldPosition: position,
      );
    }
    return const YardInfoModel(line: 0, fieldPosition: 0);
  }

  factory YardInfoModel.fromJson(Map<String, dynamic> json) {
    return YardInfoModel(
      line: toInt(json['line']) ?? 0,
      fieldPosition: toInt(json['fieldPosition']) ?? 0,
      fieldLine: toInt(json['fieldLine']),
      fieldSide: toInt(json['fieldSide']),
    );
  }
}

class LineupMemberModel extends LineupMember {
  const LineupMemberModel({
    required super.id,
    required super.status,
    required super.statusText,
    super.yardInfo,
  });

  factory LineupMemberModel.fromApiFootball(Map<String, dynamic> json, {required int statusVal}) {
    return LineupMemberModel(
      id: json['id'] ?? 0,
      status: statusVal,
      statusText: statusVal == 1 ? 'Bắt đầu' : 'Dự bị',
      yardInfo: YardInfoModel.fromApiFootball(json['grid'], json['pos']),
    );
  }

  factory LineupMemberModel.fromJson(Map<String, dynamic> json) {
    return LineupMemberModel(
      id: json['id'],
      status: toInt(json['status']) ?? 0,
      statusText: json['statusText'] ?? '',
      yardInfo:
          json['yardFormation'] != null
              ? YardInfoModel.fromJson(json['yardFormation'])
              : null,
    );
  }
}
