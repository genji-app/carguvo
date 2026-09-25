import 'package:dio/dio.dart';

import 'game_api_exception.dart';
import 'game_api_parsers.dart';
import 'game_api_retry_interceptor.dart';
import 'game_api_token_refresh_interceptor.dart';
import 'models/models.dart';

typedef TokenProvider = Future<String?> Function();

class GameApiClient {
  GameApiClient({required Dio dio, TokenProvider? tokenProvider})
    : _dio = dio,
      _tokenProvider = tokenProvider;

  final Dio _dio;
  final TokenProvider? _tokenProvider;

  static Dio createDioClient(String baseUrl, [TokenRefreshCallback? onRefreshToken]) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: const {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(GameApiRetryInterceptor(dio: dio, maxRetries: 3));

    if (onRefreshToken != null) {
      dio.interceptors.add(
        GameApiTokenRefreshInterceptor(onRefreshToken: onRefreshToken, dio: dio),
      );
    }

    return dio;
  }

  Future<Map<String, String>> _getRequestHeaders() async {
    final token = await _tokenProvider?.call();
    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': token,
    };
  }

  Future<T> _request<T>({
    required String path,
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final options = Options(
        headers: requiresAuth
            ? await _getRequestHeaders()
            : const {'Content-Type': 'application/json'},
      );

      final Response response = method == 'POST'
          ? await _dio.post(path, data: data, options: options)
          : await _dio.get(path, queryParameters: queryParameters, options: options);

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const GameApiException.parsing(description: 'Invalid response format from server');
      }

      final apiResponse = GameApiResponse.fromJson(responseData, parser);
      return apiResponse.dataOrThrow;
    } on GameApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is GameApiException) {
        throw e.error! as GameApiException;
      }
      throw GameApiException.fromDioException(e);
    } catch (e, stackTrace) {
      Error.throwWithStackTrace(
        GameApiException.parsing(description: e.toString(), originalError: e),
        stackTrace,
      );
    }
  }

  Future<List<ProviderGames>> getGames() =>
      _request(path: '/providers/games', parser: GameApiParsers.parseProviderGames);

  Future<String> getGameUrl(GetGameUrlRequest request) => _request(
    path: '/providers/get-url',
    method: 'POST',
    data: request.toApiJson(),
    parser: GameApiParsers.parseGameUrl,
  );

  Future<Map<int, List<JackpotEntry>>> getJackpots() =>
      _request(path: '/jackpot/all', requiresAuth: false, parser: GameApiParsers.parseJackpots);

  Future<int> getHistoryConfig() =>
      _request(path: '/history/config', parser: GameApiParsers.parseHistoryConfig);

  Future<bool> updateHistoryConfig(int timeCountDown) => _request(
    path: '/history/config',
    method: 'POST',
    data: {'timeCountDown': timeCountDown},
    parser: GameApiParsers.parseUpdateHistoryConfig,
  );

  Future<CardLastJoinData?> getCardLastJoin() =>
      _request(path: '/card/last-join', parser: GameApiParsers.parseCardLastJoin);

  Future<UserBalanceData> fetchBalance() =>
      _request(path: '/user/fetch-balance', parser: GameApiParsers.parseUserBalance);
}

extension _GameApiResponseClientX<T> on GameApiResponse<T> {
  T get dataOrThrow => map(
    success: (s) => s.data,
    failure: (f) {
      throw GameApiException.business(
        serverMessage: f.message,
        apiCode: f.code,
        apiStatus: f.status,
        data: f.data,
      );
    },
  );
}
