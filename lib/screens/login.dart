import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading/loading.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/home.dart';
import 'package:sale_spot/screens/make_profile.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';


class Login extends StatefulWidget {
	@override
	_LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

	FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
	GoogleSignIn _googleSignIn = GoogleSignIn();

	User _user;

	bool _isLoading = false;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
//				mainAxisAlignment:MainAxisAlignment.spaceEvenly,
			  crossAxisAlignment: CrossAxisAlignment.center,
			  children: <Widget>[
          SizedBox(
            height: screenHeight(context)/2,
          ),
			  	Center(
						child:Text("SaleSpot",
								style:TextStyle(
									color:Colors.cyan,
                  fontFamily:'Montserrat',
                  fontSize: 50.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w500,
						)
						)
					),
//			    Align(
//			    	alignment: Alignment(0,0.76),
//			    	child: _isLoading?CircularProgressIndicator():GoogleSignInButton(
//			    		borderRadius: 10.0,
//			    		darkMode: true,
//			    		onPressed: () => singInWithGoogle().catchError((e) {
//			    			setState(() {
//			    			  _isLoading = false;
//			    			});
//			    			return _googleSignIn.signOut();
//			    		}),
//			    	),
//			    ),
              SizedBox(
                height: screenHeight(context)/5,
          ),
          Align(
            alignment: Alignment(0,0.76),
            child: _isLoading?CircularProgressIndicator():GoogleSignInButton(
              borderRadius: 10.0,
              darkMode: true,
              onPressed: () => singInWithGoogle().catchError((e) {
                setState(() {
                  _isLoading = false;
                });
                return _googleSignIn.signOut();
              }),
            ),
          ),
			  ],
			)
		);
	}

	Future<void> singInWithGoogle() async {
		setState(() {
		  _isLoading = true;
		});
		GoogleSignInAccount googleUser = await _googleSignIn.signIn();
		GoogleSignInAuthentication googleAuth = await googleUser.authentication;
		AuthCredential credential = GoogleAuthProvider.getCredential(
			idToken: googleAuth.idToken,
			accessToken: googleAuth.accessToken
		);

		AuthResult authResult = await _firebaseAuth.signInWithCredential(credential).catchError((err) {
			Fluttertoast.showToast(
				msg: 'This account has been Blocked.',
				toastLength: Toast.LENGTH_LONG,
				gravity: ToastGravity.CENTER,
				backgroundColor: Colors.black,
				textColor: Colors.white,
				fontSize: 15.0
			);
		});
		FirebaseUser userDetails = authResult.user;
		QuerySnapshot snapshot = await Firestore.instance.collection('user').where('email', isEqualTo: userDetails.email).getDocuments();
		if(snapshot.documents.length!=0) {
			_user = User.fromMapObject(snapshot.documents[0].data);
			_user.documentId = snapshot.documents[0].documentID;
			_user.photoUrl = authResult.user.photoUrl;
			Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Home(_user)), (Route<dynamic> route) => false);
		}
		else {
			setState(() {
			  _isLoading = false;
			});
			Navigator.push(context, MaterialPageRoute(builder: (context) {
				return MakeProfile(authResult);
			}));
		}
	}
}
