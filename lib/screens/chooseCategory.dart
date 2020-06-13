import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
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
//    return Scaffold(
//
////      appBar: AppBar(
////        title: Text('Choose Category'),
////        titleSpacing: 2.0,
////        elevation: 0.0,
////      ),
//      body:	Container(
//          height:screenHeight(context),
//          width:screenWidth(context),
//          color: Colors.white,
//          child:CustomScrollView(
//              slivers:<Widget>[
//                SliverAppBar(
//                  expandedHeight: 200.0,
//                  floating: true,
//                  pinned: true,
//                  flexibleSpace: FlexibleSpaceBar(
//                      centerTitle: true,
//                      title: Text("Choose Category",
//                          style: TextStyle(
//                            color: Colors.white,
//                            fontSize: 16.0,
//                          )),
//                      background: Image.network(
//                        "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
//                        fit: BoxFit.cover,
//                      )),
//                ),
//                buildHeader('Categories'),
//                _categoryData(context),
//
//
//              ]
//          )
//      ),
//
//
//    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: screenHeight(context)/2.5,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text("Choose Category",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Image.network(
                    "https://cdn1.coutloot.com/homeImages/1581417591820.png",
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
           body:	Container(
              height:screenHeight(context),
              width:screenWidth(context),
               padding: EdgeInsets.only(top:20.0),
               decoration: BoxDecoration(
                   borderRadius: BorderRadius.only(topRight:  Radius.circular(20),topLeft: Radius.circular(20)),
                  color: Colors.white,
               ),
              
              child:CustomScrollView(
                  slivers:<Widget>[
//                    buildHeader('Categories'),
                    SliverToBoxAdapter(
                      child: Center(
                        child:Text("Sell Online in 30 seconds!",style: TextStyle(fontSize: 18,color: Colors.black87.withOpacity(0.7),fontWeight: FontWeight.w500),),

                      ),
                    ),
                    _categoryData(context),


                  ]
              )
        ),
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:3,
          ),
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
                    child: shimmerCategory(context,screenHeight(context)/15,screenWidth(context)/4),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: screenHeight(context)/15,
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
//        margin: EdgeInsets.all(5),
//        padding: EdgeInsets.all(15),
//        decoration: BoxDecoration(
//          color: Colors.white,
//          borderRadius: BorderRadius.all(
//              Radius.circular(10.0) //                 <--- border radius here
//          ),
//        ),
//
//        child: Text(text,style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),),
      )]
      ),
    );

  }








}
