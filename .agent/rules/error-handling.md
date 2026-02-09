---
trigger: model_decision
description: Estratégia de tratamento de erros - interceptores, ExceptionHandler e Crashlytics
---

# Tratamento de Erros

Estratégia em camadas: Interceptores HTTP → FutureHandler → ExceptionHandler Global.

## 1. Interceptores HTTP (Primeira Linha)

### Padronização de Mensagens
Interceptor extrai mensagem amigável do backend (JSON) e coloca no `DioException.message`.

### Refresh Token (401)
1. Recebe 401 → bloqueia fila de requisições
2. Tenta renovar token com Refresh Token
3. Sucesso → atualiza token + refaz requisição original
4. Falha → limpa sessão + redireciona para Login

## 2. ExceptionHandler Global (Observabilidade)

Captura exceções não tratadas na raiz com `runZonedGuarded`:

```dart
void main() async {
  runZonedGuarded(() async {
    FlutterError.onError = (details) => ExceptionHandler(details.exception, details.stack);
    runApp(const MyApp());
  }, (error, stack) => ExceptionHandler(error, stack));
}
```

O `ExceptionHandler`:
- Gera logs no console para desenvolvimento
- Envia erro como **FATAL** para Firebase Crashlytics
- Encapsula em `GlobalException` para padronização
- Erros com statusCode diferente de 500 NÃO são enviados como fatal

## Log (Classe Centralizada de Logs)

Logs centralizados via classe `Log` com métodos estáticos. **NÃO usar** `print()`, `dart:developer log()` ou `Logger()` direto.
Localização: `lib/core/logger/app_logger.dart`. Acessível via barrel `core.dart`.

```dart
Log.debug('Valor da variável', data);                          // dev only
Log.info('Usuário navegou para Home');                         // dev + hom
Log.warning('Cache expirado, recarregando');                   // dev + hom + prd
Log.error('Falha ao carregar dados', error: e, stackTrace: s); // sempre
Log.fatal('Erro crítico no app', error: e, stackTrace: s);     // sempre
```

Filtro por ambiente: dev → tudo | hom → info+ | prd → warning+

Sempre passar `error` e `stackTrace` ao logar erros:

```dart
catchError: (e, s) {
  Log.error('Falha ao verificar sessão', error: e, stackTrace: s);
  AppRoutes.goToLogin();
},
```

## 3. Tratamento Específico (FutureHandler.catchError)

Para erros esperados de negócio, usar `catchError` do FutureHandler.
Ao tratar aqui, o erro **NÃO sobe** para o ExceptionHandler Global.

```dart
await FutureHandler(
  asyncState: splashAS,
  repositoryFunction: _repository.checkToken(),
  onValue: (_) => AppRoutes.goToHome(),
  catchError: (e, s) {
    log('Sessão inválida, redirecionando...');
    AppRoutes.goToLogin();
  },
).call();
```

## Resumo

| Onde ocorre | Quem processa | Ação |
|---|---|---|
| Erro de API (Msg) | Interceptor | Extrai mensagem limpa do JSON |
| Sessão (401) | Interceptor | Refresh Token ou Logout |
| Regra de Negócio | FutureHandler | Lógica específica no Controller |
| Crash / Bug | ExceptionHandler | Log no Console + Firebase Fatal |
