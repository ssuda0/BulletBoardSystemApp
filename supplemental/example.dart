import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class FirestoreImage extends StatefulWidget {
  final StorageReference reference;
  final Widget fallback;
  final ImageProvider placeholder;

  FirestoreImage(
      {Key key,
        @required this.reference,
        @required this.fallback,
        @required this.placeholder});

  @override
  FirestoreImageState createState() =>
      FirestoreImageState(reference, fallback, placeholder);
}

class FirestoreImageState extends State<FirestoreImage> {
  final Widget fallback;
  final ImageProvider placeholder;

  String _imageUrl;
  bool _loaded = false;

  _setImageData(dynamic url) {
    setState(() {
      _loaded = true;
      _imageUrl = url;
    });
  }

  _setError() {
    setState(() {
      _loaded = false;
    });
  }

  FirestoreImageState(StorageReference reference, this.fallback, this.placeholder) {
    reference.getDownloadURL().then(_setImageData).catchError((err) {
      _setError();
    });
  }

  @override
  Widget build(BuildContext context) => _loaded
      ? FadeInImage(
    image: NetworkImage(_imageUrl),
    placeholder: placeholder,
  )
      : fallback;
}