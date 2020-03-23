
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/product_detail.dart';
import 'package:sale_spot/services/toast.dart';

class ProductPage extends StatefulWidget{
  String _categoryName;
  final User _user;
  ProductPage(this._categoryName, this._user);
  _ProductPage createState() => _ProductPage(_categoryName, _user);


}
class _ProductPage extends State<ProductPage>{
  String _categoryName;
  String _groupValue = "date";
  final User _user;
  static final _key = new GlobalKey();
  _ProductPage(this._categoryName, this._user);
  Widget _productListView=SliverToBoxAdapter( child: Container());
  void initState() {
    super.initState();
   // getProductData('date');
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(_categoryName),
      ),
        body:	Container(
            height:screenHeight(context),
            width:screenWidth(context),

            child:CustomScrollView(
                slivers:<Widget>[ //Sliver List needs first widget Sliver type
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(),
                  ]
                ),
                ),
                  _productList(_groupValue),
                ]
            )
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _sortDialog();

        },
        child: Icon(Icons.sort),
        backgroundColor: Colors.blue,
      ),
    );
  }



    _sortDialog(){
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter state) {
              return Container(
                child: new Wrap(
                  children: <Widget>[
                    Padding(
                      padding:EdgeInsets.symmetric(vertical:15.0),
                      child: Center(
                        child: Text('Sort By',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.black45,
                          letterSpacing: 1.0,
                        ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                      child:Divider(
                        color: Colors.black54,
                      ),

                    ),
                    RadioListTile(
                      value: 'date',
                      groupValue: _groupValue,
                      onChanged: (newValue) =>
                          state(() {
                            _groupValue = newValue;
                            setState(() {

                            });
                            Navigator.pop(context);
                          }),
                      title: Text("Latest Added"),
                      activeColor: Colors.red,
                      selected: false,
                    ),
                    RadioListTile(
                      value: 'salePrice',
                      groupValue: _groupValue,
                      onChanged: (newValue) =>
                          state(() {
                            _groupValue = newValue;
                            setState(() {

                            });
                            Navigator.pop(context);
                          }),
                      title: Text("Price"),
                      activeColor: Colors.red,
                      selected: false,
                    )

                  ],
                ),
              );
            }
            );
          }
          );
    }

//  getProductData(String sortBy) async {
//    QuerySnapshot snapshot=await Firestore.instance.collection('product').where("tag",arrayContains: _categoryName).orderBy(sortBy).limit(20).getDocuments();
//    List<String> urls=<String>[];
//    for(int i=0;i<snapshot.documents.length;i++) {
//      var s=await FirebaseStorage.instance.ref().child(snapshot.documents[i].documentID+"1").getDownloadURL();
//      if(s!=null) {
//        urls.add(s.toString());
//       // print(s.toString());
//      }
//    }
//    print(sortBy+"qwerty");
//    _productListView=SliverGrid (
//      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2 ),
//      delegate: SliverChildBuilderDelegate((BuildContext context, int index){
//
//
//        DocumentSnapshot ds = snapshot.documents[index];
//        String currUrl=urls[index];
//        print(ds['salePrice']);
//        return InkWell(
//          onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(snapshot.documents[index].documentID.toString(), _user))); },
//          child:new Card(
//              child:Column(
//                children: <Widget>[
//                  Image.network(currUrl,height:screenHeight(context)/5),
//                  Padding(
//                    padding: const EdgeInsets.only(left:20.0,right: 20.0,top:10),
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                      children: <Widget>[
//                        Text(ds['title'],
//                          textAlign: TextAlign.left,
//                          style: TextStyle(fontWeight: FontWeight.bold,
//                              fontSize: 18),
//                            ),
//                        Text("₹"+ds['salePrice'],
//                          style: TextStyle(
//                              color: Colors.grey[800],
//                              fontWeight: FontWeight.w900,
//                              fontStyle: FontStyle.italic,
//                              fontFamily: 'Open Sans',
//                              fontSize: 18),
//                        ),
//                      ],
//                    ),
//                  )
//                  //Text(ds['salePrice'])
//                ],
//              )
//          ),
//        );
//      },
//        childCount: snapshot.documents.length,
//      ),
//    );
//
//    setState(() {
//
//    });
//  }

  _productList(String sortBy){
    return StreamBuilder(
        stream:Firestore.instance.collection('product').where('soldFlag',isEqualTo: '0').where('waitingFlag',isEqualTo: '0').where("tag",arrayContains: _categoryName).orderBy(sortBy).snapshots(),
        builder:(BuildContext context,AsyncSnapshot<QuerySnapshot> querySnapshots){

          if(!querySnapshots.hasData)
            return SliverList(
                delegate:SliverChildBuilderDelegate(( BuildContext context, int index) {
                  return Center(
                    child: Icon(Icons.cloud_done)
                  );
                },
                  childCount:1,
                )
            );
//          if(querySnapshots.data.documents.length==0)
//            return Center(child: CircularProgressIndicator());
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2 ,childAspectRatio: 0.8,crossAxisSpacing: 1.0,mainAxisSpacing: 1.0),
            delegate: SliverChildBuilderDelegate((BuildContext context, int index){
              DocumentSnapshot documentSnapshot=querySnapshots.data.documents[index];
              Product product=Product.fromMapObject(documentSnapshot.data);
              product.productId=documentSnapshot.documentID;
              return FutureBuilder(
                  future: FirebaseStorage.instance.ref().child(product.productId.toString()+'1').getDownloadURL(),
                  builder: (BuildContext context,AsyncSnapshot<dynamic> downloadUrl){
                    String currUrl=downloadUrl.data.toString();
                    if(!downloadUrl.hasData)
                      return Container(
                          child:Center(
                              child:CircularProgressIndicator()
                          )
                      );
                    return InkWell(
                      onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(product.productId, _user))); },
                      child:new Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                        elevation: 0.3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: screenWidth(context)/2,
                              child:networkImage(currUrl,screenHeight(context)/4),
                            ),
//														SizedBox(
//															height: screenWidth(context)/10,
//															child:Padding(
//																padding: const EdgeInsets.symmetric(horizontal:15.0),
//																child: Row(
//																	crossAxisAlignment: CrossAxisAlignment.center,
//																	mainAxisAlignment: MainAxisAlignment.spaceAround,
//																	mainAxisSize: MainAxisSize.min,
//																	children: <Widget>[
//																		Expanded(child: autoSizeText(product.title, 1, 17.0, Colors.black87)),
//																		autoSizeText(rupee()+product.salePrice, 1, 18.0, Colors.black87),
//																	],
//																),
//															),
//														),
                            SizedBox(
                              height: screenWidth(context)/20,
                              child:autoSizeText(product.title, 1, 15.0, Colors.black87),
                            ),
                            SizedBox(
                              height: screenWidth(context)/20,
                              child:	autoSizeText(rupee()+product.salePrice, 1, 18.0, Colors.black87),
                            )


                          ],
                        ),

                      ),
                    );
                  }
              );


            },
              childCount: querySnapshots.hasData ? querySnapshots.data.documents.length : 0,),

          );
        }

    );
  }


}