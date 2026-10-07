import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_v2/event_detail_response_v2.dart';
import '../network/sb_http_manager.dart';
import 'events_v2_remote_datasource.dart';

final eventDetailV2RemoteDataSourceProvider =
    Provider<EventDetailV2RemoteDataSource>((ref) {
      return EventDetailV2RemoteDataSourceImpl(SbHttpManager.instance);
    });

abstract class EventDetailV2RemoteDataSource {
  Future<EventDetailResponseV2> getEventDetail(
    int eventId, {
    bool isMobile,
    bool onlyParlay,
  });

  Future<EventDetailResponseV2> getEventDetailWithCancel(
    int eventId,
    CancelToken cancelToken, {
    bool isMobile,
    bool onlyParlay,
  });
}

class EventDetailV2RemoteDataSourceImpl
    implements EventDetailV2RemoteDataSource {
  final SbHttpManager _httpManager;

  EventDetailV2RemoteDataSourceImpl(this._httpManager);

  @override
  Future<EventDetailResponseV2> getEventDetail(
    int eventId, {
    bool isMobile = true,
    bool onlyParlay = false,
  }) {
    return getEventDetailWithCancel(
      eventId,
      CancelToken(),
      isMobile: isMobile,
      onlyParlay: onlyParlay,
    );
  }

  @override
  Future<EventDetailResponseV2> getEventDetailWithCancel(
    int eventId,
    CancelToken cancelToken, {
    bool isMobile = true,
    bool onlyParlay = false,
  }) async {
    try {
      return await _httpManager.getEventDetailV2(
        eventId,
        isMobile: isMobile,
        onlyParlay: onlyParlay,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw const CancelledException('Request cancelled');
      }
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        'Failed to fetch event detail: $e',
        originalError: e,
      );
    }
  }

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');

      case DioExceptionType.badResponse:
        return ServerException(
          'Server error: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return const CancelledException('Request cancelled');

      default:
        return UnknownException(
          e.message ?? 'Unknown error occurred',
          originalError: e,
        );
    }
  }
}
