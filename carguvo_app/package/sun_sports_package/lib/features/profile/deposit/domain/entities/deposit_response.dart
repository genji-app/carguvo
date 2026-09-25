class DepositResponse {
  final String transactionId;
  final String? qrCodeUrl;
  final String? depositAddress;
  final Map<String, dynamic>? additionalData;

  const DepositResponse({
    required this.transactionId,
    this.qrCodeUrl,
    this.depositAddress,
    this.additionalData,
  });
}
