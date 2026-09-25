# Clean Architecture Updates

## Những thay đổi đã thực hiện

### 1. ✅ Sử dụng `sealed class` thay vì `class` (Freezed mới)

**Tại sao?** Freezed phiên bản mới khuyến nghị dùng `sealed class` để pattern matching tốt hơn và type-safe hơn.

**Đã cập nhật:**
```dart
// ❌ CŨ
@freezed
class AuthEntity with _$AuthEntity { ... }

@freezed
class AuthModel with _$AuthModel { ... }

// ✅ MỚI
@freezed
sealed class AuthEntity with _$AuthEntity { ... }

@freezed
sealed class AuthModel with _$AuthModel { ... }
```

**Các file đã cập nhật:**
- ✅ `lib/features/auth/domain/entities/auth_entity.dart`
- ✅ `lib/features/auth/data/models/auth_model.dart`
- ✅ `lib/features/auth/domain/state/auth_state.dart`

---

### 2. ✅ Di chuyển State & Providers từ Presentation → Domain Layer

**Tại sao?** Theo Clean Architecture:
- **State definitions** là business logic → thuộc Domain layer
- **State notifiers** chứa business logic → thuộc Domain layer  
- **Providers** là dependency injection → thuộc Domain layer
- **Presentation layer** chỉ nên chứa UI components

**Cấu trúc CŨ (SAI):**
```
lib/features/auth/
├── presentation/
│   ├── state/           # ❌ SAI - không nên ở đây
│   │   ├── auth_state.dart
│   │   └── auth_notifiers.dart
│   └── providers/       # ❌ SAI - không nên ở đây
│       └── auth_providers.dart
```

**Cấu trúc MỚI (ĐÚNG Clean Architecture):**
```
lib/features/auth/
├── domain/              # ✅ ĐÚNG
│   ├── state/          # State definitions (business logic)
│   │   ├── auth_state.dart
│   │   └── auth_state.freezed.dart
│   ├── notifiers/      # Business logic controllers
│   │   └── auth_notifiers.dart
│   └── providers/      # Dependency injection
│       └── auth_providers.dart
│
└── presentation/        # ✅ Chỉ có UI
    ├── desktop/
    ├── tablet/
    └── widgets/
```

---

### 3. ✅ Thêm Change Password Feature

**Thêm method mới:**
- `AuthRemoteDataSource.changePassword()` - Returns `SbApiResponse<dynamic>`
- `AuthRepository.changePassword()` - Returns `Either<Failure, void>`
- `AuthRepositoryImpl.changePassword()` - Implements repository interface

**Đặc điểm:**
```dart
// Remote Data Source - Returns SbApiResponse
Future<SbApiResponse<dynamic>> changePassword(
  String currentPassword,
  String newPassword,
);

// Repository Interface - Returns Either
Future<Either<Failure, void>> changePassword(
  String currentPassword,
  String newPassword,
);
```

**Lợi ích:**
- ✅ Consistent với SbApiResponse pattern
- ✅ Type-safe error handling với Freezed pattern matching
- ✅ Không dùng exceptions cho business logic

---

### 4. ✅ Sử dụng LoggerMixin

**Thêm LoggerMixin vào Data Source:**
```dart
class AuthRemoteDataSourceImpl with LoggerMixin implements AuthRemoteDataSource {
  // Auto tag logging: [AuthRemoteDataSourceImpl]
  
  Future<SbApiResponse<dynamic>> changePassword(...) async {
    logDebug('Calling API: $url');
    logDebug('Response body: ${response.body}');
    
    if (sbResponse.isError) {
      logWarning('API returned error: $errorMessage');
    } else {
      logInfo('Password changed successfully');
    }
  }
}
```

**Lợi ích:**
- ✅ Consistent logging format
- ✅ Auto tag prefix `[ClassName]`
- ✅ Support error + stackTrace logging
- ✅ Type-safe log levels (verbose, debug, info, warning, error, fatal)

---

## Clean Architecture Principles

### 🔷 Domain Layer (Core Business Logic)
**Không phụ thuộc layer nào khác**

```
domain/
├── entities/          # Pure business objects
├── repositories/      # Abstract interfaces
├── usecases/         # Business operations
├── state/            # State definitions
├── notifiers/        # Business logic controllers
└── providers/        # Dependency injection
```

**Đặc điểm:**
- Không import từ `data` hay `presentation`
- Chỉ chứa pure Dart (không Flutter UI)
- Có thể dùng `flutter_riverpod` cho state management

---

### 🔶 Data Layer (External Data)
**Phụ thuộc Domain Layer**

```
data/
├── datasources/      # API, Database access (with LoggerMixin)
├── models/          # JSON serialization
└── repositories/    # Implement domain repositories
```

**Đặc điểm:**
- Import từ `domain` layer
- Không import từ `presentation`
- Handle API calls, database, cache
- **MỚI:** Use LoggerMixin for consistent logging

---

### 🔵 Presentation Layer (UI)
**Phụ thuộc Domain Layer ONLY**

```
presentation/
├── desktop/
├── tablet/
├── mobile/
└── widgets/         # Reusable UI components
```

