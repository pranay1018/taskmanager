import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanager/src/view_models/states/auth_state.dart';
import '../repository/firebase_auth_service.dart';
import '../repository/firestore_service.dart';


final authProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(FirebaseAuthService(), FireStoreService());
});


class AuthViewModel extends StateNotifier<AuthState> {
  final FirebaseAuthService _fauth;
  final FireStoreService _fstore;

  AuthViewModel(this._fauth, this._fstore) : super(AuthState());

  Future<bool> loginUser(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final userCredential = await _fauth.loginUserWithFirebase(email, password);
      if (userCredential.user != null) {
        print("loginUserWithFirebase success");
        return true;
      }
      state = state.copyWith(userCredential: userCredential, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
    return false;
  }

  Future<bool> signupUser(String email, String password,String firstName,String lastName) async {
    state = state.copyWith(isLoading: true);
    try {
      final userCredential = await _fauth.signUpUserWithFirebase(email, password);

      final data = {
        'uid': userCredential.user?.uid,
        'email': userCredential.user?.email,
        'userName': "$firstName $lastName",
        'createdAt': DateTime.now().toIso8601String(),
      };
      if (userCredential.user != null) {
        await _fstore.addDataToFireStore(data, 'users', userCredential.user!.uid);
        return true;
      }
      state = state.copyWith(userCredential: userCredential, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
    return false;
  }

  Future<bool> googleSigning() async {
    state = state.copyWith(isLoading: true);
    try {
      final userCredential = await _fauth.signInWithGoogle();
      final data = {
        'uid': userCredential.user?.uid,
        'email': userCredential.user?.email,
        'userName': userCredential.user?.displayName,
        'createdAt': DateTime.now().toIso8601String(),
      };
      if (userCredential.user != null) {
        await _fstore.addDataToFireStore(data, 'users', userCredential.user!.uid);
        return true;
      }
      state = state.copyWith(userCredential: userCredential, isLoading: false);
    } catch (e) {
      print(e);
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
    return false;
  }


  Future<bool> logout() async {
    try {
      final isLogout =  await _fauth.signOutUser();
      state = state.copyWith(isLoading: false);
      return isLogout;
    } catch (e) {
      print(e);
    }
    return false;
  }

}
