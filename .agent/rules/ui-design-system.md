---
trigger: glob
globs: lib/shared/ui/**/*.dart, lib/**/*_page.dart, lib/**/*widgets*/**/*.dart
---

# Design System e UI

## Tema

- **Adaptive Theme** para suporte light/dark mode
- Fonte: **Poppins** (todos os pesos)

Configuração em `lib/shared/ui/ui_config.dart`.

## Singletons do Design System

Acessados via `.i` (instance):

- `AppColors.i` → cores semânticas do app
- `AppTextTheme.i` → estilos de texto predefinidos
- `AppDimensions.i` → constantes de espaçamento

## Extensões de BuildContext

```dart
context.primaryColor    // Cor primária
context.dimensions      // AppDimensions
context.textTheme       // TextTheme do tema
```

Definidas em `lib/shared/extensions/`.

## Widgets Compartilhados

| Widget | Uso |
|--------|-----|
| `SignalFutureBuilder` | Estado async (loading/error/success) |
| `ErrorBuilder` | Exibição de erros com retry |
| `DefaultInputField` | Campo de formulário |
| `DefaultShimmer` | Skeleton de loading |
| `CustomSnackBar` | Snackbar customizado |
| `Gap` | Espaçamento |
| `ListTileSkeleton` | Skeleton de item de lista |

## Regras de UI

- Usar os singletons (`AppColors.i`, etc.) em vez de valores hardcoded
- Usar extensões de context para acessar tema
- Widgets específicos de módulo ficam em `modules/nome/widgets/`
- Widgets compartilhados ficam em `shared/ui/`
