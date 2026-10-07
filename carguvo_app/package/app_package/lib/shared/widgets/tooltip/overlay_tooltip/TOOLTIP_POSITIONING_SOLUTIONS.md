# Tooltip Positioning Solutions

## 🐛 Problem Statement

When using `OverlayTooltipController` in scrollable lists (e.g., `ListView`, `BetSlipCard`), tooltips may show at incorrect positions, especially when:
- User scrolls the list
- Taps different items rapidly
- List rebuilds or updates
- Items are reused (ListView optimization)

### Root Causes:
1. **GlobalKey Reuse**: Keys may reference stale positions in scrollable lists
2. **Timing Issues**: Position calculated before layout stabilizes
3. **Scroll Events**: Button position changes but tooltip doesn't update
4. **Shared State**: Multiple items sharing same controller instance

---

## 💡 Solution Options

### Option 1: Unique Key Per Item ⭐
**Complexity**: Low | **Effectiveness**: Medium | **Performance**: Good

#### Description:
Create unique `GlobalKey` for each list item based on item ID.

#### Pros:
- ✅ Ensures each item has unique key
- ✅ No conflict when scrolling
- ✅ Key stable across rebuilds
- ✅ Simple implementation

#### Cons:
- ⚠️ Requires item ID to be available

#### Implementation:
```dart
class _BetSlipExplanationButtonState extends State<BetSlipExplanationButton> {
  // ✅ Create unique key based on bet ID
  late final GlobalKey _iconKey = GlobalKey(
    debugLabel: 'tooltip_${widget.bet?.id ?? widget.subBet?.id ?? DateTime.now().millisecondsSinceEpoch}'
  );
  
  late final _tooltipController = OverlayTooltipController();
  
  @override
  void dispose() {
    _tooltipController.remove();
    super.dispose();
  }
}
```

#### When to Use:
- Items have stable unique IDs
- Simple fix needed
- No complex scroll behavior

---

### Option 2: Controller Per Item ⭐⭐
**Complexity**: Low | **Effectiveness**: Good | **Performance**: Fair

#### Description:
Each button instance has its own `OverlayTooltipController`.

#### Pros:
- ✅ No conflict between items
- ✅ Each tooltip independent
- ✅ Better state isolation
- ✅ Easy to implement

#### Cons:
- ⚠️ More memory usage (multiple controller instances)
- ⚠️ Doesn't solve scroll position issues

#### Implementation:
```dart
class _BetSlipExplanationButtonState extends State<BetSlipExplanationButton> {
  final _iconKey = GlobalKey();
  late final _tooltipController = OverlayTooltipController(); // ✅ Own instance
  
  @override
  void dispose() {
    _tooltipController.remove(); // ✅ Clean up own controller
    super.dispose();
  }
}
```

#### When to Use:
- Multiple tooltips may be open simultaneously
- Need better state isolation
- Memory is not a concern

---

### Option 3: Position Tracking with Listener ⭐⭐⭐
**Complexity**: High | **Effectiveness**: Excellent | **Performance**: Fair

#### Description:
Track scroll position and update tooltip position in real-time.

#### Pros:
- ✅ Tooltip follows button when scrolling
- ✅ Always accurate position
- ✅ Best UX for persistent tooltips

#### Cons:
- ⚠️ Complex implementation
- ⚠️ Performance overhead (continuous tracking)
- ⚠️ May be overkill for simple tooltips

#### Implementation:
```dart
class _BetSlipExplanationButtonState extends State<BetSlipExplanationButton> {
  final _iconKey = GlobalKey();
  final _tooltipController = OverlayTooltipController();
  ScrollPosition? _scrollPosition;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // ✅ Listen to scroll events
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);
  }
  
  void _onScroll() {
    // ✅ Update tooltip position or close it
    if (_tooltipController.isShowing) {
      // Option A: Close tooltip
      _tooltipController.remove();
      
      // Option B: Update position (more complex)
      // _updateTooltipPosition();
    }
  }
  
  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _tooltipController.remove();
    super.dispose();
  }
}
```

#### When to Use:
- Tooltips should stay visible during scroll
- Need real-time position updates
- Performance is acceptable

---

### Option 4: Auto-Close on Scroll ⭐⭐⭐⭐ (RECOMMENDED)
**Complexity**: Low | **Effectiveness**: Very Good | **Performance**: Excellent

#### Description:
Automatically close tooltip when user scrolls the list.

#### Pros:
- ✅ Very simple implementation
- ✅ Prevents stale position issues
- ✅ Good UX (common pattern in mobile apps)
- ✅ No performance overhead
- ✅ Works with any list type

#### Cons:
- ⚠️ User must tap again after scrolling

#### Implementation:
```dart
class _BetSlipExplanationButtonState extends State<BetSlipExplanationButton> {
  final _iconKey = GlobalKey();
  final _tooltipController = OverlayTooltipController();
  ScrollPosition? _scrollPosition;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // ✅ Auto-close on scroll
    _scrollPosition?.removeListener(_closeTooltipOnScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_closeTooltipOnScroll);
  }
  
  void _closeTooltipOnScroll() {
    if (_tooltipController.isShowing) {
      _tooltipController.remove();
    }
  }
  
  @override
  void dispose() {
    _scrollPosition?.removeListener(_closeTooltipOnScroll);
    _tooltipController.remove();
    super.dispose();
  }
}
```

#### When to Use:
- **Most common use case** ✅
- Tooltips in scrollable lists
- Simple, effective solution needed
- Mobile-first UX

---

### Option 5: Debounced Position Recalculation ⭐⭐
**Complexity**: Medium | **Effectiveness**: Good | **Performance**: Good

