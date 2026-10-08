import 'package:live_score/src/core/domain/entities/league.dart';
import 'package:live_score/src/features/fixture/data/models/event_model.dart';
import 'package:live_score/src/features/fixture/domain/entities/fixture_details.dart';

import '../../../../core/models/soccer_fixture_model.dart';
import 'player_model.dart';

class FixtureDetailsModel extends FixtureDetails {
  const FixtureDetailsModel({
    required super.fixture,
    required super.events,
    required super.members,
    super.venue,
  });

  factory FixtureDetailsModel.fromApiFootball(List<dynamic> responseList) {
    if (responseList.isEmpty) {
      throw Exception('Fixture details not found');
    }
    final data = responseList.first;
    
    // 1. Fixture
    final fixtureModel = SoccerFixtureModel.fromApiFootball(data);
    
    // 2. Events
    final events = <EventModel>[];
    final eventsArray = data['events'] as List? ?? [];
    for (int i = 0; i < eventsArray.length; i++) {
      events.add(EventModel.fromApiFootball(eventsArray[i], i));
    }
    
    // 3. Members (Players flat list for backward compatibility)
    final members = <PlayerModel>[];
    final lineupsArray = data['lineups'] as List? ?? [];
    
    for (final lineup in lineupsArray) {
      final teamId = lineup['team']?['id'] ?? 0;
      final startXI = lineup['startXI'] as List? ?? [];
      final substitutes = lineup['substitutes'] as List? ?? [];
      
      for (final p in startXI) {
        if (p['player'] != null) {
          members.add(PlayerModel.fromApiFootball(p['player'], teamId));
        }
      }
      for (final p in substitutes) {
        if (p['player'] != null) {
          members.add(PlayerModel.fromApiFootball(p['player'], teamId));
        }
      }
    }

    // 4. Venue
    final fixtureNode = data['fixture'] ?? {};
    final venueNode = fixtureNode['venue'] ?? {};
    VenueModel? venue;
    if (venueNode['id'] != null || venueNode['name'] != null) {
      venue = VenueModel(
        id: venueNode['id'] ?? 0,
        name: venueNode['name'] ?? '',
        shortName: venueNode['city'] ?? '',
      );
    }

    return FixtureDetailsModel(
      fixture: fixtureModel,
      events: events,
      members: members,
      venue: venue,
    );
  }

}

class VenueModel extends Venue {
  const VenueModel({
    required super.id,
    required super.name,
    required super.shortName,
    super.googlePlaceId,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'],
      name: json['name'],
      shortName: json['shortName'],
      googlePlaceId: json['googlePlaceId'],
    );
  }
}
