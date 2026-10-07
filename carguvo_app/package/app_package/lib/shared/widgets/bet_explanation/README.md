# Bet Explanation Tooltip Module

A shared, reusable tooltip widget system for displaying bet explanations across the application with consistent behavior, smart positioning, and flexible configuration.

## 📦 Components

### 1. `BetExplanationTooltip`
Main tooltip widget that handles tooltip display, positioning, and lifecycle.

### 2. `BetTooltipConfig`
Configuration class for customizing tooltip appearance and behavior.

### 3. Extension Methods
- `SingleBetDataToHintData` - Convert `SingleBetData` to `HintData`
- `BetSlipToHintData` - Convert `BetSlip` to `HintData`
- `ChildBetToHintData` - Convert `ChildBet` to `HintData`

## ✨ Features

- ✅ **Smart Positioning** - Automatically positions tooltip above or below trigger based on available space
- ✅ **GPU-Accelerated** - Uses `CompositedTransform` for smooth, performant positioning
- ✅ **Flexible Configuration** - Extensive configuration options via `BetTooltipConfig`
- ✅ **Consistent UX** - Same tooltip behavior across all betting widgets
- ✅ **Easy Integration** - Simple API with sensible defaults
- ✅ **Type-Safe** - Full type safety with extension methods for model conversion

## 🚀 Quick Start

### Basic Usage (Default Icon)

```dart
BetExplanationTooltip.icon(
  hintData: singleBet.toHintData(),
  iconColor: AppColorStyles.contentSecondary,
)
```

### Custom Trigger

```dart
BetExplanationTooltip(
  hintData: bet.toHintData(),
  triggerBuilder: (onTap) => TextButton(
    onPressed: onTap,
    child: Text('Show Info'),
  ),
)
```

### Custom Configuration

```dart
BetExplanationTooltip.icon(
  hintData: myHintData,
  config: BetTooltipConfig(
    tooltipWidth: 300,
    rootOverlay: true,
    arrowPosition: ArrowPosition.topLeft,
    useSmartPositioning: false,
  ),
)
```

## 📖 Configuration Options

### Dimensions
- `tooltipWidth` - Width of tooltip (default: 275.0)
- `tooltipMaxHeight` - Max height of tooltip (default: 440.0)
- `tooltipConstraints` - Custom constraints (overrides width/height)
- `tooltipPadding` - Internal padding (default: EdgeInsets.zero)

### Positioning
- `useSmartPositioning` - Enable adaptive positioning (default: true)
- `bottomThreshold` - Space needed before switching to top (default: 100.0)
- `targetAnchor` - Manual target anchor point
- `followerAnchor` - Manual follower anchor point
- `offset` - Manual offset from anchors

### Arrow
- `arrowPosition` - Position of arrow pointer
- `arrowOffset` - Offset from edge (default: 14.0)

### Behavior
- `autoCloseOnScroll` - Close on scroll (default: true)
- `dismissOnTapOutside` - Close on outside tap (default: true)
- `rootOverlay` - Use root vs nearest overlay (default: false)

### Trigger Styling
- `triggerColor` - Icon color
- `triggerSize` - Icon size (default: 18.0)
- `triggerPadding` - Padding around trigger (default: EdgeInsets.all(4.0))
- `triggerBorderRadius` - Border radius for ink well (default: 100.0)
- `triggerIcon` - Custom icon widget
- `triggerSplashColor` - Splash color for tap

## 📝 Usage Examples

### Example 1: In BetSlipCard

```dart
class BetSlipCard extends StatelessWidget {
  final BetSlip bet;
  
  Widget _buildMatchContent() {
    return BetSlipCardMatch.fromBetSlip(
      bet: bet,
      hintData: bet.toHintData(), // ✅ Convert to HintData
    );
  }
}
```

### Example 2: In BetExplanationButton

```dart
class BetExplanationButton extends StatelessWidget {
  final SingleBetData singleBet;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return BetExplanationTooltip.icon(
      hintData: singleBet.toHintData(), // ✅ Convert to HintData
      iconColor: color,
      config: const BetTooltipConfig(
        rootOverlay: true, // Use root overlay for parlay
      ),
    );
  }
}
```

