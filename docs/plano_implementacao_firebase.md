# Plano de Engenharia e Implementação: Integração Firebase (Firestore & Authentication)

> **Documento Arquitetural de Engenharia de Software**  
> **Projeto:** GymR Workout Tracker (GymR-PDM)  
> **Status:** Pronto para Execução  
> **Padrão:** Clean Architecture / MVVM / Offline-First / Zero Mock Data  

---

## 1. Diagnóstico do Problema de Imagens no APK Release

### 1.1 Causa-Raiz
No Android, o Flutter divide as configurações de manifesto em três camadas: `debug`, `profile` e `main`.  
* O arquivo `android/app/src/debug/AndroidManifest.xml` continha `<uses-permission android:name="android.permission.INTERNET"/>` apenas para propósitos do debugger local.
* O arquivo principal de produção (`android/app/src/main/AndroidManifest.xml`) **não continha** a declaração de permissão de Internet.
* Ao gerar o APK em modo `--release`, o Gradle utiliza exclusivamente o manifesto principal e os manifestos de plugins externos. Como resultado, o sistema operacional Android bloqueou todas as conexões de rede (`SocketException` / `PermissionDenied`), impedindo que o `Image.network` baixasse as imagens dos exercícios e avatares no dispositivo físico.

### 1.2 Correção Já Aplicada
O arquivo `android/app/src/main/AndroidManifest.xml` foi atualizado com as permissões essenciais de rede:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    ...
```
*Compilação validada com `flutter analyze` (0 issues).*

---

## 2. Arquitetura da Solução com Firebase

O GymR operará no modelo **Offline-First**, utilizando o **Firebase Authentication** para controle de identidade e o **Cloud Firestore** para persistência e sincronização de dados multi-dispositivo. Como academias frequentemente possuem sinal de internet instável ou inexistente, a persistência offline nativa do Firestore garantirá que o atleta registre séries e consulte fichas sem qualquer bloqueio.

```
+-------------------------------------------------------------------------+
|                              CAMADA DE UI                               |
|   DashboardView  |  WorkoutsView  |  ActiveWorkoutView  |  ProgressView  |  ProfileView  |  AuthViews
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
|                            VIEWMODELS (MVVM)                            |
|             Gerenciamento de Estado Reativo & Notificações              |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
|                      CAMADA DE REPOSITÓRIOS (CONTRATOS)                 |
|   IAuthRepository | IWorkoutRepository | ISessionRepository | IMeasurementRepository
+-------------------------------------------------------------------------+
                                    |
                  +-----------------+-----------------+
                  |                                   |
                  v                                   v
