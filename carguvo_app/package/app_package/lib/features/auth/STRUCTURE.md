# Auth Feature - Clean Architecture Structure

## 📁 Current Structure (Updated)

```
lib/features/auth/
│
├── 📂 data/                           ← Data Layer (External)
│   ├── 📂 datasources/
│   │   └── 📄 auth_remote_datasource.dart
│   │       ├── AuthRemoteDataSource (abstract)
│   │       └── AuthRemoteDataSourceImpl (with LoggerMixin)
│   │           ├── login()
│   │           ├── register()
│   │           ├── logout()
│   │           ├── refreshToken()
│   │           └── changePassword() → SbApiResponse<dynamic>
│   │
│   ├── 📂 models/
│   │   ├── 📄 auth_model.dart
│   │   │   ├── AuthModel (sealed class)
│   │   │   ├── LoginRequestModel (sealed class)
│   │   │   └── RegisterRequestModel (sealed class)
│   │   ├── 📄 auth_model.freezed.dart (generated)
│   │   └── 📄 auth_model.g.dart (generated)
│   │
│   └── 📂 repositories/
│       └── 📄 auth_flow_repository_impl.dart
│           └── AuthFlowRepositoryImpl implements AuthFlowRepository
│               (map response → AuthFlowResult union theo bảng §3 B3 design)
│
├── 📂 domain/                         ← Domain Layer (Business Logic)
│   ├── 📂 entities/
│   │   ├── 📄 auth_entity.dart
│   │   │   ├── AuthEntity (sealed class)
│   │   │   ├── LoginRequest / RegisterRequest / OtpRequest (sealed class)
│   │   ├── 📄 auth_entity.freezed.dart (generated)
│   │   ├── 📄 auth_flow_result.dart
│   │   │   └── AuthFlowResult union (plain Dart 3 sealed, KHÔNG freezed):
│   │   │       AuthFlowSuccess / AuthFlowOtpRequired / AuthFlowFailure
│   │   └── 📄 username_check_result.dart
│   │       └── UsernameCheckResult (enum, move từ datasource)
│   │
│   ├── 📂 repositories/
│   │   └── 📄 auth_repository.dart
│   │       └── AuthFlowRepository (abstract interface, trả AuthFlowResult)
│   │
│   ├── 📂 usecases/
│   │   ├── 📄 login_usecase.dart          (→ AuthFlowResult)
│   │   ├── 📄 register_usecase.dart       (→ AuthFlowResult)
│   │   ├── 📄 submit_otp_usecase.dart     (→ AuthFlowResult)
│   │   ├── 📄 check_username_usecase.dart (→ UsernameCheckResult)
│   │   └── 📄 logout_usecase.dart         (→ Future&lt;void&gt;)
│   │
│   ├── 📂 state/                     ← State Definitions
│   │   ├── 📄 auth_state.dart
│   │   │   ├── AuthState (sealed class)
│   │   │   ├── LoginFormState (sealed class)
│   │   │   └── RegisterFormState (sealed class)
│   │   └── 📄 auth_state.freezed.dart (generated)
│   │
│   ├── 📂 notifiers/                 ← Business Logic Controllers
│   │   └── 📄 auth_notifiers.dart
│   │       ├── AuthNotifier
│   │       ├── LoginFormNotifier
│   │       └── RegisterFormNotifier
│   │
│   └── 📂 providers/                 ← Dependency Injection
│       └── 📄 auth_providers.dart
│           ├── authNotifierProvider (nhận 4 usecase)
│           ├── loginFormNotifierProvider
│           ├── registerFormNotifierProvider (nhận CheckUsernameUseCase)
│           ├── otpFormNotifierProvider
│           ├── loginUseCaseProvider / registerUseCaseProvider
│           ├── submitOtpUseCaseProvider / logoutUseCaseProvider
│           ├── checkUsernameUseCaseProvider
│           └── authFlowRepositoryProvider
│               (CỐ Ý không đặt tên authRepositoryProvider — trùng provider
│                khác ở lib/providers/auth_provider.dart, hệ phone verification)
│
└── 📂 presentation/                   ← Presentation Layer (UI Only)
    ├── 📂 desktop/
    │   ├── 📂 screens/
    │   │   └── 📄 auth_desktop_screen.dart
    │   └── 📂 widgets/
    │       ├── 📄 auth_desktop_login_form.dart
    │       └── 📄 auth_desktop_register_form.dart
    │
    ├── 📂 tablet/
    │   └── 📂 screens/
    │       └── 📄 auth_tablet_screen.dart
    │
    ├── 📂 widgets/
    │   └── 📄 auth_text_field.dart
    │
    └── 📄 auth_screen.dart (Responsive wrapper)
```

