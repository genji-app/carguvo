abstract final class IHRunnerScripts {
  IHRunnerScripts._();

  static const String bridgeShim = '''
    (function() {
      if (window.GameHost) return;

      window.GameHost = {
        postMessage: function(message) {
          var data = typeof message === 'string' ? message : JSON.stringify(message);
          var delivered = false;

          // 1. InAppWebView handler (primary)
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('flutterChannel', data);
            delivered = true;
          }

          // 2. Legacy webview_flutter channel (fallback)
          if (!delivered && window.FlutterChannel &&
              window.FlutterChannel.postMessage && !window.FlutterChannel._isShim) {
            window.FlutterChannel.postMessage(data);
            delivered = true;
          }

          // 3. Iframe postMessage (web last resort)
          if (!delivered && window.parent && window.parent !== window) {
            window.parent.postMessage(data, '*');
          }
        }
      };

      // Legacy FlutterChannel shim for older games
      if (typeof window.FlutterChannel === 'undefined') {
        window.FlutterChannel = {
          _isShim: true,
          postMessage: function(message) {
            window.GameHost.postMessage(message);
          }
        };
      }

      console.log('[IHRunner] GameHost Bridge initialized');
    })();
  ''';

  static const String earlyWebFix = '''
    (function() {
      if (typeof screen.orientation !== 'undefined') return;
      Object.defineProperty(screen, 'orientation', {
        get: function() { return { type: 'landscape-primary', angle: 0 }; }
      });
      console.log('[IHRunner] screen.orientation polyfill applied');
    })();
  ''';

  static const String fullscreenBlocker = '''
    (function() {
      if (window.__fullscreenBlocked) return;
      window.__fullscreenBlocked = true;

      var currentFsElement = null;

      var fakeRequestFullscreen = function() {
        currentFsElement = this;
        try {
          Object.defineProperty(document, 'fullscreenElement', { get: function() { return currentFsElement; }, configurable: true });
          Object.defineProperty(document, 'webkitFullscreenElement', { get: function() { return currentFsElement; }, configurable: true });
          Object.defineProperty(document, 'mozFullScreenElement', { get: function() { return currentFsElement; }, configurable: true });
          Object.defineProperty(document, 'msFullscreenElement', { get: function() { return currentFsElement; }, configurable: true });
        } catch (e) {}

        setTimeout(function() {
          try {
            document.dispatchEvent(new Event('fullscreenchange', { bubbles: true }));
            document.dispatchEvent(new Event('webkitfullscreenchange', { bubbles: true }));
            document.dispatchEvent(new Event('mozfullscreenchange', { bubbles: true }));
          } catch (e) {}
        }, 0);
        return Promise.resolve();
      };

      var fakeExitFullscreen = function() {
        currentFsElement = null;
        try {
          Object.defineProperty(document, 'fullscreenElement', { get: function() { return null; }, configurable: true });
          Object.defineProperty(document, 'webkitFullscreenElement', { get: function() { return null; }, configurable: true });
          Object.defineProperty(document, 'mozFullScreenElement', { get: function() { return null; }, configurable: true });
          Object.defineProperty(document, 'msFullscreenElement', { get: function() { return null; }, configurable: true });
        } catch (e) {}

        setTimeout(function() {
          try {
            document.dispatchEvent(new Event('fullscreenchange', { bubbles: true }));
            document.dispatchEvent(new Event('webkitfullscreenchange', { bubbles: true }));
            document.dispatchEvent(new Event('mozfullscreenchange', { bubbles: true }));
          } catch (e) {}
        }, 0);
        return Promise.resolve();
      };

      // 1. Element APIs (Standard & Vendor prefixes)
      if (typeof Element !== 'undefined') {
        Element.prototype.requestFullscreen = fakeRequestFullscreen;
        Element.prototype.webkitRequestFullscreen = fakeRequestFullscreen;
        Element.prototype.webkitRequestFullScreen = fakeRequestFullscreen;
        Element.prototype.mozRequestFullScreen = fakeRequestFullscreen;
        Element.prototype.msRequestFullscreen = fakeRequestFullscreen;
      }

      // 2. Document APIs
      document.requestFullscreen = fakeRequestFullscreen;
      document.webkitRequestFullscreen = fakeRequestFullscreen;
      document.webkitRequestFullScreen = fakeRequestFullscreen;
      document.mozRequestFullScreen = fakeRequestFullscreen;
      document.msRequestFullscreen = fakeRequestFullscreen;

      document.exitFullscreen = fakeExitFullscreen;
      document.webkitExitFullscreen = fakeExitFullscreen;
      document.webkitCancelFullScreen = fakeExitFullscreen;
      document.mozCancelFullScreen = fakeExitFullscreen;
      document.msExitFullscreen = fakeExitFullscreen;

      // 3. HTMLVideoElement APIs (iOS & Android video elements)
      if (typeof HTMLVideoElement !== 'undefined') {
        HTMLVideoElement.prototype.webkitEnterFullscreen = fakeRequestFullscreen;
        HTMLVideoElement.prototype.webkitEnterFullScreen = fakeRequestFullscreen;
        HTMLVideoElement.prototype.webkitExitFullscreen = fakeExitFullscreen;
        HTMLVideoElement.prototype.webkitExitFullScreen = fakeExitFullscreen;
        HTMLVideoElement.prototype.enterFullscreen = fakeRequestFullscreen;
        HTMLVideoElement.prototype.exitFullscreen = fakeExitFullscreen;
        HTMLVideoElement.prototype.requestFullscreen = fakeRequestFullscreen;
        HTMLVideoElement.prototype.webkitRequestFullscreen = fakeRequestFullscreen;
        HTMLVideoElement.prototype.webkitRequestFullScreen = fakeRequestFullscreen;
      }

      // 4. Fake fullscreenEnabled to satisfy SDK feature checks
      try {
        Object.defineProperty(document, 'fullscreenEnabled', { get: function() { return true; }, configurable: true });
        Object.defineProperty(document, 'webkitFullscreenEnabled', { get: function() { return true; }, configurable: true });
        Object.defineProperty(document, 'mozFullScreenEnabled', { get: function() { return true; }, configurable: true });
        Object.defineProperty(document, 'msFullscreenEnabled', { get: function() { return true; }, configurable: true });
      } catch (e) {}

      console.log('[IHRunner] Native fullscreen blocked (faked).');
    })();
  ''';

  static const String scrollLocker = '''
    (function() {
      if (window.__scrollLocked) return;
      window.__scrollLocked = true;

      // Apply CSS viewport locking with fixed positioning.
      // This forces the DOM to stay locked at (0,0), ensuring iOS WKWebView
      // handles the keyboard push via Layer panning rather than DOM scrolling,
      // which prevents the "bump/drop down" glitch when tapping inputs.
      var style = document.createElement('style');
      style.innerHTML = 'html, body { position: fixed !important; top: 0 !important; left: 0 !important; overflow: hidden !important; width: 100% !important; height: 100% !important; touch-action: none !important; }';
      document.head.appendChild(style);

      console.log('[IHRunner] Viewport scroll locked with fixed positioning.');
    })();
  ''';

  static const String playsInlineEnforcer = '''
    (function() {
      if (window.__playsInlineEnforced) return;
      window.__playsInlineEnforced = true;

      function patchVideo(video) {
        if (!video || !video.setAttribute) return;
        try {
          if (!video.hasAttribute('playsinline')) {
            video.setAttribute('playsinline', '');
          }
          if (!video.hasAttribute('webkit-playsinline')) {
            video.setAttribute('webkit-playsinline', '');
          }
          video.playsInline = true;
        } catch (e) { /* ignore */ }
      }

      if (window.HTMLVideoElement && HTMLVideoElement.prototype.play) {
        const origPlay = HTMLVideoElement.prototype.play;
        HTMLVideoElement.prototype.play = function() {
          patchVideo(this);
          return origPlay.apply(this, arguments);
        };
      }

      try {
        var videos = document.querySelectorAll('video');
        for (var i = 0; i < videos.length; i++) {
          patchVideo(videos[i]);
        }
      } catch (e) { /* ignore */ }

      try {
        var observer = new MutationObserver(function(mutations) {
          for (var i = 0; i < mutations.length; i++) {
            var added = mutations[i].addedNodes;
            for (var j = 0; j < added.length; j++) {
              var node = added[j];
              if (node.nodeName === 'VIDEO') {
                patchVideo(node);
              } else if (node.querySelectorAll) {
                var innerVideos = node.querySelectorAll('video');
                for (var k = 0; k < innerVideos.length; k++) {
                  patchVideo(innerVideos[k]);
                }
              }
            }
          }
        });

        var target = document.documentElement || document.body;
        if (target) {
          observer.observe(target, { childList: true, subtree: true });
        }
      } catch (e) { /* ignore */ }

      console.log('[IHRunner] Playsinline enforcer active.');
    })();
  ''';
}
