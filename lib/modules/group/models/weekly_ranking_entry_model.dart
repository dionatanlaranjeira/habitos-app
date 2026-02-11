class WeeklyRankingEntryModel {
  const WeeklyRankingEntryModel({
    required this.userId,
    required this.displayName,
    required this.points,
    required this.weeklyActiveDays,
    required this.seasonActiveDays,
    required this.seasonZeroDays,
    required this.position,
  });

  final String userId;
  final String displayName;
  final int points;
  final int weeklyActiveDays;
  final int seasonActiveDays;
  final int seasonZeroDays;
  final int position;

  factory WeeklyRankingEntryModel.fromMap(Map<String, dynamic> data) {
    int parseInt(dynamic value) => value is num ? value.toInt() : 0;

    return WeeklyRankingEntryModel(
      userId: data['userId'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Usuário',
      points: parseInt(data['points']),
      weeklyActiveDays: parseInt(data['weeklyActiveDays']),
      seasonActiveDays: parseInt(data['seasonActiveDays']),
      seasonZeroDays: parseInt(data['seasonZeroDays']),
      position: parseInt(data['position']),
    );
  }
}
