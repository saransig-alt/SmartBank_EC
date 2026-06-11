import 'dart:async';
import '../../entities/user_entity.dart';
import '../../repositories/i_bank_repository.dart';

/// Caso de uso: Escuchar los datos del usuario en tiempo real.
class ListenUserDataUseCase {
  final IBankRepository _repository;

  ListenUserDataUseCase(this._repository);

  Stream<UserEntity> execute(String uid) {
    return _repository.listenUserData(uid);
  }
}