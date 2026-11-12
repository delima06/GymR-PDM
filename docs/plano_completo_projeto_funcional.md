# GymR — Plano Diretor de Implementação e Credibilidade Funcional

> **Projeto:** GymR — App de Treinos de Academia e Progressão de Carga  
> **Disciplina:** Programação para Dispositivos Móveis (PDM) — UFRN  
> **Tema:** 11 — Sobrecarga Progressiva, Gestão de Treinos e Antropometria  
> **Docente:** Prof. Taniro Chacon Rodrigues  
> **Padrão de Engenharia:** MVVM Oficial Flutter, Offline-First Híbrido (SQLite + Firebase Sync)  

---

## 1. Visão Estratégica: O que Torna o GymR 100% Crível e Funcional?

Para que o projeto atinja nota máxima na avaliação acadêmica e se destaque como produto de mercado, ele **não pode se comportar como um protótipo estático**. Todo o ciclo de vida do praticante de musculação deve estar amarrado por dados reais, cálculos biomecânicos e persistência consistente.

### Os 4 Pilares da Credibilidade Funcional:
1. **Sobrecarga Progressiva Real (Equação de Epley):**
   $$1\text{RM} = \text{Carga} \times \left(1 + \frac{\text{Reps}}{30}\right)$$
   O cálculo do 1RM e os Recordes Pessoais (PR) devem ser derivados das séries que o usuário **realmente concluiu** no Treino Ativo, e não de constantes fixas.
2. **Ciclo Completo do Treino Ativo:**
   Ao clicar em *"Iniciar Treino"*, o usuário entra no ambiente de execução. Ao marcar uma série:
   - Dispara o **cronômetro regressivo de descanso** com alerta háptico/vibração real (`HapticFeedback.heavyImpact`).
   - Salva pesos e reps ajustados pelo usuário no momento.
   - Ao clicar em *"Finalizar Treino"*, grava a sessão atômica no banco, incrementa o Streak, calcula o volume total (kg) e atualiza o Dashboard em tempo real.
3. **Persistência Híbrida: SQLite Local + Firebase Cloud Sync:**
   - **Garante a exigência pedagógica da disciplina:** O SQLite local (`sqflite`) é a primeira linha de persistência offline (funciona em subsolo sem internet).
   - **Garante o nível profissional de produto:** O Firebase Authentication gerencia a identidade do atleta e o Cloud Firestore sincroniza os treinos e bioimpedância na nuvem para múltiplos dispositivos.
4. **Bioimpedância e Antropometria Integrada:**
   Ao registrar uma nova pesagem ou medição (braço, cintura, tórax), os cards do Perfil e do Progresso refletem a variação $\Delta$ real comparada à medição anterior.

---

## 2. Mapa de Telas e Fluxos de Dados Funcionais

```
                  +-----------------------------------+
                  |           INÍCIO DO APP           |
                  |     AuthGate (Verifica Sessão)    |
                  +-----------------------------------+
                       /                         \
         [Não Autenticado]                     [Autenticado]
               v                                     v
    +-----------------------+              +-----------------------------+
    |       AUTH FLOW       |              |  MainNavigationScaffold     |
    | - LoginView           |              |  (BottomNavBar 5 Abas)      |
    | - RegisterView        |              +-----------------------------+
    | - Modo Convidado      |                            |
    +-----------------------+                            |
                                 +-----------------------+-----------------------+
                                 |           |           |           |           |
                                 v           v           v           v           v
                            [INÍCIO]    [TREINOS]    [EXECUÇÃO]  [PROGRESSO]  [PERFIL]
```

### Aba 1: Início (DashboardView)
* **Tempo Ativo Real:** Soma da duração de todas as sessões executadas na semana atual.
* **Health Grade / Consistência:** Porcentagem calculada a partir da meta semanal estipulada (ex.: 4 treinos/semana).
* **Treino de Hoje:** Identifica a próxima ficha a ser executada na sequência do split (ex.: se ontem foi Treino A, hoje sugere Treino B).
* **Botão *"Iniciar Treino"*: Direciona para o Treino Ativo pré-carregando a ficha do dia.

### Aba 2: Fichas de Treino (WorkoutsView)
* **Pílulas de Fichas (A, B, C, D...):** Alternância reativa entre as divisões cadastradas.
* **Lista de Exercícios:** Cada exercício exibe imagem ilustrativa, número de séries, faixa alvo de repetições e carga base.
* **Criador de Treino (`CreateWorkoutView`):**
  - Nome do Treino, Divisão/Split (ex.: "Treino A - Peito e Tríceps").
  - Seleção de exercícios do **Catálogo Relacional** (pesquisa e filtro por grupo muscular).
  - Reordenação dinâmica (`ReorderableListView`).
  - Salvamento síncrono local no SQLite + upload assíncrono no Firestore.

### Aba 3: Treino Ativo (`ActiveWorkoutView`)
* **Cronômetro Total da Sessão:** Timer contínuo no cabeçalho.
* **Cronômetro Regressivo de Descanso:**
  - Acionado automaticamente ao marcar o checkbox de uma série.
  - Botões rápidos: `+30s`, `Pular Descanso`.
  - Vibração tátil no aparelho quando zerar.
