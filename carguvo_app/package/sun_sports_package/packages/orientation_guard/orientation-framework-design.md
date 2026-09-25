# Tài liệu thiết kế chi tiết — Orientation Framework Refactor

> **Áp dụng từ**: v2.0.0 (refactor bắt đầu sau khi tài liệu này được review và approve)
> **Ngày tạo**: 2026-05-08
> **Trạng thái**: Draft — đang review

---

## 1. Bối cảnh

Ứng dụng Flutter hiện cần quản lý orientation theo nhiều tầng khác nhau: mặc định toàn app, override theo màn hình đặc biệt, và override động theo metadata của game hoặc provider. Package hiện tại đã có nền runtime khá tốt với `OrientationGuard`, `OrientationController`, `OrientationScope`, cơ chế apply/restore lifecycle, và custom mismatch overlay ở `GameScreen`.

Thiết kế hiện tại đã chứng minh được một số năng lực cốt lõi: có thể apply orientation trên native, guard viewport trên web, tự restore trạng thái trước khi vào màn hình, và cho phép business layer resolve rule riêng thông qua `OrientationPolicyResolver<T>`. Tuy nhiên, resolver mặc định hiện vẫn chỉ phân loại mobile và non-mobile, rồi trả về portrait cho mobile và `both` cho tablet/desktop, nên chưa đủ để mô tả app-level default, screen-level override, large tablet, exact orientation như `landscapeRight`, hay tách `showPrompt` khỏi `blockContent`.

---

## 2. Vấn đề hiện tại

### 2.1 Domain model quá đơn giản

`OrientationPolicy` hiện đang gánh quá nhiều trách nhiệm trong một object: target orientation, block behavior, debug label, và UI behavior. Mô hình này phù hợp với use case cơ bản, nhưng không còn đủ expressive khi orientation rule cần thay đổi theo scope app, scope screen, experience class, và content runtime như từng game/provider.

Thiết kế `portrait / landscape / both` cũng không còn đủ cho các trường hợp orientation cụ thể theo platform. Flutter `DeviceOrientation` hỗ trợ bốn giá trị riêng biệt là `portraitUp`, `portraitDown`, `landscapeLeft`, và `landscapeRight`, và `SystemChrome.setPreferredOrientations` nhận trực tiếp `List<DeviceOrientation>`, nên các use case như game yêu cầu đúng `landscapeRight` trên tablet không thể được mô tả đẹp bằng model cũ.

### 2.2 Logic mặc định gắn chặt vào resolver cũ

`OrientationAdaptiveResolver` hiện hardcode logic "mobile dưới 600 là portrait, tablet/desktop là both". Trong khi đó, nhu cầu thực tế là:
- Package nên có package default an toàn.
- App nên có app default intent riêng.
- Screen đặc biệt như game mới override tiếp.

Tức là mặc định không nên bị buộc cứng bởi một resolver duy nhất.

### 2.3 Chưa tách rõ orientation requirement và enforcement behavior

`OrientationGuard` hiện đã có `blockOnMismatch`, `mismatchBuilder`, và callback mismatch, nhưng khái niệm "screen muốn orientation nào" và "nếu mismatch thì phản ứng ra sao" vẫn chưa được mô hình hóa thành hai lớp rõ ràng. Điều này quan trọng vì Home/app shell có thể prompt mà không block, trong khi game có thể prompt và block tùy metadata.

### 2.4 Desktop và large-screen behavior chưa có semantic ổn định

README hiện mô tả desktop web như một case guard với resize overlay, nhưng product direction mới đã chốt rằng desktop không nên dùng rotate prompt như mobile/tablet. Đồng thời, large tablet được thêm như một experience class riêng nhưng hiện tại tạm thời kế thừa desktop-like behavior.

---

## 3. Mục tiêu thiết kế

- Adaptive là package default; orientation restriction chỉ xuất hiện khi app hoặc screen khai báo rõ ràng.
- App có thể đặt `app default intent` để toàn app shell dùng chung behavior.
- Screen đặc biệt như Game có thể override app default theo experience class và runtime metadata.
- Model public cần support `mobile`, `tablet`, `largeTablet`, và `desktop`, trong đó `largeTablet` là class riêng nhưng hiện tại dùng desktop-like defaults.
- Orientation field cần support cả adaptive, portrait/landscape family, và exact direction như `landscapeRight`, bằng `List<DeviceOrientation>`.
- Enforcement phải tách thành `showPrompt` và `blockContent`.
- Hierarchical model phải support partial override theo field và precedence rõ ràng.
- Engine runtime hiện tại nên được giữ lại tối đa để giảm rủi ro refactor.

