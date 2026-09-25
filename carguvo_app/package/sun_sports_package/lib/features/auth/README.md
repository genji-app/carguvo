# Auth Feature

This feature implements authentication functionality for the Sun Sports application following **Clean Architecture** principles.

## Structure (Clean Architecture)

```
auth/
├── data/                               # Data Layer (External Data)
│   ├── datasources/
│   │   └── auth_remote_datasource.dart      # API calls for authentication
│   ├── models/
│   │   ├── auth_model.dart                  # Data models with JSON serialization
│   │   ├── auth_model.freezed.dart         # Generated freezed code
│   │   └── auth_model.g.dart               # Generated JSON serialization
│   └── repositories/
│       └── auth_flow_repository_impl.dart    # AuthFlowRepository impl (response→union)
│
├── domain/                             # Domain Layer (Business Logic)
│   ├── entities/
│   │   ├── auth_entity.dart                 # Domain entities (sealed class)
│   │   └── auth_entity.freezed.dart        # Generated freezed code
│   ├── entities/
│   │   ├── auth_flow_result.dart            # AuthFlowResult union (plain Dart 3 sealed)
│   │   └── username_check_result.dart       # UsernameCheckResult enum
│   ├── repositories/
│   │   └── auth_repository.dart             # AuthFlowRepository interface (abstract)
│   ├── usecases/
│   │   ├── login_usecase.dart              # Login → AuthFlowResult
│   │   ├── register_usecase.dart           # Register → AuthFlowResult
│   │   ├── submit_otp_usecase.dart         # Submit OTP → AuthFlowResult
│   │   ├── check_username_usecase.dart     # Check username → UsernameCheckResult
│   │   └── logout_usecase.dart             # Logout → Future&lt;void&gt;
│   ├── state/                              # State classes (sealed class)
│   │   ├── auth_state.dart
│   │   └── auth_state.freezed.dart
│   ├── notifiers/                          # State notifiers (business logic)
│   │   └── auth_notifiers.dart
│   └── providers/                          # Providers (dependency injection)
│       └── auth_providers.dart
│
└── presentation/                       # Presentation Layer (UI only)
    ├── desktop/
    │   ├── screens/
    │   │   └── auth_desktop_screen.dart    # Main desktop auth screen
    │   └── widgets/
    │       ├── auth_desktop_login_form.dart    # Desktop login form
    │       └── auth_desktop_register_form.dart  # Desktop register form
    ├── tablet/
    │   └── screens/
    │       └── auth_tablet_screen.dart      # Tablet auth screen (reuses desktop)
    ├── widgets/                            # Reusable UI components
    │   └── auth_text_field.dart            # Custom text field component
    └── auth_screen.dart                    # Main responsive auth screen
```

## Clean Architecture Layers

### 🔷 Domain Layer (Business Logic)
**Không phụ thuộc vào bất kỳ layer nào khác**
- **Entities**: Pure business objects (sealed class với Freezed)
- **Use Cases**: Business logic operations
- **Repositories**: Abstract interfaces
- **State**: Application state definitions
- **Notifiers**: State management logic
- **Providers**: Dependency injection

### 🔶 Data Layer (External Data)
**Phụ thuộc vào Domain Layer**
- **Data Sources**: API calls, database access
- **Models**: JSON serialization/deserialization (sealed class)
- **Repository Implementations**: Concrete implementations of domain repositories

### 🔵 Presentation Layer (UI)
**Phụ thuộc vào Domain Layer (KHÔNG phụ thuộc Data Layer)**
- **Screens**: Full page layouts
- **Widgets**: Reusable UI components
- Chỉ gọi Domain layer (providers, notifiers, usecases)

## Key Changes (Updated to Clean Architecture Standard)

### ✅ Sử dụng `sealed class` (Freezed mới)
```dart
// ❌ Cũ (class)
@freezed
class AuthEntity with _$AuthEntity { ... }

// ✅ Mới (sealed class)
@freezed
sealed class AuthEntity with _$AuthEntity { ... }
```

### ✅ State & Providers ở Domain Layer
```
❌ Cũ:
lib/features/auth/presentation/
  ├── state/          # SAI - không nên ở presentation
  └── providers/      # SAI - không nên ở presentation

✅ Mới (Đúng Clean Architecture):
lib/features/auth/domain/
  ├── state/          # ĐÚNG - business logic state
  ├── notifiers/      # ĐÚNG - business logic
  └── providers/      # ĐÚNG - dependency injection
```

## Features

