# StockFlow — Gestão de Estoque para Supermercado

Aplicativo Flutter para controle de estoque de supermercado com autenticação via Firebase e sincronização em tempo real.

---

## Funcionalidades

- Login e cadastro de usuário com Firebase Auth
- Lembrar e-mail entre sessões
- Recuperação de senha por e-mail
- Cadastro, edição e exclusão de produtos
- Filtro por categoria em tempo real
- Ao salvar um produto, redireciona automaticamente para a categoria dele
- Indicador visual de estoque baixo (laranja ≤ 15 unidades, vermelho ≤ 5)
- Dados isolados por usuário via Firestore

---

## Tecnologias

- [Flutter](https://flutter.dev) 3.x (Dart 3.x)
- [Firebase Auth](https://firebase.google.com/products/auth)
- [Cloud Firestore](https://firebase.google.com/products/firestore)
- [Shared Preferences](https://pub.dev/packages/shared_preferences)

---

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (stable)
- [Git](https://git-scm.com/download/win)
- [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools) com o workload **Desktop development with C++**
- **Modo Desenvolvedor** ativado no Windows (`Win + R` → `ms-settings:developers`)

## Como rodar

```bash
git clone https://github.com/AlexandreVenturini/stockflow_app.git
cd stockflow_app
flutter pub get
flutter run -d windows
```

---

## Estrutura do projeto

```
lib/
├── main.dart                    # Ponto de entrada, tema e rotas
├── firebase_options.dart        # Configuração do Firebase
├── models/
│   ├── produto.dart             # Modelo de produto
│   └── categoria.dart           # Lista de categorias e cores
├── screens/
│   ├── login_screen.dart        # Tela de login
│   ├── register_screen.dart     # Tela de cadastro
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart         # Lista de produtos com filtro
│   └── produto_form_screen.dart # Formulário de cadastro/edição
└── services/
    ├── auth_service.dart        # Login, logout, cadastro
    └── produto_service.dart     # CRUD de produtos no Firestore
```
