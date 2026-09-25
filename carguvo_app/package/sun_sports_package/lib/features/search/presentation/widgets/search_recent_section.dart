import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/core/utils/styles/spacing_styles.dart';
import 'package:sun_sports/features/search/data/storage/search_recent_storage.dart';
import 'package:sun_sports/features/search/presentation/providers/search_providers.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SearchRecentSection extends ConsumerWidget {
  const SearchRecentSection({
    super.key,
    required this.isSport,
    required this.onKeywordTap,
    this.title = 'Tìm kiếm gần đây',
  });

  final bool isSport;

  final ValueChanged<String> onKeywordTap;

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(
      isSport ? searchRecentSportProvider : searchRecentCasinoProvider,
    );
    return asyncList.when(
      data: (list) {
        final displayList = list.take(5).toList();
        if (displayList.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.labelMedium(
                color: AppColorStyles.contentSecondary,
              ),
            ),
            const Gap(AppSpacingStyles.space200),
            ...displayList.map(
              (keyword) => _RecentItem(
                key: ValueKey<String>(keyword),
                keyword: keyword,
                onTap: () => onKeywordTap(keyword),
                onRemove: () async {
                  if (isSport) {
                    await SearchRecentStorage.removeRecentSport(keyword);
                    if (context.mounted) {
                      ref.invalidate(searchRecentSportProvider);
                    }
                  } else {
                    await SearchRecentStorage.removeRecentCasino(keyword);
                    if (context.mounted) {
                      ref.invalidate(searchRecentCasinoProvider);
                    }
                  }
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RecentItem extends StatelessWidget {
  const _RecentItem({
    super.key,
    required this.keyword,
    required this.onTap,
    required this.onRemove,
  });

  final String keyword;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacingStyles.space100),
      child: InkWell(
        onTap: SoundTap.wrap(onTap),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              ImageHelper.load(
                path: AppIcons.iconRecent,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  keyword,
                  style: AppTextStyles.paragraphSmall(
                    color: AppColorStyles.contentPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(12),
              GestureDetector(
                onTap: SoundTap.wrap(onRemove),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColorStyles.contentTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
