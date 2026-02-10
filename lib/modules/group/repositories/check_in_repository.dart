import 'dart:io';

import '../models/models.dart';

abstract class CheckInRepository {
  Future<void> submitCheckIn({
    required String groupId,
    required String userId,
    required String habitId,
    required String date,
    required File photo,
    String? description,
  });

  Future<List<CheckInModel>> getCheckInsByDate({
    required String groupId,
    required String date,
  });

  Future<List<CheckInModel>> getCheckInsByUserAndDate({
    required String groupId,
    required String userId,
    required String date,
  });
}
