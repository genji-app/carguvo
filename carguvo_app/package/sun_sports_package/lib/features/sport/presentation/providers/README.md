# Sport Navigation State Management

## 📝 Tổng Quan

Provider này giải quyết vấn đề **đồng bộ bottom navigation index** giữa tablet và mobile khi responsive.

## 🐛 Vấn Đề Trước Đây

### Khi Resize Tablet ↔ Mobile:
```
User ở Tablet → Tap item Casino (index 1) ✅
↓ Resize to Mobile
Mobile screen remount → Reset về index 3 (default) ❌
User bối rối: "Tại sao tab đổi?"
```

### Khi Có Nhiều Instance:
```
Tablet Screen: selectedIndex = 3 (hardcoded)
Mobile Screen: selectedIndex = 3 (hardcoded)
→ Không share state → Không sync khi responsive
```

## ✅ Giải Pháp

### 1. **Centralized State với Riverpod**

```dart
// sport_navigation_provider.dart
final sportNavigationProvider = StateNotifierProvider<SportNavigationNotifier, int>(
  (ref) => SportNavigationNotifier(),
);
```

**Lợi ích:**
- ✅ Single source of truth
- ✅ State persist khi resize
- ✅ Sync tự động giữa tất cả consumers

### 2. **Widget Lifecycle Sync**

```dart
// sport_tablet_bottom_navigation.dart
@override
void didUpdateWidget(SportTabletBottomNavigation oldWidget) {
  // Sync selectedIndex from parent when it changes
  if (widget.selectedIndex != oldWidget.selectedIndex && 
      widget.selectedIndex != _currentIndex) {
    setState(() {
      _currentIndex = widget.selectedIndex;
    });
  }
}
```

**Lợi ích:**
- ✅ Detect prop changes from parent
- ✅ Update local state accordingly
- ✅ Không conflict với user taps

### 3. **Resize Detection & Animation Sync**

```dart
// Track width changes
double _lastContainerWidth = 0.0;

// Detect resize and sync animation
if (_lastContainerWidth != 0.0 && _lastContainerWidth != containerWidth) {
  // Sync animation to new position based on new width
  _positionAnimation = Tween<double>(
    begin: currentPosition,
    end: currentPosition,
  ).animate(_animationController);
  _animationController.value = 1.0;
}
```

**Lợi ích:**
- ✅ Indicator không bị lệch khi resize
- ✅ Position được recalculate dựa trên width mới
- ✅ Animation sync ngay lập tức

## 🔄 Flow Hoạt Động

### Scenario 1: User Tap Item
```
1. User tap "Casino" (index 1) on Tablet
   └─> SportTabletBottomNavigation._handleItemTap(1)
       └─> widget.onItemSelected?.call(1)
           └─> ref.read(sportNavigationProvider.notifier).selectItem(1)
               └─> sportNavigationProvider.state = 1
                   └─> All consumers rebuild with new index ✅

2. Resize to Mobile
   └─> SportMobileScreen rebuilds
       └─> SportTabletBottomNavigation receives selectedIndex: 1 (from provider)
           └─> didUpdateWidget() detects change
               └─> _currentIndex = 1 ✅
                   └─> Indicator ở đúng vị trí "Casino" ✅
```

### Scenario 2: Resize Tablet → Mobile
```
1. Container width changes: 477px → 390px
   └─> _lastContainerWidth (477) != containerWidth (390)
       └─> Width change detected! 🔔
           └─> Calculate new position for current index
               └─> Update animation to new position
                   └─> Indicator syncs immediately ✅
```

### Scenario 3: Resize Mobile → Tablet
```
1. Container width changes: 390px → 477px
   └─> Same flow as Scenario 2
       └─> Indicator syncs to new position ✅
```

