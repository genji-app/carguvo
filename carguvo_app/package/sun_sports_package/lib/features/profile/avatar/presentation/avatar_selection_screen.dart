import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/error/app_error_messages.dart';
import 'package:sun_sports/providers/user_provider/user_provider.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/profile/avatar/domain/entities/avatar_item.dart';
import 'package:sun_sports/features/profile/avatar/presentation/providers/avatar_providers.dart';
import 'package:sun_sports/features/profile/avatar/domain/state/avatar_state.dart';
import 'package:sun_sports/features/profile/avatar/presentation/widgets/dialog_confirm_choose_avatar.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';
import 'package:sun_sports/shared/widgets/toast/app_toast.dart';

class AvatarSelectionScreen extends ConsumerStatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  ConsumerState<AvatarSelectionScreen> createState() =>
      _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends ConsumerState<AvatarSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(avatarNotifierProvider.notifier).loadAvatars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(avatarNotifierProvider);
    final currentAvatarUrl = ref.watch(userInfoProvider)?.avatarUrl;

    return _buildBody(state, currentAvatarUrl);
  }

  Widget _buildBody(AvatarListState state, String? currentAvatarUrl) {
    switch (state.status) {
      case AvatarListStatus.initial:
      case AvatarListStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            color: AppColorStyles.contentPrimary,
            strokeWidth: 2,
          ),
        );
      case AvatarListStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? I18n.txtLoadAvatarsFailed,
          onRetry: () =>
              ref.read(avatarNotifierProvider.notifier).loadAvatars(),
        );
      case AvatarListStatus.success:
        if (state.items.isEmpty) {
          return Center(
            child: Text(
              I18n.txtLoadAvatarsFailed,
              style: AppTextStyles.paragraphSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
          );
        }
        return _AvatarGrid(
          items: state.items,
          currentAvatarUrl: currentAvatarUrl,
          updatingId: state.updatingId,
          onTapAvatar: _handleTapAvatar,
        );
    }
  }

  Future<void> _handleTapAvatar(AvatarItem item) async {
    final state = ref.read(avatarNotifierProvider);
    if (state.isUpdating) return;

    final confirmed = await DialogConfirmChooseAvatar.show(context);
    if (confirmed != true) return;
    if (!mounted) return;

    final (success, message) = await ref
        .read(avatarNotifierProvider.notifier)
        .updateAvatar(item.id);

    if (!mounted) return;

    if (success) {
      ref.read(userProvider.notifier).updateAvatarLocally(item.url);

      AppToast.showSuccess(
        context,
        message: message.isEmpty ? I18n.txtUpdateAvatarSuccess : message,
      );

      final navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop();
    } else {
      AppToast.showError(
        context,
        message: localizedOrGenericError(
          'Cập nhật avatar',
          message,
          fallback: I18n.txtUpdateAvatarFailed,
        ),
      );
    }
  }
}

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({
    required this.items,
    required this.currentAvatarUrl,
    required this.updatingId,
    required this.onTapAvatar,
  });

  final List<AvatarItem> items;
  final String? currentAvatarUrl;
  final int? updatingId;
  final ValueChanged<AvatarItem> onTapAvatar;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveBuilder.responsive<int>(
      context,
      mobile: 3,
      tablet: 4,
      desktop: 3,
      largeDesktop: 4,
    );

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected =
            currentAvatarUrl != null && currentAvatarUrl == item.url;
        final isUpdating = updatingId == item.id;

        return _AvatarTile(
          item: item,
          isSelected: isSelected,
          isUpdating: isUpdating,
          isDisabled: updatingId != null && !isUpdating,
          onTap: () => onTapAvatar(item),
        );
      },
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.item,
    required this.isSelected,
    required this.isUpdating,
    required this.isDisabled,
    required this.onTap,
  });

  final AvatarItem item;
  final bool isSelected;
  final bool isUpdating;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColorStyles.contentPrimary
        : AppColorStyles.borderSecondary;

    return InkWell(
      onTap: SoundTap.wrap(isDisabled ? null : onTap),
      borderRadius: BorderRadius.circular(100),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorStyles.backgroundTertiary,
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipOval(
                child: ImageHelper.load(
                  path: item.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            if (isUpdating)
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColorStyles.contentPrimary,
                    ),
                  ),
                ),
              )
            else if (isSelected)
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColorStyles.contentPrimary,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColorStyles.backgroundSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColorStyles.contentSecondary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraphSmall(
                color: AppColorStyles.contentSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: SoundTap.wrap(onRetry),
              child: Text(
                I18n.txtRetry,
                style: AppTextStyles.paragraphSmall(
                  color: AppColorStyles.contentPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
