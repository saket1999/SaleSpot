import 'package:sale_spot/screens/subCategory.dart';

class CategoryItem{
  String _name;
  String _imageUrl;
  String _documentId;

  CategoryItem();

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get imageUrl => _imageUrl;

  set imageUrl(String value) {
    _imageUrl = value;
  }

  String get documentId => _documentId;

  set documentId(String value) {
    _documentId = value;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['name'] = _name;
    map['imageUrl'] = _imageUrl;
    map['documentId'] = _documentId;
    return map;
  }

  CategoryItem.fromMapObject(Map<String, dynamic> map) {
    this._name = map['name'];
    this._imageUrl = map['imageUrl'];
    this._documentId = map['documentId'];
  }


}