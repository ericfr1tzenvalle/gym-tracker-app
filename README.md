# LilGym

Aplicativo Flutter para montar treinos a partir de um catálogo, registrar séries e consultar o histórico. Os treinos, sessões e séries ficam no SQLite do aparelho, separados pelo `uid` do Firebase Authentication.

## Pré-requisitos

- Flutter com Android SDK e JDK 17 instalados (`flutter doctor`); neste ambiente o build exige `JAVA_HOME=/usr/lib/jvm/java-17-openjdk`
- Um dispositivo ou emulador Android
- Projeto Firebase com Authentication → Sign-in method → **Email/Password** habilitado
- Uma conta de demonstração criada em Authentication → Users (a senha não deve entrar neste repositório)
- `android/app/google-services.json` com um cliente Android cujo `package_name` seja `com.example.gym_tracker`

O primeiro login exige internet. Depois dele, o Firebase Auth mantém a sessão local e o SQLite permite abrir os dados do aparelho offline. O app não sincroniza dados entre dispositivos.

## Rodar e testar

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d <id-do-android>
```

## Gerar o APK

```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk flutter build apk --debug
```

O arquivo gerado fica em `build/app/outputs/flutter-apk/app-debug.apk`. Para instalar: `adb install -r build/app/outputs/flutter-apk/app-debug.apk`.

## Fluxo atual

Faça login com a conta de demonstração. A conta nova começa sem treinos. Crie um treino na Home ou em Workouts, abra os detalhes e toque em **Exercise** para incluir um exercício do catálogo. O plano inicial é 3 séries de 8–12 repetições; toque no exercício para editar a faixa e segure para reordenar. Na Home, inicie um treino com exercícios ou retome a sessão ativa. Registre séries com carga igual ou maior que zero e repetições inteiras positivas. A sessão só termina ao tocar em **Finalizar treino**. A aba Evolution mostra sessões concluídas e os registros por exercício. Sair da conta mantém os dados locais dela.

O histórico preserva o nome do treino e do exercício na sessão, inclusive após excluir o treino. Sessões canceladas não aparecem no histórico nem geram sugestões. Não há cadastro de exercícios pelo usuário, Firestore, sincronização em nuvem, gráficos ou agenda semanal.

## Caminho do código

- `lib/main.dart` inicializa o Firebase; `lib/auth_gate.dart` lê o estado de autenticação e fornece o `uid` ao `AppShell`.
- `lib/app_shell.dart` abre o SQLite da conta e cria os controladores.
- `lib/pages/exercise_selection_page.dart` → `lib/controllers/workout_controller.dart` → `lib/repositories/workout_repository.dart` → `lib/repositories/account_database.dart` monta e grava o treino.
- `lib/pages/workout_session_page.dart` → `lib/controllers/workout_session_controller.dart` → `lib/repositories/session_repository.dart` registra, corrige e finaliza sessões.
- `lib/pages/evolution_page.dart` consulta o histórico de sessões concluídas.

## Roteiro da apresentação

Login online → criar treino pelo catálogo → iniciar pela Home → ativar modo avião → registrar série → fechar e reabrir → retomar e corrigir → finalizar pelo botão visível → mostrar histórico por sessão e por exercício.
