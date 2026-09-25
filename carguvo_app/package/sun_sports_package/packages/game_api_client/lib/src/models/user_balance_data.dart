part of 'models.dart';

@immutable
class UserBalanceData {
  const UserBalanceData({
    required this.balance,
    this.displayName = '',
    this.userId = '',
  });

  factory UserBalanceData.fromJson(Map<String, dynamic> json) {
    final raw = json['balance'];
    final num? balance = raw is num
        ? raw
        : raw is String
            ? _digitsOnly(raw)
            : null;
    if (balance == null) {
      throw const FormatException('Missing or invalid "balance" in fetch-balance response');
    }
    return UserBalanceData(
      balance: balance,
      displayName: json['displayName']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
    );
  }

  static num? _digitsOnly(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  final num balance;

  final String displayName;

  final String userId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBalanceData &&
          other.balance == balance &&
          other.displayName == displayName &&
          other.userId == userId;

  @override
  int get hashCode => Object.hash(balance, displayName, userId);

  @override
  String toString() =>
      'UserBalanceData(balance: $balance, displayName: $displayName, userId: $userId)';
}
