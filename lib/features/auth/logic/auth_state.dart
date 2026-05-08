import 'package:equatable/equatable.dart';
import 'package:fly_mate/features/auth/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthCheckingSession extends AuthState {
  const AuthCheckingSession();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user.id, user.email];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthForgotPasswordSent extends AuthState {
  const AuthForgotPasswordSent();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