---

## 4. Breakpoints và Experience Classification

### 4.1 Mapping từ M3 Window Size Classes sang OrientationExperience

Package sử dụng **width-based breakpoints** dựa trên Material Design 3 Window Size Classes (AndroidX Window 1.5), bao gồm 5 class từ compact đến extra-large.

| M3 Window Size Class | Width range | Device đại diện | OrientationExperience |
|---|---|---|---|
| Compact | `width < 600dp` | Phone portrait (99.96%) | `mobile` |
| Medium | `600dp ≤ width < 840dp` | Tablet portrait, foldable unfolded portrait | `tablet` |
| Expanded | `840dp ≤ width < 1200dp` | Tablet landscape, large unfolded inner display | `tablet` |
| Large | `1200dp ≤ width < 1600dp` | Large tablet, external display nhỏ | `largeTablet` |
| Extra-large | `width ≥ 1600dp` | Desktop, ultra-wide display | `desktop` |

**Lý do gộp Medium và Expanded vào `tablet`**: cả hai class đều đại diện cho thiết bị có form factor tablet và behavior orientation hợp lý như nhau. Tách ra thành `tablet` và `largeTablet` ở `1200dp` phản ánh đúng ranh giới large-screen behavior của Material 3.

**Breakpoints cụ thể cần chốt trong classifier:**

```
mobile:     shortestSide < 600dp (hoặc width < 600dp)
tablet:     600dp ≤ width < 1200dp
largeTablet: 1200dp ≤ width < 1600dp
desktop:    width ≥ 1600dp
```

> **Lưu ý**: Package classifier dùng width, không dùng shortestSide như `OrientationAdaptiveResolver` cũ. Đây là sự thay đổi có chủ đích để phù hợp hơn với M3 guidance và behavior thực tế trên web/desktop.

### 4.2 Breakpoints tạm thời vs final

Breakpoints trên là **initial defaults** của package. App developer có thể inject custom `OrientationExperienceResolver` để override nếu cần breakpoints riêng. Package không hardcode breakpoints vào widget hay guard.

---

## 5. Giải pháp đề xuất

### 5.1 Chuyển từ policy-centric sang intent-centric

Thay vì coi `OrientationPolicy` là core domain object, thiết kế mới dùng `OrientationIntent` làm mô hình khai báo mong muốn ở các scope khác nhau. Intent này được định nghĩa theo kiểu `base + overrides` cho từng experience class, giúp phản ánh đúng triết lý adaptive-by-default và defaults-and-overrides.

Một `OrientationIntent` sẽ chứa các `OrientationRule` partial để ghi đè từng field khi cần. Điều này cho phép app hoặc screen chỉ khai báo phần khác biệt so với default, thay vì phải replace toàn bộ object rule mỗi lần.

### 5.2 Dùng `List<DeviceOrientation>` cho field orientation

Thay vì giữ enum `adaptive / portrait / landscape`, field orientation trong `OrientationRule` sẽ dùng trực tiếp `List<DeviceOrientation>`. Cách này cho phép model biểu diễn đồng thời ba mức semantics:

- `[]` = adaptive/unrestricted (không giới hạn orientation).
- nhiều phần tử cùng family = portrait hoặc landscape family.
- một phần tử cụ thể = exact requirement như `landscapeRight`.

Danh sách này được coi là **allowed orientation set**, không phải priority list. Thứ tự phần tử không mang ý nghĩa; duplicate nên được normalize trước khi compare.

### 5.3 Tách orientation result và enforcement result

Design mới tách kết quả cuối thành hai lớp:

- `OrientationDecision`: experience hiện tại, allowed orientations sau khi merge, và trạng thái mismatch.
- `OrientationEnforcementDecision`: `showPrompt`, `blockContent`, và `promptKind`.

### 5.4 Thêm experience class `largeTablet`

