abstract final class PLInAppRunnerScripts {
  PLInAppRunnerScripts._();

  static const String diagnostics = r'''
    (function() {
      const safeGet = (fn) => { try { return fn(); } catch(e) { return 'ERROR: ' + e; } };

      const screenOrientationType  = safeGet(() => screen.orientation ? screen.orientation.type  : 'undefined');
      const screenOrientationAngle = safeGet(() => screen.orientation ? screen.orientation.angle : 'undefined');
      const screenWidth     = safeGet(() => screen.width);
      const screenHeight    = safeGet(() => screen.height);
      const innerWidth      = safeGet(() => window.innerWidth);
      const innerHeight     = safeGet(() => window.innerHeight);
      const devicePixelRatio = safeGet(() => window.devicePixelRatio);
      const ua              = safeGet(() => navigator.userAgent.substring(0, 80));
      const viewportMeta    = safeGet(() => {
        const m = document.querySelector('meta[name="viewport"]');
        return m ? m.content : 'NOT FOUND';
      });
      const matchMediaLandscape = safeGet(() => window.matchMedia('(orientation: landscape)').matches);
      const matchMediaPortrait  = safeGet(() => window.matchMedia('(orientation: portrait)').matches);

      console.log(
        '[PLRunner:DIAG] ' + JSON.stringify({
          screen_orientation_type:  screenOrientationType,
          screen_orientation_angle: screenOrientationAngle,
          screen_wh:                screenWidth + 'x' + screenHeight,
          inner_wh:                 innerWidth  + 'x' + innerHeight,
          dpr:                      devicePixelRatio,
          matchMedia_landscape:     matchMediaLandscape,
          matchMedia_portrait:      matchMediaPortrait,
          viewport_meta:            viewportMeta,
          ua:                       ua,
        })
      );
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

      console.log('[PLRunner] Native fullscreen blocked & faked.');
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

      // 1. Intercept HTMLVideoElement.prototype.play to patch on-the-fly
      if (window.HTMLVideoElement && HTMLVideoElement.prototype.play) {
        const origPlay = HTMLVideoElement.prototype.play;
        HTMLVideoElement.prototype.play = function() {
          patchVideo(this);
          return origPlay.apply(this, arguments);
        };
      }

      // 2. Patch existing videos
      try {
        var videos = document.querySelectorAll('video');
        for (var i = 0; i < videos.length; i++) {
          patchVideo(videos[i]);
        }
      } catch (e) { /* ignore */ }

      // 3. Observe DOM for dynamically created video elements
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
        } else {
          document.addEventListener('DOMContentLoaded', function() {
            var docTarget = document.documentElement || document.body;
            if (docTarget) {
              observer.observe(docTarget, { childList: true, subtree: true });
            }
          });
        }
      } catch (e) { /* ignore */ }

      console.log('[PLRunner] Playsinline enforcer active.');
    })();
  ''';