### Example 3: Custom Trigger with Manual Positioning

```dart
BetExplanationTooltip(
  hintData: myHintData,
  config: BetTooltipConfig(
    useSmartPositioning: false,
    targetAnchor: Alignment.bottomCenter,
    followerAnchor: Alignment.topCenter,
    offset: const Offset(0, 8),
    arrowPosition: ArrowPosition.top,
  ),
  triggerBuilder: (onTap) => ElevatedButton(
    onPressed: onTap,
    child: Text('Explain Bet'),
  ),
)
```

## 🔄 Migration Guide

### Before (Manual Tooltip)

```dart
class _OldWidget extends StatefulWidget {
  @override
  State<_OldWidget> createState() => _OldWidgetState();
}

class _OldWidgetState extends State<_OldWidget> {
  final _tooltipController = OverlayTooltipController();
  
  @override
  void dispose() {
    _tooltipController.remove();
    super.dispose();
  }
  
  void _showTooltip() {
    final hintData = _createHintData();
    _tooltipController.show(
      context: context,
      targetKey: _iconKey,
      alignment: Alignment.bottomRight,
      offset: const Offset(-12, 12),
      builder: (onClose) => TooltipContainer(
        width: 326,
        padding: EdgeInsets.zero,
        arrowPosition: ArrowPosition.topRight,
        arrowOffset: 14.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 275),
          child: SingleChildScrollView(
            child: HintContentWidget(hintData: hintData),
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _iconKey,
      onPressed: _showTooltip,
      icon: Icon(Icons.info),
    );
  }
}
```

### After (Shared Widget)

```dart
class _NewWidget extends StatelessWidget {
  final HintData hintData;
  
  @override
  Widget build(BuildContext context) {
    return BetExplanationTooltip.icon(
      hintData: hintData,
    );
  }
}
```

**Result:** ~60 lines → ~10 lines! 🎉

## 🏗️ Architecture

```
BetExplanationTooltip
├── BetTooltipConfig (Configuration)
├── SmartTooltipPositioning (Positioning mixin)
├── CompositedTooltipController (GPU positioning)
└── HintContentWidget (Content rendering)
```

## 🎯 Design Decisions

### 1. Why Extension Methods?
- **Type Safety**: Compile-time checking of conversions
- **Discoverability**: IDE autocomplete shows `.toHintData()`
- **Maintainability**: Centralized conversion logic
- **Consistency**: Same conversion logic everywhere

### 2. Why Smart Positioning?
- **Better UX**: Tooltip always visible, never cut off
- **Automatic**: No manual positioning calculations needed
- **Flexible**: Can be disabled for manual control

### 3. Why Separate Config Class?
- **Clarity**: Clear separation of concerns
- **Reusability**: Share configs across widgets
- **Extensibility**: Easy to add new options
- **Type Safety**: Compile-time validation

## 📊 Performance

- **GPU-Accelerated**: Uses `CompositedTransform` for 60fps positioning
- **Lazy Loading**: Tooltip content only built when shown
- **Efficient**: No unnecessary rebuilds
- **Memory**: Automatic cleanup on dispose

## 🧪 Testing

```dart
testWidgets('shows tooltip on tap', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BetExplanationTooltip.icon(
          hintData: testHintData,
        ),
      ),
    ),
  );
  
  // Tap trigger
  await tester.tap(find.byType(InkWell));
  await tester.pumpAndSettle();
  
  // Verify tooltip shown
  expect(find.byType(HintContentWidget), findsOneWidget);
});
```

## 📚 Related Documentation

- [Tooltip System Overview](../overlay_tooltip/README.md)
- [HintData Model](../../bet_details/hint_bubble/README.md)
- [Smart Positioning Mixin](../overlay_tooltip/smart_tooltip_positioning.dart)

## 🤝 Contributing

When adding new bet models, remember to:
1. Create extension method in `bet_data_extensions.dart`
2. Add tests for the conversion
3. Update this README with examples

## 📄 License

Internal use only - Sun Sports betting application.
