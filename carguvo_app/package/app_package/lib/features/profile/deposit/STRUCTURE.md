# 📁 Cấu trúc Deposit Feature

## 🎯 **Tổng quan**

Deposit feature được tổ chức theo **Clean Architecture** với 3 layers chính:
- **Domain Layer**: Business logic, entities, use cases, state management
- **Data Layer**: Repository implementations, data models, API integration
- **Presentation Layer**: UI widgets, screens, overlays/bottom sheets

---

## 📂 **Cấu trúc Thư mục**

```
lib/features/profile/deposit/
├── domain/                          # Domain Layer (Business Logic)
│   ├── constants/                   # Constants và magic values
│   ├── entities/                    # Domain entities và models
│   ├── notifiers/                   # State notifiers (Form & Submit)
│   ├── providers/                   # Riverpod providers
│   ├── repositories/                # Repository interfaces
│   ├── state/                       # State classes (Freezed)
│   └── usecases/                    # Use cases (Business logic)
├── data/                            # Data Layer (Implementation)
│   ├── models/                      # Data models (JSON serialization)
│   └── repositories/                # Repository implementations
└── presentation/                    # Presentation Layer (UI)
    ├── mobile/                      # Mobile-specific screens
    ├── web_tablet/                  # Web/Tablet-specific overlays
    └── widgets/                     # Shared widgets
```

---

## 🏗️ **Domain Layer**

### **1. Constants** (`domain/constants/`)

**File:**
- `deposit_constants.dart`

**Nội dung:**
- `BankType`: Bank type constants (eWallet = 2)
- `DepositAnimationDurations`: Animation durations
- `DepositUIConstants`: UI constants (spacing, heights, border radius)
- `DepositErrorMessages`: Error message constants

**Mục đích:**
- Tránh magic numbers/strings
- Centralized configuration
- Dễ maintain và update

---

### **2. Entities** (`domain/entities/`)

#### **Request Entities:**
- `bank_deposit_request.dart` - Bank deposit request
- `bank_transaction_slip_request.dart` - Transaction slip request
- `card_deposit_request.dart` - Scratch card deposit request
- `codepay_deposit_request.dart` - Codepay deposit request
- `codepay_create_qr_request.dart` - QR code creation request
- `crypto_deposit_request.dart` - Crypto deposit request
- `crypto_address_request.dart` - Crypto address request
- `ewallet_deposit_request.dart` - E-wallet deposit request
- `giftcode_deposit_request.dart` - Gift code deposit request

#### **Response Entities:**
- `deposit_response.dart` - Generic deposit response
- `codepay_create_qr_response.dart` - QR code creation response
- `crypto_address_response.dart` - Crypto address response
- `fetch_bank_account_response.dart` - Bank account config response

#### **Domain Models:**
- `bank.dart` - Bank entity
- `crypto_option.dart` - Crypto option entity
- `payment_method.dart` - Payment method enum

#### **Nested Models** (`domain/entities/models/`):
- `bank_account_item.dart` - Bank account item
- `cashout_gift_card.dart` - Gift card entity
- `cashout_gift_card_item.dart` - Gift card item
- `codepay_account.dart` - Codepay account
- `codepay_bank.dart` - Codepay bank
- `crypto_deposit_option.dart` - Crypto deposit option
- `deposit_type.dart` - Deposit type
- `fetch_bank_account_data.dart` - Deposit config data
- `fetch_bank_account_response.dart` - Config response wrapper
- `item_account.dart` - Account item
- `suggested_trans_code.dart` - Suggested transaction code

**Đặc điểm:**
- Pure Dart classes
- No dependencies on Data layer
- Used by Use Cases and Notifiers

---

### **3. State** (`domain/state/`)

**File:**
- `deposit_state.dart` - All state classes (Freezed)

**State Classes:**

#### **Form States:**
- `BankFormState` - Bank transfer form state
- `CardFormState` - Scratch card form state
- `CodepayFormState` - Codepay form state
- `CryptoFormState` - Crypto form state
- `EWalletFormState` - E-wallet form state
- `GiftcodeFormState` - Gift code form state

