
class User {
	String _name;
	String _email;
	String _mobile;
	String _address;
	int _blockedNo;
	String _photoUrl;
	String _documentId;

	User();

	String get photoUrl => _photoUrl;

	set photoUrl(String value) {
		_photoUrl = value;
	}

	String get documentId => _documentId;

	set documentId(String value) {
		_documentId = value;
	}

	int get blockedNo => _blockedNo;

	set blockedNo(int value) {
		_blockedNo = value;
	}

	String get address => _address;

	set address(String value) {
		_address = value;
	}

	String get mobile => _mobile;

	set mobile(String value) {
		_mobile = value;
	}

	String get email => _email;

	set email(String value) {
		_email = value;
	}

	String get name => _name;

	set name(String value) {
		_name = value;
	}

	Map<String, dynamic> toMap() {
		var map = Map<String, dynamic>();
		map['name'] = _name;
		map['email'] = _email;
		map['mobile'] = _mobile;
		map['address'] = _address;
		map['blockedNo'] = _blockedNo;
		return map;
	}

	User.fromMapObject(Map<String, dynamic> map) {
		this._name = map['name'];
		this._email = map['email'];
		this._mobile = map['mobile'];
		this._address = map['address'];
		this._blockedNo = map['blockedNo'];
	}
}