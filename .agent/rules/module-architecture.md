---
trigger: glob
globs: lib/modules/**/*.dart, lib/core/routes/**/*.dart, lib/global_modules/**/*.dart
---

# Estrutura de Pastas e Módulos

Organização Feature-First com camadas de suporte e módulos globais.

## Visão Macro (lib/)

```
lib/
├── core/             # Infraestrutura, Configuração e Base da Arquitetura
├── shared/           # Componentes visuais, Utilitários e Estilos reutilizáveis
├── global_modules/   # Funcionalidades GLOBAIS (Dados e Estado, sem UI)
├── modules/          # Features com telas
├── main.dart         # Entry point produção
├── main_dev.dart     # Entry point dev
└── main_hom.dart     # Entry point homologação
```

## Anatomia de um Módulo (modules/)

```
modules/login/
├── controllers/       # Lógica de View (ViewModel)
├── dtos/              # Contratos de API (Request/Response) — Freezed
├── mixins/            # Estado Reativo (Variables & Signals)
├── models/            # Entidades de Domínio específicas da feature
├── repositories/      # Comunicação de Dados (interface + impl)
├── widgets/           # Widgets EXCLUSIVOS desta tela
├── login_module.dart  # Configuração de DI e Rota (ProviderModule)
└── login_page.dart    # A Tela (View)
```

## ProviderModule — Injeção de Dependência por Rota

Dependências só são criadas quando a rota é acessada e descartadas quando sai da pilha.

```dart
class LoginModule extends ProviderModule {
  static final String path = '/login';

  LoginModule() : super(
    path: path,
    page: const LoginPage(),
    bindings: (_) => [
      Provider(create: (_) => LoginRepository()),
      Provider(create: (ctx) => LoginController(
        loginRepository: ctx.read<LoginRepository>(),
      )),
    ],
  );
}
```

**Após criar o módulo:** registrar `LoginModule().route` no `AppRouter`.

## AppRouter — Central de Roteamento

```dart
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: SplashModule.splash,
    routes: [
      SplashModule().route,
      LoginModule().route,
      // Navegação persistente (Bottom Navigation Bar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => DefaultNavigationBar(child: shell),
        branches: [
          StatefulShellBranch(routes: [HomeModule().route]),
          StatefulShellBranch(routes: [ProfileModule().route]),
        ],
      ),
    ],
  );

  // Provedores Globais (vivos durante toda execução)
  static get globalProviders => [
    Provider<LocalSecureStorage>(create: (_) => LocalSecureStorageImpl()),
    Provider<HttpAdapter>(create: (_) => HttpAdapter()),
    Provider<UserStore>(create: (_) => UserStore()),
  ];
}
```

## Módulos Globais (global_modules/)

Módulos completos SEM interface gráfica. Possuem **Store** (estado global) ao invés de Controller.

```
global_modules/user/
├── stores/        # UserStore (estado global persistente)
├── dtos/          # UserDto
├── models/        # UserEntity
├── repositories/  # UserRepository → GET /me
└── user_module.dart
```

A Store é injetada na raiz via `AppRouter.globalProviders`.

## Barrel Files (Obrigatório)

```dart
// ✅ Correto
import '../../global_modules/global_modules.dart';
import 'controllers/controllers.dart';

// ❌ Errado
import '../../global_modules/user/stores/user_store.dart';
import 'controllers/login_controller.dart';
```
