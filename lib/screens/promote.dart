import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/product_detail.dart';
import 'package:sale_spot/services/toast.dart';

class Promote extends StatefulWidget {
  final User user;
  Promote(this.user);
  @override
  _PromoteState createState() => _PromoteState(user);
}

class _PromoteState extends State<Promote> {
  final User _user;
  _PromoteState(this._user);


  String productDocID='';
  bool _isLoading=false;
  RewardedVideoAd videoAd = RewardedVideoAd.instance;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//    testDevices: testDevices != null ? <String>['testDevices'] : null,
    keywords: <String>['Book', 'Game', 'Shop', 'Buy', 'Sell', 'Electronics'],
    nonPersonalizedAds: false,
  );

  BannerAd myBanner = BannerAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: BannerAd.testAdUnitId,
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );

  @override
  void initState() {
    super.initState();

    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);

    //to display Banner Ad
    myBanner
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
      );

    //to display Video Ad
    videoAd.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("REWARDED VIDEO AD $event");
      if(event == RewardedVideoAdEvent.loaded){
//        print(_coins.toString()+'Loaded');
        setState(() {
          _isLoading=false;
        });
        showVideo();

      }
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          Firestore.instance.collection('product').document(productDocID).updateData({'priority':FieldValue.increment(1)});
//          _coins += rewardAmount;
        });
      }
    };
//    videoAd.load(
//        adUnitId: RewardedVideoAd.testAdUnitId,
//        targetingInfo: targetingInfo);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promote'),
      ),
      body: Center(
        child: getProductsList()
      ),
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
//                  bool soldFlag=product.soldFlag=='1';
//                  if(soldFlag)
//                    return Banner(
//                      message: 'Sold',
//                      location: BannerLocation.topEnd,
//                      color: Colors.green,
//                      child: listProduct(productImageUrl, product,soldFlag),
//                    );
                  return listProduct(productImageUrl, product);
                },
              );
            },
          );
        });
      },
    );
  }

  listProduct(String currUrl,Product ds){

//    bool renewFlag=Timestamp.now().toDate().difference(DateTime.parse(ds.date)).inDays>=25;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding:EdgeInsets.all(8.0),
            width:screenWidth(context)/3,
            child: networkImage(currUrl, screenWidth(context)/3),
//              child: Image.network(currUrl,height: screenWidth(context)/3,)
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
                        child: autoSizeText(ds.title, 2, 18.0, Colors.black87)
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.amberAccent,width: 2.0)
              ),
              color: Colors.black,
//              textColor: Colors.white,
              child:Row(
                children: <Widget>[
                  _isLoading?Center(child: Loading(indicator: BallPulseIndicator(), size: 30.0)):Text('Promote',style: TextStyle(color: Colors.cyanAccent),),
                ],
              ),
              onPressed: (){productDocID=ds.productId;loadVideo();},
            ),
          )
        ],
      ),
    );
  }

  void loadVideo(){
    setState(() {
      _isLoading=true;
    });

//                videoAd.show();
    videoAd.load(
        adUnitId: RewardedVideoAd.testAdUnitId,
        targetingInfo: targetingInfo);


  }

  void showVideo(){
    videoAd.show();
  }
  @override
  void dispose(){
    myBanner.dispose();
    super.dispose();
  }
}