* **Tabela de Séries Editáveis:**
  - Inputs de carga (kg) e repetições reais executadas.
  - Cálculo instantâneo de 1RM por série.
* **Finalização:**
  - Dialog de resumo com Volume Total (kg) erguido, tempo decorrido e novo Recorde Pessoal (PR) caso batido.

### Aba 4: Progresso e Sobrecarga (`ProgressView`)
* **Gráfico de Evolução de Carga:**
  - Seletor de exercício (ex.: Supino Reto, Agachamento, Levantamento Terra).
  - Plota os pontos reais das últimas sessões registradas pelo usuário.
* **Histórico de Recordes (PR):**
  - Mostra os maiores 1RMs alcançados com data e evolução percentual.
* **Antropometria (Peso, Braço, Cintura, BF):**
  - Botão *"Registrar Medição"* abre o modal com formulário completo.
  - Gráfico ou cards comparativos calculando $\Delta$ (ganho ou perda de peso/medidas).

### Aba 5: Perfil do Atleta (`ProfileView`)
* **Dados Pessoais:** Nome, nível atlético (Iniciante, Intermediário, Avançado), ID do atleta.
* **Streak Real:** Contagem consecutiva de semanas ativas calculada a partir do histórico de sessões.
* **Modal de Edição de Perfil:** Atualiza nome, meta de peso e bioimpedância.
* **Gerenciamento de Conta:** Botão funcional de Sair da Conta (`SignOut`) que retorna com segurança para a tela de autenticação.

---

## 3. Arquitetura de Dados: Estratégia Híbrida (SQLite + Firebase)

Para unir a exigência de PDM (banco SQLite local) com a sofisticação do Firebase:

```
[UI / ViewModels]
       |
       v
[Repositories Unificados]
       |
       +---> 1. Persistência Imediata no SQLite Local (sqflite) -> Garantia Offline 100%
       |
       +---> 2. Sync Assíncrono com Firebase Firestore (users/{uid}/...) -> Backup em Nuvem
```

### 3.1 Tabelas no SQLite Local (`sqflite`):
* `workouts`: `id`, `user_id`, `name`, `split`, `description`, `created_at`.
* `workout_exercises`: `id`, `workout_id`, `exercise_name`, `target_sets`, `min_reps`, `max_reps`, `target_weight`, `rest_seconds`, `order_index`.
* `workout_sessions`: `id`, `user_id`, `workout_id`, `started_at`, `finished_at`, `duration_seconds`, `total_volume_kg`.
* `set_logs`: `id`, `session_id`, `exercise_name`, `set_number`, `reps`, `weight_kg`, `rpe`, `is_completed`.
* `body_measurements`: `id`, `user_id`, `measured_at`, `weight_kg`, `body_fat`, `arms_cm`, `waist_cm`, `chest_cm`.
* `user_profile`: `user_id`, `name`, `email`, `tier`, `streak_days`, `target_weight_kg`.

### 3.2 Estrutura Espelho no Cloud Firestore:
* `/users/{uid}`
* `/users/{uid}/workouts/{workoutId}`
* `/users/{uid}/sessions/{sessionId}`
* `/users/{uid}/measurements/{measurementId}`

---

## 4. Cronograma de Execução Faseado

### Fase 1: Autenticação & Infraestrutura Firebase
- [x] Correção das permissões de internet no Android (`AndroidManifest.xml`).
- [ ] Adição das dependências Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`).
- [ ] Configuração do `google-services.json` em `android/app/`.
- [ ] Implementação de `AuthService` e `AuthRepository`.
- [ ] Criação de `LoginView`, `RegisterView` e `AuthGate` com design neon/sombrio Stitch.

### Fase 2: Conexão Fim-a-Fim do Treino Ativo e Dashboard
- [ ] Fazer com que o botão *"Iniciar Treino"* da Dashboard e da lista de treinos injete a ficha selecionada no `ActiveWorkoutViewModel`.
- [ ] Vincular a finalização do treino à gravação da sessão no banco SQLite e Firestore.
- [ ] Atualizar o Dashboard para ler o tempo ativo e consistência das sessões reais salvas.

### Fase 3: Módulo de Evolução e Recordes Pessoais (PR)
- [ ] Implementar a consulta de 1RM na tabela `set_logs` para exibir a evolução histórica real no gráfico da `ProgressView`.
- [ ] Modal de *"Nova Medição"* persistindo os dados e recalculando $\Delta$ de peso e medidas corporais.

### Fase 4: Perfil e Sincronização em Nuvem
- [ ] Modal de Edição de Perfil salvando no banco local e atualizando o Firestore.
- [ ] Botão de Logout desconectando do Firebase Auth e limpando o estado de navegação.

### Fase 5: Auditoria de Qualidade e Entrega
- [ ] Validação rigorosa com `flutter analyze` (0 warnings).
- [ ] Bateria de testes automatizados com `flutter test`.
- [ ] Geração do APK Release final (`flutter build apk --release`).

