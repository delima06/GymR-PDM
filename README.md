# GymR - App de Treinos de Academia e Progressão de Carga

**Disciplina:** Programação de Dispositivos Móveis (PDM)  
**Instituição:** Universidade Federal do Rio Grande do Norte (UFRN)  
**Docente:** Taniro Chacon Rodrigues  
**Discentes:** Pedro Davi e Thiago de Lima  
**Tema:** 11 — App de Treinos de Academia e Progressão de Carga  

---

## 1. Visão Geral e Contexto

No universo da musculação e da calistenia, a **sobrecarga progressiva** é a variável mais determinante para a hipertrofia e o ganho de força a longo prazo. Entretanto, a grande maioria dos praticantes enfrenta dificuldades práticas no dia a dia da academia: fichas de treino em papel que se perdem ou desgastam, anotações desorganizadas em blocos de notas e perda de sinal de internet em ambientes fechados ou subsolos.

O **GymR** foi concebido para resolver essas fricções reais. Trata-se de um aplicativo móvel desenhado sob a filosofia *offline-first*, garantindo autonomia completa mesmo sem conexão de rede. Ele une organização metódica de rotinas de treino, execução guiada com cronômetro em tempo real, monitoramento científico de progressão de carga (1RM) e acompanhamento antropométrico de evolução física.

---

## 2. Requisitos Funcionais e Implementação

O projeto contempla integralmente o escopo definido na proposta da disciplina:

| Requisito Funcional | Descrição e Implementação Técnica |
| :--- | :--- |
| **Catálogo Ilustrado de Exercícios** | Banco de dados relacional populado via seed com dezenas de exercícios classificados por grupamento muscular (*Peito, Costas, Pernas, Ombros, Braços, Core*) e por tipo de equipamento (*Barra, Halteres, Máquina, Peso Corporal*). Cada exercício conta com orientações técnicas de execução, músculos primários/secundários e referências visuais. |
| **Criador de Fichas e Divisões de Treino** | Interface para criação e personalização de rotinas semanais (ex.: *ABC, Upper/Lower, Full Body, Push/Pull/Legs*). Permite definir o volume de séries, faixa alvo de repetições (mínima e máxima), carga inicial, tempo de descanso entre séries e reordenação dinâmica de exercícios com drag-and-drop (`ReorderableListView`). |
| **Modo "Treino Ativo" com Cronômetro** | Ambiente de execução ao vivo durante a sessão. O atleta marca séries concluídas, ajusta pesos e repetições reais executadas no momento e ativa automaticamente o cronômetro regressivo de descanso com alertas visuais e sonoros/hápticos. |
| **Cálculo de 1RM e Sugestão de Progressão** | Armazenamento de registros de carga e cálculo automatizado da estimativa de 1 Repetição Máxima (1RM) através da equação validada de Epley: $$1\text{RM} = \text{Carga} \times \left(1 + \frac{\text{Reps}}{30}\right)$$ O sistema monitora Recordes Pessoais (PR) e sugere incrementos incrementais de sobrecarga assim que o usuário atinge o limite superior da faixa de repetições estipulada na ficha. |
| **Acompanhamento Antropométrico** | Módulo de evolução física com registro histórico de peso corporal, percentual de gordura estimado e circunferências corpóreas (braço, tórax, cintura, quadril e panturrilha), viabilizando a análise de correlação entre ganho de força e composição corporal. |
| **Funcionamento 100% Offline** | Arquitetura *offline-first* alimentada por banco de dados relacional local **SQLite** (`sqflite`). Toda criação de ficha, histórico de sessões e consulta de exercícios é armazenada em disco local com transações atômicas (ACID), permitindo funcionamento pleno em academias sem cobertura de rede móvel ou Wi-Fi. |

---

## 3. Arquitetura e Decisões de Engenharia