+----------------------------------+ +----------------------------------+
|      FIRESTORE REPOSITORIES      | |      LOCAL CACHE / OFFLINE       |
|    Cloud Firestore SDK Remoto    | |    Firestore Offline Persistence |
|   (users, workouts, sessions)    | |    (Sincronização Automática)    |
+----------------------------------+ +----------------------------------+
```

---

## 3. Modelagem de Dados no Cloud Firestore

Toda a árvore de dados será isolada por usuário sob `/users/{userId}`, garantindo segurança estrita e compatibilidade nativa com as regras de acesso do Firestore.

### 3.1 Coleção: `/users/{userId}`
Armazena a identidade esportiva e biometria resumida do atleta.
```json
{
  "uid": "USER_AUTH_UID",
  "name": "Lucas Silva",
  "email": "lucas@example.com",
  "athleteTier": "Intermediário B",
  "userCode": "GR-9284",
  "planTier": "PRO ELITE",
  "streakDays": 12,
  "currentWeightKg": 78.4,
  "weightDeltaKg": -2.1,
  "targetWeightKg": 82.0,
  "leanMassKg": 66.2,
  "bodyFatPercentage": 14.8,
  "bodyFatDelta": -1.2,
  "photoUrl": "https://...",
  "createdAt": "2026-11-12T00:00:00Z",
  "updatedAt": "2026-11-12T00:00:00Z"
}
```

### 3.2 Subcoleção: `/users/{userId}/workouts/{workoutId}`
Armazena as fichas de treino criadas pelo usuário ou treinador.
```json
{
  "id": "workout_push_01",
  "name": "Treino A - Peito, Ombros e Tríceps",
  "split": "Treino A",
  "description": "Foco em hipertrofia de superiores com ênfase em cadeia anterior.",
  "targetMuscleGroups": ["Peito", "Ombros", "Tríceps"],
  "estimatedDurationMinutes": 60,
  "exercises": [
    {
      "id": "ex_supino_reto",
      "exerciseName": "Supino Reto com Barra",
      "targetMuscle": "Peito",
      "targetSets": 4,
      "minReps": 8,
      "maxReps": 10,
      "targetRpe": 8.5,
      "restTimeSeconds": 90,
      "weightKg": 80.0,
      "notes": "Pausa de 1s no peitoral.",
      "order": 1
    }
  ],
  "createdAt": "2026-11-12T00:00:00Z",
  "updatedAt": "2026-11-12T00:00:00Z"
}
```

### 3.3 Subcoleção: `/users/{userId}/sessions/{sessionId}`
Registra o histórico de execuções completas de treino (dados do `ActiveWorkout`).
```json
{
  "id": "session_20261112_01",
  "workoutId": "workout_push_01",
  "workoutName": "Treino A - Peito, Ombros e Tríceps",
  "startedAt": "2026-11-12T18:00:00Z",
  "finishedAt": "2026-11-12T19:05:00Z",
  "durationSeconds": 3900,
  "totalVolumeKg": 8450.0,
  "completedSetsCount": 16,
  "notes": "Treino com alta intensidade e boa recuperação entre séries.",
  "exerciseLogs": [
    {
      "exerciseId": "ex_supino_reto",
      "exerciseName": "Supino Reto com Barra",
      "sets": [
        { "setNumber": 1, "reps": 10, "weightKg": 80.0, "rpe": 8.0, "isCompleted": true },
        { "setNumber": 2, "reps": 10, "weightKg": 80.0, "rpe": 8.5, "isCompleted": true },
        { "setNumber": 3, "reps": 9,  "weightKg": 80.0, "rpe": 9.0, "isCompleted": true },
        { "setNumber": 4, "reps": 8,  "weightKg": 80.0, "rpe": 9.5, "isCompleted": true }
      ]
    }
  ]
}
```

### 3.4 Subcoleção: `/users/{userId}/measurements/{measurementId}`
Histórico de bioimpedância e aferição de medidas corporais.
```json
{
  "id": "measurement_20261112",
  "measuredAt": "2026-11-12T07:30:00Z",
  "weightKg": 78.4,
  "bodyFatPercentage": 14.8,
  "chestCm": 102.5,
  "armsCm": 39.5,
  "waistCm": 79.0,
  "thighsCm": 59.0,
  "calvesCm": 38.0,
  "notes": "Avaliação em jejum pela manhã."
}
```

---

## 4. Regras de Segurança do Firestore (`firestore.rules`)

Segurança em nível de linha com zero acesso anônimo:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Função auxiliar de autenticação
    function isAuthenticated() {
      return request.auth != null;
    }
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Cada usuário possui acesso exclusivo aos seus próprios documentos
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /workouts/{workoutId} {
        allow read, write: if isOwner(userId);
      }

      match /sessions/{sessionId} {
        allow read, write: if isOwner(userId);
      }

      match /measurements/{measurementId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

---

## 5. Roteiro Passo a Passo de Implementação

### Fase 1: Setup do Firebase no Projeto Flutter
1. **Adicionar Pacotes Oficiais no `pubspec.yaml`:**
   - `firebase_core: ^3.12.0`
   - `firebase_auth: ^5.5.0`
   - `cloud_firestore: ^5.6.5`
2. **Configuração de Plataforma Android:**
   - Inclusão do plugin `com.google.gms.google-services` em `android/build.gradle.kts` e `android/app/build.gradle.kts`.
   - Adição do arquivo `google-services.json` em `android/app/`.
   - Execução do FlutterFire CLI (`flutterfire configure`) para geração de `lib/firebase_options.dart`.
3. **Inicialização no `lib/main.dart`:**
   - Inicializar `WidgetsFlutterBinding.ensureInitialized()`.
   - `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
   - Habilitar `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true)`.

---