#### **Submit States:**
- `BankSubmitState` - Bank deposit submit state (idle, submitting, success, error)
- `CardSubmitState` - Card deposit submit state
- `CodepaySubmitState` - Codepay deposit submit state
- `CryptoSubmitState` - Crypto deposit submit state
- `EWalletSubmitState` - E-wallet deposit submit state
- `GiftcodeSubmitState` - Gift code deposit submit state

**Đặc điểm:**
- Immutable (Freezed)
- Type-safe
- Pattern matching với `when()` và `maybeWhen()`

---

### **4. Use Cases** (`domain/usecases/`)

**Submit Use Cases:**
- `submit_bank_deposit_usecase.dart`
- `submit_card_deposit_usecase.dart`
- `submit_codepay_deposit_usecase.dart`
- `submit_crypto_deposit_usecase.dart`
- `submit_ewallet_deposit_usecase.dart`
- `submit_giftcode_deposit_usecase.dart`

**Get Use Cases:**
- `get_config_deposit_usecase.dart`
- `get_crypto_address_usecase.dart`

**Create Use Cases:**
- `create_code_pay_qr_usecase.dart`
- `create_transaction_slip_usecase.dart`

**Đặc điểm:**
- Encapsulate business logic
- Input: Request entities
- Output: `Either<Failure, Response>`
- No dependencies on Presentation layer
- Easy to test

**Pattern:**
```dart
class SubmitCardDepositUseCase {
  final DepositRepository _repository;
  
  Future<Either<Failure, DepositResponse>> call(
    CardDepositRequest request,
  ) async {
    return await _repository.submitCardDeposit(request);
  }
}
```

---

### **5. Notifiers** (`domain/notifiers/`)

#### **Form Notifiers:**
- `bank_form_notifier.dart` - Manages bank form state
- `card_form_notifier.dart` - Manages card form state
- `codepay_form_notifier.dart` - Manages codepay form state
- `crypto_form_notifier.dart` - Manages crypto form state
- `ewallet_form_notifier.dart` - Manages e-wallet form state
- `giftcode_form_notifier.dart` - Manages gift code form state

**Responsibilities:**
- Form field updates
- Validation logic
- Error state management

#### **Submit Notifiers:**
- `bank_submit_notifier.dart` - Manages bank deposit submission
- `card_submit_notifier.dart` - Manages card deposit submission
- `codepay_submit_notifier.dart` - Manages codepay deposit submission
- `crypto_submit_notifier.dart` - Manages crypto deposit submission
- `ewallet_submit_notifier.dart` - Manages e-wallet deposit submission
- `giftcode_submit_notifier.dart` - Manages gift code deposit submission

**Responsibilities:**
- Submit state management (idle → submitting → success/error)
- Calls Use Cases
- Stores response data
- Error handling

**Pattern:**
```dart
class CardSubmitNotifier extends StateNotifier<CardSubmitState> {
  final SubmitCardDepositUseCase _submitCardDepositUseCase;
  
  Future<void> submit(CardDepositRequest request) async {
    state = const CardSubmitState.submitting();
    final result = await _submitCardDepositUseCase(request);
    result.fold(
      (failure) => state = CardSubmitState.error(failure.message),
      (response) => state = const CardSubmitState.success(),
    );
  }
}
```

#### **Other Notifiers:**
- `codepay_qr_timer_notifier.dart` - QR code countdown timer
- `deposit_notifiers.dart` - Payment method selection notifier

---

### **6. Providers** (`domain/providers/`)

#### **`deposit_providers.dart`** - Main Providers

**Data Layer Providers:**
- `depositRepositoryProvider` - Repository instance

**Options Providers (Load Data):**
- `configDepositProvider` - Deposit configuration (cached)
- `bankListProvider` - List of banks
- `walletListProvider` - List of e-wallets
- `cardTypeListProvider` - List of card types
- `denominationListProvider` - Denominations for selected card type
- `cryptoOptionsProvider` - Crypto deposit options

