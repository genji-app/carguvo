import 'dart:async';
import 'dart:js_interop';

import 'package:app_env/app_env.dart';
import 'package:web/web.dart' as web;

class BodyLevelGameIframe {
  BodyLevelGameIframe._(this._iframe);

  final web.HTMLIFrameElement _iframe;

  static const htmlActiveClass = 's88-casino-embed';

  static BodyLevelGameIframe attach({
    required void Function(web.HTMLIFrameElement iframe) configure,
  }) {
    final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;

    configure(iframe);

    iframe.style
      ..position = 'fixed'
      ..top = '0'
      ..left = '0'
      ..width = '100vw'
      ..height = '100dvh'
      ..border = 'none'
      ..zIndex = '10'
      ..visibility = 'hidden';

    iframe.style.setProperty('touch-action', 'auto');

    web.document.body!.appendChild(iframe);
    web.document.documentElement!.classList.add(htmlActiveClass);

    final instance = BodyLevelGameIframe._(iframe);
    instance._startScrollHeadroomGuard();
    return instance;
  }

  void show() => _iframe.style.visibility = 'visible';

  void detach() {
    _stopScrollHeadroomGuard();
    web.document.documentElement!.classList.remove(htmlActiveClass);
    _iframe.remove();
  }

  static const _scrollSettleDelay = Duration(milliseconds: 350);

  static const _scrollEdgeSlack = 8.0;

  Timer? _settleTimer;
  bool _touchActive = false;
  JSFunction? _onScroll;
  JSFunction? _onTouchStart;
  JSFunction? _onTouchEnd;

  void _startScrollHeadroomGuard() {
    final onScroll = (web.Event e) {
      _settleTimer?.cancel();
      _settleTimer = Timer(_scrollSettleDelay, _armScrollHeadroom);
    }.toJS;
    final onTouchStart = (web.Event e) {
      _touchActive = true;
      _settleTimer?.cancel();
    }.toJS;
    final onTouchEnd = (web.Event e) {
      _touchActive = false;
      _settleTimer?.cancel();
      _settleTimer = Timer(_scrollSettleDelay, _armScrollHeadroom);
    }.toJS;

    _onScroll = onScroll;
    _onTouchStart = onTouchStart;
    _onTouchEnd = onTouchEnd;
    web.window.addEventListener('scroll', onScroll);
    web.window.addEventListener('touchstart', onTouchStart);
    web.window.addEventListener('touchend', onTouchEnd);
    web.window.addEventListener('touchcancel', onTouchEnd);
    _settleTimer = Timer(_scrollSettleDelay, _armScrollHeadroom);
  }

  void _stopScrollHeadroomGuard() {
    _settleTimer?.cancel();
    _settleTimer = null;
    final onScroll = _onScroll;
    final onTouchStart = _onTouchStart;
    final onTouchEnd = _onTouchEnd;
    if (onScroll != null) {
      web.window.removeEventListener('scroll', onScroll);
    }
    if (onTouchStart != null) {
      web.window.removeEventListener('touchstart', onTouchStart);
    }
    if (onTouchEnd != null) {
      web.window
        ..removeEventListener('touchend', onTouchEnd)
        ..removeEventListener('touchcancel', onTouchEnd);
    }
    _onScroll = null;
    _onTouchStart = null;
    _onTouchEnd = null;
    _touchActive = false;
  }

  void _armScrollHeadroom() {
    _settleTimer = null;
    if (_touchActive) return;
    if (!web.document.documentElement!.classList.contains(htmlActiveClass)) {
      return;
    }
    final el = web.document.scrollingElement;
    if (el == null) return;
    final max = el.scrollHeight - el.clientHeight;
    if (max <= 0) return;
    final cur = el.scrollTop;
    if (cur > _scrollEdgeSlack && cur < max - _scrollEdgeSlack) return;
    el.scrollTop = max / 2;
  }
}

bool get isPhoneWeb => AppDevice.isPhoneBrowser;
