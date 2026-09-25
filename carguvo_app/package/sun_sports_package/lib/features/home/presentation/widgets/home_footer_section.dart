import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/core/utils/extensions/image_helper.dart';
import 'package:sun_sports/core/utils/styles/app_color.dart';
import 'package:sun_sports/core/utils/styles/app_color_styles.dart';
import 'package:sun_sports/core/utils/styles/app_icons.dart';
import 'package:sun_sports/core/utils/styles/app_text_styles.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

enum HomeFooterVariant { mobile, tablet, desktop }

class HomeFooterSection extends StatelessWidget {
  const HomeFooterSection({super.key, this.isDesktop = false});

  final bool isDesktop;

  static const double _mobileScale = 0.8;

  static const double _desktopContentWidth = 1140;

  static const double _desktopColumnGap = 64;

  static const double _desktopLinksMinWidth = 152.5 + 157.5;

  static const double _desktopCertBlockWidth =
      (2 * _desktopCertPadding + 109.5) + 16 + (2 * _desktopCertPadding + 109);

  static const double _desktopCertPadding = 24;

  static const double _desktopOneRowMinWidth =
      _desktopLinksMinWidth + _desktopCertBlockWidth + 2 * _desktopColumnGap;

  static const double _desktopWatermarkBoxWidth = 1141;
  static const double _desktopWatermarkBoxHeight = 159;
  static const double _desktopWatermarkTopOffset = 0.96;

  static const double _watermarkAspect = 2262 / 351;

  static const double _chatAspect = 30.6896 / 30.0001;

  static const List<_FooterLinkGroup> _linkGroups = [
    _FooterLinkGroup('Chính sách', [
      _FooterLink('Chính sách bảo mật', 'https://sun88.win/chinh-sach-bao-mat'),
      _FooterLink('Chính sách Cookie', 'https://sun88.win/chinh-sach-cookies'),
    ]),
    _FooterLinkGroup('Điều khoản', [
      _FooterLink(
        'Điều khoản sử dụng',
        'https://sun88.win/cac-dieu-khoan-su-dung',
      ),
      _FooterLink(
        'Miễn trừ trách nhiệm',
        'https://sun88.win/mien-tru-trach-nhiem',
      ),
    ]),
  ];

  static const String _tabletLinkTitle = 'Chính sách & điều khoản';

  static const String _paymentTitle = 'Phương thức thanh toán';
  static const String _certificationTitle = 'Chứng nhận bảo mật';

  static const String _facebookUrl = 'https://www.facebook.com/Sun88official';
  static const String _telegramUrl = 'https://t.me/sun88official';

