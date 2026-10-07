class WithdrawResponse {
  final int status;
  final WithdrawResponseData data;

  const WithdrawResponse({required this.status, required this.data});

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? const {};
    return WithdrawResponse(
      status: json['status'] as int? ?? 0,
      data: WithdrawResponseData.fromJson(dataJson),
    );
  }
}

class WithdrawResponseData {
  final String? message;

  const WithdrawResponseData({this.message});

  factory WithdrawResponseData.fromJson(Map<String, dynamic> json) {
    return WithdrawResponseData(message: json['message']?.toString());
  }
}
