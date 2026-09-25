library;

class PaygateResult {
  const PaygateResult({required this.ok, required this.status, this.message});

  final bool ok;

  final int status;
  final String? message;

  static const PaygateResult offline = PaygateResult(
    ok: false,
    status: -1,
    message: 'Không kết nối được máy chủ, vui lòng thử lại',
  );
}
