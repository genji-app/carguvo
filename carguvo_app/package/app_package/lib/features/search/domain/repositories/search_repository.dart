import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_package/core/error/failures.dart';
import 'package:app_package/features/search/data/models/search_response_model.dart';

abstract class SearchRepository {
  Future<Either<Failure, SearchResponseModel>> search(
    String query, {
    CancelToken? cancelToken,
  });
}