---

## 🔄 Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER (UI)                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  AuthDesktopLoginForm                                │   │
│  │  - Hiển thị UI                                       │   │
│  │  - Lắng nghe user input                             │   │
│  │  - Gọi domain providers                             │   │
│  └─────────────────┬───────────────────────────────────┘   │
└────────────────────┼───────────────────────────────────────┘
                     │
                     ↓ ref.read(authNotifierProvider.notifier)
┌────────────────────┼───────────────────────────────────────┐
│                    │    DOMAIN LAYER (Business Logic)      │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  AuthNotifier (StateNotifier)                       │   │
│  │  - Validate business rules                          │   │
│  │  - Call use cases                                   │   │
│  │  - Manage state transitions                         │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ↓ loginUseCase.call()                   │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  LoginUseCase                                        │   │
│  │  - Pure business logic                               │   │
│  │  - Call repository interface                         │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ↓ authRepository.login()                │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  AuthFlowRepository (Abstract Interface)             │   │
│  │  - Define contract                                   │   │
│  └─────────────────┬───────────────────────────────────┘   │
└────────────────────┼───────────────────────────────────────┘
                     │
                     ↓ Implementation
┌────────────────────┼───────────────────────────────────────┐
│                    │       DATA LAYER (External)            │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  AuthFlowRepositoryImpl                              │   │
│  │  - Implement AuthFlowRepository                      │   │
│  │  - Map response → AuthFlowResult union               │   │
│  │  - Call data source                                  │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ↓ remoteDataSource.login()              │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  AuthRemoteDataSourceImpl                            │   │
│  │  - Make API calls                                    │   │
│  │  - Parse JSON                                        │   │
│  │  - Return AuthModel                                  │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ↓ HTTP POST /auth/login                 │
│                [ Backend API ]                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Dependency Graph

```
                    ┌──────────────────┐
                    │   Presentation   │
                    │   (UI Widgets)   │
                    └────────┬─────────┘
                             │
                             │ import domain/providers
                             │ import domain/state
                             │
                    ┌────────▼─────────┐
                    │      Domain      │
                    │  (Business Logic)│
                    └────────┬─────────┘
                             │
                   ┌─────────┼─────────┐
                   │                   │
       domain/     │         domain/   │     domain/
       state/      │         notifiers/│     providers/
    ┌──────────┐   │      ┌──────────┐ │  ┌──────────┐
    │  States  │◄──┘      │Notifiers │◄┘  │Providers │
    └──────────┘          └─────┬────┘    └──────────┘
                                │
                      domain/   │     domain/
                      usecases/ │     entities/
                   ┌──────────┐ │  ┌──────────┐
                   │Use Cases │◄┘  │ Entities │
                   └────┬─────┘    └──────────┘
                        │
              domain/   │
              repositories/
           ┌──────────┐ │
           │Repository│◄┘
           │Interface │
           └────┬─────┘
                │
                │ implemented by
                │
        ┌───────▼──────────┐
        │       Data       │
        │  (External Data) │
        └───────┬──────────┘
                │
      ┌─────────┼─────────┐
      │                   │
data/ │         data/     │     data/
repositories/   models/   │     datasources/
┌──────────┐ ┌──────────┐ │  ┌──────────┐
│Repository│ │  Models  │◄┘  │DataSource│
│   Impl   │ └──────────┘    └─────┬────┘
└──────────┘                       │
                                   │
                          ┌────────▼────────┐
                          │   Backend API   │
                          └─────────────────┘
```

---

## 🎯 Layer Responsibilities

### 🔵 Presentation Layer
**Trách nhiệm:**
- ✅ Render UI
- ✅ Handle user interactions
- ✅ Navigate between screens
- ✅ Display loading/error states

**KHÔNG làm:**
- ❌ Business logic
- ❌ API calls
- ❌ Data transformation
- ❌ State management logic

**Import từ:**
- ✅ `domain/providers`
- ✅ `domain/state`
- ✅ `shared/widgets`
- ❌ KHÔNG import từ `data/`

---

### 🔷 Domain Layer
**Trách nhiệm:**
- ✅ Business logic
- ✅ Use cases
- ✅ State management
- ✅ Validation rules
- ✅ Dependency injection

**KHÔNG làm:**
- ❌ UI rendering
- ❌ API calls (trực tiếp)
- ❌ JSON parsing

**Import từ:**
- ✅ `domain/*` (internal)
- ✅ `flutter_riverpod`
- ❌ KHÔNG dùng `dartz`/`Failure` trong feature auth (B3: thay bằng AuthFlowResult union)
- ❌ KHÔNG import từ `presentation/`
- ❌ KHÔNG import từ `data/` (chỉ interface)

