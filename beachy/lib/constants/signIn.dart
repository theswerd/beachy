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
  if(account == null){
    return false;
  }else{
    final GoogleSignInAuthentication googleAuth = await account.authentication;  
    final AuthCredential credential = GoogleAuthProvider.getCredential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    final AuthResult user = await FirebaseAuth.instance.signInWithCredential(credential);  
 
    return true; 
  }
  return account == null?false:true;
}

