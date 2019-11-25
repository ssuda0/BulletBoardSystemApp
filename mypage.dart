import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';

class MyPageScreen extends StatefulWidget{
  static const routeName = '/mypageScreen';
  @override
  MyPageScreenState createState() => MyPageScreenState();
}

class MyPageScreenState extends State<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
        appBar : AppBar(
          leading: IconButton(
            icon: new Icon(Icons.keyboard_backspace),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: new Icon(Icons.exit_to_app),
              onPressed: () async{
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushNamed(context, LoginPage.routeName);
              },
            ),
          ],
        ),
        body:FutureBuilder(
            future : _buildBody(context),
            builder : (BuildContext context, AsyncSnapshot<Widget> snapshot){
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasError)
                    return Text('loading...');
                  return snapshot.data;
                default:
                  return Text('loading...');
              }
            }
        ),
      ),
    );
  }

  Future<Widget> _buildBody(BuildContext context) async{
    FirebaseUser uid = await _getUserID(context);
    if (uid.isAnonymous==true){
      return _buildAnonymous(context, uid);
    }
    else{
      return _buildProfile(context, uid);
    }

  }

  Future<Widget> _buildProfile(BuildContext context, FirebaseUser uid) async {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 20 / 11,
          child: FutureBuilder<Widget>(
            future : _getImage('user-profile-image/${uid.uid}.jpg'),
            builder:  (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasError)
                    return Image.network('http://handong.edu/site/handong/res/img/logo.png');
                  return snapshot.data;
                default:
                  return Text('loading...');
              }
            },
          ),
        ),
        Text(
          uid.uid,
          style : new TextStyle(
            fontSize : 20.0,
          ),
        ),
        Divider(height: 1.0, color: Colors.black),
        Text(uid.email),
      ],
    );
  }

  Future<Widget> _buildAnonymous(BuildContext context,  FirebaseUser uid) async{
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 20 / 11,
          child: Image.network('http://handong.edu/site/handong/res/img/logo.png'),
        ),
        Text(
          uid.uid,
          style : new TextStyle(
            fontSize : 20.0,
          ),
        ),
        Divider(height: 1.0, color: Colors.black),
        Text("anonymous"),
      ],
    );
  }

  Future<FirebaseUser> _getUserID(BuildContext context) async{
    FirebaseUser userId = await FirebaseAuth.instance.currentUser();
    return userId;
  }

  Future<Widget> _getImage(String profileImageName) async {
    final StorageReference storageReference = FirebaseStorage().ref().child(profileImageName);
    final url = await storageReference.getDownloadURL();
    return Image.network(url.toString());
  }

}