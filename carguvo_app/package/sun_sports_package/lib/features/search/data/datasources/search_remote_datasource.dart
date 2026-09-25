import 'package:dio/dio.dart';

abstract class SearchRemoteDataSource {
  Future<Map<String, dynamic>> search(String query, {CancelToken? cancelToken});
}
