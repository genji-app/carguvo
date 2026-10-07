import 'package:dio/dio.dart';
import 'package:app_package/core/services/network/sb_http_manager.dart';
import 'package:app_package/features/search/data/datasources/search_remote_datasource.dart';

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl(this._http);

  final SbHttpManager _http;

  @override
  Future<Map<String, dynamic>> search(
    String query, {
    CancelToken? cancelToken,
  }) async {
    return _http.getSearch(query, cancelToken: cancelToken);
  }
}
