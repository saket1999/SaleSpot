import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/product_detail.dart';
import 'package:sale_spot/services/toast.dart';

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
        title: Text('My Products'),
      ),
      body: getProductsList()
//      Container(
//        height:screenHeight(context),
//        width:screenWidth(context),
//          child:CustomScrollView(
//              slivers:<Widget>[
//                _myProductList,
//              ]
//          )
//      ),
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
        if(itemCount==0)
          return Center(child: Icon(Icons.cloud_done),);
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
                    return Container();
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
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(5.0),
              width:screenWidth(context)/3,
              child: networkImage(currUrl, screenWidth(context)/3),
//              child: Image.network(currUrl,height: screenWidth(context)/3,)
          ),
          Expanded(
            child: GestureDetector(
              onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(ds.productId.toString(), _user)));},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: autoSizeText(ds.title, 2, 20.0, Colors.black87)
//                      child: Text(ds.title,style: TextStyle(fontSize: 20.0, color: Colors.black87)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: autoSizeText(rupee()+ds.salePrice, 1, 20.0, Colors.black87)
//                      child: Text(rupee()+ds.salePrice,style: TextStyle(fontSize: 20.0, color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          soldFlag?Container():Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap:(){    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EditProduct(_user,ds.productId.toString())));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(Icons.edit),
                  ),
                ),
                GestureDetector(
                  onTap: (){return deleteDialog(context,ds);},
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(Icons.delete),
                  ),
                ),
                GestureDetector(
                  onTap:(){return soldDialog(context,ds);},
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(Icons.check),
                  ),
                ),
              ],
            )
          )
        ],
      ),
    );
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
    Firestore.instance.collection('product').document(ds.productId).updateData({'soldFlag':'Sold'});
  }



}

