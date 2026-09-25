import 'package:dio/dio.dart';

class FixJsonContentTypeTransformer extends BackgroundTransformer {
  @override
  Future<dynamic> transformResponse(
    RequestOptions options,
    ResponseBody responseBody,
  ) {
    final rawTypes = responseBody.headers['content-type'] ?? [];
    final raw = rawTypes.isNotEmpty ? rawTypes.first.toLowerCase() : '';

    if (raw.contains('application/json') || raw.contains('json')) {
      responseBody.headers['content-type'] = ['application/json'];
    }

    return super.transformResponse(options, responseBody);
  }
}
