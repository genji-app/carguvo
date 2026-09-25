import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/search/data/models/search_response_model.dart';
import 'package:sun_sports/features/search/domain/repositories/search_repository.dart';

class SearchUseCase {
  final SearchRepository _repository;

  SearchUseCase(this._repository);

  Future<Either<Failure, SearchResponseModel>> call(
    String query, {
    CancelToken? cancelToken,
  }) async {
    return _repository.search(query, cancelToken: cancelToken);
  }
}