### Fase 2: Módulo de Autenticação (Design System Stitch)
1. **Contratos & Repositório:**
   - Criação de `lib/core/services/auth_service.dart` e `lib/core/repositories/auth_repository.dart`.
   - Métodos: `signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `sendPasswordResetEmail`, `signOut`, `currentUserStream`.
2. **Telas de Autenticação:**
   - `lib/ui/auth/login_view.dart`: Tela de login com fundo escuro (`#0E0F12`), campos com borda sutil (`#22242A`), botão primário neon (`#10D85E`) e tipografia Inter/Plus Jakarta Sans.
   - `lib/ui/auth/register_view.dart`: Criação de conta (Nome, Email, Senha, Confirmação) com criação imediata do perfil padrão no Firestore.
   - `lib/ui/auth/forgot_password_view.dart`: Recuperação de senha por e-mail.
3. **Guardião de Rotas (`AuthGate`):**
   - Criação de `lib/ui/auth/auth_gate.dart`:
     - Se `snapshot.hasData` (usuário logado) -> renderiza `MainNavigationScaffold`.
     - Caso contrário -> renderiza `LoginView`.

---

### Fase 3: Migração dos Repositórios para Cloud Firestore
1. **Serialização dos Modelos:**
   - Atualizar `Workout`, `WorkoutExercise`, `WorkoutSession`, `SetLog`, `BodyMeasurement` e `UserProfile` com métodos `toMap()` e `fromMap(Map<String, dynamic> data, String id)` ou `fromFirestore(DocumentSnapshot doc)`.
2. **Implementações Firestore:**
   - `lib/core/repositories/firestore_workout_repository.dart`: Escuta reativa via `Stream<List<Workout>>` e métodos assíncronos de inserção, edição e exclusão.
   - `lib/core/repositories/firestore_session_repository.dart`: Persistência de sessões finalizadas e cálculo de métricas de volume e frequência.
   - `lib/core/repositories/firestore_measurement_repository.dart`: Registro de medidas e geração de dados para os gráficos de carga e bioimpedância.
   - `lib/core/repositories/firestore_user_profile_repository.dart`: Leitura e atualização do atleta ativo.

---

### Fase 4: Adaptação das Telas & ViewModels
1. **`DashboardViewModel`:**
   - Obter dados do usuário ativo do Firestore em tempo real.
   - Métricas como tempo ativo semanal, frequência de treinos e cards dinâmicos derivados de sessões gravadas.
2. **`WorkoutsViewModel` & `CreateWorkoutView`:**
   - Persistir novas fichas e exercícios diretamente na subcoleção do Firestore.
   - Sincronização automática entre abas.
3. **`ActiveWorkoutViewModel`:**
   - Finalização do treino grava a sessão completa no Firestore.
   - Atualização automática do streak e do volume total do usuário.
4. **`ProgressViewModel`:**
   - Gráficos de evolução de carga puxando dados históricos de sessões reais gravadas.
   - Exibição de peso corporal, braço e cintura baseados em `measurements`.
5. **`ProfileViewModel`:**
   - Botão "Sair da Conta" funcional com `authRepository.signOut()`.
   - Edição de perfil salva imediatamente no documento do atleta.

---

### Fase 5: Validação, Testes e Segurança
1. **Testes Unitários:**
   - Mocks de `FirebaseAuth` e `FirebaseFirestore` via `fake_cloud_firestore` e `firebase_auth_mocks`.
   - Teste de fluxo completo de autenticação e recuperação de treinos.
2. **Verificação de Regras:**
   - Validação de que um usuário não autenticado não consegue ler documentos de outro usuário.
3. **Qualidade de Código:**
   - `flutter analyze` com 0 avisos.
   - `flutter test` com 100% de sucesso.
4. **Geração do APK Release Atualizado:**
   - Compilação com permissões de rede ativas e SDK do Firebase configurado.

---

## 6. Próximo Passo Imediato
Para iniciarmos a implementação, você precisa apenas fornecer o arquivo de credenciais do Firebase:
* `google-services.json` (do seu projeto no console do Firebase) colocado em `android/app/`.  
* Com isso, faremos a instalação dos pacotes, o setup das telas de Login/Cadastro e a migração de toda a persistência local para o Cloud Firestore.

