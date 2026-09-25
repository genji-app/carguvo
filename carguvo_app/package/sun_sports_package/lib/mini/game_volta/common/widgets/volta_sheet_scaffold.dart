import 'package:flutter/material.dart';

import 'package:sun_sports/core/utils/styles/app_text_styles.dart';

import '../volta_colors.dart';
import '../volta_metrics.dart';

enum VoltaSheetChrome { list, panel }

class VoltaSheetScaffold extends StatelessWidget {
  const VoltaSheetScaffold({
    required this.title,
    required this.child,
    this.columns,
    this.footer,
    this.chrome = VoltaSheetChrome.list,
    this.fitContent = false,
    this.panelHeader = false,
    super.key,
  });

  final bool panelHeader;

  final bool fitContent;

  final VoltaSheetChrome chrome;

  bool get _panel => chrome == VoltaSheetChrome.panel;

  bool get _panelLook => _panel || panelHeader;

  final String title;

  final Widget child;

  final Widget? columns;

  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final bool centered = VoltaMetrics.isTablet(context);

    final Widget body = Column(
      mainAxisSize: fitContent ? MainAxisSize.min : MainAxisSize.max,
      children: <Widget>[
        const SizedBox(height: 8),
        if (!centered)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: VoltaColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        _header(context),
        if (columns != null) columns!,
        if (fitContent) Flexible(child: child) else Expanded(child: child),
        if (footer != null) footer!,
        if (_panel) const SizedBox(height: 20),
      ],
    );

    return DecoratedBox(
      decoration: centered ? _dialogDecoration : _sheetDecoration,
      child: centered
          ? ClipRRect(borderRadius: _dialogRadius, child: body)
          : SafeArea(top: false, child: body),
    );
  }

  Widget _header(BuildContext context) {
    final double pad = _panelLook ? 12 : 0;
    return Padding(
      padding: EdgeInsets.all(pad),
      child: SizedBox(
        height: _panelLook ? 32 : 56,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelLarge(
                color: VoltaColors.contentPrimary,
              ),
            ),
            Positioned(
              right: _panelLook ? 0 : 4,
              top: 0,
              bottom: 0,
              child: Center(child: _closeButton(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    if (!_panelLook) {
      return IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.close, size: 20),
        color: VoltaColors.contentSecondary,
        tooltip: 'Đóng',
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: VoltaColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.close,
          size: 16,
          color: VoltaColors.contentPrimary,
        ),
      ),
    );
  }

  Color get _background =>
      _panelLook ? VoltaColors.surfaceRaised : const Color(0xFF0E0D0C);

  double get _radius => _panelLook ? 24 : 16;

  BoxDecoration get _sheetDecoration => BoxDecoration(
    color: _background,
    borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
  );

  BorderRadius get _dialogRadius => BorderRadius.all(Radius.circular(_radius));

  BoxDecoration get _dialogDecoration =>
      BoxDecoration(color: _background, borderRadius: _dialogRadius);
}