  static const String orientationPolyfill = r'''
    (function() {
      const TAG = '[PLRunner:OrientationPolyfill]';

      // ── 1. screen.orientation (modern API) ──────────────────────────────────
      const landscapeOrientationDescriptor = {
        get: function() {
          return {
            type: 'landscape-primary',
            angle: 90,
            lock: function() { return Promise.resolve(); },
            unlock: function() {},
          };
        },
        configurable: true,
      };

      try {
        const currentType = (typeof screen.orientation !== 'undefined')
          ? screen.orientation.type
          : 'undefined';
        console.log(TAG + ' screen.orientation.type BEFORE patch: ' + currentType);

        if (!currentType || currentType === 'undefined' || currentType.startsWith('portrait')) {
          Object.defineProperty(screen, 'orientation', landscapeOrientationDescriptor);
          console.log(TAG + ' Patched screen.orientation → landscape-primary');
        } else {
          console.log(TAG + ' screen.orientation already landscape, no patch needed');
        }
      } catch (e) {
        console.error(TAG + ' screen.orientation patch failed: ' + e);
      }

      // ── 2. screen.width / screen.height (legacy API — primary root cause) ───
      // On iOS, screen.width/height never rotate. Games check screen.width < screen.height
      // to decide portrait vs landscape. We swap them to reflect landscape reality.
      try {
        const origWidth  = screen.width;
        const origHeight = screen.height;
        console.log(TAG + ' screen.width/height BEFORE patch: ' + origWidth + 'x' + origHeight);

        if (origWidth < origHeight) {
          const landscapeW = origHeight;
          const landscapeH = origWidth;
          Object.defineProperty(screen, 'width',  { get: function() { return landscapeW; }, configurable: true });
          Object.defineProperty(screen, 'height', { get: function() { return landscapeH; }, configurable: true });
          console.log(TAG + ' Patched screen.width/height: ' + landscapeW + 'x' + landscapeH);
        } else {
          console.log(TAG + ' screen.width already > height, no patch needed');
        }
      } catch (e) {
        console.error(TAG + ' screen.width/height patch failed: ' + e);
      }

      // ── 3. window.orientation (legacy API, 0=portrait, 90=landscape-right) ──
      try {
        const currentWinOrientation = window.orientation;
        console.log(TAG + ' window.orientation BEFORE patch: ' + currentWinOrientation);

        if (currentWinOrientation === 0 || currentWinOrientation === 180 || typeof currentWinOrientation === 'undefined') {
          Object.defineProperty(window, 'orientation', { get: function() { return 90; }, configurable: true });
          console.log(TAG + ' Patched window.orientation → 90');
        } else {
          console.log(TAG + ' window.orientation already landscape (' + currentWinOrientation + '), no patch needed');
        }
      } catch (e) {
        console.error(TAG + ' window.orientation patch failed: ' + e);
      }

      // ── 4. window.matchMedia ─────────────────────────────────────────────────
      // iOS matchMedia reads actual viewport size (innerWidth/innerHeight), NOT screen.width/height.
      // So patching screen.* is NOT enough — matchMedia will still report portrait when
      // innerWidth < innerHeight (e.g. during initial load phase when innerWH=0x0).
      // We intercept matchMedia and override orientation-specific queries only.
      try {
        if (window.__matchMediaPatched !== true) {
          const _origMatchMedia = window.matchMedia.bind(window);
          const _matchMediaOverride = function(query) {
            const normalizedQ = (query || '').replace(/\s/g, '').toLowerCase();
            const isLandscapeQuery = normalizedQ.includes('orientation:landscape');
            const isPortraitQuery  = normalizedQ.includes('orientation:portrait');

            if (!isLandscapeQuery && !isPortraitQuery) {
              return _origMatchMedia(query);
            }

            // Force landscape=true, portrait=false regardless of actual layout.
            const targetMatches = isLandscapeQuery;
            const real = _origMatchMedia(query);

            const fake = Object.create(real);
            Object.defineProperty(fake, 'matches', { get: function() { return targetMatches; }, configurable: true });
            fake.addEventListener = function(type, listener) {
              if (type === 'change') {
                try {
                  const ev = Object.create(real);
                  Object.defineProperty(ev, 'matches', { get: function() { return targetMatches; } });
                  listener(ev);
                } catch(ex) { /* ignore */ }
              }
              return real.addEventListener(type, listener);
            };
            fake.addListener = function(listener) {
              try {
                const ev = Object.create(real);
                Object.defineProperty(ev, 'matches', { get: function() { return targetMatches; } });
                listener(ev);
              } catch(ex) { /* ignore */ }
              return real.addListener(listener);
            };
            return fake;
          };

          Object.defineProperty(window, 'matchMedia', {
            value: _matchMediaOverride,
            configurable: true,
            writable: true,
          });
          window.__matchMediaPatched = true;
          console.log(TAG + ' Patched window.matchMedia → forces orientation:landscape=true');
        } else {
          console.log(TAG + ' window.matchMedia already patched, skipping');
        }
      } catch (e) {
        console.error(TAG + ' window.matchMedia patch failed: ' + e);
      }

      // ── 5. window.innerWidth / innerHeight ───────────────────────────────────
      // Many game engines check `innerWidth > innerHeight` directly.
      // On first load, innerWidth/innerHeight can be 0x0 (WebView not yet laid out)
      // or still portrait even when the device is landscape.
      // Smart proxy: if real values are 0 or portrait → fallback to patched screen dims;
      //              if already correct landscape → return real values (self-healing).
      try {
        if (window.__innerWHPatched !== true) {
          const iwDesc = Object.getOwnPropertyDescriptor(Window.prototype, 'innerWidth')
                      || Object.getOwnPropertyDescriptor(window, 'innerWidth');
          const ihDesc = Object.getOwnPropertyDescriptor(Window.prototype, 'innerHeight')
                      || Object.getOwnPropertyDescriptor(window, 'innerHeight');

          if (iwDesc && iwDesc.get && ihDesc && ihDesc.get) {
            const origGetIW = iwDesc.get;
            const origGetIH = ihDesc.get;

            Object.defineProperty(window, 'innerWidth', {
              get: function() {
                const realW = origGetIW.call(this);
                const realH = origGetIH.call(this);
                if (realW === 0 || realW < realH) return screen.width;
                return realW;
              },
              configurable: true,
            });

            Object.defineProperty(window, 'innerHeight', {
              get: function() {
                const realW = origGetIW.call(this);
                const realH = origGetIH.call(this);
                if (realW === 0 || realW < realH) return screen.height;
                return realH;
              },
              configurable: true,
            });

            window.__innerWHPatched = true;
            console.log(TAG + ' Patched innerWidth/innerHeight with smart landscape fallback');
          } else {
            console.log(TAG + ' innerWidth/innerHeight descriptors not found, skipping');
          }
        }
      } catch (e) {
        console.error(TAG + ' innerWidth/innerHeight patch failed: ' + e);
      }

      // ── 6. Dispatch orientation events ──────────────────────────────────────
      // After all patches, dispatch resize + orientationchange so games that
      // listen for these events re-evaluate their layout with patched values.
      try {
        if (!window.__orientationEventsDispatched) {
          window.__orientationEventsDispatched = true;
          window.dispatchEvent(new Event('resize'));
          window.dispatchEvent(new Event('orientationchange'));
          // Delayed re-dispatch for games that initialize after a microtask/tick.
          setTimeout(function() {
            window.dispatchEvent(new Event('resize'));
            window.dispatchEvent(new Event('orientationchange'));
          }, 100);
          console.log(TAG + ' Dispatched resize + orientationchange events');
        }
      } catch (e) {
        console.error(TAG + ' Event dispatch failed: ' + e);
      }

      // ── Verification log ─────────────────────────────────────────────────────
      const postMatchLandscape = (function() {
        try { return window.matchMedia('(orientation: landscape)').matches; } catch(e) { return 'ERROR'; }
      })();
      console.log(
        TAG + ' AFTER all patches'
        + ' — screen: ' + screen.width + 'x' + screen.height
        + ' inner: '  + window.innerWidth + 'x' + window.innerHeight
        + ' orientation.type: ' + (screen.orientation ? screen.orientation.type : 'undefined')
        + ' window.orientation: ' + window.orientation
        + ' matchMedia(landscape): ' + postMatchLandscape
      );
    })();
  ''';

