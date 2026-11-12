# GymR — Plano Diretor de Engenharia de Software e Projeto Funcional

> **Disciplina:** Programação para Dispositivos Móveis (PDM)  
> **Instituição:** Universidade Federal do Rio Grande do Norte (UFRN)  
> **Docente:** Prof. Taniro Chacon Rodrigues  
> **Discentes:** Pedro Davi e Thiago de Lima  
> **Tema 11:** App de Treinos de Academia e Progressão de Carga  
> **Referência Arquitetural:** Arquitetura Oficial Recomendada pelo Time Flutter ([docs.flutter.dev/app-architecture](https://docs.flutter.dev/app-architecture))  
> **Estratégia de Implementação:** **SQLite Local e Funcionalidade Fim-a-Fim Primeiro** $\rightarrow$ **Firebase por Último**  

---

## 1. Princípios de Engenharia e Padrão da Disciplina

O projeto GymR segue à risca a arquitetura pedagógica orientada pelo Prof. Taniro Chacon Rodrigues. A aplicação estrutura-se na **Separação de Responsabilidades (SoC)**, na **Fonte Única de Verdade (SSOT)** e no **Fluxo Unidirecional de Dados (UDF)** através do padrão **MVVM (Model-View-ViewModel)** com **`MultiProvider`** e **`ChangeNotifier`**.

### 1.1 Regra Fundamental da Implementação: Local-First (SQLite)
* O aplicativo **deve ser 100% funcional, responsivo e crível operando exclusivamente com o banco de dados relacional local SQLite (`sqflite`)**.
* Toda criação de fichas, registro de séries no Treino Ativo, cronômetro regressivo, cálculo de 1RM e aferições antropométricas operam localmente com persistência ACID em disco.
* **A integração com o Firebase (Authentication e Cloud Firestore) será implementada como última camada**, funcionando como um módulo complementar de sincronização em nuvem e backup, sem quebrar o requisito essencial de funcionamento offline da disciplina.

---

## 2. Arquitetura Orientada pelo Professor (Mapeamento de Camadas)

```
+---------------------------------------------------------------------------------------+
|                               CAMADA DE APRESENTAÇÃO (UI)                             |
|  [DashboardView]  [WorkoutsView]  [ActiveWorkoutView]  [ProgressView]  [ProfileView]  |
|                               (Widgets Declarativos)                                  |
+---------------------------------------------------------------------------------------+
                                           |  (Comandos / Eventos de Toque)
                                           v
+---------------------------------------------------------------------------------------+
|                                    VIEWMODELS (MVVM)                                  |
|   [DashboardViewModel]       [WorkoutsViewModel]       [ActiveWorkoutViewModel]       |
|            [ProgressViewModel]                 [ProfileViewModel]                     |
|                                (ChangeNotifier)                                       |
+---------------------------------------------------------------------------------------+
                                           |  (Consultas e Mutações)
                                           v
+---------------------------------------------------------------------------------------+
|                               CAMADA DE DADOS (DATA LAYER)                            |
|             [ExerciseRepository]  [WorkoutRepository]  [HistoryRepository]            |
|                               (Fontes Únicas da Verdade)                              |
+---------------------------------------------------------------------------------------+
                                           |  (Transações SQL ACID)
                                           v
+---------------------------------------------------------------------------------------+
|                             LOCAL DATABASE (AppDatabase)                              |
|                   SQLite Nativo (sqflite) em Armazenamento Interno                    |
|        Tabelas: exercises, workouts, workout_exercises, workout_sessions,             |
|                 workout_sets, measurements                                            |
+---------------------------------------------------------------------------------------+
                                           :
                                           : (Última Etapa: Backup Opcional em Nuvem)
                                           v
+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
:                          CAMADA REMOTA: FIREBASE (POR ÚLTIMO)                         :
:          Firebase Authentication (Identidade) + Cloud Firestore (Sync)                :
+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
```

### 2.1 Fluxo Unidirecional de Dados (UDF)
1. **Evento:** O usuário interage com a View (ex.: conclui uma série ou cria uma ficha).
2. **Comando:** A View despacha o método assíncrono para seu respectivo `ViewModel`.
3. **Persistência:** O `ViewModel` invoca o `Repository`, que executa a transação no SQLite (`AppDatabase`).
4. **Novo Estado:** O `Repository` retorna os dados atualizados para o `ViewModel`, que atualiza seu estado interno (`UI State`) e dispara `notifyListeners()`.
5. **Re-renderização:** As Views inscritas via `context.watch<T>()` ou `Consumer<T>` reconstroem apenas os componentes afetados com **Zero Overflow** e **Zero Mock Data**.

---

## 3. Especificação Funcional Fim-a-Fim (Base SQLite)

### 3.1 Aba 1: Início (`DashboardView`)
* **Tempo Ativo Semanal Real:**
  - Soma da coluna `durationSeconds` da tabela `workout_sessions` filtrada pelos últimos 7 dias.
  - Exibe no card de largura total (`TEMPO ATIVO`) o valor real formatado (ex.: "2h 45m").
* **Consistência Semanal (Health Grade):**
  - Relação percentual entre o número de sessões finalizadas na semana e a meta estipulada (ex.: 3 de 4 treinos = 75%).
* **Card "Treino de Hoje":**
  - Identifica a próxima ficha a ser executada na ordem das fichas cadastradas (`workouts`).
  - Botão **`INICIAR TREINO`**: Direciona automaticamente para a aba de *Treino Ativo*, injetando a ficha selecionada.
* **Categorias Superiores:** Filtram visualmente os treinos por divisão muscular.

---

### 3.2 Aba 2: Fichas de Treino (`WorkoutsView` & `CreateWorkoutView`)
* **Navegação por Abas de Fichas (A, B, C, D...):**
  - Lista de fichas vindas de `workoutRepository.getAllWorkouts()`.
* **Lista de Exercícios da Ficha:**
  - Renderiza cada exercício com imagem técnica correspondente (`ExerciseImageHelper`), número de séries, faixa alvo de repetições e carga base.
  - Toque no exercício abre `ExerciseDetailView` com instruções anatômicas completas.
* **Criador de Treino (`CreateWorkoutView`):**
  - Permite definir: Nome, Split (ex.: Push/Pull/Legs ou ABCD), e Descrição.
  - Adiciona exercícios diretamente do catálogo do SQLite (`exercises`).
  - Suporte a reordenação com drag-and-drop (`ReorderableListView`).
  - Salvamento transacional atômico no SQLite.

---

### 3.3 Aba 3: Modo "Treino Ativo" (`ActiveWorkoutView`)
* **Cronômetro da Sessão:**
  - Timer contínuo marcando a duração total do treino.
* **Tabela de Séries Interativa:**
  - Séries pré-preenchidas com a meta da ficha.
  - Campos de entrada editáveis para peso (kg) e repetições reais executadas.
  - Checkbox de conclusão de série.
* **Cronômetro Regressivo de Descanso:**
  - Ao marcar uma série como concluída, o cronômetro de descanso é ativado automaticamente com o tempo configurado no exercício (ex.: 60s ou 90s).
  - Controles rápidos: `+30s` e `Pular`.
  - **Feedback Háptico Real:** Ao zerar o tempo de descanso, o aparelho vibra (`HapticFeedback.vibrate()`).
* **Botão "Adicionar Série Extra":**
  - Permite ao atleta adicionar séries além do planejado em tempo real.
* **Finalização do Treino:**
  - Ao clicar em *"Finalizar Treino"*, calcula:
    - Volume total erguido: $\sum (\text{Carga} \times \text{Reps})$ das séries concluídas.
    - 1RM estimado por série via fórmula de Epley.
  - Grava a sessão em `workout_sessions` e as séries em `workout_sets`.
  - Dispara a atualização dos ViewModels das outras abas (Dashboard, Progresso e Perfil).

---

### 3.4 Aba 4: Progresso e Sobrecarga (`ProgressView`)
* **Cálculo Científico de 1RM (Equação de Epley):**
  $$1\text{RM} = \text{Carga} \times \left(1 + \frac{\text{Reps}}{30}\right)$$
  *(Para 1 repetição, $1\text{RM} = \text{Carga}$).*
* **Gráfico de Evolução de Carga:**
  - Seletor de exercício dinâmico baseado nos exercícios que o usuário já treinou.
  - Plota os pontos reais de carga máxima e 1RM das sessões finalizadas.
* **Sugestão de Sobrecarga Progressiva:**
  - Se o atleta realizou 12 ou mais repetições na carga atual, o sistema exibe o badge de recomendação para aumentar o peso no próximo treino.
* **Antropometria (Medidas Corporais):**
  - Exibe o último peso corporal registrado, circunferência de braço e cintura.
  - Variação calculada ($\Delta$) em relação à penúltima medição.
  - Botão **`REGISTRAR MEDIÇÃO`**: Modal com formulário completo que salva em `measurements` e atualiza a tela na hora.

---

### 3.5 Aba 5: Perfil do Atleta (`ProfileView`)
* **Identidade do Atleta:**
  - Nome, Nível Atlético e Código de Identificação.
* **Streak Real:**
  - Calculado pelo histórico de sessões consecutivas salvas em `workout_sessions`.
* **Cards de Biometria:**
  - Peso atual, massa magra estimada e percentual de gordura sincronizados com a tabela `measurements`.
* **Modal de Edição de Perfil:**
  - Permite alterar o nome do atleta e metas físicas.

---

## 4. Roteiro de Implementação em 5 Etapas Rigorosas

```
+-----------------------------------------------------------------------------------+
| ETAPA 1: PIPELINE DO TREINO ATIVO & REATIVIDADE DO DASHBOARD                      |
| -> Iniciar Treino pela Dashboard/Fichas -> Timer -> Gravação de Sessões SQLite     |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
| ETAPA 2: CÁLCULO DE 1RM, GRÁFICO HISTÓRICO & PROGRESSÃO DE CARGA                  |
| -> Integração da fórmula de Epley com dados de workout_sets -> Gráfico na Progress|
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
| ETAPA 3: MÓDULO ANTROPOMÉTRICO & BIOMETRIA COMPLETA                               |
| -> Modal de Medição Física -> Persistência em measurements -> Variação Delta      |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
| ETAPA 4: GESTÃO COMPLETA DE FICHAS (CRUD & REORDENAÇÃO)                           |
| -> Criador de Fichas -> ReorderableListView -> Catálogo de Exercícios             |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
| ETAPA 5 (ÚLTIMA): INTEGRAÇÃO FIREBASE (AUTH & CLOUD FIRESTORE SYNC)               |
| -> Firebase Auth -> Serviço de Sincronização em Nuvem sem quebrar SQLite          |
+-----------------------------------------------------------------------------------+
```

---

### Detalhamento das Etapas Técnicas:

#### Etapa 1: Pipeline do Treino Ativo & Reatividade do Dashboard
1. Ajustar `MainNavigationScaffold` e `ActiveWorkoutView` para que, ao chamar `_startWorkout([id])`, o treino seja carregado instantaneamente e a sessão inicie sem atrito.
2. Garantir que `ActiveWorkoutViewModel.finishWorkout()` grave com sucesso no SQLite e chame `loadDashboardData()`, `loadProgressData()` e `loadProfileData()`.
3. Validar no Dashboard que o card `TEMPO ATIVO` reflete a soma exata dos minutos de treinos finalizados.

#### Etapa 2: Cálculo de 1RM, Gráfico Histórico & Progressão de Carga
1. Conectar `ProgressViewModel.loadProgressData()` à tabela `workout_sets` via `HistoryRepository`.
2. Fazer o seletor de exercícios da `ProgressView` carregar dinamicamente os exercícios já executados pelo usuário.
3. Renderizar a curva histórica de carga real calculando o 1RM estimado de Epley.
4. Exibir o badge de sugestão de progressão de carga sempre que o atleta alcançar o topo da faixa de reps.

#### Etapa 3: Módulo Antropométrico & Biometria Completa
1. Ativar o modal de medição em `ProgressView` para capturar peso (kg), percentual de gordura (%), braço (cm), cintura (cm) e tórax (cm).
2. Salvar o registro em `measurements` via `HistoryRepository.saveMeasurement()`.
3. Calcular a diferença ($\Delta$) entre a última e a penúltima medição para exibir nos badges (+/- kg, +/- cm).
4. Refletir o peso mais recente e a bioimpedância na tela de `ProfileView`.

#### Etapa 4: Gestão Completa de Fichas (CRUD & Reordenação)
1. Vincular `CreateWorkoutView` ao `WorkoutRepository` para salvar novas rotinas com transação atômica.
2. Implementar a opção de exclusão e edição de fichas existentes.
3. Testar a reordenação de exercícios com `ReorderableListView`.

#### Etapa 5 (Por Último): Integração Firebase (Auth & Cloud Firestore Sync)
1. Adicionar `firebase_core`, `firebase_auth` e `cloud_firestore` no `pubspec.yaml`.
2. Adicionar o `google-services.json` em `android/app/`.
3. Implementar telas de `LoginView`, `RegisterView` com design neon/escuro do Stitch e a opção **"Modo Convidado / Continuar Offline"**.
4. Criar o serviço `FirebaseSyncService` que, de forma assíncrona e não-bloqueante, sincroniza os dados do SQLite local com o Cloud Firestore quando houver rede, preservando o funcionamento 100% autônomo do app.

---

## 5. Critérios de Aceite e Verificação Contínua
* **Compilação Limpa:** `flutter analyze` com **0 erros e 0 warnings**.
* **Suíte de Testes:** `flutter test` com **100% dos testes verdes**.
* **Zero Mock Data:** Todas as métricas exibidas em tela são originárias de leituras reais do SQLite.
* **Zero Overflow:** Layouts protegidos com `Flexible`, `Expanded` e `TextOverflow.ellipsis` em todas as resoluções de tela.
* **Pacote de Produção:** APK Release gerado e validado em dispositivo Android físico.
