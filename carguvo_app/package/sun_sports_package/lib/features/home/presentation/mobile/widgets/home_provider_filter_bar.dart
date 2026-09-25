library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sun_sports/core/constants/i18n.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/features/game/game.dart';
import 'package:sun_sports/providers/casino_provider_menu_provider.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

const double kHomeProviderFilterRowHeight = 26;

const Duration kHomeProviderFilterDuration = Duration(milliseconds: 250);

const Map<String, String> _kShortLabels = <String, String>{
  'sun': 'Sunwin',
  'ncc:amb-vn': 'Sexy',
  'ncc:lcevo': 'Evo',
  'ncc:vivo': 'Vivo',
  'ncc:via-casino-vn': 'Via',
};

const Color _kChipFlare = Color(0xFFF38744);
const Color _kChipSweep = AppColors.yellow300;

class HomeProviderFilterBar extends ConsumerStatefulWidget {
  const HomeProviderFilterBar({
    required this.providers,
    required this.providerId,
    required this.onProvider,
    required this.rawQuery,
    required this.onQuery,
    super.key,
  });

  final List<LobbyCategory> providers;

  final String providerId;

  final ValueChanged<String> onProvider;

  final String rawQuery;

  final ValueChanged<String> onQuery;

  @override
  ConsumerState<HomeProviderFilterBar> createState() =>
      _HomeProviderFilterBarState();
}

