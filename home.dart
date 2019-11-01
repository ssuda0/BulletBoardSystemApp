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

import 'model/products_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


import 'model/product.dart';
import 'product.dart';
import 'detail.dart';


class HomePage extends StatelessWidget {
  // TODO: Add a variable for Category (104)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            semanticLabel: 'menu',
          ),
          onPressed: () {
            print('Menu button');
          },
        ),
        title: Text('SHRINE'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              semanticLabel: 'search',
            ),
            onPressed: () {
              print('Search button');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              semanticLabel: 'filter',
            ),
            onPressed: () {
              print('Filter button');
            },
          ),
        ],
      ),
      body: Center(
        child : _buildBody(context),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Product').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildGridView(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildGridView(context, List<DocumentSnapshot> snapshot){
    print("2");
    print(snapshot);
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16.0),
      childAspectRatio: 8.0 / 9.0,
      children: snapshot.map((data) => _buildGridCard(context, data)).toList(),
      //children: _buildGridCards(context),
    );
  }

  Widget _buildGridCard(BuildContext context, DocumentSnapshot data) {
    print("3");
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());

    final productRecord = ProductRecord.fromSnapshot(data);

    final StorageReference storageReference = FirebaseStorage().ref().child(productRecord.assetName);
    final imageUrl = storageReference.getDownloadURL().toString();


    print(storageReference.getDownloadURL().toString());
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
                  case ConnectionState.none:
                    return Text("Loading...");
                  case ConnectionState.active:
                    return Text("Loading...");
                  case ConnectionState.waiting:
                    return Text("Loading...");
                  case ConnectionState.done:
                      return snapshot.data;
                  default:
                    return Text("Loading...");
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
                              //Navigator.pushNamed(context, DetailScreen.routeName, arguments: DetailArguments(productRecord));
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


//  Future<String> _getImageURL(ProductRecord productRecord) async {
//    print("4");
//    print(productRecord.assetName);
//    final StorageReference storageReference = FirebaseStorage().ref().child(productRecord.assetName);
//    final url = await storageReference.getDownloadURL();
//    return url.toString();
//  }

  Future<Widget> _getImage(ProductRecord productRecord) async {
    final StorageReference storageReference = FirebaseStorage().ref().child(productRecord.assetName);
    final url = await storageReference.getDownloadURL();
    return Image.network(url.toString());
  }
}