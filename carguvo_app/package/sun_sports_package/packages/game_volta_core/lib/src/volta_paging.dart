class VoltaPaging {
  const VoltaPaging._();

  static int pageCount(int total, int pageSize) {
    if (pageSize <= 0) return 1;
    if (total <= 0) return 1;
    return (total + pageSize - 1) ~/ pageSize;
  }

  static List<T> pageOf<T>(List<T> items, int page, int pageSize) {
    if (items.isEmpty || pageSize <= 0) return const <Never>[];
    final int pages = pageCount(items.length, pageSize);
    final int clamped = page < 1 ? 1 : (page > pages ? pages : page);
    final int start = (clamped - 1) * pageSize;
    final int end = start + pageSize;
    return items.sublist(start, end > items.length ? items.length : end);
  }
}
