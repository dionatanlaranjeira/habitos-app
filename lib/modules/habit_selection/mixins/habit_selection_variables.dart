import 'package:signals/signals_flutter.dart';
import '../models/category_model.dart';
import '../models/habit_model.dart';

mixin HabitSelectionVariables {
  // Estado das categorias
  final categoriesAS = asyncSignal<List<CategoryModel>>(AsyncLoading());

  // Estado da biblioteca de hábitos
  final habitLibraryAS = asyncSignal<List<HabitModel>>(AsyncLoading());

  // Lista de IDs selecionados (Sinal reativo)
  final selectedHabitIds = signal<List<String>>([]);

  // Estado da operação de salvamento
  final saveStatusAS = asyncSignal<void>(AsyncData(null));

  // Getters de conveniência
  bool get canConfirm =>
      selectedHabitIds.value.length >= 3 && selectedHabitIds.value.length <= 5;
  int get selectedCount => selectedHabitIds.value.length;
}
