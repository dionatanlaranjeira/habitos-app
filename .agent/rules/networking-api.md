---
trigger: glob
globs: lib/**/repositories/**/*.dart, lib/**/dtos/**/*.dart, lib/**/models/**/*.dart, lib/core/network/**/*.dart
---

# Consumo de API & Networking

Comunicação externa centralizada no `HttpAdapter`. Padrão Mapper para desacoplamento.

## HttpAdapter (Wrapper do Dio)

- Singleton, timeouts de 30s
- Headers padrão: `Content-Type: application/json` + identificador de ambiente
- Interceptores: Autenticação, Refresh Token, Logs, Tratamento de Erro

## Repository — Recebe DTOs, Retorna Models

Regra estrita: `JSON → DTO → Model` (conversão via `.toDomain()`)

```dart
class LoginRepositoryImpl implements LoginRepository {
  final HttpAdapter _httpAdapter;
  LoginRepositoryImpl({required HttpAdapter httpAdapter}) : _httpAdapter = httpAdapter;

  @override
  Future<LoginModel> login(LoginRequestDto dto) async {
    final response = await _httpAdapter.post(
      'v1/auth/login',
      data: dto.toJson(),
      options: Options(extra: {'show-message': true}),
    );
    return LoginResponseDto.fromJson(response.data['data']).toDomain();
  }
}
```

## Por que Mappers? (DTO vs Model)

| Característica | DTO (Data Transfer Object) | Model (Domain Entity) |
|---|---|---|
| Onde vive? | Camada de Infra/Data | Camada de Domínio |
| Responsabilidade | Transportar dados da API (JSON) | Regra de Negócio e Visualização |
| Pode ter nulos? | Sim (APIs são incertas) | Evitamos (Null Safety rigoroso) |
| Quem acessa? | Apenas o Repository | Controller, View, Stores |

Se a API mudar, ajusta-se apenas o DTO + Mapper. O Model e a View permanecem intactos.

## Feedback Automático (show-message)

O `MessageInterceptor` exibe Toast/Snack com mensagem do backend:

```dart
options: Options(extra: {'show-message': true}),
```

## Repositories — Interface + Implementação

```dart
// Interface
abstract class LoginRepository {
  Future<LoginModel> login(LoginRequestDto dto);
}

// Implementação
class LoginRepositoryImpl implements LoginRepository { ... }
```
