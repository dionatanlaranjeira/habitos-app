class SeasonDurationModel {
  final String id;
  final int days;
  final String name;
  final String description;

  const SeasonDurationModel({
    required this.id,
    required this.days,
    required this.name,
    required this.description,
  });

  factory SeasonDurationModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return SeasonDurationModel(
      id: id,
      days: data['days'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'days': days,
    'name': name,
    'description': description,
  };

  static SeasonDurationModel empty() =>
      const SeasonDurationModel(id: '', days: 0, name: '', description: '');
}