### Implemented
- ✅ Clean Architecture structure đúng chuẩn
- ✅ Sealed class với Freezed (bản mới)
- ✅ State & Providers ở Domain layer
- ✅ Login functionality
- ✅ Register functionality
- ✅ **Change Password functionality** (**NEW**)
  - Returns `SbApiResponse<dynamic>` for type-safe error handling
  - Uses Freezed pattern matching (`success`/`failure`)
  - Integrated with LoggerMixin for debugging
- ✅ **LoggerMixin integration** (**NEW**)
  - Auto-tagged logging `[ClassName]`
  - Type-safe log levels (verbose, debug, info, warning, error, fatal)
  - Consistent logging format across data sources
- ✅ Custom text field component với multiple states:
  - Default state
  - Active/focused state (viền vàng #FDE272)
  - Filled state (có nội dung + label nổi)
  - Error state (viền đỏ #F63D68 + error message)
  - Password visibility toggle
- ✅ Form validation
- ✅ State management với Riverpod
- ✅ Desktop/Tablet responsive layout
- ✅ Error handling với SbApiResponse pattern matching

### To Be Implemented
- ⏳ Mobile layout
- ⏳ Forgot password flow
- ⏳ Social login (Google, Facebook, etc.)
- ⏳ Biometric authentication
- ⏳ Token refresh mechanism
- ⏳ Persistent login (Remember me)

## Usage

### Navigate to Auth Screen

```dart
import 'package:sun_sports/features/auth/presentation/auth_screen.dart';

// In your router or navigation:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const AuthScreen()),
);
```

### Using Providers (từ Domain Layer)

```dart
import 'package:sun_sports/features/auth/domain/providers/auth_providers.dart';
import 'package:sun_sports/features/auth/domain/state/auth_state.dart';

// Watch auth state
final authState = ref.watch(authNotifierProvider);

// Perform login
final authNotifier = ref.read(authNotifierProvider.notifier);
await authNotifier.login(username, password);

// Handle state changes
ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  next.maybeWhen(
    authenticated: (auth) {
      // Navigate to home
    },
    error: (message) {
      // Show error
    },
    orElse: () {},
  );
});
```

## Design

The UI follows the Figma design specifications:
- Login screen: https://www.figma.com/design/Kmxt5j4aqDHQBPQNOCpuEw/Sun-Sport?node-id=864-6709
- Text field states: https://www.figma.com/design/Kmxt5j4aqDHQBPQNOCpuEw/Sun-Sport?node-id=864-6735

### Colors
- Background: `#141414` (gray950), `#111010` (gray900)
- Text: `#FFFEF5` (gray25), `#9C9B95` (gray300), `#74736F` (gray400)
- Border: `#252423` (gray700), `#393836` (gray600)
- Accent: `#FDE272` (yellow300), `#FEFBE8` (yellow50)
- Error: `#F63D68` (red500)

### Typography
- Heading Small: Inter, 24px, SemiBold (600), line height 28px
- Paragraph Medium: Inter, 16px, Regular (400), line height 24px
- Paragraph Small: Inter, 14px, Regular (400), line height 20px
- Label XSmall: Inter, 12px, Medium (500), line height 18px
- Button Medium: Inter, 16px, SemiBold (600), line height 24px
- Button Small: Inter, 14px, SemiBold (600), line height 20px

## API Endpoints

The following endpoints are expected from the backend:

### Login
```
POST /auth/login
Body: { "username": string, "password": string }
Response: { "access_token": string, "refresh_token": string, "user_id": string, "expires_at": string? }
```

### Register
```
POST /auth/register
Body: { "username": string, "password": string, "email": string, "phone": string? }
Response: { "access_token": string, "refresh_token": string, "user_id": string, "expires_at": string? }
```

### Logout
```
POST /auth/logout
Response: { }
```

### Refresh Token
```
POST /auth/refresh
Body: { "refresh_token": string }
Response: { "access_token": string, "refresh_token": string, "user_id": string, "expires_at": string? }
```

### Forgot Password
```
POST /auth/forgot-password
Body: { "email": string }
Response: { }
```

## Testing

Run tests for the auth feature:

```bash
flutter test test/features/auth/
```

## Notes

- ✅ **Đã cập nhật**: Sử dụng `sealed class` theo Freezed mới
- ✅ **Đã cập nhật**: State & Providers đã chuyển sang Domain layer (đúng Clean Architecture)
- ⏳ Mobile layout chưa implement. Hiện tại mobile sẽ hiển thị desktop layout.
- ⏳ API integration cần config endpoint trong `lib/core/network/api_endpoints.dart`
- ⏳ Token storage cần implement với secure storage
- ⏳ Token refresh mechanism cần implement
