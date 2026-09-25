# Hệ thống Category & Lobby

## Tổng quan kiến trúc

Game screen có hai mode rõ ràng, được quản lý bởi `GameViewMode`:

| Mode | Khi nào | Hiển thị |
|------|---------|----------|
| `lobby` | Không có query, không có category | `GameLobbyView` (SDUI sections) |
| `filter` | Có query hoặc đang chọn category | `GameGridView` (kết quả lọc) |

Mode được tính tự động qua `GameFilterStateX.viewMode` — không cần kiểm tra `isEmpty` rải rác.

---

## Các thành phần chính

### 1. `CasinoLobbySettings` (`casino_settings`)

Config SDUI lobby từ remote, ánh xạ tới JSON key `"lobby"`:

```json
{
  "lobby": {
    "translation_key": "txt_game_category_all",
    "icon": "ic_home.svg",
    "icon_active": "ic_home_yellow.svg",
    "sections": [
      { "title": "Casino nổi bật", "filter": { "strategy": "collection", "params": { "id": "featured" } } },
      { "banner_id": "providersBanner" }
    ]
  }
}
```

Khi `lobby` là `null` hoặc thiếu bất kỳ field nào, repository tự fallback về preset hardcode.

### 2. `CasinoCategory` với `group_key` (`casino_settings`)

Mỗi category trong `categories[]` có thể khai báo `group_key` để điều khiển sidebar:

```json
{ "id": "sunwin", "group_key": "priority", "filter": { "strategy": "in_house" } }
{ "id": "slots",  "group_key": "standard", "filter": { "strategy": "by_game_type", "params": { "game_type": "slot" } } }
{ "id": "sports"  /* không có group_key → bị exclude khỏi sidebar */ }
```

Giá trị `group_key`: `"priority"` | `"standard"` | không có (excluded).

### 3. `CaxiloCategories` — domain model

```dart
// Lấy từ provider (reactive theo settings change)
final categories = ref.watch(gameCategoriesProvider);

categories.all         // Tab "All/Home" — từ lobby.translation_key/icon
categories.categories  // Danh sách tabs còn lại — từ CasinoSettings.categories[]
```

### 4. `GameCategorySelection` — state

```dart
// Tạo selection
GameCategorySelection()                        // Rỗng = lobby mode
GameCategorySelection.fromCategory(category)   // Có category = filter mode

// Chuyển thành filter để gọi repository
final filter = selection.toFilter(); // ← luôn dùng cái này
```

> ⚠️ `selection.matches(game)` **không hoạt động đúng** với collection-based categories
> (newgames, featured, popular). Luôn dùng `toFilter()` + `repository.getGames(filter: ...)`.

### 5. `GameFilterState` & `GameViewMode`

```dart
extension GameFilterStateX on GameFilterState {
  GameViewMode get viewMode =>
      searchQuery.isEmpty && categorySelection.isEmpty
          ? GameViewMode.lobby
          : GameViewMode.filter;
}
```

`_runSearch()` trong `GameFilterNotifier` **bỏ qua** khi `viewMode == lobby` — game list
chỉ được load khi user chọn category lần đầu (lazy loading).

---

## Provider graph

```
caxiloEventsProvider (Stream)
    │
    ├── gameCategoriesProvider        → CaxiloCategories (reactive)
    └── casinoSidebarCategoriesProvider → CaxiloSidebarData (reactive)

gameFilterProvider (autoDispose)
    └── GameFilterState { searchQuery, categorySelection, results, status }
        └── .viewMode → GameViewMode.lobby | .filter
```

---

## Cách thêm category mới

Chỉ cần cập nhật remote JSON (`categories[]` trong `CasinoSettings`):

```json
{
  "id": "new_category",
  "group_key": "standard",
  "translation_key": "txt_game_new_category",
  "icon": "ic_new.svg",
  "icon_active": "ic_new_active.svg",
  "filter": {
    "strategy": "by_game_type",
    "params": { "game_type": "..." }
  }
}
```

Không cần sửa code app — category sẽ tự xuất hiện sau khi settings reload.

---

## Sidebar grouping

Desktop sidebar được chia thành 2 group:

| Group | Nội dung |
|-------|---------|
| `priority` | Tab "All" + categories có `group_key: "priority"` (Sunwin, Jackpot) |
| `standard` | Categories có `group_key: "standard"` (Slots, Live, Cards, ...) |

Categories không có `group_key` được classify tự động theo loại filter (backward compat):
- `InHouseFilter` / `ProvidersFilter` → priority
- `CaxiloTypesFilter(jackpot)` → priority
- `CaxiloTypesFilter(sport)` → bị exclude
- Các type khác → standard
