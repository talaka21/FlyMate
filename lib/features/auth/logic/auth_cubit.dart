import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fly_mate/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({required AuthRepository repository})
    : _repository = repository,
      super(const AuthInitial());

  /// يُستدعى عند فتح التطبيق — يتحقق إذا في جلسة محفوظة
  Future<void> checkSession() async {
    emit(const AuthCheckingSession());
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _repository.getCachedUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
          return;
        }
      }
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  /// تسجيل الدخول
  Future<void> signIn({required String email, required String password}) async {
    // ── Validation ────────────────────────────────────────────────
    final validationError = _validateSignIn(email: email, password: password);
    if (validationError != null) {
      emit(AuthError(validationError));
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await _repository.signIn(
        email: email.trim(),
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// إنشاء حساب جديد
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // ── Validation ────────────────────────────────────────────────
    final validationError = _validateSignUp(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (validationError != null) {
      emit(AuthError(validationError));
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await _repository.signUp(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        passwordConfirmation: confirmPassword,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// نسيت كلمة المرور
  Future<void> forgotPassword({required String email}) async {
    if (email.trim().isEmpty) {
      emit(AuthError('Please enter your email'));
      return;
    }
    if (!_isValidEmail(email)) {
      emit(AuthError('Please enter a valid email'));
      return;
    }

    emit(const AuthLoading());
    try {
      await _repository.forgotPassword(email: email.trim());
      emit(const AuthForgotPasswordSent());
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthUnauthenticated());
  }

  /// إعادة تعيين الحالة (مثلاً بعد ما يشوف الـ error)
  void resetState() => emit(const AuthInitial());

  // ── Private Validators ──────────────────────────────────────────

  String? _validateSignIn({required String email, required String password}) {
    if (email.trim().isEmpty) return 'Please enter your email';
    if (!_isValidEmail(email)) return 'Please enter a valid email';
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateSignUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (fullName.trim().isEmpty) return 'Please enter your full name';
    if (fullName.trim().length < 3) return 'Name must be at least 3 characters';
    if (email.trim().isEmpty) return 'Please enter your email';
    if (!_isValidEmail(email)) return 'Please enter a valid email';
    if (password.isEmpty) return 'Please enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }
}