**Đặc điểm:**
- Import từ `domain` layer (providers, notifiers, state)
- **KHÔNG** import trực tiếp từ `data` layer
- Chỉ chứa UI widgets và screens

---

## Dependency Flow

```
┌─────────────────┐
│  Presentation   │  ← UI only
│    (Flutter)    │
└────────┬────────┘
         │ depends on
         ↓
┌─────────────────┐
│     Domain      │  ← Business Logic (Pure Dart + Riverpod)
│  (Use Cases)    │
└────────┬────────┘
         │ depends on
         ↓
┌─────────────────┐
│      Data       │  ← External Data (API, DB) + LoggerMixin
│  (Repository)   │
└─────────────────┘
```

**Quy tắc:**
- ❌ Presentation **KHÔNG** import Data
- ✅ Presentation → Domain → Data
- ✅ Domain không phụ thuộc ai

---

## Import Examples

### ✅ ĐÚNG - Presentation imports Domain

```dart
// ✅ auth_desktop_login_form.dart
import 'package:sun_sports/features/auth/domain/providers/auth_providers.dart';
import 'package:sun_sports/features/auth/domain/state/auth_state.dart';
```

### ❌ SAI - Presentation imports Data

```dart
// ❌ KHÔNG làm thế này
import 'package:sun_sports/features/auth/data/models/auth_model.dart';
import 'package:sun_sports/features/auth/data/datasources/auth_remote_datasource.dart';
```

### ✅ ĐÚNG - Domain không import Presentation

```dart
// ✅ auth_notifiers.dart (ở domain/)
import 'package:sun_sports/features/auth/domain/entities/auth_entity.dart';
import 'package:sun_sports/features/auth/domain/usecases/login_usecase.dart';
// KHÔNG import từ presentation/
```

---

## API Response Patterns

### ✅ Sử dụng SbApiResponse với Pattern Matching

```dart
// Data Source returns SbApiResponse
final response = await changePassword(...);

// Use Freezed pattern matching
response.when(
  success: (messageKey, status, locale, data) {
    // Type-safe success handling
    logInfo('Success (status: $status)');
  },
  failure: (messageKey, code, locale, error, data) {
    // Type-safe error handling
    logWarning('Failed (code: $code): $error');
    
    switch (code) {
      case 99:
        // Handle specific error codes
        break;
      default:
        // Handle other errors
    }
  },
);
```

**Lợi ích:**
- ✅ Type-safe - compiler enforces handling all cases
- ✅ No exceptions for business logic
- ✅ Clear success/failure separation

---

## Lợi ích của Clean Architecture

### 1. **Testability** ✅
- Domain layer không phụ thuộc UI → dễ test business logic
- Mock repositories dễ dàng

### 2. **Maintainability** ✅
- Thay đổi UI không ảnh hưởng business logic
- Thay đổi API không ảnh hưởng UI

### 3. **Scalability** ✅
- Dễ thêm features mới
- Dễ refactor

### 4. **Separation of Concerns** ✅
- UI là UI
- Business logic là business logic
- Data access là data access

### 5. **Debuggability** ✅ (NEW)
- LoggerMixin provides consistent logging
- Auto-tagged class names
- Easy to track data flow

---

## Migration Summary

### Files Moved:
```
presentation/state/auth_state.dart 
  → domain/state/auth_state.dart ✅

presentation/state/auth_notifiers.dart 
  → domain/notifiers/auth_notifiers.dart ✅

presentation/providers/auth_providers.dart 
  → domain/providers/auth_providers.dart ✅
```

### New Features Added:
- ✅ `changePassword` method in AuthRemoteDataSource
- ✅ `changePassword` method in AuthRepository
- ✅ LoggerMixin integration in AuthRemoteDataSourceImpl
- ✅ SbApiResponse pattern matching

### Imports Updated:
- ✅ `auth_desktop_login_form.dart`
- ✅ `auth_desktop_register_form.dart`
- ✅ `auth_notifiers.dart`
- ✅ `auth_providers.dart`

### Freezed Updated:
- ✅ All entities: `class` → `sealed class`
- ✅ All models: `class` → `sealed class`
- ✅ All states: `class` → `sealed class`

---

## Checklist

- [x] Sử dụng `sealed class` cho Freezed
- [x] State ở `domain/state/`
- [x] Notifiers ở `domain/notifiers/`
- [x] Providers ở `domain/providers/`
- [x] Presentation chỉ chứa UI
- [x] Presentation không import Data layer
- [x] Domain không import Presentation
- [x] Cập nhật tất cả imports
- [x] Rebuild freezed generated files
- [x] Cập nhật documentation
- [x] Thêm changePassword feature
- [x] Sử dụng LoggerMixin cho logging
- [x] Sử dụng SbApiResponse pattern matching

---

## Kết luận

✅ **Auth feature bây giờ đã follow đúng Clean Architecture!**

- ✅ Sealed class (Freezed mới)
- ✅ State & Providers ở Domain layer
- ✅ Separation of concerns rõ ràng
- ✅ Testable và maintainable
- ✅ Change Password feature
- ✅ Consistent logging with LoggerMixin
- ✅ Type-safe error handling with SbApiResponse

















