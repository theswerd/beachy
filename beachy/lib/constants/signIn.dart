import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<bool> signInWithGoogle()async{
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  
  GoogleSignInAccount account = await _googleSignIn.signIn();
  
  return account == null?false:true;

}

