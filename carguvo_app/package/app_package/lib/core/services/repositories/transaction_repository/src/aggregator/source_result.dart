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