  static const String landscapeViewport = r'''
    (function() {
      const TAG = '[PLRunner:Viewport]';

      const detectIsLandscape = function() {
        const w = window.innerWidth;
        const h = window.innerHeight;
        if (w === 0 || h === 0) {
          const fw = screen.width;
          const fh = screen.height;
          if (fw > 0 && fh > 0) {
            console.log(TAG + ' innerWH=0x0, falling back to patched screen.WH: ' + fw + 'x' + fh);
            return fw > fh;
          }
          const orientType = (screen.orientation && screen.orientation.type) || '';
          const fallback = orientType.startsWith('landscape');
          console.log(TAG + ' innerWH=0x0, falling back to orientation: ' + orientType + ' → landscape=' + fallback);
          return fallback;
        }
        return w > h;
      };

      const buildContent = function(isLandscape) {
        const suffix = 'initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
        return isLandscape
          ? ('width=device-width, ' + suffix)
          : ('width=device-height, ' + suffix);
      };

      const applyViewport = function() {
        var meta = document.querySelector('meta[name="viewport"]');
        const existed = !!meta;
        if (!meta) {
          meta = document.createElement('meta');
          meta.name = 'viewport';
          document.getElementsByTagName('head')[0].appendChild(meta);
        }
        const expected = buildContent(detectIsLandscape());
        const previous = meta.content;
        if (previous !== expected) {
          meta.content = expected;
          console.log(
            TAG + ' Applied — innerWH=' + window.innerWidth + 'x' + window.innerHeight
            + ' isLandscape=' + detectIsLandscape()
            + ' previous="' + previous + '"'
            + ' new="' + expected + '"'
            + ' metaExisted=' + existed
          );
          return true;
        }
        console.log(TAG + ' No change needed — content="' + expected + '" innerWH=' + window.innerWidth + 'x' + window.innerHeight);
        return false;
      };

      applyViewport();

      // ── Targeted MutationObserver (performance optimized) ──────────────────
      // Watch <head> childList only (for meta being added/removed), and the
      // viewport meta itself for content attribute changes.
      // Debounce via requestAnimationFrame; auto-disconnect after 3 stable frames.
      let rafId = null;
      let stableCount = 0;
      const STABLE_THRESHOLD = 3;

      const debouncedApply = function() {
        if (rafId !== null) return;
        rafId = requestAnimationFrame(function() {
          rafId = null;
          const changed = applyViewport();
          if (changed) {
            stableCount = 0;
          } else {
            stableCount++;
            if (stableCount >= STABLE_THRESHOLD) {
              observer.disconnect();
              console.log(TAG + ' Viewport stable, Observer disconnected to reduce CPU usage');
            }
          }
        });
      };

      const observer = new MutationObserver(function(mutations) {
        const isRelevant = mutations.some(function(m) {
          if (m.type === 'childList') {
            return Array.from(m.addedNodes).some(function(n) { return n.nodeName === 'META'; });
          }
          return m.type === 'attributes';
        });
        if (isRelevant) debouncedApply();
      });

      observer.observe(document.head, { childList: true });

      const existingMeta = document.querySelector('meta[name="viewport"]');
      if (existingMeta) {
        observer.observe(existingMeta, { attributes: true, attributeFilter: ['content'] });
      }

      window.addEventListener('resize', function() {
        console.log(TAG + ' resize event, re-applying...');
        stableCount = 0;
        applyViewport();
      });
    })();
  ''';
}
