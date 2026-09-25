import 'package:flutter/material.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/services/repositories/repositories.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';

extension TransactionStatusX on TransactionStatus {
  Color get color => switch (this) {
    TransactionStatus.success => AppColors.green400,
    TransactionStatus.pending => AppColors.orange400,
    TransactionStatus.rejected => AppColors.red400,
    TransactionStatus.transfered => AppColors.green400,
    TransactionStatus.processing => AppColors.orange400,
    TransactionStatus.newRequest => AppColors.blue400,
    TransactionStatus.other => AppColors.red400,
  };

  String get label => switch (this) {
    TransactionStatus.success => I18n.txtSuccess,
    TransactionStatus.pending => I18n.txtPending,
    TransactionStatus.rejected =>
      I18n.txtFailure,
    TransactionStatus.transfered => I18n.txtTransfered,
    TransactionStatus.processing => I18n.txtProcessing,
    TransactionStatus.newRequest => I18n.txtNewRequest,
    TransactionStatus.other => I18n.txtNotAvailable,
  };
}

extension TransactionSlipTypeX on TransactionSlipType {
  String get label => switch (this) {
    TransactionSlipType.withdraw => I18n.txtWithdraw,
    TransactionSlipType.deposit => I18n.txtDeposit,
    TransactionSlipType.other => I18n.txtNotAvailable,
  };

  Color get color => switch (this) {
    TransactionSlipType.deposit => AppColorStyles.contentPrimary,
    TransactionSlipType.withdraw => AppColorStyles.contentSecondary,
    TransactionSlipType.other => AppColorStyles.contentPrimary,
  };

  Color get amountColor => switch (this) {
    TransactionSlipType.deposit => AppColors.green400,
    TransactionSlipType.withdraw => AppColorStyles.contentPrimary,
    TransactionSlipType.other => AppColorStyles.contentPrimary,
  };

  Widget get icon => switch (this) {
    TransactionSlipType.deposit => ImageHelper.load(
      path: AppIcons.transactionDeposit,
      color: color,
    ),
    TransactionSlipType.withdraw => ImageHelper.load(
      path: AppIcons.transactionWithdraw,
      color: color,
    ),
    TransactionSlipType.other => ImageHelper.load(
      path: AppIcons.transactionWithdraw,
      color: color,
    ),
  };
}

extension TransactionPaymentMethodX on TransactionPaymentMethod {
  String get label => switch (this) {
    TransactionPaymentMethod.ibanking => I18n.txtIBanking,
    TransactionPaymentMethod.atm => I18n.txtATM,
    TransactionPaymentMethod.office => I18n.txtOffice,
    TransactionPaymentMethod.digitalWallets => I18n.txtDigitalWallets,
    TransactionPaymentMethod.smartPay => I18n.txtSmartPay,
    TransactionPaymentMethod.codePay => I18n.txtCodepay,
    TransactionPaymentMethod.card => I18n.txtScratchCard,
    TransactionPaymentMethod.crypto => I18n.txtCrypto,
    TransactionPaymentMethod.qrPay => I18n.txtQRPay,
    TransactionPaymentMethod.iap => I18n.txtIAP,
    TransactionPaymentMethod.other => I18n.txtNotAvailable,
  };
}

extension UnifiedTransactionUIX on UnifiedTransaction {
  String get detailsTitle => map(
    slip: (s) => switch (s.slipType) {
      TransactionSlipType.withdraw => I18n.txtWithdrawalDetails,
      TransactionSlipType.deposit => I18n.txtDepositDetails,
      TransactionSlipType.other => I18n.txtNotAvailable,
    },
    cardDeposit: (_) => I18n.txtDepositDetails,
    cardWithdraw: (_) => I18n.txtWithdrawalDetails,
    activity: (_) => 'Chi tiết giao dịch',
  );
}

extension TransactionFailureX on TransactionFailure {
  String get userMessage => switch (this) {
    TransactionNetworkFailure() =>
      message ?? 'Không có kết nối mạng. Vui lòng thử lại.',
    TransactionServerFailure() =>
      message ?? 'Lỗi máy chủ. Vui lòng thử lại sau.',
    TransactionParseFailure() =>
      message ?? 'Không thể tải dữ liệu. Vui lòng thử lại.',
    TransactionActionFailure() =>
      message ?? 'Không thể thực hiện. Vui lòng thử lại.',
    TransactionAuthFailure() =>
      message ?? 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
    TransactionBusinessFailure() =>
      message ?? 'Đã xảy ra lỗi nghiệp vụ. Vui lòng thử lại.',
    TransactionUnknownFailure() =>
      message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.',
  };
}
