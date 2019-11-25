import 'package:Shrine/product.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'product.dart';

String productName= " ";
int price = 0;
String description = " ";
File _image;
int maxID = 0;

final _productNameController = TextEditingController();
final _priceController = TextEditingController();
final _descriptionController = TextEditingController();

class AddScreenArguments{
  int maxId;
  AddScreenArguments(this.maxId);
}

class AddScreen extends StatefulWidget{
  static const routeName = '/addScreen';
  @override
  AddScreenState createState(){
    return AddScreenState();
  }
}

class AddScreenState extends State<AddScreen>{
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add',
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text("Cancel",style:TextStyle(color:Colors.white)),
                onPressed: () {
                  _clearControllers();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child:Center(
                  child : Text('Add'),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
                child : Text(
                  "Save",
                  style:TextStyle(color:Colors.white),
                ),
                onPressed:() async{
                  _setValue();
                  _clearControllers();
                  await _makeDocument(context);
                }
            ),
          ],
        ),
        body: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 20 / 11,
              child: _image == null? Image.network('http://handong.edu/site/handong/res/img/logo.png') : Image.file(_image),
            ),
            Container(
                alignment: Alignment.topRight,
                child : IconButton(
                  icon : Icon(Icons.camera_alt),
                  onPressed:() {
                    chooseImage();
                  },
                )
            ),
            Flexible(
              child : MakeTextFieldList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeDocument(BuildContext context) async{
    final AddScreenArguments args = ModalRoute.of(context).settings.arguments;

    maxID = args.maxId +1;

    await Firestore.instance.collection('Product').add(
        {
          'category' : "accessories",
          'isFeatured' : true,
          'id' : maxID,
          'name' : productName,
          'price' : price,
          'detailDescription' : description,
          'uid' : await _makeUserID(context),
          'createdAt' : FieldValue.serverTimestamp(),
          'modifiedAt' : FieldValue.serverTimestamp(),
          'like' : [],
        });

    if(_image!=null){
      await uploadImage(context);
    }else {

    }

    Navigator.of(context).pop();
  }

  Future uploadImage(BuildContext context) async{
    StorageReference storageReference = FirebaseStorage.instance.ref().child('${maxID}-0.jpg');
    StorageUploadTask  uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    _image = null;
    print('File Uploaded');
  }

  Future chooseImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<String> _makeUserID(BuildContext context) async{
    FirebaseUser userId = await FirebaseAuth.instance.currentUser();
    String uid = userId.uid;
    print(uid);
    return uid;
  }

  _setValue(){
    productName = _productNameController.text.toString();
    price = int.parse(_priceController.text.toString());
    description = _descriptionController.text.toString();
  }
  _clearControllers(){
    _productNameController.clear();
    _priceController.clear();
    _descriptionController.clear();
  }

}

class MakeTextFieldList extends StatefulWidget{
  @override
  MakeTextFieldListState createState(){
    return MakeTextFieldListState();
  }
}

class MakeTextFieldListState extends State<MakeTextFieldList>{
  Widget build(BuildContext context){
    return ListView(
      children: <Widget>[
        _makeTextField(context,'Product Name',false ,_productNameController, TextInputType.text, productName),
        _makeTextField(context,'Price', false, _priceController,TextInputType.number, price),
        _makeTextField(context,'Description', false, _descriptionController,TextInputType.text, description),
      ],
    );
  }

  TextFormField _makeTextField(BuildContext context, String label, bool flag, TextEditingController controllers, keyboardTypeThis, globalValue) {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter ' + label;
        }
        return null;
      },
      keyboardType: keyboardTypeThis,
      controller: controllers,
      obscureText: flag,
      decoration: InputDecoration(
        filled: false,
        labelText: label,
      ),
    );
  }
}