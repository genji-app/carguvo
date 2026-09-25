import 'preload_storage_stub.dart'
    if (dart.library.html) 'preload_storage_web.dart' as impl;

void savePreloadedUrls(List<String> urls) => impl.savePreloadedUrls(urls);