**Use Case Providers:**
- `submitCardDepositUseCaseProvider`
- `submitBankDepositUseCaseProvider`
- `submitCodepayDepositUseCaseProvider`
- `submitEWalletDepositUseCaseProvider`
- `submitCryptoDepositUseCaseProvider`
- `submitGiftcodeDepositUseCaseProvider`
- `createCodePayQrUseCaseProvider`
- `getCryptoAddressUseCaseProvider`
- `createTransactionSlipUseCaseProvider`

**Submit Providers (Per Method):**
- `cardSubmitNotifierProvider`
- `bankSubmitNotifierProvider`
- `codepaySubmitNotifierProvider`
- `ewalletSubmitNotifierProvider`
- `cryptoSubmitNotifierProvider`
- `giftcodeSubmitNotifierProvider`

**Performance Optimizations:**
- `configDepositProvider` uses `keepAlive()` for caching
- Selective watching with `select()` where applicable

#### **`deposit_form_providers.dart`** - Form Providers

**Form Notifier Providers:**
- `bankFormProvider`
- `cardFormProvider`
- `codepayFormProvider`
- `cryptoFormProvider`
- `ewalletFormProvider`
- `giftcodeFormProvider`

#### **`deposit_overlay_provider.dart`** - Overlay State

- `depositOverlayStateProvider` - Overlay visibility state

---

### **7. Repositories** (`domain/repositories/`)

**File:**
- `deposit_repository.dart` - Repository interface

**Methods:**
- `Future<Either<Failure, FetchBankAccountsData>> getConfigDeposit()`
- `Future<Either<Failure, DepositResponse>> submitBankDeposit(BankDepositRequest request)`
- `Future<Either<Failure, DepositResponse>> submitCardDeposit(CardDepositRequest request)`
- `Future<Either<Failure, DepositResponse>> submitCodepayDeposit(CodepayDepositRequest request)`
- `Future<Either<Failure, DepositResponse>> submitEWalletDeposit(EWalletDepositRequest request)`
- `Future<Either<Failure, DepositResponse>> submitCryptoDeposit(CryptoDepositRequest request)`
- `Future<Either<Failure, DepositResponse>> submitGiftcodeDeposit(GiftcodeDepositRequest request)`
- `Future<Either<Failure, CodepayCreateQrResponse>> createCodePayQr(CodepayCreateQrRequest request)`
- `Future<Either<Failure, CryptoAddressResponse>> getCryptoAddress(CryptoAddressRequest request)`
- `Future<Either<Failure, DepositResponse>> createTransactionSlip(BankTransactionSlipRequest request)`

**Đặc điểm:**
- Abstract interface
- Returns `Either<Failure, Success>`
- No implementation details

---

## 📊 **Data Layer**

### **1. Models** (`data/models/`)

**Files:**
- `bank_deposit_request_model.dart` - JSON serialization for bank requests
- `bank_model.dart` - Bank JSON model
- `deposit_response_model.dart` - Deposit response JSON model

**Đặc điểm:**
- JSON serialization (json_serializable)
- Freezed for immutability
- Maps to/from Domain entities

**Pattern:**
```dart
@freezed
class DepositResponseModel with _$DepositResponseModel {
  const factory DepositResponseModel({
    required String transactionId,
    // ...
  }) = _DepositResponseModel;
  
  factory DepositResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DepositResponseModelFromJson(json);
}
```

---

### **2. Repositories** (`data/repositories/`)

**File:**
- `deposit_repository_impl.dart` - Repository implementation

**Responsibilities:**
- HTTP API calls
- JSON serialization/deserialization
- Error mapping (HTTP → Failure)
- Data transformation (Model → Entity)

