class GameModeModel {
  final String id;
  final String name;
  final String description;

  const GameModeModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory GameModeModel.fromFirestore(String id, Map<String, dynamic> data) {
    return GameModeModel(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
  };

  static GameModeModel empty() =>
      const GameModeModel(id: '', name: '', description: '');
}
