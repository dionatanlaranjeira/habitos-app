# Flutter App Template

Um template-base para projetos Flutter, pré-configurado com uma arquitetura modular, `Makefile` para automação e setup de flavors (dev, hom, prd) pronto para uso.

## 🚀 Configuração Inicial (Passo Obrigatório)

Para usar este template, **não o clone diretamente**. Siga estes passos para configurar seu novo projeto corretamente:

1.  **Crie seu Repositório:** Clique no botão verde **"Use this template"** no topo desta página do GitHub.
2.  **Dê um nome** ao seu novo repositório (ex: `meu_app_cliente`) e crie-o.
3.  **Clone o *novo* repositório** para sua máquina local:
    ```bash
    git clone [https://github.com/SEU-USUARIO/SEU-NOVO-REPO.git](https://github.com/SEU-USUARIO/SEU-NOVO-REPO.git)
    cd SEU-NOVO-REPO
    ```
4.  **Execute o Script de Setup:** Este é o passo mais importante. Ele renomeia o `bundle id` (Android/iOS), o nome de exibição do app, o `package` do Kotlin e todos os outros placeholders no projeto.

    Rode o comando `make setup` passando os dois parâmetros obrigatórios: `bundle` e `name`.

    ```bash
    make setup bundle=com.suaempresa.seu_app_legal name="Meu App Legal"
    ```
    * **`bundle`**: O identificador único do seu app (ex: `com.minhaempresa.meu_app`).
        * Use `snake_case` (com underscores) se necessário (ex: `meu_app`). O script irá convertê-lo automaticamente para `camelCase` (ex: `meuApp`) onde for necessário no iOS.
    * **`name`**: O nome de exibição "humano" do app (ex: `"Meu Aplicativo"`).
        * **Importante:** Use aspas se o nome contiver espaços.

5.  **Pronto!** O script irá configurar tudo e criar um arquivo `template.config` para salvar o estado do projeto.

Agora você pode rodar `make clean` (ou `flutter pub get`) e começar a desenvolver.

## 🛠️ Comandos Disponíveis (`Makefile`)

Este template usa um `Makefile` para automatizar tarefas comuns.

| Comando | Descrição |
| :--- | :--- |
| **`make setup bundle=... name=...`** | Configura o projeto com um novo bundle id e nome. **Pode ser re-executado** com segurança. |
| `make clean` | Limpa o projeto (`flutter clean`) e busca as dependências (`flutter pub get`). |
| `make module n=<nome>` | Cria a estrutura completa de um novo módulo em `lib/modules/`. (Ex: `make module n=auth_login`) |
| `make assets` | Gera o arquivo `lib/shared/generated/assets.dart` com base na pasta `assets/`. |
| `make watch` | Inicia o `build_runner` em modo "watch" para geração de código. |
| `make build [env=...]` | Compila o APK para um ambiente (`dev`, `hom`, `prd`). (Padrão: `dev`) |
| `make bundle` | Compila o App Bundle (AAB) para o ambiente de produção (`prd`). |
| `make help` | Exibe todos os comandos disponíveis. |

---

## Recursos Padrão do Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
