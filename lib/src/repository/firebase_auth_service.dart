import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmanager/src/network/abstract/base_firebase_service.dart';

class FirebaseAuthService extends BaseFirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signUpUserWithFirebase(
      String email, String password) async {
    final userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return userCredential;
  }

  @override
  Future<UserCredential> loginUserWithFirebase(
      String email, String password) async {
    final userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }

  @override
  bool isUserLogin() {
    if (auth.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> signOutUser() async {
    try {
       await auth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;  }

  @override

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId: "93470584453-en2q6967j1k6ucjq4pjvob0l8q3jg0r9.apps.googleusercontent.com",
      scopes: ['email', 'profile', 'openid'],

    ).signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }



}
