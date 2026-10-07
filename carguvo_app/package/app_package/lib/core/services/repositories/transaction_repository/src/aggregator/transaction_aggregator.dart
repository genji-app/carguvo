import '../models/models.dart';

sealed class SourceResult {
  const SourceResult(this.source);

  final TransactionSource source;
}

class SourceSuccess extends SourceResult {
  const SourceSuccess(
    super.source, {
    required this.items,
    required this.totalCount,
  }) : super();

  final List<UnifiedTransaction> items;

  final int totalCount;
}

class SourceFailure extends SourceResult {
  const SourceFailure(super.source, {required this.error}) : super();

  final Object error;
}

class AggregatedPage {
  const AggregatedPage({
    required this.items,
    required this.isLastPage,
    required this.exhaustedSources,
  });

  final List<UnifiedTransaction> items;

  final bool isLastPage;

  final Set<TransactionSource> exhaustedSources;
}

final class TransactionAggregator {
  const TransactionAggregator();

  AggregatedPage merge(
    List<SourceResult> results, {
    required int skip,
    required int limit,
    Set<TransactionSource> alreadyExhausted = const {},
  }) {
    final items =
        results.whereType<SourceSuccess>().expand((r) => r.items).toList()
          ..sort((a, b) => b.sortTime.compareTo(a.sortTime));

    final newlyExhausted = {
      ...results.whereType<SourceFailure>().map((r) => r.source),
      ...results
          .whereType<SourceSuccess>()
          .where((r) {
            return (skip + r.items.length) >= r.totalCount;
          })
          .map((r) => r.source),
    };

    final allExhausted = alreadyExhausted.union(newlyExhausted);

    final activeSourcesInThisRequest = results.map((r) => r.source).toSet();
    final isLastPage = activeSourcesInThisRequest.every(allExhausted.contains);

    return AggregatedPage(
      items: items,
      isLastPage: isLastPage,
      exhaustedSources: allExhausted,
    );
  }
}
