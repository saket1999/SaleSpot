
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  User _user;
  EditProfile(this._user);
  @override
  _EditProfileState createState() => _EditProfileState(_user);
}

class _EditProfileState extends State<EditProfile>{

  User _user;
  _EditProfileState(this._user);
  final _formKey = GlobalKey<FormState>();

  bool _isLoading=false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //height:screenHeight(context);
    return WillPopScope(
      onWillPop:(){
        Navigator.pop(context,_user);
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Color(int.parse('0xff0288D1')),
        body:SafeArea(
          child: Stack(
            children: <Widget>[
              //                  Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Padding(
//                        padding: EdgeInsets.fromLTRB(0,screenHeight(context)/6,0,0),
//                        child: CircleAvatar(
//                          radius:screenHeight(context)/10 ,
//                          backgroundImage: NetworkImage(_user.photoUrl),
//                        ),
//                      ),
//                      Text(_user.name,
//                        style: TextStyle(
//                          fontSize: 30.0,
//                          color: Colors.white,
//                          fontWeight: FontWeight.bold,
//                        ),
//                      ),
//                      SizedBox(
//                        height: 20,
//                        width: screenWidth(context)/2,
//                        child:Divider(
//                          color: Colors.white,
//                        ),
//
//                      ),
//                      Container(
//
//                        decoration: BoxDecoration(
//                          color: Colors.white,
//                          borderRadius: BorderRadius.all(
//                            Radius.circular(5.0),
//
//                          ),
//                        ),
//                        padding: EdgeInsets.all(10.0),
//                        margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
//                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          children: <Widget>[
//                            Icon(Icons.phone),
//                            Padding(
//                              padding: const EdgeInsets.all(5.0),
//                              child: Text(_user.mobile,
//                                style:TextStyle(
//                                  fontSize: 20.0,
//                                ),),
//                            ),
//
//                          ],
//                        ),
//
//                      ),
//                      Container(
//                        decoration: BoxDecoration(
//                          color: Colors.white,
//                          borderRadius: BorderRadius.all(
//                            Radius.circular(5.0),
//
//                          ),
//                        ),
//                        padding: EdgeInsets.all(10.0),
//                        margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
//                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          children: <Widget>[
//                            Icon(Icons.email),
//                            Padding(
//                              padding: const EdgeInsets.all(5.0),
//                              child: Text(_user.email,
//                                style:TextStyle(
//                                  fontSize: 20.0,
//                                ),),
//                            ),
//                          ],
//                        ),
//
//                      ),
//                      Container(
//                        decoration: BoxDecoration(
//                          color: Colors.white,
//                          borderRadius: BorderRadius.all(
//                            Radius.circular(5.0),
//
//                          ),
//                        ),
//                        padding: EdgeInsets.all(10.0),
//                        margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
//                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          children: <Widget>[
//                            Icon(Icons.location_on),
//                            Padding(
//                              padding: const EdgeInsets.all(5.0),
//                              child: Text(_user.address,
//                                style:TextStyle(
//                                  fontSize: 20.0,
//                                ),),
//                            ),
//                          ],
//                        ),
//
//                      ),
//                      RaisedButton(
//                        shape: new RoundedRectangleBorder(
//                            borderRadius: new BorderRadius.circular(18.0),
//                            side: BorderSide(color: Colors.black)),
//                        color: Colors.white,
////                        textColor: Colors.black,
//                        child:Text("Update Details"),
//                        onPressed: (){_showDialog();},
//                      ),
//                    ],
//                  ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: Container(
                          margin: EdgeInsets.all(20),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            backgroundImage:NetworkImage(_user.photoUrl),
                            radius: screenWidth(context)/5,
                          ))),
                  ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Name',style: TextStyle(color: Colors.white),),
                      subtitle: Text(_user.name,style: TextStyle(color: Colors.white70))),
                  ListTile(
                      leading: Icon(Icons.phone_iphone),
                      title: Text('Mobile',style: TextStyle(color: Colors.white)),
                      subtitle: Text(_user.mobile,style: TextStyle(color: Colors.white70))),
                  ListTile(
                      leading: Icon(Icons.alternate_email),
                      title: Text('Email',style: TextStyle(color: Colors.white)),
                      subtitle: Text(_user.email,style: TextStyle(color: Colors.white70))),
                  ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Address',style: TextStyle(color: Colors.white)),
                      subtitle: Text(_user.address,style: TextStyle(color: Colors.white70))),
                  RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)),
                        color: Colors.white,
//                        textColor: Colors.black,
                        child:Text("Update Details"),
                        onPressed: (){_showDialog();},
                      ),
                ],
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Colors.white70,
                        size:30
                    ),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context,_user);
                      });
                    },
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }


  _showDialog() async {
    String _newPhoneNo=_user.mobile;
    String _newAddress=_user.address;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(  // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child:Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      onSaved: (value){
                        _newPhoneNo=value;
                      },
                      initialValue: _user.mobile,
                      validator: (value){
                        if(value.length!=10)
                          return 'Enter valid Phone no.';
                        else
                          return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Phone No.',
                          errorStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      ),
                    ),
                    SizedBox(
                      height:10 ,
                    ),
                    TextFormField(
                      onSaved: (value){
                        _newAddress=value;
                      },
                      initialValue: _user.address,
                      validator: (value){
                        if(value.length==0)
                          return 'Enter valid Address';
                        else
                          return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Hostel Address',
                          errorStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      ),
                    ),

                    _isLoading?Container():FlatButton(
                        child: const Text('UPDATE'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            setState(() {
                              _isLoading=true;
                            });

                            _updateDetails(_newPhoneNo,_newAddress);
                            toast('In Process');
                          }


                        }),
                    _isLoading?Padding(
                        padding:EdgeInsets.all(10.0),
                        child:CircularProgressIndicator()
                    ):FlatButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),


                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future _updateDetails(String _newPhoneNo,String _newAddress) async{

    await Firestore.instance.collection('user').document(_user.documentId).updateData({'mobile':_newPhoneNo,'address':_newAddress});
    _user.mobile=_newPhoneNo;
    _user.address=_newAddress;
    setState(() {
      _isLoading=false;
    });
    storeSharedPreferences();
    toast('Update Done');
    Navigator.pop(context);
  }

  void storeSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('storedObject', json.encode(_user.toMap()));
    prefs.setString('storedId', _user.documentId);
    prefs.setString('storePhoto', _user.photoUrl);
  }



}