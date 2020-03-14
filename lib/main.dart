import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sale_spot/screens/home.dart';
import 'package:sale_spot/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes/user.dart';



void main() {

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    final String jsonObject = prefs.getString('storedObject');
    final String jsonId = prefs.getString('storedId');
    final String jsonPhoto = prefs.getString('storePhoto');

    if(jsonObject!=null && jsonObject.isNotEmpty) {
      User _user = User.fromMapObject(json.decode(jsonObject));
      _user.documentId = jsonId;
      _user.photoUrl = jsonPhoto;
      return runApp(MyApp(_user));
    }
    else
      return runApp(MyApp(User()));
  });
}

class MyApp extends StatelessWidget {

  GoogleSignIn _googleSignIn = GoogleSignIn();

  User _user;
  MyApp(this._user);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sale Spot',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: MaterialColor( 0xFF000000,
          const <int, Color>{
            50: const Color(0xFF000000),
            100: const Color(0xFF000000),
            200: const Color(0xFF000000),
            300: const Color(0xFF000000),
            400: const Color(0xFF000000),
            500: const Color(0xFF000000),
            600: const Color(0xFF000000),
            700: const Color(0xFF000000),
            800: const Color(0xFF000000),
            900: const Color(0xFF000000),
          },),
      ),
      home: _user.email!=null?Home(_user):Login(),
    );
  }
}
