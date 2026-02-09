class CategoryModel {
  final String id;
  final Map<String, String> title;
  final int order;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.order,
  });

  factory CategoryModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      title: Map<String, String>.from(data['title'] as Map? ?? {}),
      order: data['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {'title': title, 'order': order};

  String getLocalizedTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? id;
  }
}