#### Description:
Add delay before showing tooltip to ensure layout is stable.

#### Pros:
- ✅ Ensures stable position
- ✅ Handles rapid taps gracefully
- ✅ Prevents race conditions

#### Cons:
- ⚠️ Noticeable delay (100-200ms)
- ⚠️ May feel sluggish
- ⚠️ Doesn't solve scroll issues

#### Implementation:
```dart
class _BetSlipExplanationButtonState extends State<BetSlipExplanationButton> {
  final _iconKey = GlobalKey();
  final _tooltipController = OverlayTooltipController();
  Timer? _showTimer;
  
  void _showTooltip() {
    // Cancel previous timer
    _showTimer?.cancel();
    
    // ✅ Debounce: wait 100ms before showing
    _showTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      // Verify position is still valid
      final renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;
      
      // Show tooltip with fresh position
      _tooltipController.show(...);
    });
  }
  
  @override
  void dispose() {
    _showTimer?.cancel();
    _tooltipController.remove();
    super.dispose();
  }
}
```

#### When to Use:
- Rapid tap scenarios
- Need to prevent double-shows
- Acceptable to have small delay

---

### Option 6: CompositedTransformFollower ⭐⭐⭐⭐⭐ (ADVANCED)
**Complexity**: Very High | **Effectiveness**: Excellent | **Performance**: Excellent

#### Description:
Use Flutter's built-in `CompositedTransformFollower` for automatic position tracking.

#### Pros:
- ✅ Native Flutter solution
- ✅ Automatically follows target widget
- ✅ Best performance (GPU-accelerated)
- ✅ No manual position calculation
- ✅ Works perfectly with scroll

#### Cons:
- ⚠️ Requires complete refactor of tooltip system
- ⚠️ More complex initial setup
- ⚠️ Different API than current implementation

#### Implementation:
```dart
class _BetSlipExplanationButtonState extends State<BetSlipExplanationButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  
  void _showTooltip() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(-12, 12),
          child: TooltipContainer(
            width: 326,
            child: HintContentWidget(hintData: hintData),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        onPressed: _showTooltip,
        icon: Icon(Icons.info),
      ),
    );
  }
  
  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}
```

#### When to Use:
- Building new tooltip system from scratch
- Need perfect scroll tracking
- Performance is critical
- Long-term solution

---

## 🎯 Recommended Approach

### Quick Fix (Immediate):
**Option 4: Auto-Close on Scroll** + **Option 1: Unique Keys**

```dart
class _BetSlipExplanationButtonState extends State<BetSlipExplanationButton> {
  // ✅ Unique key per item
  late final GlobalKey _iconKey = GlobalKey(
    debugLabel: 'tooltip_${widget.bet?.id ?? widget.subBet?.id}'
  );
  
  late final _tooltipController = OverlayTooltipController();
  ScrollPosition? _scrollPosition;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // ✅ Auto-close on scroll
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_tooltipController.isShowing) {
      _tooltipController.remove();
    }
  }
  
  void _showTooltip() {
    final hintData = _toHintData();
    if (hintData == null) return;
    
    // Wait for next frame to ensure layout is stable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;
      
      _tooltipController.show(
        context: context,
        targetKey: _iconKey,
        autoPosition: true,
        // ... rest of config
      );
    });
  }
  
  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _tooltipController.remove();
    super.dispose();
  }
}
```

### Long-term (Future):
Consider migrating to **Option 6: CompositedTransformFollower** for best performance and UX.

---

## 📊 Comparison Matrix

| Solution | Complexity | Effectiveness | Performance | UX | Use Case |
|----------|-----------|---------------|-------------|-----|----------|
| **Option 1: Unique Key** | ⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Simple lists |
| **Option 2: Controller Per Item** | ⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | Multiple tooltips |
| **Option 3: Position Tracking** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | Persistent tooltips |
| **Option 4: Auto-Close** | ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **Most common** ✅ |
| **Option 5: Debounced** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | Rapid taps |
| **Option 6: CompositedTransform** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | New systems |

---

## 🔧 Testing Checklist

After implementing any solution, test these scenarios:

- [ ] Tap tooltip button while list is scrolling
- [ ] Rapidly tap different tooltip buttons
- [ ] Scroll list while tooltip is showing
- [ ] Tap tooltip near screen edges (top, bottom, left, right)
- [ ] Rotate device (if applicable)
- [ ] Fast scroll and immediate tap
- [ ] Tap, scroll away, scroll back
- [ ] Multiple tooltips in same list
- [ ] List rebuild while tooltip showing
- [ ] Navigate away and back

---

## 📚 Related Files

- `overlay_tooltip_controller.dart` - Main controller implementation
- `overlay_tooltip.dart` - Tooltip widget
- `bet_slip_card_match.dart` - Example usage in scrollable list
- `bet_explanation_ic_button.dart` - Another usage example

---

## 🐛 Known Issues

1. **Stale Position**: Fixed by post-frame callback + scroll listener
2. **Key Conflicts**: Fixed by unique keys per item
3. **Scroll Artifacts**: Fixed by auto-close on scroll
4. **Rapid Taps**: Fixed by debouncing or proper cleanup

---

## 💡 Best Practices

1. **Always use unique keys** for list items
2. **Clean up listeners** in dispose()
3. **Check mounted state** before showing tooltip
4. **Verify render box** before position calculation
5. **Use auto-close** for scrollable lists (most cases)
6. **Consider CompositedTransform** for complex scenarios

---

**Last Updated**: 2026-01-08
**Version**: 1.0
**Author**: Development Team
