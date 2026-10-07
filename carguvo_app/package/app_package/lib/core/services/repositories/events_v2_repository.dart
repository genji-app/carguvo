import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/events_v2_remote_datasource.dart';
import '../models/api_v2/events_request_model.dart';
import '../models/api_v2/league_model_v2.dart';

final eventsV2RepositoryProvider = Provider<EventsV2Repository>((ref) {
  final remoteDataSource = ref.watch(eventsV2RemoteDataSourceProvider);
  return EventsV2RepositoryImpl(remoteDataSource);
});

abstract class EventsV2Repository {
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

class EventsV2RepositoryImpl implements EventsV2Repository {
  final EventsV2RemoteDataSource _remoteDataSource;

  EventsV2RepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LeagueModelV2>> getEvents(EventsRequestModel request) {
    return _remoteDataSource.getEvents(request);
  }

  @override
  Future<List<LeagueModelV2>> getEventsWithCancel(
    EventsRequestModel request,
    CancelToken cancelToken,
  ) {
    return _remoteDataSource.getEventsWithCancel(request, cancelToken);
  }

  @override
  Future<List<LeagueModelV2>> getLiveEvents(int sportId, {int? sportTypeId}) {
    return _remoteDataSource.getLiveEvents(sportId, sportTypeId: sportTypeId);
  }

  @override
  Future<List<LeagueModelV2>> getTodayEvents(int sportId, {int? sportTypeId}) {
    return _remoteDataSource.getTodayEvents(sportId, sportTypeId: sportTypeId);
  }

  @override
  Future<List<LeagueModelV2>> getEarlyEvents(int sportId, {int? sportTypeId}) {
    return _remoteDataSource.getEarlyEvents(sportId, sportTypeId: sportTypeId);
  }

  @override
  Future<List<String>> getEventDates(
    int sportId, {
    int days = 30,
    int tzOffset = -420,
    CancelToken? cancelToken,
  }) {
    return _remoteDataSource.getEventDates(
      sportId,
      days: days,
      tzOffset: tzOffset,
      cancelToken: cancelToken,
    );
  }
}
