import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/postNewAd.dart';
import 'package:sale_spot/screens/productPage.dart';
import 'package:sale_spot/services/toast.dart';

class SubCategory extends StatefulWidget {
  final String _documentId;
  final String _categoryName;
  final User _user;
  final String _addPost;
  SubCategory(this._documentId,this._categoryName ,this._user,this._addPost);

  @override
  _SubCategory createState() => _SubCategory(_documentId,_categoryName, _user,_addPost);
}

class _SubCategory extends State<SubCategory> {
  String _documentId;
  String _categoryName;
  String _addPost;
  final User _user;
  _SubCategory(this._documentId,this._categoryName, this._user,this._addPost);

  @override
  Widget build(BuildContext context) {
    List<String>st=<String>[];
    return Scaffold(
        appBar: AppBar(
          title: Text(_categoryName),
        ),
        body:	StreamBuilder(
          stream: Firestore.instance.collection('category').document(_documentId).collection('subCategory').orderBy('name').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
            return new ListView(
              children: snapshot.data.documents.map((document) {
                st.add(document['name']);
//                print(st);
                return Card(
                  elevation: 0.1,
                  child: ListTile(
                    trailing: Icon(Icons.arrow_forward_ios,size: 10.0,),
                    title: new Text(document['name']),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>
                      _addPost=='visitPost'?ProductPage(document['name'], _user):PostNewAd(_categoryName,document['name'],_user)));
                    },

                  ),
                );

              }).toList(),
            );

          },

        )



    );


  }



}