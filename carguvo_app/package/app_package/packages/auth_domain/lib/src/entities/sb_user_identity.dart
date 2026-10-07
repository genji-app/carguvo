library;

class SbUserIdentity {
  const SbUserIdentity({
    this.uid = '',
    this.displayName = '',
    this.custLogin = '',
    this.custId = '',
    this.balance = 0,
    this.currency = 'VND',
    this.status = 'Active',
  });

  final String uid;
  final String displayName;

  final String custLogin;

  final String custId;

  final double balance;

  final String currency;
  final String status;

  static SbUserIdentity parse(Map<String, dynamic> info) {
    if (info.containsKey('0')) {
      final username = info['0']?.toString() ?? '';
      return SbUserIdentity(
        uid: '',
        displayName: username,
        custLogin: username,
        custId: '',
        balance: balanceFromKUnits(info['2']?.toString() ?? '0'),
        currency: info['1']?.toString() ?? 'VND',
        status: info['3']?.toString() ?? 'Active',
      );
    }

    return SbUserIdentity(
      uid: info['uid']?.toString() ?? '',
      displayName: info['displayName']?.toString() ?? '',
      custLogin: info['cust_login']?.toString() ?? '',
      custId: info['cust_id']?.toString() ?? '',
      balance: balanceFromKUnits(info['balance']?.toString() ?? '0'),
      currency: info['currency']?.toString() ?? 'VND',
      status: info['status']?.toString() ?? 'Active',
    );
  }

  static double balanceFromKUnits(String raw) {
    final cleaned = raw.replaceAll('.', '');
    return (int.tryParse(cleaned) ?? 0).toDouble();
  }

  Map<String, dynamic> toUserDataMap() => {
        'uid': uid,
        'displayName': displayName,
        'cust_login': custLogin,
        'cust_id': custId,
        'balance': balance,
        'currency': currency,
        'status': status,
      };

  @override
  String toString() =>
      'SbUserIdentity(custLogin: $custLogin, custId: "$custId", '
      'displayName: $displayName, balance: $balance, currency: $currency)';
}