class _HomeProviderFilterBarState extends ConsumerState<HomeProviderFilterBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expand = AnimationController(
    vsync: this,
    duration: kHomeProviderFilterDuration,
    value: _searchOnly || widget.rawQuery.isNotEmpty ? 1 : 0,
  );

  late final TextEditingController _text = TextEditingController(
    text: widget.rawQuery,
  );
  final FocusNode _focus = FocusNode();

  final ScrollController _chipScroll = ScrollController();
  final Map<String, GlobalKey> _chipKeys = <String, GlobalKey>{};

  String? _revealedFor;

  bool _userExpanded = false;

  bool get _searchOnly => widget.providers.length < 2;

  bool get _expanded =>
      _userExpanded || _searchOnly || widget.rawQuery.isNotEmpty;

  @override
  void didUpdateWidget(HomeProviderFilterBar old) {
    super.didUpdateWidget(old);
    if (widget.rawQuery != _text.text) {
      _text.value = TextEditingValue(
        text: widget.rawQuery,
        selection: TextSelection.collapsed(offset: widget.rawQuery.length),
      );
    }
    if (_expanded != (_expand.value == 1)) {
      if (_expanded) {
        _expand.forward();
      } else {
        _expand.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expand.dispose();
    _text.dispose();
    _focus.dispose();
    _chipScroll.dispose();
    super.dispose();
  }

  void _openSearch() {
    if (_expanded) return;
    setState(() => _userExpanded = true);
    _expand.forward();
    _focus.requestFocus();
  }

  void _dismiss() {
    if (_searchOnly) {
      if (widget.rawQuery.isNotEmpty) widget.onQuery('');
      return;
    }
    if (widget.rawQuery.isNotEmpty) widget.onQuery('');
    _focus.unfocus();
    setState(() => _userExpanded = false);
    _expand.reverse();
  }

  void _scheduleReveal() {
    final String key =
        '${widget.providerId}|'
        '${widget.providers.map((LobbyCategory e) => e.id).join(',')}';
    if (key == _revealedFor) return;
    final bool smooth = _revealedFor != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderObject? object = _chipKeys[widget.providerId]?.currentContext
          ?.findRenderObject();
      if (object == null || !_chipScroll.hasClients) return;
      _revealedFor = key;
      _chipScroll.position.ensureVisible(
        object,
        alignment: 0.5,
        duration: smooth
            ? kHomeProviderFilterDuration
            : Duration.zero,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleReveal();
    final ProviderGameManager manager = ref.watch(providerGameManagerProvider);
    return PopScope(
      canPop: !(_expanded && !_searchOnly),
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _dismiss();
      },
      child: _row(manager),
    );
  }

  Widget _row(ProviderGameManager manager) {
    return SizedBox(
      height: kHomeProviderFilterRowHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double total = constraints.maxWidth;
            final Widget chips = _searchOnly
                ? const SizedBox.shrink()
                : _chips(manager);
            return AnimatedBuilder(
              animation: _expand,
              builder: (BuildContext context, _) {
                final double e = Curves.easeOut.transform(_expand.value);
                final double searchWidth =
                    kHomeProviderFilterRowHeight +
                    (total - kHomeProviderFilterRowHeight) * e;
                final double gap = 10 * (1 - e);
                final double chipsWidth = (total - searchWidth - gap).clamp(
                  0.0,
                  total,
                );
                return Row(
                  children: <Widget>[
                    SizedBox(
                      width: searchWidth,
                      child: _searchBox(expandedFactor: e, contentWidth: total),
                    ),
                    if (!_searchOnly) ...<Widget>[
                      SizedBox(width: gap),
                      SizedBox(
                        width: chipsWidth,
                        child: IgnorePointer(
                          ignoring: e > 0.5,
                          child: Opacity(
                            opacity: (1 - e).clamp(0.0, 1.0),
                            child: chips,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _searchBox({
    required double expandedFactor,
    required double contentWidth,
  }) {
    final double e = expandedFactor;
    final bool expanded = _expanded;
    final bool showX = !_searchOnly || widget.rawQuery.isNotEmpty;
    final double radius = 13 - 5 * e;
    final double padH = 3.8 + (10 - 3.8) * e;

    final Widget box = Container(
      height: kHomeProviderFilterRowHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColorStyles.backgroundTertiary,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColorStyles.borderSecondary, width: 0.7),
      ),
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: contentWidth,
        maxWidth: contentWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH),
          child: Row(
            children: <Widget>[
              ImageHelper.load(
                path: AppIcons.icSearch,
                width: 17,
                height: 17,
                fit: BoxFit.contain,
              ),
              Expanded(
                child: Opacity(
                  opacity: e,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _input(enabled: expanded),
                  ),
                ),
              ),
              Opacity(
                opacity: showX ? e : 0,
                child: IgnorePointer(ignoring: !showX, child: _clearButton()),
              ),
            ],
          ),
        ),
      ),
    );

    if (expanded) return box;
    return Semantics(
      button: true,
      label: I18n.txtSearchGame,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(_openSearch),
        child: box,
      ),
    );
  }

  Widget _input({required bool enabled}) {
    return TextField(
      controller: _text,
      focusNode: _focus,
      enabled: enabled,
      onChanged: widget.onQuery,
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.yellow300,
      cursorHeight: 14,
      style: AppTextStyles.textStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: AppColorStyles.contentPrimary,
      ),
      decoration: InputDecoration.collapsed(
        hintText: I18n.txtSearchGame,
        hintStyle: AppTextStyles.textStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          color: AppColorStyles.contentTertiary,
        ),
      ),
    );
  }

  Widget _clearButton() {
    return Semantics(
      button: true,
      label: _searchOnly ? 'Xoá tìm kiếm' : 'Đóng tìm kiếm',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: SoundTap.wrap(_dismiss),
        child: SizedBox.square(
          dimension: 20,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                for (final double angle in <double>[0.7853982, -0.7853982])
                  Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: 14,
                      height: 1.67,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC3C2BC),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chips(ProviderGameManager manager) {
    final String selected = widget.providerId;
    final List<LobbyCategory> providers = widget.providers;
    return ListView.separated(
      controller: _chipScroll,
      scrollDirection: Axis.horizontal,
      scrollCacheExtent: const ScrollCacheExtent.pixels(3000),
      padding: EdgeInsets.zero,
      itemCount: providers.length + 1,
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _chip(
            id: '',
            label: 'Tất cả',
            icon: selected.isEmpty
                ? AppIcons.iconNccAllSelected
                : AppIcons.iconNccAll,
            selected: selected.isEmpty,
          );
        }
        final LobbyCategory category = providers[index - 1];
        final bool isSelected = category.id == selected;
        return _chip(
          id: category.id,
          label:
              _kShortLabels[category.id] ??
              casinoProviderMenuLabel(category, manager),
          icon: isSelected
              ? casinoProviderMenuIcons(category).active
              : casinoProviderMenuIcons(category).icon,
          selected: isSelected,
        );
      },
    );
  }

  Widget _chip({
    required String id,
    required String label,
    required String icon,
    required bool selected,
  }) {
    final GlobalKey key = _chipKeys.putIfAbsent(id, () => GlobalKey());
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox.square(
            dimension: 20,
            child: ImageHelper.load(
              path: icon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: AppTextStyles.textStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 16 / 10,
              color: AppColorStyles.contentPrimary,
            ),
          ),
        ],
      ),
    );

    return Align(
      key: key,
      widthFactor: 1,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: SoundTap.wrap(() => widget.onProvider(id)),
          child: SizedBox(
            height: 25,
            child: selected ? _selectedChip(content) : _idleChip(content),
          ),
        ),
      ),
    );
  }

  Widget _idleChip(Widget content) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColorStyles.backgroundSecondary,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColorStyles.borderPrimary),
    ),
    child: content,
  );

  Widget _selectedChip(Widget content) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColorStyles.borderPrimary,
      borderRadius: BorderRadius.circular(16),
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment(-0.48, -0.87),
          end: Alignment(0.48, 0.87),
          colors: <Color>[_kChipFlare, Color(0x00F38744)],
          stops: <double>[0.09, 0.52],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0x00FDE272), _kChipSweep, Color(0x00FDE272)],
            stops: <double>[0, 0.5, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundSecondary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x00FDE272),
                    Color(0x33FDE272),
                  ],
                ),
              ),
              child: content,
            ),
          ),
        ),
      ),
    ),
  );
}
