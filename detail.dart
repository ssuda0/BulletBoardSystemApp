//import 'package:flutter/material.dart';
//import 'product.dart';
//
//class DetailArguments{
//  ProductRecord productRecord;
//  DetailArguments(this.productRecord);
//}
//
//class DetailScreen extends StatelessWidget {
//  static const routeName = '/detailScreen';
//  Widget build(BuildContext context) {
//
//  }
//}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'product.dart';
import 'edit.dart';

class DetailArguments{
  final DocumentSnapshot data;
  DetailArguments(this.data);
}

class DetailScreen extends StatefulWidget{
  static const routeName = '/detailScreen';
  DetailScreenState createState() => DetailScreenState();
}

DocumentSnapshot documentSnapshot;

class DetailScreenState extends State<DetailScreen> {
  Widget build(BuildContext context) {
    final DetailArguments args = ModalRoute.of(context).settings.arguments;
    documentSnapshot = args.data;
    final productRecord = ProductRecord.fromSnapshot(documentSnapshot);
    return  MaterialApp(
      title: 'Detail',
      home: Scaffold(
        appBar: AppBar(
          title: Center(child:Text('Detail')),
          leading: new IconButton(
            icon: new Icon(Icons.keyboard_backspace),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon : Icon(Icons.mode_edit),
              onPressed: () async {
                if(productRecord.uid == await _makeUserID(context)){
                  Navigator.pushNamed(context, EditScreen.routeName, arguments: EditScreenArguments(documentSnapshot));
                }else{
                  print("wrong userid");
                }
              },
            ),
            IconButton(
              icon : Icon(Icons.delete),
              onPressed: () async {
                if(productRecord.uid == await _makeUserID(context)){
                  _deleteData(context);
                  Navigator.pop(context);
                }else{
                  print("wrong userid");
                }
              },
            )
          ],
        ),
        //body: BuildBody(documentSnapshot),
        body :  StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('Product').document(args.data.documentID).snapshots(),
          builder: (context, snapshot) {
            documentSnapshot = snapshot.data;
            if (!snapshot.hasData) return LinearProgressIndicator();
            return BuildBody();
          },
        ),
      ),
    );
  }

  Future _deleteData(BuildContext context) async{
    final DetailArguments args = ModalRoute.of(context).settings.arguments;
    final productRecord = ProductRecord.fromSnapshot(args.data);
    final db = Firestore.instance;
    final storage =  FirebaseStorage().ref().child(productRecord.assetName);
    await db.collection('Product').document(args.data.documentID).delete();
    await storage.delete();
  }

  Future<String> _makeUserID(BuildContext context) async{
    FirebaseUser userId = await FirebaseAuth.instance.currentUser();
    String uid = userId.uid;
    return uid;
  }

}

class BuildBody extends StatefulWidget{
  @override
  BuildBodyState createState(){
    return BuildBodyState();
  }
}

class BuildBodyState extends State<BuildBody>{
  @override
  Widget build(BuildContext context) {
    ProductRecord productRecord = ProductRecord.fromSnapshot(documentSnapshot);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
            aspectRatio: 20 / 11,
            child: FutureBuilder<Widget>(
              future : _getImage(productRecord),
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
            )
        ),
        TitleSection(),
        Divider(height: 1.0, color: Colors.black),
        Expanded(
          child :TextSection(),
        ),
        PlusSection(),
      ],
    );
  }

  Future<Widget> _getImage(ProductRecord productRecord) async {
    final StorageReference storageReference = FirebaseStorage().ref().child(productRecord.assetName);
    final url = await storageReference.getDownloadURL();
    return Image.network(url.toString());
  }
}

class TitleSection extends StatefulWidget{
  @override
  TitleSectionState createState(){
    return TitleSectionState();
  }
}

class TitleSectionState extends State<TitleSection>{
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());
    final productRecord = ProductRecord.fromSnapshot(documentSnapshot);
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: <Widget>[
          Expanded(
            child :Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productRecord.name, style: theme.textTheme.title),
                Text(formatter.format(productRecord.price), style: theme.textTheme.subtitle,),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon : Icon(Icons.thumb_up),
                onPressed:() {
                  _updateThumb(context);
                },
              ),
              Text(productRecord.like.length.toString()),
            ],
          ),
        ],
      ),
    );
  }


  Future<Widget> _updateThumb(BuildContext context) async{
    final db = Firestore.instance;
    final productRecord = ProductRecord.fromSnapshot(documentSnapshot);
    String uid = await _makeUserID(context);

    if(productRecord.like.contains(uid)){
      return _showSnackBar(context, "You can only it once!!");
    }else{
      var list = List<String>();
      list.add(uid);
      db.collection('Product').document(documentSnapshot.documentID).updateData(
          {
            "like": FieldValue.arrayUnion(list)
          });
      return _showSnackBar(context, "I LIKE IT");
    }

  }

  Future<String> _makeUserID(BuildContext context) async{
    FirebaseUser userId = await FirebaseAuth.instance.currentUser();
    String uid = userId.uid;
    return uid;
  }

  Widget _showSnackBar(BuildContext context, String contents){
    final snackBar = SnackBar(content : Text(contents),);
    Scaffold.of(context).showSnackBar(snackBar);
  }

}


class TextSection extends StatefulWidget{
  @override
  TextSectionState createState(){
    return TextSectionState();
  }
}

class TextSectionState extends State<TextSection>{
  Widget build(BuildContext context){
    final productRecord = ProductRecord.fromSnapshot(documentSnapshot);
    return Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        productRecord.detailDescription,
        softWrap: true,
      ),
    );
  }
}

class PlusSection extends StatefulWidget{
  @override
  PlusSectionState createState(){
    return PlusSectionState();
  }
}

class PlusSectionState extends State<PlusSection>{
  Widget build(BuildContext context){
    final productRecord = ProductRecord.fromSnapshot(documentSnapshot);
    var createdDate = new DateTime.fromMicrosecondsSinceEpoch(int.parse(productRecord.createdAt.microsecondsSinceEpoch.toString()));
    var modifiedDate = new DateTime.fromMicrosecondsSinceEpoch(int.parse(productRecord.modifiedAt.microsecondsSinceEpoch.toString()));

    return Container(
      padding : EdgeInsets.all(20),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('creator : ' + productRecord.uid),
          Text('created at : ' + DateFormat('yy.MM.dd hh:mm').format(createdDate)),
          Text('modified at : ' + DateFormat('yy.MM.dd hh:mm').format(modifiedDate)),
        ],
      ),
    );
  }

}
