import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/core.dart';
import '../models/models.dart';
import 'weekly_ranking_repository.dart';

class WeeklyRankingRepositoryImpl implements WeeklyRankingRepository {
  WeeklyRankingRepositoryImpl({required FunctionsAdapter functionsAdapter})
    : _functions = functionsAdapter.instance;

  final FirebaseFunctions _functions;

  @override
  Future<WeeklyRankingModel> getWeeklyRanking({required String groupId}) async {
    final callable = _functions.httpsCallable('getWeeklyGroupRanking');
    final result = await callable.call(<String, dynamic>{'groupId': groupId});

    final data = result.data;
    if (data is! Map) {
      throw Exception('Resposta inválida da função getWeeklyGroupRanking');
    }

    return WeeklyRankingModel.fromMap(Map<String, dynamic>.from(data));
  }
}
