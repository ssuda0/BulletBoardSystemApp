import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRecord{
  final int id;
  final bool isFeatured;
  final String detailDescription;
  final String name;
  final int price;
  final Timestamp createdAt;
  final Timestamp modifiedAt;
  final String uid;
  final DocumentReference reference;
  final List like;

  ProductRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['id'] != null), //make sure the variable has a non-null value.
        assert(map['isFeatured']!=null),
        assert(map['name']!=null),
        assert(map['price']!=null),
        assert(map['detailDescription']!=null),
        assert(map['createdAt']!=null),
        assert(map['modifiedAt']!=null),
        assert(map['uid']!=null),
        assert(map['like']!=null),
        id = map['id'],
        isFeatured = map['isFeatured'],
        name = map['name'],
        price = map['price'],
        detailDescription=map['detailDescription'],
        createdAt = map['createdAt'],
        modifiedAt = map['modifiedAt'],
        uid = map['uid'],
        like = map['like'];

  ProductRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference : snapshot.reference);

  String toString() => "Record<$name:$price>";

  String get assetName => '$id-0.jpg';
  String get assetPackage => 'shrine_images';
}