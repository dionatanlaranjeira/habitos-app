import 'weekly_ranking_entry_model.dart';

class WeeklyRankingModel {
  const WeeklyRankingModel({
    required this.weekStartDate,
    required this.weekEndDate,
    required this.timezone,
    required this.totalParticipants,
    required this.top,
    this.myPosition,
  });

  final String weekStartDate;
  final String weekEndDate;
  final String timezone;
  final int totalParticipants;
  final List<WeeklyRankingEntryModel> top;
  final WeeklyRankingEntryModel? myPosition;

  factory WeeklyRankingModel.fromMap(Map<String, dynamic> data) {
    int parseInt(dynamic value) => value is num ? value.toInt() : 0;

    final topRaw = data['top'] as List<dynamic>? ?? [];
    final myPositionRaw = data['myPosition'];

    return WeeklyRankingModel(
      weekStartDate: data['weekStartDate'] as String? ?? '',
      weekEndDate: data['weekEndDate'] as String? ?? '',
      timezone: data['timezone'] as String? ?? 'UTC',
      totalParticipants: parseInt(data['totalParticipants']),
      top: topRaw
          .whereType<Map>()
          .map(
            (item) => WeeklyRankingEntryModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      myPosition: myPositionRaw is Map
          ? WeeklyRankingEntryModel.fromMap(
              Map<String, dynamic>.from(myPositionRaw),
            )
          : null,
    );
  }
}
