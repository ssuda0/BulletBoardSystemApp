// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();


class LoginPage extends StatefulWidget {
  static const routeName = '/loginScreen';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _success;
  String _userID;

  void _signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _success = true;
        _userID = user.uid;
        Navigator.pushNamed(context, HomePage.routeName);
        //Navigator.pop(context);
      } else {
        _success = false;
      }
    });
  }

  void _signInAnonymously(BuildContext context) async {
    final FirebaseUser user = (await _auth.signInAnonymously()).user;
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);

    assert(user.providerData.length == 1);
    assert(user.providerData[0].providerId == 'firebase');
    assert(user.providerData[0].uid != null);
    assert(user.providerData[0].displayName == null);
    assert(user.providerData[0].photoUrl == null);
    assert(user.providerData[0].email == null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    setState(() {
      if (user != null) {
        _success = true;
        _userID = user.uid;
        Navigator.pushNamed(context, HomePage.routeName);
        //Navigator.pop(context);
      } else {
        _success = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                SizedBox(height: 16.0),
                Text('SHRINE'),
              ],
            ),
            SizedBox(height: 120.0),
            RaisedButton(
              child: Text('GOOGLE Sign In'),
              onPressed: () {
                _signInWithGoogle(context);
              },
            ),
            SizedBox(height: 12.0),
            RaisedButton(
              child: Text('GUEST Sign In'),
              onPressed: () {
                _signInAnonymously(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}



// TODO: Add AccentColorOverride (103)
