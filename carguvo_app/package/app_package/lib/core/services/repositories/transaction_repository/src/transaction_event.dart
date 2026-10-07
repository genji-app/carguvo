import 'models/models.dart';

sealed class TransactionEvent {
  const TransactionEvent();
}

final class TransactionCreatedEvent extends TransactionEvent {
  const TransactionCreatedEvent({required this.source});

  final TransactionSource source;
}

final class TransactionMutatedEvent extends TransactionEvent {
  const TransactionMutatedEvent();
}

final class TransactionCacheInvalidatedEvent extends TransactionEvent {
  const TransactionCacheInvalidatedEvent();
}

final class ComplainCreatedEvent extends TransactionEvent {
  const ComplainCreatedEvent();
}