Experience class public chuẩn hóa thành bốn mức: `mobile`, `tablet`, `largeTablet`, `desktop`. `largeTablet` tương ứng với M3 Large class (1200–1600dp), ở giai đoạn hiện tại kế thừa desktop-like defaults (adaptive/no prompt/no block), nhưng có thể thay đổi độc lập về sau.

---

## 6. Domain model đề xuất

### 6.1 OrientationExperience

```dart
enum OrientationExperience {
  mobile,
  tablet,
  largeTablet,
  desktop,
}
```

### 6.2 OrientationRule

```dart
class OrientationRule {
  final List<DeviceOrientation>? orientations;
  final bool? showPrompt;
  final bool? blockContent;

  const OrientationRule({
    this.orientations,
    this.showPrompt,
    this.blockContent,
  });
}
```

**Semantics của field `orientations`:**

| Giá trị | Ý nghĩa |
|---|---|
| `null` | Không override; kế thừa từ tầng trên |
| `[]` | Override thành adaptive/unrestricted |
| `[portraitUp, portraitDown]` | Portrait family |
| `[landscapeLeft, landscapeRight]` | Landscape family |
| `[landscapeRight]` | Exact orientation requirement |

### 6.3 OrientationIntent

```dart
class OrientationIntent {
  final OrientationRule? base;
  final OrientationRule? mobile;
  final OrientationRule? tablet;
  final OrientationRule? largeTablet;
  final OrientationRule? desktop;

  const OrientationIntent({
    this.base,
    this.mobile,
    this.tablet,
    this.largeTablet,
    this.desktop,
  });
}
```

Mỗi experience override là một `OrientationRule?`. Khi `null`, tầng đó kế thừa `base`, rồi kế thừa package default.

### 6.4 OrientationDecision

```dart
class OrientationDecision {
  final OrientationExperience experience;
  final List<DeviceOrientation> allowedOrientations;
  final bool isMismatch;

  const OrientationDecision({
    required this.experience,
    required this.allowedOrientations,
    required this.isMismatch,
  });
}
```

### 6.5 OrientationEnforcementDecision

```dart
enum OrientationPromptKind {
  none,
  rotate,
  resize,
  custom,
}

class OrientationEnforcementDecision {
  final bool showPrompt;
  final bool blockContent;
  final OrientationPromptKind promptKind;

  const OrientationEnforcementDecision({
    required this.showPrompt,
    required this.blockContent,
    required this.promptKind,
  });
}
```

---

## 7. Rules và Precedence

### 7.1 Package default

Tất cả field của package default:

```
orientations = []   → adaptive/unrestricted
showPrompt   = false
blockContent = false
```

Đây là trạng thái an toàn nhất: không giới hạn, không prompt, không block.

### 7.2 Thứ tự precedence (từ thấp đến cao)

```
1. Package default
2. App default intent (base)
3. App default intent (experience override)
4. Screen intent (base)
5. Screen intent (experience override)
6. Runtime/content override
```

Rule cụ thể hơn thắng rule chung hơn. Merge diễn ra theo **từng field**, không replace cả object.

### 7.3 Luật merge chi tiết

- **General to specific**: app base -> app experience -> screen base -> screen experience -> runtime.
- **Field-level merge**: chỉ field nào được khai báo (non-null) mới override field cùng tên ở tầng thấp hơn.
- **`null` = kế thừa**: trường `null` được ignore trong bước merge, giá trị tầng trước vẫn giữ nguyên.
- **`[]` = override sang adaptive**: trường `orientations = []` có nghĩa là "override về adaptive", không phải "kế thừa".
- **`largeTablet` fallback**: khi `largeTablet` rule là `null` ở mọi tầng, merge engine fall back về `desktop` rule (hoặc `base` rule nếu `desktop` cũng null), không phải package default trực tiếp.

### 7.4 Ví dụ merge cụ thể

**Ví dụ 1: App default intent ghi đè package default cho mobile**

```
Package default:  orientations=[], showPrompt=false, blockContent=false
App base:         orientations=null, showPrompt=null, blockContent=null
App mobile:       orientations=[portraitUp, portraitDown], showPrompt=true, blockContent=null

→ Kết quả cho mobile:
  orientations = [portraitUp, portraitDown]  ← từ app mobile
  showPrompt   = true                        ← từ app mobile
  blockContent = false                       ← từ package default (app không override)
```

