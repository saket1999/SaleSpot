import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/product_detail.dart';
import 'package:sale_spot/services/shimmerLayout.dart';
import 'package:sale_spot/services/toast.dart';

import 'chooseCategory.dart';
import 'editProduct.dart';

class myProductList extends StatefulWidget {
  final User _user;
  myProductList(this._user);
  @override
  _MyProductListState createState() => _MyProductListState(_user);
}

class _MyProductListState extends State<myProductList>{
  final User _user;
  _MyProductListState(this._user);

//  Widget _myProductList=SliverToBoxAdapter( child: Container());

  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Products',),
      ),
      body: getProductsList()

    );
  }

  getProductsList(){
    return StreamBuilder(
      stream: Firestore.instance.collection('user').document(_user.documentId).collection("myProduct").snapshots(),
      builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> querySnapshots){
        if(!querySnapshots.hasData)
          return Center(child: Icon(Icons.cloud_queue));
        int itemCount=querySnapshots.data.documents.length;
//        print('Products count is: '+itemCount.toString());
//        if(itemCount==0)
//          return Center(child: Icon(Icons.cloud_done),);
          if(itemCount==0)
            {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/empty-cart1.png',width: screenWidth(context)/1.2,),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('You haven`t posted anything yet',style: TextStyle(color: Colors.grey),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: MaterialButton(
                        padding: EdgeInsets.all(18.0),
                          child: Text('Post Your Ad'),
                          color: Colors.redAccent[200],
                          textColor: Colors.white,
                          splashColor: Colors.white,
                          height: 40,
                          minWidth: 150,
                          elevation: 4,
//                      highlightElevation: 2,
                          onPressed:(){
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ChooseCategory(_user)));
                          },

                      ),
                    )
                  ],
                ),
              );
            }
        return ListView.builder(itemCount: itemCount,itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot documentSnapshot=querySnapshots.data.documents[index];
//          print(documentSnapshot.data);
//          print('DocId: '+documentSnapshot.documentID.toString());
//          print(querySnapshots.data.);
          return StreamBuilder(
            stream: Firestore.instance.collection('product').document(documentSnapshot['productId']).snapshots(),
            builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> documentSnapshot){
              if(!documentSnapshot.hasData)
                  return Container();
//              print(documentSnapshot.data.data);
              Product product=Product.fromMapObject(documentSnapshot.data.data);
              product.productId=documentSnapshot.data.documentID;

              return FutureBuilder(
                future: FirebaseStorage.instance.ref().child(product.productId.toString()+'1').getDownloadURL(),
                builder: (BuildContext context,AsyncSnapshot<dynamic> downloadUrl){
                  if(!downloadUrl.hasData)
//                    return Center(child:CircularProgressIndicator() );
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: shimmerItemHorizontal(context,screenWidth(context)/3,screenWidth(context)),
                    );
//                  print('Download url is: '+downloadUrl.data.toString());
                  String productImageUrl=downloadUrl.data.toString();
                  bool soldFlag=product.soldFlag=='1';
                  if(soldFlag)
                    return Banner(
                      message: 'Sold',
                      location: BannerLocation.topEnd,
                      color: Colors.green,
                      child: listProduct(productImageUrl, product,soldFlag),
                    );
                  return listProduct(productImageUrl, product,soldFlag);
                },
              );
          },
          );
        });
      },
    );
  }

  listProduct(String currUrl,Product ds,bool soldFlag){

    bool renewFlag=Timestamp.now().toDate().difference(DateTime.parse(ds.date)).inDays>=25;
    return Card(
      elevation: 0.1,
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.15,
        closeOnScroll: true,
        secondaryActions: soldFlag==false?<Widget>[
          IconSlideAction(
              caption: 'Edit',
              color: Colors.grey[300]	,
              icon: Icons.edit,
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EditProduct(_user, ds)));
              }
          ),
          IconSlideAction(
              caption: 'Delete',
              color: Colors.red[400]	,
              icon: Icons.delete,
              onTap: (){
                return deleteDialog(context,ds);
              }
          ),
          IconSlideAction(
              caption: 'Sold',
              color: Colors.green[400]	,
              icon: Icons.check,
              onTap: (){
                return soldDialog(context,ds);
              }
          ),

        ]:
        <Widget>[
          IconSlideAction(
              caption: 'Sold',
              color: Colors.green[400]	,
              icon: Icons.check,
              onTap: (){
                toast('Sold product cannot be modified');
//              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Your Product is Sold')));
              }
          ),
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
//          Container(
//              padding:EdgeInsets.all(8.0),
//              width:screenWidth(context)/3,
//              child: networkImage(currUrl, screenWidth(context)/3),
////              child: Image.network(currUrl,height: screenWidth(context)/3,)
//          ),
            GestureDetector(
              onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(ds.productId.toString(), _user)));},
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: networkImage(currUrl,screenWidth(context)/3),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(ds.productId.toString(), _user)));},
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom:4.0),
                        child: autoSizeText(ds.title, 3, 18.0, Colors.black87)
//                      child: Text(ds.title,style: TextStyle(fontSize: 20.0, color: Colors.black87)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom:4.0),
                        child: autoSizeText(rupee()+ds.salePrice, 1, 20.0, Colors.black87)
//                      child: Text(rupee()+ds.salePrice,style: TextStyle(fontSize: 20.0, color: Colors.black87)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back_ios,size:15.0,color: Colors.grey,),
                ),
              ],
            )
//            soldFlag?Container():(renewFlag?
//      Padding(
//        padding: const EdgeInsets.all(8.0),
//        child: RaisedButton(
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(18.0),
//            side: BorderSide(color: Colors.amberAccent,width: 2.0)
//          ),
//          color: Colors.white,
//          textColor: Colors.white,
//          child:Row(
//            children: <Widget>[
//              Text('Renew',style: TextStyle(color: Colors.amberAccent),),
//              Icon(Icons.check,color: Colors.amberAccent,),
//            ],
//          ),
//          onPressed: (){renewProduct(ds);},
//        ),
//      ):
//            Expanded(
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  crossAxisAlignment: CrossAxisAlignment.end,
//                  children: <Widget>[
//                    GestureDetector(
//                      onTap:(){    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EditProduct(_user, ds)));
//                      },
//                      child: Padding(
//                        padding: const EdgeInsets.all(10.0),
//                        child: Icon(Icons.edit),
//                      ),
//                    ),
//                    GestureDetector(
//                      onTap: (){return deleteDialog(context,ds);},
//                      child: Padding(
//                        padding: const EdgeInsets.all(10.0),
//                        child: Icon(Icons.delete),
//                      ),
//                    ),
//                    GestureDetector(
//                      onTap:(){return soldDialog(context,ds);},
//                      child: Padding(
//                        padding: const EdgeInsets.all(10.0),
//                        child: Icon(Icons.check),
//                      ),
//                    ),
//                  ],
//                )
//            ))
          ],
        ),
      ),
    );
  }

  renewProduct(Product product){
    Firestore.instance.collection('product').document(product.productId).updateData({'date':Timestamp.now().toDate().toString()});

  }
  deleteDialog(BuildContext context,Product product) async {
    return showDialog<void>(
      context: context,
//      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete '+product.title+'?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                deleteProduct(product);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  }

  soldDialog(BuildContext context,Product product) async {
    return showDialog<void>(
      context: context,
//      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark '+product.title+' as sold?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                soldProduct(product);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  }

  void deleteProduct(Product product) async {
    Firestore.instance.collection('toBeDeleted').add({'productId':product.productId});
    //TODO implement cloud function for deletion
  }

  void soldProduct(Product ds) async {
    Firestore.instance.collection('product').document(ds.productId).updateData({'soldFlag':'1'});
  }



}

