import 'package:dartz/dartz.dart';
import 'package:sun_sports/core/error/failures.dart';
import 'package:sun_sports/features/profile/avatar/domain/entities/avatar_item.dart';

abstract class AvatarRepository {
  Future<Either<Failure, List<AvatarItem>>> getAvatars();

  Future<Either<Failure, String>> updateAvatar(int avatarId);
}