**Ví dụ 2: Screen intent chỉ override `blockContent` cho game**

```
Đã merge đến app level: orientations=[portraitUp, portraitDown], showPrompt=true, blockContent=false
Screen base:            orientations=null, showPrompt=null, blockContent=null
Screen mobile:          orientations=null, showPrompt=null, blockContent=true

→ Kết quả cho mobile:
  orientations = [portraitUp, portraitDown]  ← giữ từ app
  showPrompt   = true                        ← giữ từ app
  blockContent = true                        ← override bởi screen mobile
```

**Ví dụ 3: Runtime game override exact orientation cho tablet**

```
Đã merge đến screen level: orientations=[landscapeLeft, landscapeRight], showPrompt=true, blockContent=true
Runtime game tablet:        orientations=[landscapeRight], showPrompt=null, blockContent=null

→ Kết quả cho tablet:
  orientations = [landscapeRight]            ← override bởi runtime game
  showPrompt   = true                        ← giữ từ screen
  blockContent = true                        ← giữ từ screen
```

**Ví dụ 4: largeTablet không có rule riêng, fall back về desktop**

```
App desktop: orientations=[], showPrompt=false, blockContent=false
App largeTablet: null (không khai báo)

→ Kết quả cho largeTablet:
  Lấy desktop rule → orientations=[], showPrompt=false, blockContent=false
```

**Ví dụ 5: `base` rule áp cho mọi experience class không có override**

```
App base:    orientations=[portraitUp, portraitDown], showPrompt=true, blockContent=false
App mobile:  null
App tablet:  null

→ Kết quả cho mobile:  orientations=[portraitUp, portraitDown], showPrompt=true, blockContent=false
→ Kết quả cho tablet:  orientations=[portraitUp, portraitDown], showPrompt=true, blockContent=false
→ Kết quả cho largeTablet: fall back về desktop rule → nếu desktop null → base rule
```

---

## 8. promptKind Derivation

`OrientationPromptKind` được derive tự động từ experience class và orientation decision, không phải field do user cấu hình. Logic derivation mặc định:

| Experience | isMismatch | promptKind |
|---|---|---|
| `mobile` | true | `rotate` |
| `tablet` | true | `rotate` |
| `largeTablet` | true | `resize` |
| `desktop` | true | `resize` |
| bất kỳ | false | `none` |

**Ghi chú:**
- `rotate`: dùng khi thiết bị di động có thể xoay vật lý, hiện prompt dạng "xoay màn hình".
- `resize`: dùng khi window có thể resize nhưng không xoay vật lý, hiện prompt dạng "resize cửa sổ".
- Nếu `showPrompt = false` từ merged rule, engine sẽ ignore `promptKind` và không hiện prompt dù có mismatch.
- `custom` là giá trị đặc biệt: khi được set từ `mismatchBuilder` override, UI renderer biết cần render custom widget thay vì default view.

---

## 9. Decision matrix mặc định

### 9.1 App shell default

| Experience | Orientations | showPrompt | blockContent | promptKind |
|---|---|---|---|---|
| Mobile | `[portraitUp, portraitDown]` | true | false | rotate |
| Tablet | `[portraitUp, portraitDown]` | true | false | rotate |
| Large tablet | `[]` | false | false | none |
| Desktop | `[]` | false | false | none |

### 9.2 Game screen override

| Experience | Orientations | showPrompt | blockContent | promptKind | Ghi chú |
|---|---|---|---|---|---|
| Mobile | từ game metadata | true | configurable | rotate | Landscape family hoặc exact |
| Tablet | từ game metadata | true | configurable | rotate | Có thể `[landscapeRight]` |
| Large tablet | kế thừa desktop | false | false | none | Hiện behave như desktop |
| Desktop | `[]` | false | false | none | Adaptive |

---

## 10. API draft đề xuất

### Root setup

```dart
GlobalOrientationOrchestrator(
  controller: orientationController,
  appIntent: OrientationIntent(
    base: OrientationRule(orientations: [], showPrompt: false),
    mobile: OrientationRule(
      orientations: [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      showPrompt: true,
    ),
    tablet: OrientationRule(
      orientations: [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      showPrompt: true,
    ),
  ),
  child: MaterialApp(...),
)
```