**Pattern:**
```dart
class DepositRepositoryImpl implements DepositRepository {
  final SbHttpManager _httpManager;
  
  @override
  Future<Either<Failure, DepositResponse>> submitCardDeposit(
    CardDepositRequest request,
  ) async {
    try {
      // Convert entity to model
      final requestModel = BankDepositRequestModel.fromEntity(request);
      
      // Make API call
      final response = await _httpManager.post(...);
      
      // Convert model to entity
      final entity = DepositResponseModel.fromJson(response).toEntity();
      
      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

---

## 🎨 **Presentation Layer**

### **1. Widgets** (`presentation/widgets/`)

**Container Widgets:**
- `bank_container_section.dart` - Bank transfer form container
- `card_container.dart` - Scratch card form container
- `codepay_container_section.dart` - Codepay form container
- `crypto_container.dart` - Crypto deposit container
- `ewallet_container.dart` - E-wallet form container
- `giftcode_container.dart` - Gift code container

**Transfer/Confirm Containers:**
- `bank_transfer_container.dart` - Bank transfer details
- `bank_confirm_money_transfer_container.dart` - Bank transfer confirmation
- `codepay_transfer_section.dart` - Codepay QR transfer
- `crypto_confirm_money_transfer_container.dart` - Crypto confirmation
- `ewallet_confirm_money_transfer_container.dart` - E-wallet confirmation

**Shared Widgets:**
- `deposit_header.dart` - Deposit screen header
- `deposit_payment_method_card.dart` - Payment method card
- `deposit_payment_methods_grid.dart` - Payment methods grid
- `deposit_payment_methods_grid_web.dart` - Web payment methods grid
- `waiting_payment_confirm_section.dart` - Waiting payment confirmation UI
- `dialog_confirmation_bank.dart` - Bank selection dialog

**Đặc điểm:**
- `ConsumerWidget` hoặc `ConsumerStatefulWidget`
- Uses Riverpod providers
- Responsive design (mobile/web)
- Local UI state với `ValueNotifier` (optimized)

---

### **2. Mobile Screens** (`presentation/mobile/`)

#### **Bank** (`mobile/bank/`):
- `bank_container.dart` - Bank form container
- `bank_transfer_money_bottom_sheet.dart` - Transfer details bottom sheet
- `bank_confirm_money_transfer_bottomsheet.dart` - Confirmation bottom sheet

#### **Codepay** (`mobile/codepay/`):
- `codepay_container.dart` - Codepay form container
- `codepay_transation_bottom_sheet.dart` - QR transaction bottom sheet

#### **Crypto** (`mobile/crypto/`):
- `crypto_confirm_money_transfer_bottom_sheet.dart` - Crypto confirmation

#### **E-Wallet** (`mobile/ewallet/`):
- `ewallet_confirm_money_transfer_bottom_sheet.dart` - E-wallet confirmation

#### **Root:**
- `deposit_mobile_bottom_sheet.dart` - Main mobile bottom sheet

**Đặc điểm:**
- Bottom sheet UI
- Mobile-optimized layouts
- Uses shared widgets from `widgets/`

---

### **3. Web/Tablet Overlays** (`presentation/web_tablet/`)

**Main Overlays:**
- `deposit_overlay.dart` - Main deposit overlay
- `deposit_waiting_payment_confirm_overlay.dart` - Waiting payment overlay

**Payment Method Overlays:**
- `bank_transfer_overlay.dart` - Bank transfer overlay
- `bank_confirm_money_transfer_overlay.dart` - Bank confirmation overlay
- `card_overlay.dart` - Scratch card overlay
- `codepay_transfer_overlay.dart` - Codepay transfer overlay
- `crypto_overlay.dart` - Crypto deposit overlay
- `crypto_confirm_money_transfer_overlay.dart` - Crypto confirmation overlay
- `ewallet_overlay.dart` - E-wallet overlay
- `ewallet_confirm_money_transfer_overlay.dart` - E-wallet confirmation overlay
- `giftcode_overlay.dart` - Gift code overlay

**Shared Components:**
- `deposit_payment_method_container_web.dart` - Payment method container
- `deposit_payment_methods_grid_web.dart` - Payment methods grid

**Đặc điểm:**
- Dialog/Overlay UI
- Web/tablet-optimized layouts
- Uses shared widgets from `widgets/`

---

### **4. Root Files**

**`mobile_waiting_payment_confirm_bottom_sheet.dart`**:
- Mobile waiting payment confirmation bottom sheet (root level)

---

## 🔄 **Data Flow**

### **Submit Flow:**

```
User Action (UI)
    ↓
Widget → FormNotifier.validate()
    ↓
Widget → SubmitNotifier.submit(request)
    ↓
SubmitNotifier → UseCase.call(request)
    ↓
