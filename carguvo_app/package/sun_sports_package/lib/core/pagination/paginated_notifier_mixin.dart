// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sun_sports/core/misc/request_lock_mixin.dart';

part 'paginated_notifier_mixin.freezed.dart';

mixin PaginatedNotifierMixin<R, D>
    on StateNotifier<PaginatedState<D>>, RequestLock {
  @protected
  Future<R> request([int? cursor]);

  @protected
  Future<void> onInitialResponse(R response);

  @protected
  Future<void> onRefreshResponse(R response);

  @protected
  Future<void> onMoreResponse(R response, D data);

  @protected
  Future<void> onRequestError(Object error, StackTrace stackTrace);

  Future<void> loadInitial() async {
    if (!mounted) return;
    if (lock()) return;

    final currentState = state;
    state = currentState.copyWith(status: PaginatedStatus.loading);

    try {
      final response = await request();

      if (!mounted) return;
      await onInitialResponse(response);
    } catch (e, st) {
      if (!mounted) return;
      state = const PaginatedState.error();

      await onRequestError(e, st);
    } finally {
      unlock();
    }
  }

  Future<void> refresh([bool clear = true]) async {
    if (!mounted) return;
    if (lock()) return;

    try {
      final currentState = state;

      state = currentState.copyWith(
        status: PaginatedStatus.refreshing,
        data: clear ? null : currentState.data,
      );

      final response = await request();

      if (!mounted) return;
      await onRefreshResponse(response);
    } catch (e, st) {
      if (!mounted) return;
      state = const PaginatedState.error();

      await onRequestError(e, st);
    } finally {
      unlock();
    }
  }

  Future<void> loadMore() async {
    if (!mounted) return;
    if (lock()) return;

    try {
      if (state.canLoadMore) {
        final currentState = state;

        state = currentState.copyWith(status: PaginatedStatus.loadingMore);

        final response = await request(currentState.cursor);

        if (!mounted) return;
        await onMoreResponse(response, currentState.data as D);
      }
    } catch (e, st) {
      if (!mounted) return;
      state = state.copyWith(status: PaginatedStatus.error);

      await onRequestError(e, st);
    } finally {
      unlock();
    }
  }
}

enum PaginatedStatus {
  initial,
  loading,
  data,
  noData,
  refreshing,
  loadingMore,
  error,
}

@freezed
class PaginatedState<T> with _$PaginatedState<T> {
  PaginatedState._({required this.status, this.data, this.cursor});

  const PaginatedState.initial()
    : status = PaginatedStatus.initial,
      data = null,
      cursor = null;

  const PaginatedState.error()
    : status = PaginatedStatus.error,
      data = null,
      cursor = null;

  factory PaginatedState.withData({required T data, int? cursor}) =>
      PaginatedState._(
        status: PaginatedStatus.data,
        data: data,
        cursor: cursor,
      );

  factory PaginatedState.empty() => PaginatedState._(
    status: PaginatedStatus.noData,
    data: null,
    cursor: null,
  );

  @override
  final PaginatedStatus status;

  @override
  final T? data;

  @override
  final int? cursor;

  PaginatedState<T> loadingMore() =>
      copyWith(status: PaginatedStatus.loadingMore);

  PaginatedState<T> refreshing() =>
      copyWith(status: PaginatedStatus.refreshing);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaginatedState<T> &&
          other.status == status &&
          identical(other.data, data) &&
          other.cursor == cursor);

  @override
  int get hashCode => Object.hash(status, identityHashCode(data), cursor);
}

extension PaginatedStateExtension<T> on PaginatedState<T> {
  bool get canLoadMore => switch (status) {
    PaginatedStatus.data => cursor != null && cursor != 0,
    _ => false,
  };

}
