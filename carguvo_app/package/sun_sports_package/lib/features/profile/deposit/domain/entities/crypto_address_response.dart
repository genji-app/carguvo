class CryptoAddressResponse {
  final String address;
  final String qrCode;
  final String message;
  final String network;

  const CryptoAddressResponse({
    required this.address,
    required this.qrCode,
    required this.message,
    required this.network,
  });

  factory CryptoAddressResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return CryptoAddressResponse(
      address: data['address'] as String? ?? '',
      qrCode: data['qrCode'] as String? ?? '',
      message: data['message'] as String? ?? '',
      network: data['network'] as String? ?? '',
    );
  }
}
