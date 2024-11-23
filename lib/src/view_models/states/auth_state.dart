import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final bool isLoading;
  final UserCredential? userCredential;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.userCredential,
    this.errorMessage,
  });

  AuthState copyWith({bool? isLoading, UserCredential? userCredential, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userCredential: userCredential ?? this.userCredential,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
