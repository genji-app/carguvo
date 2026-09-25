import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/deposit/domain/entities/bank.dart';
import 'package:sun_sports/features/profile/deposit/presentation/providers/deposit_providers.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/features/profile/deposit/presentation/utils/deposit_navigator.dart';
import 'package:sun_sports/shared/widgets/buttons/shine_button.dart';
import 'package:sun_sports/shared/widgets/cards/inner_shadow_card.dart';
import 'package:sun_sports/shared/widgets/forms/selection_menu.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class DialogConfirmationBank extends ConsumerStatefulWidget {
  const DialogConfirmationBank({super.key});

  static Future<void> show(BuildContext context) => showGeneralDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const DialogConfirmationBank(),
  );

  @override
  ConsumerState<DialogConfirmationBank> createState() =>
      _DialogConfirmationBankState();
}

class _DialogConfirmationBankState
    extends ConsumerState<DialogConfirmationBank> {
  String? _selectedBankId;
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final GlobalKey _bankButtonKey = GlobalKey();

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(bankListProvider);
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InnerShadowCard(
          child: Container(
            width: screenSize.width > 500 ? 500 : screenSize.width * 0.9,
            constraints: BoxConstraints(maxHeight: screenSize.height * 0.85),
            decoration: BoxDecoration(
              color: AppColors.gray950,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.75),
                  offset: const Offset(0, -20),
                  blurRadius: 200,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInstructionText(),
                          const SizedBox(height: 24),
                          _buildBankDropdown(banksAsync),
                          const SizedBox(height: 16),
                          _buildAccountNameField(),
                          const SizedBox(height: 16),
                          _buildAccountNumberField(),
                          const SizedBox(height: 16),
                          _buildWarningText(),
                        ],
                      ),
                    ),
                  ),
                  _buildConfirmButton(banksAsync),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: AppColors.yellow400,
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.yellow400,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Xác Minh Ngân Hàng',
            style: AppTextStyles.headingSmall(color: AppColors.gray25),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: SoundTap.wrap(() => DepositNavigator().closeAll<void>(context)),
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Center(
              child: Icon(Icons.close, size: 20, color: AppColors.gray25),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildInstructionText() => Text(
    'Nhập thông tin ngân hàng của bạn để xác minh chính chủ',
    style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
  );

  Widget _buildBankDropdown(AsyncValue<List<Bank>> banksAsync) =>
      banksAsync.when(
        data: (banks) {
          if (banks.isEmpty) {
            return Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.gray950,
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Không có ngân hàng nào',
                  style: AppTextStyles.labelSmall(color: Colors.red),
                ),
              ),
            );
          }

          if (_selectedBankId == null && banks.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedBankId = banks.first.id;
              });
            });
          }

          final selectedBank = banks.firstWhere(
            (bank) => bank.id == _selectedBankId,
            orElse: () => banks.first,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              return InkWell(
                onTap: SoundTap.wrap(() async {
                  final menuItems = banks
                      .map(
                        (bank) => SelectionMenuItem(
                          value: bank.id,
                          label: bank.name,
                          iconUrl: bank.iconUrl,
                        ),
                      )
                      .toList();

                  final selectedValue = await SelectionMenu.show(
                    context: context,
                    items: menuItems,
                    buttonKey: _bankButtonKey,
                    buttonWidth: constraints.maxWidth,
                    selectedValue: _selectedBankId,
                  );
                  if (selectedValue != null && mounted) {
                    setState(() {
                      _selectedBankId = selectedValue;
                    });
                  }
                }),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  key: _bankButtonKey,
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray950,
                    border: Border.all(
                      color: AppColors.yellow400,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (selectedBank.iconUrl != null)
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.gray25,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.gray700,
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ImageHelper.load(
                              path: selectedBank.iconUrl!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                              errorWidget: const Icon(
                                Icons.account_balance,
                                size: 20,
                                color: AppColors.gray950,
                              ),
                              placeholder: const Icon(
                                Icons.account_balance,
                                size: 20,
                                color: AppColors.gray950,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          selectedBank.name,
                          style: AppTextStyles.paragraphMedium(
                            color: AppColors.gray25,
                          ),
                        ),
                      ),
                      ImageHelper.load(
                        path: AppIcons.chevronDown,
                        width: 20,
                        height: 20,
                        color: AppColors.gray25,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.gray950,
            border: Border.all(color: AppColors.yellow400, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.gray950,
            border: Border.all(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              logAndGenericError('DepositBankConfirm', error),
              style: AppTextStyles.labelSmall(color: Colors.red),
            ),
          ),
        ),
      );

  Widget _buildAccountNameField() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColors.gray950,
      border: Border.all(
        color: AppColors.yellow400,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: _accountNameController,
      style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
      decoration: InputDecoration(
        hintText: 'Tên Tài Khoản',
        hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
        border: InputBorder.none,
      ),
    ),
  );

  Widget _buildAccountNumberField() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColors.gray950,
      border: Border.all(
        color: AppColors.yellow400,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: _accountNumberController,
      style: AppTextStyles.paragraphMedium(color: AppColors.gray25),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Số Tài Khoản',
        hintStyle: AppTextStyles.paragraphMedium(color: AppColors.gray400),
        border: InputBorder.none,
      ),
    ),
  );

  Widget _buildWarningText() => Text(
    '*Chỉ Cần Xác Minh 1 Lần*',
    style: AppTextStyles.paragraphSmall(
      color: AppColors.yellow400,
    ),
  );

  Widget _buildConfirmButton(AsyncValue<List<Bank>> banksAsync) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.gray700, width: 0.5)),
    ),
    child: ShineButton(
      text: 'XÁC NHẬN',
      height: 48,
      size: ShineButtonSize.large,
      width: double.infinity,
      style: ShineButtonStyle.primaryYellow,
      onPressed: () => _handleConfirm(banksAsync),
    ),
  );

  void _handleConfirm(AsyncValue<List<Bank>> banksAsync) {
    banksAsync.whenData((banks) {
      if (_selectedBankId == null) {
        return;
      }

      if (_accountNameController.text.trim().isEmpty) {
        return;
      }

      if (_accountNumberController.text.trim().isEmpty) {
        return;
      }

      Navigator.of(context).pop();
    });
  }
}
