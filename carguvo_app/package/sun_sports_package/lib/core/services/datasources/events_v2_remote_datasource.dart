import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';
import '../network/sb_http_manager.dart';

final eventsV2RemoteDataSourceProvider = Provider<EventsV2RemoteDataSource>((
  ref,
) {
  return EventsV2RemoteDataSourceImpl(SbHttpManager.instance);
});

abstract class EventsV2RemoteDataSource {
  Future<List<LeagueModelV2>> getEvents(EventsRequestModel request);

  Future<List<LeagueModelV2>> getEventsWithCancel(
    EventsRequestModel request,
    CancelToken cancelToken,
  );

  Future<List<LeagueModelV2>> getLiveEvents(int sportId, {int? sportTypeId});

  Future<List<LeagueModelV2>> getTodayEvents(int sportId, {int? sportTypeId});

  Future<List<LeagueModelV2>> getEarlyEvents(int sportId, {int? sportTypeId});

  Future<List<String>> getEventDates(
    int sportId, {
    int days,
    int tzOffset,
    CancelToken? cancelToken,
  });
}

class EventsV2RemoteDataSourceImpl implements EventsV2RemoteDataSource {
  final SbHttpManager _httpManager;

  EventsV2RemoteDataSourceImpl(this._httpManager);

  @override
  Future<List<LeagueModelV2>> getEvents(EventsRequestModel request) {
    return getEventsWithCancel(request, CancelToken());
  }

  @override
  Future<List<LeagueModelV2>> getEventsWithCancel(
    EventsRequestModel request,
    CancelToken cancelToken,
  ) async {
    try {
      return await _httpManager.getEventsV2(request, cancelToken: cancelToken);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw const CancelledException('Request cancelled');
      }
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException('Failed to fetch events: $e', originalError: e);
    }
  }

  @override
  Future<List<LeagueModelV2>> getLiveEvents(int sportId, {int? sportTypeId}) {
    return getEvents(
      EventsRequestModel.live(sportId, sportTypeId: sportTypeId),
    );
  }

  @override
  Future<List<LeagueModelV2>> getTodayEvents(int sportId, {int? sportTypeId}) {
    return getEvents(
      EventsRequestModel.today(sportId, sportTypeId: sportTypeId),
    );
  }

  @override
  Future<List<LeagueModelV2>> getEarlyEvents(int sportId, {int? sportTypeId}) {
    return getEvents(
      EventsRequestModel.early(sportId, sportTypeId: sportTypeId),
    );
  }

  @override
  Future<List<String>> getEventDates(
    int sportId, {
    int days = 30,
    int tzOffset = -420,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _httpManager.getEventDates(
        sportId,
        days: days,
        tzOffset: tzOffset,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw const CancelledException('Request cancelled');
      }
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException('Failed to fetch event dates: $e', originalError: e);
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

abstract class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class TimeoutException extends ApiException {
  const TimeoutException(super.message);
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class ServerException extends ApiException {
  final int? statusCode;

  const ServerException(super.message, {this.statusCode});
}

class CancelledException extends ApiException {
  const CancelledException(super.message);
}

class UnknownException extends ApiException {
  final Object? originalError;

  const UnknownException(super.message, {this.originalError});
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}
