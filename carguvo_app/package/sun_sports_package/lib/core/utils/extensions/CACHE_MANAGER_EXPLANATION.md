# Cơ chế hoạt động của `cached_manager.dart`

## Tổng quan

`cached_manager.dart` chứa class `AssetsCacheManager` - một hệ thống quản lý cache tập trung cho các assets (icons, images) trong ứng dụng. Class này sử dụng `flutter_cache_manager` để lưu trữ và quản lý cache files trên thiết bị.

## Kiến trúc

### 1. Singleton Pattern
```dart
class AssetsCacheManager {
  AssetsCacheManager._();  // Private constructor
  static CacheManager? _cacheManager;  // Singleton instance
}
```
- Class sử dụng **Singleton Pattern** để đảm bảo chỉ có một instance của `CacheManager` trong toàn bộ app
- Constructor private (`_()`) ngăn việc tạo instance từ bên ngoài
- `_cacheManager` là biến static để lưu trữ instance duy nhất

### 2. Cache Configuration

```dart
static CacheManager getInstance({Duration? maxAge}) {
  _cacheManager ??= CacheManager(
    Config(
      'sports_images_cache',           // Tên cache database
      stalePeriod: maxAge ?? defaultMaxAge,  // Thời gian hết hạn (mặc định 365 ngày)
      maxNrOfCacheObjects: 100,        // Số lượng file tối đa trong cache
      repo: JsonCacheInfoRepository(databaseName: 'sports_images_cache.db'),
    ),
  );
  return _cacheManager!;
}
```

**Cấu hình:**
- **Database name**: `sports_images_cache` - tên database lưu metadata
- **Stale period**: 14 ngày (2 tuần) - thời gian file được coi là "cũ"
  - **Lưu ý**: Với versioning, cache được quản lý theo version thay vì thời gian
  - `maxAge` được set 2 tuần để cache lâu dài cho đến khi version thay đổi
  - `flutter_cache_manager` yêu cầu `stalePeriod` (không thể null), nhưng với versioning thì ít quan trọng hơn
- **Max objects**: 100 files - giới hạn số lượng file trong cache
- **Repository**: Sử dụng JSON database để lưu thông tin cache

## Cơ chế Versioning

### 1. Cache Key Generation

```dart
static String getCacheKeyForIcon(AssetsData icon, {int? version, bool autoClearOldVersions = true}) {
  final effectiveVersion = version ?? icon.newVersion;
  
  if (autoClearOldVersions) {
    clearOldVersionsForIcon(icon);
  }
  
  return '${icon.label}_v$effectiveVersion';
}
```

**Cách hoạt động:**
- Cache key có format: `{label}_v{version}`
- Ví dụ: `icon_logo_v1`, `icon_plus_v2`
- Nếu không chỉ định version, sử dụng `icon.newVersion`
- Tự động xóa cache của version cũ khi tạo key mới

### 2. Version-based Cache Invalidation

```dart
static Future<void> clearOldVersionsForIcon(AssetsData icon) async {
  if (icon.oldVersion != icon.newVersion) {
    final oldVersionCacheKey = '${icon.label}_v${icon.oldVersion}';
    try {
      await getCacheManager().removeFile(oldVersionCacheKey);
    } catch (_) {}
  }
}
```

**Quy trình:**
1. So sánh `oldVersion` và `newVersion`
2. Nếu khác nhau → tạo cache key cho version cũ
3. Xóa file cache của version cũ khỏi storage
4. Giữ lại file cache của version mới

**Lợi ích:**
- Tự động dọn dẹp cache cũ khi có version mới
- Tiết kiệm dung lượng storage
- Đảm bảo app luôn sử dụng assets mới nhất

## Quy trình Cache SVG Icons

### Method: `getCachedSvgPath()`

```dart
static Future<String> getCachedSvgPath(AssetsData icon) async {
  try {
    // 1. Tạo cache key với version mới
    final cacheKey = getCacheKeyForIcon(icon);
    
    // 2. Kiểm tra cache có file chưa
    final cacheManager = getCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(cacheKey);
    
    // 3. Nếu có trong cache → trả về path local
    if (fileInfo != null && await fileInfo.file.exists()) {
      return fileInfo.file.path;
    }
    
    // 4. Chưa có → tải từ network và cache
    final file = await cacheManager.getSingleFile(
      icon.urlPath,  // URL từ network
      key: cacheKey,  // Cache key với version
    );
    
    if (await file.exists()) {
      return file.path;
    }
  } catch (e) {
    debugPrint('Failed to cache SVG icon ${icon.label}: $e');
  }
  
  // 5. Fallback: trả về URL gốc nếu cache thất bại
  return icon.urlPath;
}
```

### Flowchart quy trình:

```
┌─────────────────────────────────┐
│  getCachedSvgPath(icon)         │
└──────────────┬──────────────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Tạo cache key        │
    │ {label}_v{version}    │
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Xóa cache version cũ │
    │ (nếu có)             │
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Kiểm tra cache       │
    │ có file chưa?        │
    └──────────┬───────────┘
               │
        ┌──────┴──────┐
        │             │
       CÓ           CHƯA
        │             │
        ▼             ▼
┌──────────────┐  ┌──────────────┐
│ Trả về path │  │ Tải từ network│
│ file local  │  │ và cache lại  │
└──────────────┘  └──────┬───────┘
                        │
                        ▼
                 ┌──────────────┐
                 │ Trả về path  │
                 │ file cached  │
                 └──────────────┘
```

## Cách sử dụng trong App

### 1. Trong `CachedSvgIcon` widget:

```dart
class CachedSvgIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AssetsCacheManager.getCachedSvgPath(icon),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? SizedBox(...);
        }
        
        final path = snapshot.data ?? icon.urlPath;
        
        // Nếu là URL → load từ network
        if (path.startsWith('http://') || path.startsWith('https://')) {
          return SvgPicture.network(path, ...);
        }
        
        // Nếu là path local → load từ file
        return SvgPicture.file(File(path), ...);
      },
    );
  }
}
```

### 2. Trong `SplashScreen` (preload):

```dart
Future<void> _preloadIcons() async {
  final icons = [
    AssetsManager.iconLogo,
    AssetsManager.iconPlus,
    AssetsManager.iconAvatar,
    // ...
  ];
  
  for (final icon in icons) {
    try {
      await AssetsCacheManager.getCachedSvgPath(icon);
    } catch (e) {
      debugPrint('Failed to preload icon ${icon.label}: $e');
    }
  }
}
```

## Quản lý Cache

### 1. Xóa toàn bộ cache:

```dart
static Future<void> clearCache() async {
  await getInstance().emptyCache();
  _cacheManager = null;  // Reset singleton
}
```

### 2. Lấy CacheManager instance:

```dart
static CacheManager getCacheManager({Duration? maxAge}) {
  return AssetsCacheManager.getInstance(maxAge: maxAge);
}
```

## Ưu điểm của thiết kế

1. **Tách biệt trách nhiệm**: 
   - `AssetsManager` chỉ chứa data
   - `AssetsCacheManager` chỉ xử lý cache logic

2. **Version-based invalidation**: 
   - Tự động xóa cache cũ khi có version mới
   - Đảm bảo app luôn dùng assets đúng version

3. **Singleton Pattern**: 
   - Chỉ một instance CacheManager trong app
   - Tiết kiệm memory và đảm bảo consistency

4. **Error handling**: 
   - Try-catch trong các method quan trọng
   - Fallback về URL gốc nếu cache thất bại

5. **Flexible configuration**: 
   - Có thể tùy chỉnh `maxAge` cho từng use case
   - Dễ dàng mở rộng thêm tính năng

## Ví dụ thực tế

### Scenario: Update icon logo từ v1 → v2

1. **Trước khi update:**
   - Cache key: `icon_logo_v1`
   - File cached: `/cache/icon_logo_v1.svg`

2. **Update trong `AssetsManager`:**
   ```dart
   static const AssetsData iconLogo = AssetsData(
     label: 'icon_logo',
     urlPath: 'https://.../ic_logo_88_v2.svg',
     oldVersion: 1,    // Version cũ
     newVersion: 2,     // Version mới
   );
   ```

3. **Khi app gọi `getCachedSvgPath(iconLogo)`:**
   - Tạo cache key mới: `icon_logo_v2`
   - Xóa file cache cũ: `icon_logo_v1` → removed
   - Tải và cache file mới: `icon_logo_v2` → cached
   - Trả về path: `/cache/icon_logo_v2.svg`

4. **Kết quả:**
   - App tự động sử dụng icon mới
   - Cache cũ được dọn dẹp tự động
   - Không cần restart app hoặc clear cache thủ công

## Lưu ý quan trọng

1. **Cache key format**: Phải tuân thủ format `{label}_v{version}` để đảm bảo versioning hoạt động đúng

2. **Version update**: Khi update version trong `AssetsData`, phải đảm bảo:
   - `oldVersion` = version hiện tại trong cache
   - `newVersion` = version mới cần cache

3. **Network errors**: Nếu network thất bại, method sẽ fallback về URL gốc, widget cần handle case này

4. **Storage limits**: Cache giới hạn 100 files, nếu vượt quá sẽ tự động xóa file cũ nhất

5. **Thread safety**: `flutter_cache_manager` đã handle thread safety, nhưng nên tránh gọi `clearCache()` khi đang load assets

6. **maxAge vs Versioning**:
   - **Versioning** là cơ chế chính để quản lý cache: khi version thay đổi → cache cũ bị xóa
   - **maxAge** (stalePeriod) là lớp bảo vệ bổ sung, nhưng ít quan trọng hơn khi đã có versioning
   - `maxAge` được set 2 tuần (14 ngày) để cache lâu dài cho đến khi version thay đổi
   - `flutter_cache_manager` yêu cầu `stalePeriod` (không thể null), nhưng với versioning thì giá trị này ít ảnh hưởng
   - **Kết luận**: Với versioning, `maxAge` vẫn cần (vì API yêu cầu) nhưng không quan trọng bằng versioning