## 📊 State Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│         sportNavigationProvider (Riverpod)          │
│              selectedIndex: int (state)             │
└──────────────┬──────────────────────┬───────────────┘
               │                      │
               │ watch                │ watch
               │                      │
       ┌───────▼──────┐       ┌──────▼────────┐
       │ SportTablet  │       │ SportMobile   │
       │   Screen     │       │   Screen      │
       └───────┬──────┘       └──────┬────────┘
               │                     │
               │ pass index          │ pass index
               │                     │
       ┌───────▼──────────────────────▼────────┐
       │   SportTabletBottomNavigation         │
       │   - selectedIndex (prop from parent)  │
       │   - _currentIndex (local state)       │
       │   - didUpdateWidget() syncs prop→state│
       │   - onItemSelected() updates provider │
       └───────────────────────────────────────┘
```

## 🧪 Test Cases

### ✅ Case 1: Tap Item on Tablet
```dart
Tablet: tap "Casino" (index 1)
Expected: Provider state = 1, indicator at "Casino" ✅
```

### ✅ Case 2: Resize Tablet → Mobile (Same Index)
```dart
Tablet: index = 3 (Thể thao)
Resize to Mobile
Expected: Mobile index = 3, indicator at "Thể thao" ✅
```

### ✅ Case 3: Tap on Mobile, Resize to Tablet
```dart
Mobile: tap "Live" (index 2)
Resize to Tablet
Expected: Tablet index = 2, indicator at "Live" ✅
```

### ✅ Case 4: Multiple Rapid Resizes
```dart
Tablet → Mobile → Tablet → Mobile (rapid)
Expected: Indicator always at correct position, no lag ✅
```

### ✅ Case 5: Resize During Animation
```dart
Tablet: tap index 1 (animating from 3 → 1)
During animation: resize to Mobile
Expected: Animation completes on Mobile, indicator at index 1 ✅
```

## 💡 Best Practices

### 1. **Provider Scope**
```dart
// GOOD: Provider defined at feature level
final sportNavigationProvider = StateNotifierProvider<...>(...);

// BAD: Provider defined globally (if not needed globally)
// → Keep scope minimal for better performance
```

### 2. **Watch vs Read**
```dart
// GOOD: Use watch in build() to rebuild on changes
selectedIndex: ref.watch(sportNavigationProvider)

// GOOD: Use read in callbacks/events
ref.read(sportNavigationProvider.notifier).selectItem(index)

// BAD: Use watch in callbacks → unnecessary rebuilds
onTap: () => ref.watch(sportNavigationProvider) // ❌
```

### 3. **didUpdateWidget Pattern**
```dart
// GOOD: Check both conditions to avoid unnecessary updates
if (widget.selectedIndex != oldWidget.selectedIndex && 
    widget.selectedIndex != _currentIndex) {
  setState(() { _currentIndex = widget.selectedIndex; });
}

// BAD: Only check prop change → might trigger when already in sync
if (widget.selectedIndex != oldWidget.selectedIndex) { // ❌
  setState(() { _currentIndex = widget.selectedIndex; });
}
```

## 🚀 Performance Optimizations

### 1. **RepaintBoundary**
```dart
child: RepaintBoundary(
  child: SvgPicture.asset(...), // Cache SVG widget
)
```
→ Prevents unnecessary repaints

### 2. **Animation State Check**
```dart
final position = _animationController.isAnimating
    ? _positionAnimation.value  // Use animation during tap
    : currentPosition;           // Use calculated position during resize
```
→ Smooth animation for taps, instant sync for resize

### 3. **Width Change Detection**
```dart
if (_lastContainerWidth != 0.0 && _lastContainerWidth != containerWidth) {
  // Only update when width actually changes
}
```
→ Avoid unnecessary animation updates

## 📚 Related Files

- `sport_navigation_provider.dart` - State management
- `sport_tablet_bottom_navigation.dart` - Widget với sync logic
- `sport_mobile_screen.dart` - Mobile consumer
- `sport_tablet_screen.dart` - Tablet consumer

## 🔧 Troubleshooting

### Issue: Indicator bị lệch sau resize
**Solution:** Check `_lastContainerWidth` logic, ensure animation sync

### Issue: Index không persist khi resize
**Solution:** Verify provider is used in both Mobile & Tablet screens

### Issue: Animation bị jerky khi resize
**Solution:** Check `RepaintBoundary`, ensure `isAnimating` check

---

**Version:** 1.0  
**Last Updated:** 2025-11-15

