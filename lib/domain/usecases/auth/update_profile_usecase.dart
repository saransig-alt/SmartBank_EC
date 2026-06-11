import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';

class UpdateProfileUseCase {
  final IAuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> execute(UserEntity user) {
    return repository.updateUserProfile(user);
  }
}
