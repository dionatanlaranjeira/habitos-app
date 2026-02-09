---
trigger: always_on
---

# App de Rotina e Bons Hábitos — Documento de Produto (MVP)

## 1. Visão Geral

Este produto é um aplicativo mobile focado em **rotina, bons hábitos e competição em grupo**.

O app funciona como um **campeonato de hábitos**, onde usuários competem com amigos em grupos fechados durante temporadas, acumulando pontos por hábitos cumpridos diariamente.

O foco do produto é **consistência**, **pressão social leve** e **simplicidade**.

---

## 2. Proposta de Valor

### Para o usuário
> "Você mantém bons hábitos porque está competindo com seus amigos. Todo dia vale ponto."

### Diferenciais
- Competição social (não solitária)
- Regras simples e transparentes
- Temporadas com reset (ninguém fica para trás para sempre)
- Sem motivação artificial, sem coaching, sem autoajuda

---

## 3. Público-Alvo

- Jovens adultos (18–35 anos)
- Pessoas competitivas
- Usuários que já tentaram apps de hábitos e abandonaram
- Pessoas que funcionam melhor com pressão social leve

**Não é um app para todos — e isso é intencional.**

---

## 4. Conceitos Fundamentais

### Grupo
- Espaço fechado de competição
- Criado por convite (link compartilhável ou código alfanumérico)
- Entre 3 e 10 participantes

### Temporada
- Período fixo de competição
- Duração: 14 ou 30 dias
- Ao final, ranking é encerrado e salvo no histórico

### Hábito
- Ação positiva recorrente
- Binário: feito / não feito
- Escolhido a partir de uma biblioteca fixa

---

## 5. Regras de Hábitos

- Cada usuário deve escolher **no mínimo 3 e no máximo 5 hábitos**
- Hábitos são escolhidos **antes do início da temporada**
- Não é permitido trocar hábitos durante a temporada
- Todos os hábitos possuem o mesmo peso no MVP

---

## 6. Check-in Diário

- O check-in pode ser feito diariamente entre **00:00 e 23:59**
- Não é permitido marcar dias passados (sem backfill)
- Cada hábito marcado como feito gera pontuação
- O check-in é visível para os outros membros do grupo

---

## 7. Sistema de Pontuação

### Regra Base
- **1 hábito feito = 1 ponto**

### Pontuação do Dia
- Pontos do dia = número de hábitos cumpridos
- Exemplo:
  - Usuário com 5 hábitos
  - Cumpriu 4 no dia
  - Pontuação do dia = 4 pontos

### Observações
- Não existe streak
- Não existe multiplicador
- Não existe bônus oculto

O sistema prioriza **justiça, clareza e previsibilidade**.

---

## 8. Rankings

### Ranking da Temporada (Principal)
- Soma total de pontos durante a temporada
- Define o vencedor oficial

### Ranking Semanal
- Soma de pontos da semana atual
- Reiniciado automaticamente toda semana
- Serve para manter engajamento e sensação de virada

### Critérios de Desempate
1. Maior número de dias ativos (≥1 hábito feito)
2. Menor número de dias zerados
3. Empate técnico (ambos exibidos na mesma posição)

---

## 9. Modos de Grupo

### Modo Normal (padrão)
- Pontuação normal: 1 ponto por hábito feito

### Modo Hardcore
- O usuário só pontua no dia se cumprir **100% dos hábitos**
- Caso contrário, pontuação do dia = 0

O modo é escolhido pelo criador do grupo antes da temporada.

---

## 10. Fluxo Principal do Usuário

1. Criar conta (login)
2. Criar ou entrar em um grupo
3. Escolher hábitos
4. Início da temporada
5. Check-in diário
6. Acompanhamento do ranking
7. Encerramento da temporada
8. Nova temporada opcional

---

## 11. Escopo do MVP

### Incluído
- Autenticação de usuários (Email/Senha, Google, Apple)
- Grupos fechados com convite (link compartilhável ou código alfanumérico)
- Temporadas (14 ou 30 dias)
- Biblioteca fixa de hábitos
- Check-in diário
- Ranking da temporada
- Ranking semanal
- Histórico de temporadas
- Multilíngue (pt-BR e en)

### Fora do MVP
- Inteligência Artificial
- Recomendações personalizadas
- Validação por imagem
- Integrações externas (wearables, health APIs)
- Feed social avançado

---