  @override
  Widget build(BuildContext context) {
    final variant = isDesktop
        ? HomeFooterVariant.desktop
        : (ResponsiveBuilder.isMobile(context)
              ? HomeFooterVariant.mobile
              : HomeFooterVariant.tablet);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (variant) {
          HomeFooterVariant.mobile => _buildMobile(),
          HomeFooterVariant.tablet => _buildTablet(),
          HomeFooterVariant.desktop => _buildDesktop(),
        },
        if (variant != HomeFooterVariant.mobile) _buildPaymentBar(variant),
        _buildCopyright(variant),
      ],
    );
    return ColoredBox(
      color: AppColorStyles.backgroundSecondary,
      child: isDesktop
          ? Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildDesktopWatermark(),
                ),
                body,
              ],
            )
          : body,
    );
  }

  Widget _buildMobile() {
    const s = _mobileScale;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20 * s, 48 * s, 20 * s, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLinkGroup(
                  _linkGroups[0].title,
                  _linkGroups[0].links,
                  scale: s,
                ),
              ),
              const Gap(32 * s),
              Expanded(
                child: _buildLinkGroup(
                  _linkGroups[1].title,
                  _linkGroups[1].links,
                  scale: s,
                ),
              ),
            ],
          ),
          const Gap(48 * s),
          _buildMobilePayment(),
          const Gap(48 * s),
          _buildCertification(layout: _CertLayout.spread, scale: s),
        ],
      ),
    );
  }

  Widget _buildTablet() => Padding(
    padding: const EdgeInsets.fromLTRB(40, 56, 40, 56),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 40,
      runSpacing: 32,
      children: [
        _buildLinkGroup(
          _tabletLinkTitle,
          [for (final group in _linkGroups) ...group.links],
        ),
        _buildCertification(layout: _CertLayout.stacked),
      ],
    ),
  );

  Widget _buildDesktop() => _centered(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final links = <Widget>[
          Expanded(
            child: _buildLinkGroup(_linkGroups[0].title, _linkGroups[0].links),
          ),
          const Gap(_desktopColumnGap),
          Expanded(
            child: _buildLinkGroup(_linkGroups[1].title, _linkGroups[1].links),
          ),
        ];
        final certs = _buildCertification(layout: _CertLayout.inline);
        if (constraints.maxWidth >= _desktopOneRowMinWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [...links, const Gap(_desktopColumnGap), certs],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: links),
            const Gap(32),
            certs,
          ],
        );
      },
    ),
  );

  Widget _centered({required EdgeInsets padding, required Widget child}) =>
      Padding(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _desktopContentWidth),
            child: child,
          ),
        ),
      );

  Widget _buildLinkGroup(
    String title,
    List<_FooterLink> links, {
    double scale = 1,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _singleLine(title, headingStyle(scale)),
      Gap(16 * scale),
      for (int i = 0; i < links.length; i++) ...[
        if (i > 0) Gap(16 * scale),
        _buildLinkRow(links[i], scale),
      ],
    ],
  );

  Widget _singleLine(String text, TextStyle style) =>
      Text(text, style: style, maxLines: 1, softWrap: false);

  Widget _buildLinkRow(_FooterLink link, [double scale = 1]) {
    final label = _singleLine(link.label, linkStyle(scale));
    if (link.url.isEmpty) return label;
    return InkWell(onTap: SoundTap.wrap(() => _openUrl(link.url)), child: label);
  }

  Widget _buildCertification({required _CertLayout layout, double scale = 1}) {
    final cards = <Widget>[
      _buildCertCard(AppIcons.iconDMCA, 109.5 * scale, 327 / 101, scale: scale),
      _buildCertCard(AppIcons.iconCGA, 109 * scale, 327 / 128, scale: scale),
    ];
    final Widget body = switch (layout) {
      _CertLayout.stacked => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [cards[0], Gap(16 * scale), cards[1]],
      ),
      _CertLayout.inline => Row(
        mainAxisSize: MainAxisSize.min,
        children: [cards[0], Gap(16 * scale), cards[1]],
      ),
      _CertLayout.spread => Padding(
        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [cards[0], cards[1]],
        ),
      ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_certificationTitle, style: headingStyle(scale)),
        Gap(16 * scale),
        body,
      ],
    );
  }

  Widget _buildCertCard(
    String path,
    double logoWidth,
    double logoAspect, {
    double scale = 1,
  }) => Container(
    height: 60 * scale,
    padding: EdgeInsets.symmetric(
      horizontal: _desktopCertPadding * scale,
      vertical: 8 * scale,
    ),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12 * scale)),
    child: Center(
      child: ImageHelper.load(
        path: path,
        width: logoWidth,
        height: logoWidth / logoAspect,
        fit: BoxFit.contain,
      ),
    ),
  );

  Widget _buildPaymentBar(HomeFooterVariant variant) {
    switch (variant) {
      case HomeFooterVariant.mobile:
        return const SizedBox.shrink();
      case HomeFooterVariant.tablet:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
          child: SizedBox(
            height: 36,
            child: _spreadRow(_desktopPaymentItems(), minGap: 8),
          ),
        );
      case HomeFooterVariant.desktop:
        return _centered(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_paymentTitle, style: headingStyle()),
                const Gap(12),
                SizedBox(
                  height: 36,
                  child: _spreadRow(_desktopPaymentItems(), minGap: 8),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildMobilePayment() {
    const s = _mobileScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_paymentTitle, style: headingStyle(s)),
        const Gap(16 * s),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8 * s, vertical: 12 * s),
          child: Column(
            children: [
              SizedBox(
                height: 36 * s,
                child: _spreadRow(
                  [
                    _wideLogo(AppIcons.iconNapas, 78 * s, 234 / 62),
                    _wideLogo(AppIcons.iconVietQR, 68 * s, 204 / 59),
                    _squareLogo(AppIcons.payBank, 28.8 * s, boxed: false),
                    _squareLogo(AppIcons.icPaymentCrypto, 28.8 * s, boxed: false),
                    _squareLogo(AppIcons.icCryptoEth, 28.8 * s, boxed: false),
                    _squareLogo(AppIcons.icCryptoUsdt, 28.8 * s, boxed: false),
                  ],
                  minGap: 17 * s,
                ),
              ),
              const Gap(12 * s),
              SizedBox(
                height: 36 * s,
                child: _spreadRow(
                  [
                    _fixedLogo(AppIcons.payVinaphone, 87 * s, 23 * s),
                    _fixedLogo(AppIcons.payMobifone, 77 * s, 17 * s),
                    _squareLogo(AppIcons.icPaymentMomo, 28.8 * s, boxed: false),
                    _squareLogo(
                      AppIcons.icPaymentViettelPay,
                      28.8 * s,
                      boxed: true,
                      radius: 6 * s,
                    ),
                    _squareLogo(
                      AppIcons.icPaymentZaloPay,
                      28.8 * s,
                      boxed: true,
                      radius: 6 * s,
                    ),
                    _squareLogo(
                      AppIcons.iconCardViettel,
                      28.8 * s,
                      boxed: true,
                      radius: 6 * s,
                    ),
                  ],
                  minGap: 13 * s,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _spreadRow(List<_PaymentItem> items, {required double minGap}) {
    final natural =
        items.fold(0.0, (sum, item) => sum + item.width) +
        minGap * (items.length - 1);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= natural) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final item in items) item.widget],
          );
        }
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) Gap(minGap),
                items[i].widget,
              ],
            ],
          ),
        );
      },
    );
  }

  List<_PaymentItem> _desktopPaymentItems() => [
    _wideLogo(AppIcons.iconNapas, 78, 234 / 62),
    _wideLogo(AppIcons.iconVietQR, 68, 204 / 59),
    _fixedLogo(AppIcons.payVinaphone, 87, 23),
    _fixedLogo(AppIcons.payMobifone, 90, 19.385),
    _squareLogo(AppIcons.payBank, 28.8, boxed: false),
    _squareLogo(AppIcons.icPaymentCrypto, 28.8, boxed: false),
    _squareLogo(AppIcons.icCryptoEth, 28.8, boxed: false),
    _squareLogo(AppIcons.icCryptoUsdt, 28.8, boxed: false),
    _squareLogo(AppIcons.icPaymentMomo, 27, boxed: false),
    _squareLogo(AppIcons.icPaymentViettelPay, 28.8, boxed: true),
    _squareLogo(AppIcons.icPaymentZaloPay, 28.8, boxed: true),
    _squareLogo(AppIcons.iconCardViettel, 28.8, boxed: true),
  ];

  _PaymentItem _wideLogo(String path, double width, double aspect) =>
      _fixedLogo(path, width, width / aspect);

  _PaymentItem _fixedLogo(String path, double width, double height) =>
      _PaymentItem(
        width,
        ImageHelper.load(
          path: path,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      );

  _PaymentItem _squareLogo(
    String path,
    double size, {
    required bool boxed,
    double radius = 6,
  }) {
    final icon = ImageHelper.load(
      path: path,
      width: size,
      height: size,
      fit: boxed ? BoxFit.cover : BoxFit.contain,
    );
    if (!boxed) return _PaymentItem(size, icon);
    return _PaymentItem(
      size,
      Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.gray25,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: icon,
      ),
    );
  }

  Widget _buildCopyright(HomeFooterVariant variant) {
    final isDesktopVariant = variant == HomeFooterVariant.desktop;
    final s = variant == HomeFooterVariant.mobile ? _mobileScale : 1.0;
    final horizontal = switch (variant) {
      HomeFooterVariant.mobile => 16.0 * s,
      HomeFooterVariant.tablet => 40.0,
      HomeFooterVariant.desktop => 24.0,
    };
    final topInset = switch (variant) {
      HomeFooterVariant.mobile => 16.5 * s,
      HomeFooterVariant.tablet => 20.5,
      HomeFooterVariant.desktop => 40.0,
    };
    final height = switch (variant) {
      HomeFooterVariant.mobile => 57.6,
      HomeFooterVariant.tablet => 77.0,
      HomeFooterVariant.desktop => 116.0,
    };

    final row = Row(
      children: [
        Expanded(child: Text('© 2026 Sun88', style: copyrightStyle(s))),
        _buildSocialIcons(s),
      ],
    );

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          if (!isDesktopVariant)
            Positioned(
              left: variant == HomeFooterVariant.tablet ? 40 : 0,
              right: variant == HomeFooterVariant.tablet ? 40 : 0,
              bottom: variant == HomeFooterVariant.mobile ? -9.5 * s : -10.8,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final markHeight = width / _watermarkAspect;
                  return SizedBox(
                    height: markHeight,
                    child: Center(
                      child: ImageHelper.load(
                        path: AppIcons.iconSun88Footer,
                        width: width,
                        height: markHeight,
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
              ),
            ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topInset,
                left: horizontal,
                right: horizontal,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: isDesktopVariant
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _desktopContentWidth,
                        ),
                        child: row,
                      )
                    : row,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopWatermark() => IgnorePointer(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(
              constraints.maxWidth,
              _desktopWatermarkBoxWidth,
            );
            final k = width / _desktopWatermarkBoxWidth;
            return SizedBox(
              width: width,
              height: _desktopWatermarkBoxHeight * k,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    top: _desktopWatermarkTopOffset * k,
                    left: 0,
                    child: ImageHelper.load(
                      path: AppIcons.iconSun88Footer,
                      width: width,
                      height: width / _watermarkAspect,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _buildSocialIcons([double scale = 1]) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildSocialIcon(
        path: AppIcons.iconFacebook,
        width: 36 * scale,
        height: 36 * scale,
        url: _facebookUrl,
      ),
      Gap(24 * scale),
      _buildSocialIcon(
        path: AppIcons.iconTelegram,
        width: 36 * scale,
        height: 36 * scale,
        url: _telegramUrl,
      ),
      Gap(24 * scale),
      _buildSocialIcon(
        path: AppIcons.iconChatBubble,
        width: 30 * scale,
        height: 30 * scale * _chatAspect,
        onTap: _openLiveChat,
      ),
    ],
  );

  Widget _buildSocialIcon({
    required String path,
    required double width,
    required double height,
    String url = '',
    VoidCallback? onTap,
  }) {
    final icon = ImageHelper.load(
      path: path,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
    final effectiveTap = onTap ?? (url.isEmpty ? null : () => _openUrl(url));
    if (effectiveTap == null) return icon;
    return InkWell(
      borderRadius: BorderRadius.circular(width / 2),
      onTap: SoundTap.wrap(effectiveTap),
      child: icon,
    );
  }

  static TextStyle headingStyle([double scale = 1]) => AppTextStyles.textStyle(
    fontSize: 16 * scale,
    height: 24 / 16,
    fontWeight: FontWeight.w700,
    color: AppColorStyles.contentPrimary,
  );

  static TextStyle linkStyle([double scale = 1]) {
    final base = AppTextStyles.paragraphMedium(color: AppColors.gray300);
    if (scale == 1) return base;
    return base.copyWith(fontSize: (base.fontSize ?? 16) * scale);
  }

  static TextStyle copyrightStyle([double scale = 1]) =>
      AppTextStyles.textStyle(
        fontSize: 12 * scale,
        height: 18 / 12,
        fontWeight: FontWeight.w700,
        color: AppColors.gray200,
      );

  static Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> _openLiveChat() => _openUrl(SbConfig.livechatUrl);
}

enum _CertLayout { stacked, inline, spread }

class _PaymentItem {
  const _PaymentItem(this.width, this.widget);

  final double width;
  final Widget widget;
}

class _FooterLinkGroup {
  const _FooterLinkGroup(this.title, this.links);

  final String title;
  final List<_FooterLink> links;
}

class _FooterLink {
  const _FooterLink(this.label, [this.url = '']);

  final String label;
  final String url;
}