### Screen setup (game)

```dart
OrientationGuard(
  intent: OrientationIntent(
    mobile: OrientationRule(
      orientations: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      showPrompt: true,
      blockContent: true,
    ),
    tablet: OrientationRule(
      orientations: [DeviceOrientation.landscapeRight],
      showPrompt: true,
      blockContent: true,
    ),
  ),
  child: GameScreen(...),
)
```

### Resolver setup

```dart
abstract class OrientationIntentResolver<T> {
  const OrientationIntentResolver();

  OrientationIntent resolve(BuildContext context, T model);
}
```

### Experience classifier

```dart
abstract class OrientationExperienceResolver {
  const OrientationExperienceResolver();

  OrientationExperience resolve(BuildContext context);
}
```

---

## 11. Mapping từ package cũ sang mới

| Thành phần cũ | Trạng thái | Thành phần mới |
|---|---|---|
| `OrientationPolicy` | Deprecate dần | `OrientationIntent` + `OrientationRule` + decision models |
| `OrientationPolicyResolver<T>` | Evolve | `OrientationIntentResolver<T>` |
| `OrientationAdaptiveResolver` | Tách vai trò | `OrientationExperienceResolver` + app default intent config |
| `OrientationGuard` | Giữ engine, đổi input | nhận `intent` thay vì `policy` |
| `OrientationMismatchView` | Giữ như default renderer | nhận `OrientationEnforcementDecision` |
| `GlobalOrientationOrchestrator` | Đổi input | nhận `appIntent` thay vì policy cũ |
| `GameScreen(gamePolicy)` | Refactor | `GameScreen(gameIntent)` hoặc runtime override |
| `blockOnMismatch` (param trực tiếp của Guard) | Deprecate | field trong `OrientationRule.blockContent` |

---

## 12. Kế hoạch triển khai chi tiết

### Giai đoạn 1: Thêm model mới (không phá API cũ)

1. Thêm `OrientationExperience`, `OrientationRule`, `OrientationIntent`, `OrientationDecision`, `OrientationEnforcementDecision`.
2. Viết utility normalize cho `List<DeviceOrientation>`.
3. Viết merge engine field-level theo thứ tự precedence.
4. Viết default `OrientationExperienceResolver` với breakpoints M3 đã chốt.
5. Viết tests cho merge engine và experience classifier.

**Deliverable**: Model mới tồn tại song song với API cũ, chưa được expose ra public.

### Giai đoạn 2: Bridge với engine cũ

1. Viết adapter từ `OrientationIntent` sang apply layer hiện tại.
2. Giữ nguyên `OrientationGuard`, controller, scope.
3. Cho phép root app inject `appIntent` mới dưới dạng preview API, nhưng vẫn fallback về policy cũ nếu cần.
4. Giữ `OrientationMismatchView` nhưng bổ sung khả năng nhận enforcement decision.

**Deliverable**: Runtime behavior ổn định, backward-compatible.

### Giai đoạn 3: Refactor resolver và root orchestration

1. Tạo `OrientationIntentResolver<T>` thay cho `OrientationPolicyResolver<T>`.
2. Tách `OrientationAdaptiveResolver` cũ thành experience classifier và app default intent.
3. Cập nhật `GlobalOrientationOrchestrator` để nhận `appIntent`.
4. Cập nhật docs/examples cho app shell default mới.

**Deliverable**: Root API mới đã public, API cũ marked deprecated.

### Giai đoạn 4: Refactor Game flow

1. Đổi `GameScreen` từ `gamePolicy` sang `gameIntent` hoặc runtime override.
2. Support exact tablet rule như `[DeviceOrientation.landscapeRight]`.
3. Chuyển game mismatch flow sang decision-driven prompt/block.
4. Giữ debounce 1s mismatch logic vì đang giảm flicker khi xoay.

**Deliverable**: Game flow dùng API mới, `promptKind` derivation chạy đúng.

### Giai đoạn 5: Cleanup và deprecation

1. Deprecate `OrientationPolicy` public API cũ.
2. Viết migration guide từ v1 sang v2.
3. Cập nhật README sang narrative mới.
4. Đổi examples sang API mới hoàn toàn.

**Deliverable**: Package v2.0.0 release candidate.

---

## 13. Technical Rules

