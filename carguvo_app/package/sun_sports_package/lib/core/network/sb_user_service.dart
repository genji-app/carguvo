import 'package:auth_domain/auth_domain.dart';
import 'package:sun_sports/core/network/api_endpoints.dart';

class SbUserService {
  SbUserService._();

  static Map<String, dynamic> parseUserInfo(Map<String, dynamic> info) =>
      SbUserIdentity.parse(info).toUserDataMap();

  static double parseBalance(String balanceStr) =>
      SbUserIdentity.balanceFromKUnits(balanceStr);

  static Map<String, dynamic> createEmptyUserData() {
    return {
      'uid': '',
      'displayName': '',
      'cust_login': '',
      'cust_id': '',
      'balance': 0.0,
      'currency': '',
      'status': 'Active',
    };
  }

  static void resetUserData(Map<String, dynamic> user) {
    user['uid'] = '';
    user['displayName'] = '';
    user['cust_login'] = '';
    user['cust_id'] = '';
    user['balance'] = 0.0;
    user['currency'] = '';
    user['status'] = 'Active';
  }

  static String buildUserInfoUrl(String baseUrl) =>
      SbApiEndpoints.buildUserInfoUrl(baseUrl);

  static String buildUserBalanceUrl(String baseUrl) =>
      SbApiEndpoints.buildUserBalanceUrl(baseUrl);

  static String buildNotificationUrl(String baseUrl) =>
      SbApiEndpoints.buildNotificationUrl(baseUrl);

  static String buildTransactionHistoryUrl(
    String apiDomain, {
    int slipType = 0,
    int skip = 0,
    int limit = 10,
  }) => SbApiEndpoints.buildTransactionHistoryUrl(
    apiDomain,
    slipType: slipType,
    skip: skip,
    limit: limit,
  );

  static String buildDepositComplainsHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 10,
  }) => SbApiEndpoints.buildDepositComplainsHistoryUrl(
    apiDomain,
    skip: skip,
    limit: limit,
  );

  static String buildCardDepositHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 10,
  }) => SbApiEndpoints.buildCardDepositHistoryUrl(
    apiDomain,
    skip: skip,
    limit: limit,
  );

  static String buildCardWithdrawHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 10,
  }) => SbApiEndpoints.buildCardWithdrawHistoryUrl(
    apiDomain,
    skip: skip,
    limit: limit,
  );

  static String buildBankAccountsUrl(String apiDomain) =>
      SbApiEndpoints.buildBankAccountsUrl(apiDomain);

  static String buildPlayHistoryUrl(
    String apiDomain, {
    int skip = 0,
    int limit = 5,
    String? assetName,
  }) => SbApiEndpoints.buildPlayHistoryUrl(
    apiDomain,
    skip: skip,
    limit: limit,
    assetName: assetName,
  );

  static String buildCleanupPlayHistoryUrl(String apiDomain) =>
      SbApiEndpoints.buildCleanupPlayHistoryUrl(apiDomain);
}
