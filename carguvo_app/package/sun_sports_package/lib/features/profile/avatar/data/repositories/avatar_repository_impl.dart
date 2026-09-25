import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/core/services/network/sb_http_manager.dart';
import 'package:sun_sports/core/services/network/sun_api_exception.dart';
import 'package:sun_sports/core/utils/app_logger.dart';
import 'package:sun_sports/features/profile/avatar/domain/entities/avatar_item.dart';
import 'package:sun_sports/features/profile/avatar/domain/repositories/avatar_repository.dart';

class AvatarRepositoryImpl implements AvatarRepository {
  final SbHttpManager _httpManager;
  final AppLogger _logger = AppLogger(tag: 'AvatarRepository');

  AvatarRepositoryImpl({SbHttpManager? httpManager})
    : _httpManager = httpManager ?? SbHttpManager.instance;

  @override
  Future<Either<Failure, List<AvatarItem>>> getAvatars() async {
    try {
      final rawItems = await _httpManager.getAvatars();
      final avatars = rawItems.map(AvatarItem.fromJson).toList();
      _logger.d('✅ getAvatars success: ${avatars.length} items');
      return Right(avatars);
    } on SunApiException catch (e, stackTrace) {
      _logger.e('getAvatars failed', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      _logger.e('getAvatars unexpected', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateAvatar(int avatarId) async {
    try {
      final message = await _httpManager.updateAvatar(avatarId);
      _logger.d('✅ updateAvatar success: $message');
      return Right(message);
    } on SunApiException catch (e, stackTrace) {
      _logger.e('updateAvatar failed', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.message));
    } catch (e, stackTrace) {
      _logger.e('updateAvatar unexpected', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