### Rule 1: `null` khác `[]`

- `null` = không override, kế thừa từ tầng cao hơn.
- `[]` = explicit override về adaptive/unrestricted.

Đây là rule quan trọng nhất cho partial override model.

### Rule 2: `orientations` là allowed set

- Không coi phần tử đầu tiên là preferred orientation.
- Thứ tự không có nghĩa.
- Normalize (sort + dedup) trước khi compare và store.

### Rule 3: Desktop và large tablet mặc định không prompt

Desktop và `largeTablet` đều dùng desktop-like defaults: adaptive, no prompt, no block. Behavior này sẽ chỉ thay đổi khi có product requirement rõ ràng.

### Rule 4: Enforcement tách khỏi orientation

Orientation decision không tự quyết định block. `showPrompt` và `blockContent` chỉ đến từ merged rule, không được suy ngược từ allowed orientations.

### Rule 5: Mismatch là fact, không phải reaction

Mismatch chỉ là trạng thái boolean: current orientation không nằm trong allowed set. Phản ứng (prompt, block, custom UI) là layer riêng phía trên.

### Rule 6: `promptKind` là derived, không phải configured

`promptKind` được derive từ experience class và mismatch state, không phải field do user set trực tiếp trong rule. User chỉ set `showPrompt` và `blockContent`.

### Rule 7: `largeTablet` fall back về `desktop`

Khi merge engine không tìm thấy rule nào cho `largeTablet` ở mọi tầng, nó tự động fall back về `desktop` rule, không phải package default trực tiếp. Đây là cơ chế giúp `largeTablet` kế thừa desktop-like behavior mà không cần copy rule.

---

## 14. Test Strategy

### 14.1 Unit test: merge engine

| Test | Input | Expected |
|---|---|---|
| Package default khi không có intent | không có intent | adaptive, no prompt, no block |
| App intent override package default | app mobile: portrait | mobile = portrait |
| Screen intent override app intent | screen mobile: blockContent=true | mobile blockContent=true |
| Experience override chỉ ghi đè field được khai báo | screen tablet: showPrompt=false | chỉ showPrompt đổi, các field khác giữ |
| Runtime override thắng tất cả | runtime: `[landscapeRight]` | orientations = `[landscapeRight]` |
| `null` field kế thừa | screen mobile.blockContent = null | giữ giá trị từ app |
| `[]` override sang adaptive | screen mobile.orientations = `[]` | orientations = `[]`, không phải kế thừa |
| `largeTablet` null fall back về desktop | desktop: adaptive, largeTablet: null | largeTablet = adaptive |

### 14.2 Unit test: orientation semantics

| Test | Input | Expected |
|---|---|---|
| `[]` là adaptive | `[]` | isMismatch = false với mọi orientation hiện tại |
| Portrait family | `[portraitUp, portraitDown]` + current portrait | isMismatch = false |
| Portrait family | `[portraitUp, portraitDown]` + current landscape | isMismatch = true |
| Landscape family | `[landscapeLeft, landscapeRight]` + current landscape | isMismatch = false |
| Exact landscapeRight | `[landscapeRight]` + current landscapeRight | isMismatch = false |
| Exact landscapeRight | `[landscapeRight]` + current landscapeLeft | isMismatch = true |
| Normalize duplicates | `[portraitUp, portraitUp]` | normalize về `[portraitUp]` |
| Order-insensitive equality | `[portraitUp, portraitDown]` vs `[portraitDown, portraitUp]` | equal |

### 14.3 Unit test: experience classification

| Viewport width | Expected OrientationExperience |
|---|---|
| 375dp | mobile |
| 599dp | mobile |
| 600dp | tablet |
| 839dp | tablet |
| 840dp | tablet |
| 1199dp | tablet |
| 1200dp | largeTablet |
| 1599dp | largeTablet |
| 1600dp | desktop |
| 1920dp | desktop |

### 14.4 Unit test: promptKind derivation

| Experience | isMismatch | showPrompt | Expected promptKind |
|---|---|---|---|
| mobile | true | true | rotate |
| tablet | true | true | rotate |
| largeTablet | true | true | resize |
| desktop | true | true | resize |
| mobile | false | true | none |
| mobile | true | false | none (không show dù mismatch) |

### 14.5 Widget test: app shell behavior

