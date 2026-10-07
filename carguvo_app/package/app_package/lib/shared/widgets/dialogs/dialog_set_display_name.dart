import 'dart:async';

import 'package:auth_domain/auth_domain.dart' show AuthValidator;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_package/core/services/auth/display_name_status.dart';
import 'package:app_package/core/services/network/sb_http_manager.dart';
import 'package:app_package/core/utils/styles/app_color_styles.dart';
import 'package:app_package/core/utils/styles/app_text_styles.dart';
import 'package:app_package/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_package/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_package/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:app_package/providers/auth_provider.dart';
import 'package:app_package/providers/user_provider/user_provider.dart';
import 'package:app_package/shared/widgets/buttons/shine_button.dart';
import 'package:app_package/shared/widgets/cards/inner_shadow_card.dart';
import 'package:app_package/shared/widgets/livestream/livestream_overlay_blocker.dart';
import 'package:app_package/shared/widgets/toast/app_toast.dart';

class DialogSetDisplayName extends ConsumerStatefulWidget {
  const DialogSetDisplayName({required this.loginName, super.key});

  final String loginName;

  static Future<void> show(
    BuildContext context, {
    required String loginName,
  }) async {
    pushLivestreamOverlayBlock();
    try {
      await showGeneralDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        barrierDismissible: false,
        barrierLabel: null,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DialogSetDisplayName(loginName: loginName),
      );
    } finally {
      popLivestreamOverlayBlock();
    }
  }

  @override
  ConsumerState<DialogSetDisplayName> createState() =>
      _DialogSetDisplayNameState();
}

class _DialogSetDisplayNameState extends ConsumerState<DialogSetDisplayName> {
  final _controller = TextEditingController();
  String _displayName = '';
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid =>
      AuthValidator.validateDisplayName(_displayName, widget.loginName) == null;

  Future<void> _submit() async {
    if (!_valid || _submitting) return;
    final accessToken = SbHttpManager.instance.userToken;
    if (accessToken.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await ref
          .read(authRemoteDataSourceProvider)
          .updateDisplayName(
            accessToken: accessToken,
            displayName: _displayName,
          );
      await DisplayNameStatus.markSettled();
      if (!mounted) return;
      unawaited(ref.read(userProvider.notifier).fetchUserInfo());
      Navigator.of(context).pop();
      AppToast.showSuccess(context, message: 'Đổi tên hiển thị thành công');
    } on DisplayNameUpdateException catch (error) {
      if (!mounted) return;
      if (error.isAlreadySet) {
        await DisplayNameStatus.markSettled();
        if (!mounted) return;
        Navigator.of(context).pop();
        AppToast.showGeneric(context, message: error.message);
      } else {
        setState(() => _submitting = false);
        AppToast.showError(context, message: error.message);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppToast.showError(
        context,
        message: 'Không kết nối được máy chủ, vui lòng thử lại',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (next == false && mounted) Navigator.of(context).pop();
    });

    return PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InnerShadowCard(
            child: Container(
              width: screenSize.width > 400 ? 400 : screenSize.width * 0.9,
              decoration: BoxDecoration(
                color: AppColorStyles.backgroundTertiary,
                border: Border.all(
                  color: AppColorStyles.borderSecondary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.75),
                    offset: const Offset(0, -20),
                    blurRadius: 200,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildHeader(), _buildBody()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Đặt tên hiển thị',
                style: AppTextStyles.headingXXSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tài khoản của bạn chưa có tên hiển thị. Vui lòng đặt tên để tiếp tục sử dụng.',
            style: AppTextStyles.paragraphSmall(
              color: AppColorStyles.contentSecondary,
            ),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'Tên hiển thị',
            controller: _controller,
            maxLength: 15,
            errorText: AuthValidator.validateDisplayNameRealtime(
              _displayName,
              widget.loginName,
            ),
            onChanged: (value) => setState(() => _displayName = value),
            onEditingComplete: _submit,
          ),
          const SizedBox(height: 24),
          ShineButton(
            text: _submitting ? 'Đang lưu...' : 'Xác nhận',
            height: 48,
            width: double.infinity,
            onPressed: _valid && !_submitting ? _submit : null,
          ),
        ],
      ),
    );
  }
}
