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
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'product.dart';
import 'add.dart';
import 'mypage.dart';
import 'detail.dart';

class HomePage extends StatefulWidget{
  static const routeName = '/homeScreen';
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // TODO: Add a variable for Category (104)
  int maxId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.account_circle,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.pushNamed(context, MyPageScreen.routeName);
            },
        ),
        title: Center(child : Text('SHRINE')),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: () {
              Navigator.pushNamed(context, AddScreen.routeName, arguments : AddScreenArguments(maxId));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Center(
            child : _buildDropdownButton(context),
          ),
          Expanded(
            child : _buildBody(context),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  String dropdownValue = 'ASC';


  Widget _buildDropdownButton(BuildContext context){
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
          color: Colors.deepPurple
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['ASC', 'DESC'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: dropdownValue=='DESC'?  Firestore.instance.collection('Product').orderBy('price', descending: true).snapshots()
          : Firestore.instance.collection('Product').orderBy('price').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildGridView(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildGridView(context, List<DocumentSnapshot> snapshot){
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16.0),
      childAspectRatio: 8.0 / 9.0,
      children: snapshot.map((data) => _buildGridCard(context, data)).toList(),
      //children: _buildGridCards(context),
    );
  }

  Widget _buildGridCard(BuildContext context, DocumentSnapshot data) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());

    final productRecord = ProductRecord.fromSnapshot(data);

    if(maxId < productRecord.id){
      maxId = productRecord.id;
    }

    return Card (
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
              aspectRatio: 18 / 11,
            child: FutureBuilder<Widget>(
              future : _getImage(productRecord),
              // ignore: missing_return
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      productRecord.name,
                      style: TextStyle(
                        fontSize: 15,
                      )
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    formatter.format(productRecord.price),
                    style: theme.textTheme.body2,
                  ),
                  Expanded(
                    child : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                            child : Text("more", style:TextStyle(color:Colors.blue)),
                            onPressed:(){
                              Navigator.pushNamed(context, DetailScreen.routeName, arguments: DetailArguments(data));
                            }
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<Widget> _getImage(ProductRecord productRecord) async {
    final StorageReference storageReference = FirebaseStorage().ref().child(productRecord.assetName);
    final url = await storageReference.getDownloadURL();
    return Image.network(url.toString());
  }
}