O projeto segue rigorosamente a **Arquitetura Oficial Sugerida pelo Time Flutter** ([docs.flutter.dev/app-architecture](https://docs.flutter.dev/app-architecture)), adotada nas aulas do Prof. Taniro Chacon Rodrigues. A estrutura fundamenta-se nos princípios de **Separação de Responsabilidades (SoC)**, **Fonte Única de Verdade (SSOT)** e **Fluxo Unidirecional de Dados (UDF)** através do padrão **MVVM (Model-View-ViewModel)**.

### Mapeamento das Camadas

1. **Camada de Apresentação (UI Layer):**
   - **Views:** Widgets puramente declarativos (`DashboardView`, `WorkoutsView`, `ActiveWorkoutView`, `ProgressView`). São responsáveis exclusivamente pela renderização dos componentes, captura de eventos do usuário (toques, formulários, reordenações) e transições de tela. Não contêm lógica de negócio ou persistência.
   - **ViewModels:** Classes `ChangeNotifier` (`DashboardViewModel`, `WorkoutsViewModel`, `ActiveWorkoutViewModel`, `ProgressViewModel`). Gerenciam o estado da tela (`UI State`), processam regras de apresentação (cálculo de 1RM com a equação de Epley, timers de descanso) e expõem comandos assíncronos acionados pelas Views.

2. **Camada de Domínio (Domain Layer):**
   - **Models:** Entidades de domínio imutáveis (`Exercise`, `Workout`, `WorkoutExercise`, `WorkoutSession`, `WorkoutSet`, `Measurement`). Representam as estruturas de negócio fundamentais do aplicativo, independentes de plugins externos ou de detalhes do banco de dados.

3. **Camada de Dados (Data Layer / Model Layer):**
   - **Repositories:** Fontes únicas da verdade (`ExerciseRepository`, `WorkoutRepository`, `HistoryRepository`). Encapsulam operações de CRUD, conversões de registros em objetos de domínio e garantem a integridade relacional. São injetados diretamente nos ViewModels via `MultiProvider`.
   - **Data Sources / Local Database:** Módulo `AppDatabase` encapsulando as operações nativas do SQLite (`sqflite`), garantindo persistência local ACID em disco com suporte a operações transacionais completas.

### Fluxo Unidirecional de Dados (UDF)
O ciclo de atualização em todas as telas respeita estritamente o fluxo unidirecional:
$$\text{[View: Evento de Usuário]} \xrightarrow{\text{Command}} \text{[ViewModel]} \xrightarrow{\text{Mutação/Consulta}} \text{[Repository]} \xrightarrow{\text{SQLite}} \text{[Data]}$$
$$\text{[Data]} \xrightarrow{\text{Model}} \text{[Repository]} \xrightarrow{\text{UI State}} \text{[ViewModel]} \xrightarrow{\text{notifyListeners()}} \text{[View: Rebuild]}$$

### Estrutura de Diretórios
```
lib/
├── core/
│   └── theme/                  # Tokens visuais (AppColors, AppTheme)
├── data/
│   ├── database/               # Driver e migrações SQLite (AppDatabase)
│   └── repositories/           # Repositórios (ExerciseRepository, WorkoutRepository, HistoryRepository)
├── domain/
│   └── models/                 # Modelos de domínio (Exercise, Workout, Measurement, etc.)
└── ui/
    ├── active_workout/         # View & ViewModel da sessão ao vivo com cronômetro
    ├── dashboard/              # View & ViewModel do painel principal
    ├── exercises/              # Detalhes técnicos e catálogo de exercícios
    ├── progress/               # View & ViewModel de cargas, 1RM e antropometria
    ├── widgets/                # Componentes compartilhados (GymrLogoTitle, etc.)
    └── workouts/               # View & ViewModel de fichas e rotinas semanais
```

### Tecnologias e Bibliotecas Utilizadas
- **Framework:** [Flutter](https://flutter.dev) (Dart SDK `>=3.5.0 <4.0.0`)
- **Gerenciamento de Estado:** `provider` (gerência reativa com `ChangeNotifier`)
- **Persistência Local:** `sqflite` + `path` / `path_provider` (SQLite nativo Android/iOS)
- **Design System:** Material 3 Dark com tema customizado *Kinetic Neon Performance* e `google_fonts` (Plus Jakarta Sans)
- **Utilitários:** `intl` (formatação de datas e números) e `uuid` (geração de identificadores determinísticos)

---

## 4. Como Executar o Projeto

### Pré-requisitos
- Flutter SDK instalado (versão estável 3.24+ ou superior)
- Android SDK configurado (Java JDK 17, Android NDK 28+)
- Dispositivo Android com depuração USB ativada ou emulador configurado

### Passo a Passo

1. **Clonar o repositório:**
   ```bash
   git clone https://github.com/pedrodavs/GymR-PDM.git
   cd GymR-PDM
   ```

2. **Instalar as dependências do pubspec:**
   ```bash
   flutter pub get
   ```

3. **Verificar a integridade do código:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Executar em modo desenvolvimento:**
   ```bash
   flutter run
   ```

5. **Gerar o pacote de produção (APK Release):**
   ```bash
   flutter build apk --release
   ```
   O instalador otimizado e minificado com R8 estará disponível em:
   `build/app/outputs/flutter-apk/app-release.apk`
