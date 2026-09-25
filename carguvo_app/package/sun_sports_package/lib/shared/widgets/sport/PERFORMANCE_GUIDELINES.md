# Performance Guidelines for Sport Widgets

> **CRITICAL:** All widgets in this folder MUST follow these guidelines.

---

## Widget Base Class Rules

```
┌─────────────────────────────────────────────────────────────────┐
│                    WIDGET SELECTION GUIDE                        │
├─────────────────────────────────────────────────────────────────┤
│  Cần Riverpod ref?                                              │
│       │                                                          │
│       ├── NO ──→ Cần local state?                               │
│       │              ├── NO ──→ StatelessWidget                 │
│       │              └── YES ─→ StatefulWidget                  │
│       │                                                          │
│       └── YES ─→ Cần local state hoặc animation?                │
│                      ├── NO ──→ ConsumerWidget                  │
│                      └── YES ─→ ConsumerStatefulWidget          │
│                                                                  │
│  ❌ KHÔNG dùng: HookWidget, HookConsumerWidget                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Access Patterns

### ❌ KHÔNG LÀM (Anti-patterns)

```dart
// ❌ Anti-pattern 1: watch toàn bộ state trong build
class BadWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔴 Rebuild MỌI LÚC state thay đổi (bất kỳ field nào)
    final state = ref.watch(leagueProvider);
    return Text(state.leagues.first.name);
  }
}

// ❌ Anti-pattern 2: Multiple watches
class BadWidget2 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔴 3 subscriptions = 3x rebuild chances
    final leagues = ref.watch(leagueProvider);
    final odds = ref.watch(oddsProvider);
    final events = ref.watch(eventProvider);
    // ...
  }
}

// ❌ Anti-pattern 3: Hook trong widget
class BadWidget3 extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔴 Hook rebuild toàn bộ widget
    final controller = useAnimationController(duration: Duration(ms: 300));
    final prevValue = usePrevious(value);
    // ...
  }
}
```

### ✅ NÊN LÀM (Best practices)

```dart
// ✅ Pattern 1: Select specific field
class GoodWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🟢 Chỉ rebuild khi leagueName thay đổi
    final leagueName = ref.watch(
      leagueProvider.select((s) => s.leagues.first.name),
    );
    return Text(leagueName);
  }
}

// ✅ Pattern 2: Consumer cho partial rebuild
class GoodWidget2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Static content - không bao giờ rebuild
        const Text('Header'),

        // 🟢 Chỉ phần này rebuild
        Consumer(
          builder: (_, ref, child) {
            final score = ref.watch(
              leagueProvider.select((s) => s.getScore(eventId)),
            );
            return Text('Score: $score');
          },
          // Static child được reuse
          child: const Icon(Icons.sports),
        ),
      ],
    );
  }
}

// ✅ Pattern 3: Multiple fields với Record
class GoodWidget3 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🟢 Select multiple fields trong 1 subscription
    final data = ref.watch(
      leagueProvider.select((s) => (
        homeScore: s.getHomeScore(eventId),
        awayScore: s.getAwayScore(eventId),
        isLive: s.isLive(eventId),
      )),
    );
    return ScoreDisplay(
      home: data.homeScore,
      away: data.awayScore,
      isLive: data.isLive,
    );
  }
}

// ✅ Pattern 4: Animation với StatefulWidget
class GoodWidget4 extends ConsumerStatefulWidget {
  @override
  ConsumerState<GoodWidget4> createState() => _GoodWidget4State();
}

class _GoodWidget4State extends ConsumerState<GoodWidget4>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;
  double? _previousValue;  // Thay cho usePrevious

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = ref.watch(
      oddsProvider.select((s) => s.odds),
    );

    // Detect change
    if (_previousValue != null && currentValue != _previousValue) {
      _controller.forward(from: 0);
    }
    _previousValue = currentValue;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        color: Colors.green.withOpacity(1 - _controller.value),
        child: Text(currentValue.toString()),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## Performance Checklist

Trước khi submit PR, verify:

- [ ] Không có `HookWidget` hoặc `HookConsumerWidget`
- [ ] Không có `ref.watch(provider)` không có `.select()`
- [ ] Không có `useAnimationController`, `usePrevious`, etc.
- [ ] Mỗi `Consumer` widget có `child` parameter cho static content
- [ ] Animation dùng `SingleTickerProviderStateMixin`
- [ ] Previous value tracking dùng instance variable

---

*Document created: 2025-01-07*