## 12. Princípios de Produto

- Simplicidade > complexidade
- Clareza > gamificação exagerada
- Justiça > dopamina artificial
- Pressão social leve > motivação forçada

---

## 13. Stack Técnica (MVP)

- Frontend: Flutter
- Autenticação: Firebase Auth (Email/Senha, Google, Apple)
- Banco de dados: Firestore
- Backend: Cloud Functions
- Notificações (opcional): Firebase Cloud Messaging

---

## 14. Métricas de Sucesso (iniciais)

- % de usuários que fazem check-in diário
- Número médio de dias ativos por usuário na temporada
- Retenção até o final da temporada
- Número médio de participantes por grupo

---

## 15. Visão de Evolução (Pós-MVP)

- Estatísticas avançadas
- Visualização de consistência
- Reações sociais
- Mensagens automáticas simples
- Exploração futura de IA (fora do escopo inicial)

## 16. Regras de Tempo e Timezone

- O "dia" do check-in é definido pelo **timezone do grupo**.
- O timezone do grupo é definido na criação (padrão: timezone do criador).
- Janela de check-in: 00:00–23:59 no timezone do grupo.
- Sem backfill no MVP: check-in só pode ser feito para o dia atual.

## 17. Estados da Temporada

- `draft`: grupo em formação, membros entram e escolhem hábitos
- `active`: temporada em andamento, check-ins habilitados
- `closed`: temporada encerrada, ranking final salvo

Regras:
- Temporada só inicia quando o criador clicar em **"Iniciar temporada"** (ou automaticamente ao atingir 3 membros — definir no projeto).
- Hábitos só podem ser definidos/alterados em `draft`.

## 18. Entrada e Saída de Membros

- Entrada durante `draft`: permitida
- Entrada durante `active`: (definir) permitida até 24h após início OU permitida sempre (entra do dia atual em diante)
- Saída durante `active`: permitida, mas histórico da temporada permanece no ranking final como "saiu" (sem pontuar após sair)

## 19. Biblioteca de Hábitos (MVP)

- O app fornece uma biblioteca fixa inicial (15–25 hábitos), organizada por categorias.
- Todos são binários (feito/não feito) e auto-declarados no MVP.
- Cada usuário escolhe 3–5 hábitos ativos por temporada.

## 20. Regras do Modo Hardcore (detalhado)

- O usuário só pontua no dia se cumprir **100%** dos seus hábitos ativos.
- Se cumprir 100%: pontuação do dia = número de hábitos ativos (3–5)
- Caso contrário: pontuação do dia = 0


---
description: Contexto de produto do Hábitos App - regras de negócio, entidades e escopo MVP
alwaysApply: true
---

# Produto — Hábitos App (MVP)

App de **campeonato de hábitos**: usuários competem com amigos em grupos fechados durante temporadas.
Documento completo: `docs/product.md`

## Entidades Principais

- **Grupo**: espaço fechado de competição, 3–10 participantes, convite por link ou código
- **Temporada**: período fixo (14 ou 30 dias), ranking encerrado e salvo no histórico ao final
- **Hábito**: ação recorrente binária (feito/não feito), de uma biblioteca fixa
- **Check-in**: registro diário (00:00–23:59), sem backfill, visível para o grupo

## Regras de Negócio Críticas

- Mínimo 3, máximo 5 hábitos por usuário
- Hábitos escolhidos ANTES da temporada, sem troca durante
- 1 hábito feito = 1 ponto (sem streak, sem multiplicador, sem bônus)
- **Modo Normal**: 1 ponto por hábito feito
- **Modo Hardcore**: só pontua se cumprir 100% dos hábitos no dia (senão 0)
- Desempate: (1) mais dias ativos, (2) menos dias zerados, (3) empate técnico

## Rankings

- **Ranking da Temporada**: soma total de pontos — define o vencedor
- **Ranking Semanal**: reset toda semana — engajamento e virada

## Auth e Idioma

- Firebase Auth: Email/Senha, Google, Apple
- Multilíngue: pt-BR e en

## Escopo MVP

Inclui: auth, grupos com convite, temporadas, biblioteca de hábitos, check-in, rankings, histórico
Fora: IA, recomendações, validação por imagem, wearables, feed social avançado

## Princípios

- Simplicidade > complexidade
- Clareza > gamificação exagerada
- Justiça > dopamina artificial
- Pressão social leve > motivação forçada