| ID | Experience | Current orientation | Expected mismatch | Expected prompt |
|---|---|---|---|---|
| WS-01 | Mobile | portrait | No | No |
| WS-02 | Mobile | landscape | Yes | Yes |
| WS-03 | Tablet | portrait | No | No |
| WS-04 | Tablet | landscape | Yes | Yes |
| WS-05 | Large tablet | portrait | No | No |
| WS-06 | Large tablet | landscape | No | No |
| WS-07 | Desktop | any | No | No |

### 14.6 Widget test: game screen behavior

| ID | Experience | Allowed orientations | Current orientation | mismatch | prompt | block |
|---|---|---|---|---|---|---|
| WG-01 | Mobile | `[landscapeLeft, landscapeRight]` | portrait | Yes | Yes | Configurable |
| WG-02 | Mobile | `[landscapeLeft, landscapeRight]` | landscape | No | No | No |
| WG-03 | Tablet | `[landscapeRight]` | landscapeRight | No | No | No |
| WG-04 | Tablet | `[landscapeRight]` | landscapeLeft | Yes | Yes | Configurable |
| WG-05 | Tablet | `[landscapeRight]` | portrait | Yes | Yes | Configurable |
| WG-06 | Large tablet | `[]` | any | No | No | No |
| WG-07 | Desktop | `[]` | any | No | No | No |
| WG-08 | Mobile | `[landscapeLeft, landscapeRight]` + blockContent=false | portrait | Yes | Yes | No |
| WG-09 | Mobile | `[landscapeLeft, landscapeRight]` + blockContent=true | portrait | Yes | Yes | Yes |

### 14.7 Regression test cho engine cũ

| ID | Test | Expected |
|---|---|---|
| RE-01 | Capture previous policy khi vào guard | previous state được save đúng |
| RE-02 | Restore state khi dispose guard | state trước khi vào màn hình được restore |
| RE-03 | Nested guard override behavior | child guard thắng parent guard |
| RE-04 | Mismatch callback không spam khi transition | callback chỉ fire khi state thực sự thay đổi |
| RE-05 | GameScreen debounce 1s vẫn hoạt động | mismatch UI chỉ hiện sau 1s stable |
| RE-06 | Restore khi pop từ game về home | home orientation được restore đúng |
| RE-07 | Orientation thay đổi trong lúc loading game | debounce chặn mismatch UI khi đang trong transition state |
| RE-08 | Runtime override thắng screen intent | exact `[landscapeRight]` thắng screen landscape family |

---

## 15. Rủi ro và biện pháp giảm thiểu

| Rủi ro | Mức độ | Biện pháp |
|---|---|---|
| Refactor domain model làm vỡ API cũ | Cao | Additive trước, deprecate sau; giữ adapter từ `OrientationPolicy` cũ |
| Nhầm lẫn giữa `null` và `[]` | Trung bình | Docs rõ ràng + unit test riêng cho merge semantics |
| Over-coupling widget layer với resolution logic | Trung bình | Guard chỉ là engine; resolve intent/decision trước khi vào guard |
| `largeTablet` bị hiểu nhầm là `desktop` | Thấp | Docs ghi rõ: `largeTablet` là class riêng, hiện tại chỉ kế thừa desktop-like defaults |
| Breakpoints mới (width-based) làm lệch behavior so với cũ (shortestSide) | Trung bình | Test so sánh behavior trước/sau trên các thiết bị thực tế |
| `promptKind` bị misconfigure thủ công | Thấp | Không cho user set trực tiếp; chỉ có thể override qua `custom` builder |

---

## 16. Khuyến nghị triển khai

Không rewrite package từ đầu. Nên giữ `OrientationGuard`, controller, scope, và phần lớn runtime engine hiện tại; tập trung thay domain model, resolution flow, và public API narrative.

Thứ tự triển khai hiệu quả nhất:

1. Thêm model mới và merge engine (không phá cũ).
2. Viết test đầy đủ cho merge engine.
3. Thêm experience classifier với breakpoints M3 mới.
4. Bridge với engine cũ.
5. Refactor app root sang `appIntent`.
6. Refactor `GameScreen` sang runtime game override.
7. Cập nhật examples và README.
8. Deprecate model cũ sau khi test matrix xanh.