UseCase → Repository.method(request)
    ↓
Repository → API Call
    ↓
Repository → Map Model → Entity
    ↓
UseCase → Return Either<Failure, Entity>
    ↓
SubmitNotifier → Update State (success/error)
    ↓
Widget → Listen to State → Navigate/Show Result
```

### **Form Flow:**

```
User Input
    ↓
Widget → FormNotifier.updateField(value)
    ↓
FormNotifier → Validate & Update State
    ↓
Widget → Rebuild with New State
    ↓
Widget → Show Validation Errors / Enable Submit Button
```

---

## 🎯 **Payment Methods**

Deposit feature hỗ trợ 6 payment methods:

1. **Bank Transfer** (`PaymentMethod.bank`)
   - Form: Bank selection, account info, amount
   - Flow: Form → Transfer Details → Confirmation → Waiting

2. **Codepay** (`PaymentMethod.codepay`)
   - Form: Bank selection, amount
   - Flow: Form → QR Generation → Waiting

3. **E-Wallet** (`PaymentMethod.eWallet`)
   - Form: Wallet selection, amount
   - Flow: Form → QR Generation → Waiting

4. **Crypto** (`PaymentMethod.crypto`)
   - Form: Crypto selection, amount
   - Flow: Form → Address Generation → Confirmation → Waiting

5. **Scratch Card** (`PaymentMethod.scratchCard`)
   - Form: Card type, denomination, serial, code
   - Flow: Form → Submit → Waiting

6. **Gift Code** (`PaymentMethod.giftcode`)
   - Form: Gift code input
   - Flow: Form → Submit → Waiting

---

## 🔑 **Key Design Patterns**

### **1. Clean Architecture**
- Domain layer independent
- Use Cases encapsulate business logic
- Repository pattern for data access

### **2. Separation of Concerns**
- Form Notifiers: Form state management
- Submit Notifiers: Submit state management
- Use Cases: Business logic
- Repositories: Data access

### **3. State Management (Riverpod)**
- `StateNotifier` for complex state
- `Provider` for shared data
- `FutureProvider` for async data
- `select()` for optimized watching

### **4. Responsive Design**
- Mobile: Bottom sheets
- Web/Tablet: Overlays/Dialogs
- Shared widgets for common UI

### **5. Performance Optimization**
- Provider caching với `keepAlive()`
- Selective watching với `select()`
- `ValueNotifier` cho local UI state
- `const` constructors where possible

---

## 📝 **File Naming Conventions**

- **Entities**: `{name}_entity.dart` hoặc `{name}.dart`
- **Use Cases**: `{action}_{entity}_usecase.dart`
- **Notifiers**: `{method}_{type}_notifier.dart` (form/submit)
- **Providers**: `{feature}_providers.dart`
- **Widgets**: `{name}_container.dart` hoặc `{name}_section.dart`
- **Overlays**: `{name}_overlay.dart`
- **Bottom Sheets**: `{name}_bottom_sheet.dart`

---

## 🎓 **Best Practices**

1. ✅ **Domain Independence**: Domain layer không depend vào Data/Presentation
2. ✅ **Use Cases First**: Business logic trong Use Cases, không trong Notifiers
3. ✅ **Immutable State**: Sử dụng Freezed cho state classes
4. ✅ **Error Handling**: `Either<Failure, Success>` pattern
5. ✅ **Type Safety**: Explicit types, không dùng `dynamic`
6. ✅ **Constants**: Không dùng magic numbers/strings
7. ✅ **Performance**: Cache providers, selective watching
8. ✅ **Testing**: Use Cases dễ test (pure functions)

---

## 📚 **Related Documentation**

- `DEPOSIT_IMPROVEMENT_PLAN.md` - Improvement plan
- `LOGIC_COMPARISON.md` - Logic comparison (before/after)
- `SETSTATE_ANALYSIS.md` - setState usage analysis
- `FORM_SUBMIT_NOTIFIER_ANALYSIS.md` - Form/Submit notifier analysis
- `USECASES_STATUS.md` - Use cases status
- `IMPROVEMENT_STATUS.md` - Improvement progress

---

**Last Updated:** After Architecture Improvements

