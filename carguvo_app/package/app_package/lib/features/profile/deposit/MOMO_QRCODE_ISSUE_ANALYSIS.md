# Phân Tích: Vì Sao QR Code MoMo Không Hiển Thị Khi Xác Nhận Thanh Toán

## 🔍 Vấn Đề

Khi xác nhận thanh toán MoMo, QR code **KHÔNG xuất hiện** mặc dù QR code chưa hết hạn.

## 📊 Phân Tích Chi Tiết

### 1. Flow Hiện Tại

**Bước 1**: User tạo QR code MoMo
- `EWalletContainer` → Submit form → API trả về `CodepayCreateQrResponse`
- QR code được lưu vào `DepositStorage` với key = `bankName` (ví dụ: "MoMo")
- QR code được hiển thị trong `EWalletConfirmMoneyTransferContainer`

**Bước 2**: User click "Xác nhận chuyển khoản"
- `_handleConfirm()` trong `ewallet_confirm_money_transfer_container.dart` được gọi
- Chỉ truyền **text data** vào màn hình "waiting payment confirm":
  ```dart
  DepositMobileWaitingPaymentConfirmBottomSheet.show(
    navigator.context,
    amount: amount,
    paymentMethod: paymentMethod,
    transactionCode: transactionCode,
    bankName: bankName,
    accountName: accountName,
    accountNumber: accountNumber,
    note: note,
    bankBranch: bankBranch,
    // ❌ THIẾU: qrCode và remainingTime!
  );
  ```

**Bước 3**: Màn hình "waiting payment confirm"
- `WaitingPaymentConfirmSection` chỉ hiển thị **text information**
- **KHÔNG có logic** để hiển thị QR code
- **KHÔNG lấy QR code** từ `DepositStorage`

### 2. Root Cause

**Vấn đề chính**: QR code và remainingTime **KHÔNG được truyền** vào màn hình "waiting payment confirm"

**Code hiện tại**:
```dart
// ewallet_confirm_money_transfer_container.dart - _handleConfirm()
void _handleConfirm() async {
  // ... extract data ...
  
  // ❌ Chỉ truyền text data, KHÔNG truyền qrCode và remainingTime
  DepositMobileWaitingPaymentConfirmBottomSheet.show(
    navigator.context,
    amount: amount,
    paymentMethod: paymentMethod,
    transactionCode: transactionCode,
    bankName: bankName,
    accountName: accountName,
    accountNumber: accountNumber,
    note: note,
    bankBranch: bankBranch,
  );
}
```

**Màn hình "waiting payment confirm"**:
```dart
// waiting_payment_confirm_section.dart
class WaitingPaymentConfirmSection extends StatelessWidget {
  // ❌ KHÔNG có qrCode và remainingTime fields
  final String amount;
  final PaymentMethod paymentMethod;
  final String transactionCode;
  // ... other text fields ...
  // ❌ THIẾU: String? qrCode;
  // ❌ THIẾU: int? remainingTime;
}
```

### 3. QR Code Được Lưu Ở Đâu?

QR code được lưu trong `DepositStorage`:
- **Key**: `bankName` (ví dụ: "MoMo")
- **Value**: JSON string chứa `CodepayCreateQrResponse` với `qrcode` và `remainingTime`
- **Method**: `DepositStorage.getCodepayResponse(bankName)` → Trả về `CodepayCreateQrResponse?`

**Code**:
```dart
// deposit_storage.dart
static CodepayCreateQrResponse? getCodepayResponse(String bankName) {
  // Lấy từ Hive storage
  // Kiểm tra expiration
  // Trả về response với qrcode và remainingTime
}
```

## 💡 Giải Pháp

### Option 1: Truyền QR Code Trực Tiếp (Recommended) ⭐

**Ưu điểm**:
- Đơn giản, không cần query storage
- QR code đã có sẵn trong `widget.qrResponse`

**Nhược điểm**:
- Cần thay đổi signature của `WaitingPaymentConfirmSection`

**Implementation**:

1. **Update `_handleConfirm()`** để truyền QR code:
```dart
// ewallet_confirm_money_transfer_container.dart
void _handleConfirm() async {
  // ... existing code ...
  
  final qrCode = widget.qrResponse.qrcode; // ✅ Lấy QR code
  final remainingTime = widget.qrResponse.remainingTime; // ✅ Lấy remainingTime
  
  DepositMobileWaitingPaymentConfirmBottomSheet.show(
    navigator.context,
    amount: amount,
    paymentMethod: paymentMethod,
    transactionCode: transactionCode,
    bankName: bankName,
    accountName: accountName,
    accountNumber: accountNumber,
    note: note,
    bankBranch: bankBranch,
    qrCode: qrCode, // ✅ Thêm QR code
    remainingTime: remainingTime, // ✅ Thêm remainingTime
  );
}
```

2. **Update `DepositMobileWaitingPaymentConfirmBottomSheet`**:
```dart
class DepositMobileWaitingPaymentConfirmBottomSheet extends ConsumerStatefulWidget {
  // ... existing fields ...
  final String? qrCode; // ✅ Thêm optional QR code
  final int? remainingTime; // ✅ Thêm optional remainingTime
  
  const DepositMobileWaitingPaymentConfirmBottomSheet({
    // ... existing params ...
    this.qrCode,
    this.remainingTime,
  });
}
```

3. **Update `WaitingPaymentConfirmSection`** để hiển thị QR code:
```dart
class WaitingPaymentConfirmSection extends StatelessWidget {
  // ... existing fields ...
  final String? qrCode; // ✅ Thêm optional QR code
  final int? remainingTime; // ✅ Thêm optional remainingTime
  
  const WaitingPaymentConfirmSection({
    // ... existing params ...
    this.qrCode,
    this.remainingTime,
  });
  
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _buildTitle(),
      const SizedBox(height: 32),
      // ✅ Hiển thị QR code nếu có (cho eWallet/codepay)
      if (qrCode != null && 
          (paymentMethod == PaymentMethod.eWallet || 
           paymentMethod == PaymentMethod.codepay))
        _buildQRCodeSection(),
      const SizedBox(height: 16),
      _buildPaymentInfoCard(context),
      const SizedBox(height: 16),
      _buildTransactionDetailsSection(context),
    ],
  );
  
  // ✅ Thêm method để hiển thị QR code
  Widget _buildQRCodeSection() {
    // Similar to _QRCodeSection in ewallet_confirm_money_transfer_container.dart
  }
}
```

### Option 2: Lấy QR Code Từ Storage

**Ưu điểm**:
- Không cần thay đổi signature nhiều
- Tự động lấy từ storage nếu có

**Nhược điểm**:
- Cần query storage mỗi lần hiển thị
- Phức tạp hơn

**Implementation**:
```dart
// waiting_payment_confirm_section.dart
@override
Widget build(BuildContext context) {
  // ✅ Lấy QR code từ storage nếu là eWallet/codepay
  CodepayCreateQrResponse? qrResponse;
  if (paymentMethod == PaymentMethod.eWallet || 
      paymentMethod == PaymentMethod.codepay) {
    qrResponse = DepositStorage.getCodepayResponse(bankName);
  }
  
  return Column(
    children: [
      // ... existing widgets ...
      if (qrResponse != null && qrResponse.qrcode.isNotEmpty)
        _buildQRCodeSection(qrResponse.qrcode, qrResponse.remainingTime),
      // ... rest of widgets ...
    ],
  );
}
```

## 🎯 Recommendation

**Nên dùng Option 1** vì:
1. ✅ Đơn giản hơn - QR code đã có sẵn trong `widget.qrResponse`
2. ✅ Không cần query storage - Giảm overhead
3. ✅ Đảm bảo data consistency - Dùng cùng data từ API response

## 📝 Checklist Implementation

- [ ] Update `_handleConfirm()` trong `ewallet_confirm_money_transfer_container.dart` để truyền `qrCode` và `remainingTime`
- [ ] Update `DepositMobileWaitingPaymentConfirmBottomSheet` để nhận `qrCode` và `remainingTime`
- [ ] Update `DepositWaitingPaymentConfirmOverlayWeb` để nhận `qrCode` và `remainingTime`
- [ ] Update `WaitingPaymentConfirmSection` để:
  - Thêm `qrCode` và `remainingTime` fields
  - Thêm `_buildQRCodeSection()` method
  - Hiển thị QR code nếu có (cho eWallet/codepay)
- [ ] Test: QR code hiển thị khi xác nhận thanh toán MoMo
- [ ] Test: QR code không hiển thị khi đã hết hạn
- [ ] Test: QR code hiển thị đúng cho cả mobile và web




