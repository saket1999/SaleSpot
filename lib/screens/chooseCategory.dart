import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/postNewAd.dart';
import 'package:sale_spot/screens/subCategory.dart';
import 'package:sale_spot/services/shimmerLayout.dart';
import 'package:sale_spot/services/toast.dart';

class ChooseCategory extends StatefulWidget {
  final User _user;

  ChooseCategory(this._user);

  @override
  _ChooseCategoryState createState() => _ChooseCategoryState(_user);
}

class _ChooseCategoryState extends State<ChooseCategory> {
  final User _user;
  _ChooseCategoryState(this._user);
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Choose Category'),
        titleSpacing: 2.0,
        elevation: 0.0,
      ),
      body:	Container(
          height:screenHeight(context),
          width:screenWidth(context),
          color: Colors.white,
          child:CustomScrollView(
              slivers:<Widget>[

                buildHeader('Categories'),
                _categoryData(context),

              ]
          )
      ),


    );
  }
  Widget _categoryData(BuildContext context){

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('category').snapshots(),
      builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
        //print(snapshot.data);
        if(!snapshot.hasData) {
          return SliverList(
              delegate:SliverChildBuilderDelegate(( BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                  ],
                );
              },
                childCount:1,
              )
          );
        }

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3),
          delegate: SliverChildBuilderDelegate((BuildContext context, int index){
            DocumentSnapshot ds = snapshot.data.documents[index];
            //print(ds['iconId']);
            return FutureBuilder<dynamic> (
              future: FirebaseStorage.instance.ref().child('categoryIcon').child(ds['name']+'.png').getDownloadURL(),
              builder: (BuildContext context,AsyncSnapshot<dynamic> asyncSnapshot) {
                String iconUrl=asyncSnapshot.data.toString();
                //print(iconUrl+"*");
                if(iconUrl=='null')
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: shimmerCategory(context,screenWidth(context)/5,screenWidth(context)/4),
                  );
                return Card(
										elevation: 0.0,
                  child:headerCategoryItem(ds['name'],iconUrl, snapshot.data.documents[index].documentID.toString()),

                );
              },
            );
          },
            childCount: snapshot.hasData ? snapshot.data.documents.length : 0,
          ),
        );
      },
    );

  }

  Widget headerCategoryItem(String name,String iconUrl,String documentId) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>SubCategory(documentId,name, _user,"addNewPost")));
        },
        child: Container(
          //color: Colors.lightBlueAccent,
          decoration: BoxDecoration(
//						color: Colors.white,
            border: Border.all(color: Colors.grey[200],width: 1.0),
            borderRadius: BorderRadius.all(
                Radius.circular(5.0) //                 <--- border radius here
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: screenWidth(context)/5,
                child:Container(
//																	color:Colors.blueGrey,
                  child: networkImageWithoutHeightConstraint(iconUrl),
                ),

              ),
              SizedBox(
                height: screenWidth(context)/10,
                child:autoSizeText(name),
              ),
//							networkImageWithoutHeightConstraint(iconUrl),
//							SizedBox(
//								height: 10,
//							),
//							autoSizeText(name)
            ],
          ),
        )

    );
  }
  Widget buildHeader(String text){
    return SliverList(
      delegate: SliverChildListDelegate([Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
              Radius.circular(10.0) //                 <--- border radius here
          ),
        ),

        child: Text(text,style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),),
      )]
      ),
    );

  }








}
