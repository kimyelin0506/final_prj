import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Initialize GoogleSignIn instance outside of the method to avoid potential issues
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Check if the user canceled the sign-in
    if (googleUser == null) {
      print("Google sign-in canceled");
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (error) {
    print("Google sign-in error: $error");
    // Handle the error, show a message to the user, or try to sign in again.
    return null; // Or return a specific value indicating failure.
  }
}
