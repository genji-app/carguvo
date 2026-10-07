import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_package/core/error/failures.dart';
import 'package:app_package/features/search/data/models/search_response_model.dart';
import 'package:app_package/features/search/domain/repositories/search_repository.dart';

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
