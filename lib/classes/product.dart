class Product{
  String _title;
  String _salePrice;
  String _originalPrice;
  String _details;
  String _soldFlag;
  String _waitingFlag;
  String _sellerId;
  String _date;
  String _imageCount;
  String _productId;
  int _priority;



  List<String> _tag;
  List<String> _partName;
  List<String> _partValue;

  int get priority => _priority;

  set priority(int value) {
    _priority = value;
  }


  String get productId => _productId;

  set productId(String value) {
    _productId = value;
  }


  Product();

  String get imageCount => _imageCount;

  set imageCount(String value) {
    _imageCount = value;
  }


  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get salePrice => _salePrice;

  List<String> get partValue => _partValue;

  set partValue(List<String> value) {
    _partValue = value;
  }

  List<String> get partName => _partName;

  set partName(List<String> value) {
    _partName = value;
  }

  List<String> get tag => _tag;

  set tag(List<String> value) {
    _tag = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get sellerId => _sellerId;

  set sellerId(String value) {
    _sellerId = value;
  }

  String get waitingFlag => _waitingFlag;

  set waitingFlag(String value) {
    _waitingFlag = value;
  }

  String get soldFlag => _soldFlag;

  set soldFlag(String value) {
    _soldFlag = value;
  }

  String get details => _details;

  set details(String value) {
    _details = value;
  }

  String get originalPrice => _originalPrice;

  set originalPrice(String value) {
    _originalPrice = value;
  }

  set salePrice(String value) {
    _salePrice = value;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['title'] = _title;
    map['salePrice'] = _salePrice;
    map['originalPrice'] = _originalPrice;
    map['details'] = _details;
    map['sellerId'] = _sellerId;
    map['soldFlag'] = _soldFlag;
    map['waitingFlag'] = _waitingFlag;
    map['date'] = _date;
    map['imageCount'] = _imageCount;
    map['tag'] = _tag;
    map['partName'] = _partName;
    map['partValue'] = _partValue;
    map['priority']=_priority;
    return map;
  }

  Product.fromMapObject(Map<String, dynamic> map) {
    this._title=map['title'];
    this._salePrice=int.parse(map['salePrice']).toString();
    this._originalPrice=map['originalPrice'];
    this._details=map['details'];
    this._sellerId=map['sellerId'];
    this._soldFlag=map['soldFlag'];
    this._waitingFlag=map['waitingFlag'];
    this._date=map['date'];
    this._imageCount=map['imageCount'];
    if(map.containsKey('priority')) {
      this._priority = int.parse(map['priority'].toString());
    }
    this._tag=map['tag'].map<String>((value){return value.toString();}).toList();
    this._partName=map['partName'].map<String>((value){return value.toString();}).toList();
    this._partValue=map['partValue'].map<String>((value){return value.toString();}).toList();
  }

}

