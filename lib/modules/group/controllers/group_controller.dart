import 'package:signals/signals_flutter.dart';

import '../../../global_modules/global_modules.dart';

class GroupController {
  final String groupId;
  final GroupRepository _groupRepository;

  GroupController({
    required GroupRepository groupRepository,
    required this.groupId,
  }) : _groupRepository = groupRepository {
    _loadGroup();
  }

  final groupAS = asyncSignal<GroupModel?>(AsyncLoading());

  Future<void> _loadGroup() async {
    // Por enquanto, apenas recarrega se necessário ou busca detalhes extras
    // Como o objeto GroupModel já vem da lista, poderíamos passá-lo direto.
    // Mas para garantir dados frescos, vamos buscar pelo ID se tiver um método getGroupById.
    // O repositório atual tem getGroupByCode e getGroupsByUser.
    // Falta um getGroupById(id).
    // Para o MVP, vamos assumir que o dado vem da navegação ou store,
    // mas o ideal é buscar de novo.
    // Vou deixar placeholder e usar o que tivermos.

    // TODO: Implementar getGroupById no repositório se necessário
    groupAS.value = AsyncData(null);
  }
}
