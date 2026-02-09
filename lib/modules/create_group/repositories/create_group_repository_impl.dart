import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/core.dart';
import '../models/models.dart';
import 'create_group_repository.dart';

class CreateGroupRepositoryImpl implements CreateGroupRepository {
  final FirebaseFirestore _firestore;

  CreateGroupRepositoryImpl({required FirestoreAdapter firestore})
    : _firestore = firestore.instance;

  @override
  Future<List<GameModeModel>> getGameModes() async {
    try {
      final snapshot = await _firestore.collection('game_modes').get();
      return snapshot.docs
          .map((doc) => GameModeModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e, s) {
      Log.error('Erro ao buscar modos de jogo', error: e, stackTrace: s);
      return [];
    }
  }

  @override
  Future<List<SeasonDurationModel>> getSeasonDurations() async {
    try {
      final snapshot = await _firestore.collection('season_durations').get();
      return snapshot.docs
          .map((doc) => SeasonDurationModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e, s) {
      Log.error(
        'Erro ao buscar durações de temporada',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }
}
