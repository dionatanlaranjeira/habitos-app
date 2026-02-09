---
trigger: always_on
---

# Convenções de Código

## Nomenclatura

- Arquivos: `snake_case` (ex: `splash_controller.dart`)
- Classes: `PascalCase` (ex: `SplashController`)
- Variáveis/funções: `camelCase`
- Constantes de storage: `UPPER_SNAKE_CASE` (ex: `ACCESS_TOKEN`)

## Organização de Arquivos

- **Classe Única por Arquivo (OBRIGATÓRIO):** É **PROIBIDO** criar mais de uma classe no mesmo arquivo, mesmo que sejam classes privadas (`_MinhaClasse`). Cada classe deve ter seu próprio arquivo para facilitar a localização e manutenção.
  - *Exceções ÚNICAS:* DTOs gerados com `Freezed` ou `Mixins` de variáveis que são usados exclusivamente pelo Controller no mesmo contexto de arquivo (seguindo o padrão de Mixins).
  - *Widgets auxiliares privados (`_MeuWidget`) devem ir para a pasta `widgets/` da feature.*
  - **Exemplo:**
    - ❌ ERRADO: `create_group_page.dart` com `_StepIdentity`, `_StepSeason`, `_StepMode` no mesmo arquivo
    - ✅ CORRETO: `create_group_page.dart` + `widgets/step_identity.dart`, `widgets/step_season.dart`, `widgets/step_mode.dart`

## Dados Dinâmicos (OBRIGATÓRIO)

**NUNCA** use enums ou constantes estáticas para dados que podem mudar ou precisam de flexibilidade. **TUDO** no produto é dinâmico e deve ser carregado do Firestore.

```dart
// ❌ ERRADO — Dados estáticos no código
enum GameMode { normal, hardcore }
enum SeasonDuration { sprint14, marathon30 }

// ✅ CORRETO — Dados carregados do Firestore
class GameModeModel {
  final String id;
  final String name;
  final String description;
  
  factory GameModeModel.fromFirestore(String id, Map<String, dynamic> data) { ... }
}
```

**Regra:** Se o dado pode ser editado pelo admin, traduzido, ou ter novos valores adicionados no futuro, ele DEVE estar no Firestore, não no código.

## Renderização de Estado Assíncrono (OBRIGATÓRIO)

**SEMPRE** utilize o `SignalFutureBuilder` para renderizar estados `AsyncState` na UI. **NUNCA** use `Watch` diretamente para gerenciar estados de loading/error/data.

```dart
// ✅ CORRETO
SignalFutureBuilder<MeuModel>(
  asyncState: controller.meuDadoAS.value,
  loadingWidget: CircularProgressIndicator(),
  builder: (data) => MeuWidget(data: data),
)

// ❌ ERRADO — Nunca faça isso para AsyncState
Watch((context) {
  if (controller.meuDadoAS.watch(context).isLoading) { ... }
  // ...
})
```

O `Watch` simples deve ser usado apenas para signals síncronos (ex: `selectedHabitIds`, `isExpanded`).


## Barrel Files (Obrigatório)

Cada subpasta tem arquivo de exportação (`controllers.dart`, `models.dart`, etc.):

```dart
// ✅ Correto
import '../../global_modules/global_modules.dart';
import 'controllers/controllers.dart';

// ❌ Errado — importar arquivo direto
import '../../global_modules/user/stores/user_store.dart';
```

## DTOs com Freezed

```dart
@freezed
class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required String token,
    required String refreshToken,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}

// Mapper obrigatório: DTO → Model
extension LoginResponseDtoMapper on LoginResponseDto {
  LoginModel toDomain() => LoginModel(token: token, refreshToken: refreshToken);
}

## Modelos (Entidades de Domínio)

Modelos que representam entidades do banco de dados (Firestore) devem utilizar o padrão `fromFirestore` em vez de Freezed.

```dart
class HabitModel {
  final String id;
  final String name;
  // ... campos finais (final)

  const HabitModel({required this.id, required this.name});

  factory HabitModel.fromFirestore(String id, Map<String, dynamic> data) {
    return HabitModel(
      id: id,
      name: data['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
  };
}
```
```

Rodar code generation: `dart run build_runner build --delete-conflicting-outputs`

## Repositories — Interface + Implementação

```dart
abstract class LoginRepository {
  Future<LoginModel> login(LoginRequestDto dto);
}

class LoginRepositoryImpl implements LoginRepository {
  final HttpAdapter _httpAdapter;
  LoginRepositoryImpl({required HttpAdapter httpAdapter}) : _httpAdapter = httpAdapter;
  // ...
}
```

## Pages — StatelessWidget

Views devem ser `StatelessWidget`. Estado fica no Controller (Signals).

## Controllers — Com Mixin de Variáveis

```dart
mixin LoginVariables {
  final loginAS = asyncSignal<AuthModel>(AsyncLoading());
  final cpfController = TextEditingController();
}

class LoginController with LoginVariables {
  final AuthRepository _repository;
  LoginController(this._repository);
}
```

## Internacionalização (l10n - ARB)

As strings devem ser organizadas de forma modular para evitar arquivos confusos, utilizando **divisores visuais** para separar os contextos.

- **Nomenclatura:** Use o padrão `prefixo_chave` em **camelCase**.
- **Divisores Visuais:** Utilize chaves com o formato `@@ --- NOME_DO_MODULO ---` para criar separações claras no arquivo.
- **Prefixos:**
  - `shared_`: Para strings globais.
  - `{nomeModulo}_`: Para strings específicas de uma feature.

*Exemplo de organização no ARB:*
```json
{
  "@@locale": "pt_BR",
  "@@ --- SHARED ---": "",
  "shared_confirm": "Confirmar",
  
  "@@ --- HABIT SELECTION ---": "",
  "habitSelection_title": "Escolha seus hábitos",
  "@habitSelection_title": {
    "description": "Título da tela de seleção de hábitos"
  }
}
```