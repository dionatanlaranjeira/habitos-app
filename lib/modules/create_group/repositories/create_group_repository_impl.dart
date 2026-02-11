import 'dart:math';

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

  @override
  Future<GroupModel> createGroup({
    required String name,
    required String ownerId,
    required int seasonDuration,
    required String gameMode,
    required String timezone,
    String status = 'draft',
    DateTime? seasonStartDate,
  }) async {
    final code = _generateCode();
    final docRef = _firestore.collection('groups').doc();
    final group = GroupModel(
      id: docRef.id,
      name: name,
      code: code,
      ownerId: ownerId,
      memberIds: [ownerId],
      createdAt: DateTime.now(),
      seasonDuration: seasonDuration,
      gameMode: gameMode,
      timezone: timezone,
      status: status,
      seasonStartDate: seasonStartDate,
    );
    await docRef.set(group.toFirestore());
    return group;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (index) => chars[rng.nextInt(chars.length)]).join();
  }
}
