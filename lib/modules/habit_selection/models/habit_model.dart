import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String name;
  final String category;
  final int iconCode;
  final int order;

  const HabitModel({
    required this.id,
    required this.name,
    required this.category,
    required this.iconCode,
    this.order = 0,
  });

  factory HabitModel.fromFirestore(String id, Map<String, dynamic> data) {
    return HabitModel(
      id: id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      iconCode:
          data['iconCode'] as int? ?? 0xe876, // fallback para check (done)
      order: data['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'iconCode': iconCode,
      'order': order,
    };
  }

  IconData get iconData => IconData(iconCode, fontFamily: 'MaterialIcons');
}
