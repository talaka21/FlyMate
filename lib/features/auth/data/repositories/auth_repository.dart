import 'package:fly_mate/features/auth/data/models/user_model.dart';

import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

abstract class AuthRepository {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<void> forgotPassword({required String email});
  Future<void> signOut();
  Future<UserModel?> getCachedUser();
  Future<bool> isLoggedIn();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _remote.signIn(email: email, password: password);
    await _local.saveUser(user);
    return user;
  }

  @override
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final user = await _remote.signUp(
      fullName: fullName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    await _local.saveUser(user);
    return user;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _remote.forgotPassword(email: email);
  }

  @override
  Future<void> signOut() async {
    await _local.clearUser();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return _local.getUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _local.getToken();
    return token != null && token.isNotEmpty;
  }
}