---

### 🔶 Data Layer
**Trách nhiệm:**
- ✅ API calls
- ✅ Database access
- ✅ JSON serialization
- ✅ Caching
- ✅ Implement repository interfaces

**KHÔNG làm:**
- ❌ Business logic
- ❌ UI rendering
- ❌ State management

**Import từ:**
- ✅ `domain/entities`
- ✅ `domain/repositories` (interfaces)
- ✅ `core/network`
- ❌ KHÔNG import từ `presentation/`

---

## 🔄 Example: Login Flow

### 1️⃣ User taps Login button (Presentation)
```dart
// auth_desktop_login_form.dart
onPressed: () async {
  if (loginFormNotifier.validate()) {
    loginFormNotifier.setSubmitting(true);
    await authNotifier.login(username, password);
    loginFormNotifier.setSubmitting(false);
  }
}
```

### 2️⃣ AuthNotifier handles business logic (Domain)
```dart
// presentation/notifiers/auth_notifiers.dart
Future<void> login(String username, String password) async {
  state = const AuthState.loading();

  final result = await _loginUseCase(
    LoginRequest(username: username, password: password),
  );

  switch (result) {
    case AuthFlowSuccess(:final auth):
      await _onAuthSuccess(auth, username, password); // side-effects ở notifier
    case AuthFlowOtpRequired(:final sessionId, :final message):
      state = AuthState.otpRequired(
        sessionId: sessionId,
        message: message ?? 'Vui lòng nhập mã OTP',
        username: username,
        password: password,
      );
    case AuthFlowFailure(:final message, :final showPopup):
      state = AuthState.error(message, showPopup: showPopup);
  }
}
```

### 3️⃣ LoginUseCase executes business operation (Domain)
```dart
// domain/usecases/login_usecase.dart
Future<AuthFlowResult> call(LoginRequest request) {
  return repository.login(request);
}
```

### 4️⃣ AuthFlowRepository interface (Domain)
```dart
// domain/repositories/auth_repository.dart
abstract class AuthFlowRepository {
  Future<AuthFlowResult> login(LoginRequest request);
}
```

### 5️⃣ AuthFlowRepositoryImpl calls API (Data)
```dart
// data/repositories/auth_flow_repository_impl.dart
// Exception KHÔNG bắt ở đây — để propagate lên notifier catch.
Future<AuthFlowResult> login(LoginRequest request) async {
  final requestModel = LoginRequestModel.fromEntity(request);
  final response = await remoteDataSource.login(requestModel);
  return _map(response, noDataMessage: 'Đăng nhập thất bại');
}
```

### 6️⃣ DataSource makes HTTP call (Data)
```dart
// data/datasources/auth_remote_datasource.dart
Future<AuthModel> login(LoginRequestModel request) async {
  final response = await apiClient.post('/auth/login', data: {
    'username': request.username,
    'password': request.password,
  });
  return AuthModel.fromJson(response);
}
```

### 7️⃣ UI reacts to state change (Presentation)
```dart
// auth_desktop_login_form.dart
ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  next.maybeWhen(
    authenticated: (auth) {
      // Navigate to home
      context.go('/home');
    },
    error: (message) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    },
    orElse: () {},
  );
});
```

---

## 📦 Key Benefits

### ✅ Testability
```dart
// Mock repository dễ dàng
class MockAuthFlowRepository extends Mock implements AuthFlowRepository {}

test('login success', () async {
  final mockRepo = MockAuthFlowRepository();
  final useCase = LoginUseCase(mockRepo);

  when(() => mockRepo.login(any()))
    .thenAnswer((_) async => AuthFlowSuccess(mockAuthEntity));

  final result = await useCase(loginRequest);
  expect(result, isA<AuthFlowSuccess>());
});
```

### ✅ Maintainability
- Thay UI không ảnh hưởng business logic
- Thay API không ảnh hưởng UI

### ✅ Scalability
- Dễ thêm features mới
- Dễ refactor từng layer độc lập

---

## 🎓 Clean Architecture Checklist

- [x] Domain layer không depend vào Presentation
- [x] Domain layer không depend vào Data (chỉ interface)
- [x] Presentation chỉ depend vào Domain
- [x] Data depend vào Domain (implement interfaces)
- [x] State ở Domain layer
- [x] Notifiers ở Domain layer  
- [x] Providers ở Domain layer
- [x] UI components ở Presentation layer
- [x] Use sealed class cho Freezed
- [x] Repository pattern
- [x] Use case pattern
- [x] Dependency injection với Riverpod

✅ **All checks passed! Clean Architecture implemented correctly!**



















