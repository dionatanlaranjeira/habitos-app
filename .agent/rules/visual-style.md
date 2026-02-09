---
description: Diretrizes de Estética e Estilo Visual (Moderno & Material 3)
alwaysApply: true
---

# Guia de Estilo Visual — Moderno & Material 3

Todas as interfaces deste projeto devem seguir uma estética **Premium, Moderna e Viva**, utilizando os princípios do **Material Design 3 (M3)**.

## 1. Princípios de Design

*   **Material 3 (M3):** O app deve obrigatoriamente usar `useMaterial3: true`. Os componentes devem seguir as especificações de M3 (NavigationBar, M3 Buttons, Large Top App Bars).
*   **Minimalismo Premium:** Interfaces limpas, com respiro (espaçamento generoso) e foco no conteúdo.
*   **Interatividade Reativa:** Uso de micro-animações, feedbacks táteis e transições suaves entre estados.

## 2. Cores e Luminosidade

*   **Cores Dinâmicas:** Priorizar o uso de `ColorScheme` para garantir harmonia entre cores primárias, secundárias e superfícies.
*   **Vibrância:** Evitar cores genéricas. Utilizar paletas saturadas de forma equilibrada para dar vida ao app.
*   **Contraste e Acessibilidade:** Garantir legibilidade em todos os modos (Light/Dark), respeitando as diretrizes de acessibilidade do M3.

## 3. Formas e Superfícies

*   **Cantos Arredondados:** Seguir o padrão de arredondamento do M3 (Extra Large para cards e botões principais).
*   **Elevação e Profundidade:** Utilizar elevação tonal (mudança de cor de fundo) em vez de sombras pesadas, conforme o padrão M3.
*   **Glassmorphism (Opcional):** Pode ser usado em elementos específicos (como blur em AppBars ou fundos de diálogos) para conferir um aspecto mais moderno e sofisticado.

## 4. Tipografia

*   **Hierarquia Clara:** Diferenciar claramente títulos, subtítulos e corpo de texto usando pesos e tamanhos da escala tipográfica do M3.
*   **Poppins:** Conforme definido no `ui-design-system.md`, utilizar a fonte Poppins com pesos variados para criar ritmo visual.

## 5. Componentes e Comportamento

*   **Feedback Visual:** Todo botão deve ter um efeito de ripple/clique visível e apropriado.
*   **Loading States:** Usar `DefaultShimmer` ou skeletons elegantes em vez de apenas um `CircularProgressIndicator` centralizado, para manter o layout estruturado durante o carregamento.
*   **Micro-Animações:** Utilizar animações implícitas (`AnimatedContainer`, `AnimatedOpacity`) para mudanças de estado simples.

## 6. Checklist de Qualidade Visual

- [ ] O componente respeita as margens padrão do `AppDimensions.i`?
- [ ] O texto está perfeitamente legível contra o fundo?
- [ ] O design "respira" ou está muito apertado?
- [ ] A interação parece "mágica" e suave ou travada?
- [ ] Segue as cores semânticas de `AppColors.i`?
