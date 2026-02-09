import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'create_group_repository.dart';

class CreateGroupRepositoryImpl implements CreateGroupRepository {
  final FirebaseFirestore _firestore;

  CreateGroupRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _seedData();
  }

  Future<void> _seedData() async {
    // Seed Game Modes
    final modesCount = await _firestore.collection('game_modes').count().get();
    if (modesCount.count == 0) {
      final modes = [
        {
          'name': 'Normal',
          'description':
              '1 ponto por cada hábito cumprido. Ideal para quem está começando.',
        },
        {
          'name': 'Hardcore',
          'description':
              'Tudo ou nada. Você só pontua no dia se cumprir 100% dos seus hábitos.',
        },
      ];
      for (var mode in modes) {
        await _firestore.collection('game_modes').add(mode);
      }
    }

    // Seed Season Durations
    final durationsCount = await _firestore
        .collection('season_durations')
        .count()
        .get();
    if (durationsCount.count == 0) {
      final durations = [
        {
          'days': 14,
          'name': 'Sprint (14 dias)',
          'description': 'Competição rápida e intensa de duas semanas.',
        },
        {
          'days': 30,
          'name': 'Maratona (30 dias)',
          'description': 'Para grupos que buscam consistência a longo prazo.',
        },
      ];
      for (var duration in durations) {
        await _firestore.collection('season_durations').add(duration);
      }
    }
  }

  @override
  Future<List<GameModeModel>> getGameModes() async {
    final snapshot = await _firestore.collection('game_modes').get();
    return snapshot.docs
        .map((doc) => GameModeModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<SeasonDurationModel>> getSeasonDurations() async {
    final snapshot = await _firestore.collection('season_durations').get();
    return snapshot.docs
        .map((doc) => SeasonDurationModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
