import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/chatScreen.dart';
import 'package:sale_spot/screens/imageHero.dart';
import 'package:sale_spot/services/toast.dart';
class ProductDetail extends StatefulWidget {
  final String _documentId;
  final User _user;
  ProductDetail(this._documentId, this._user);
  @override
  _ProductDetailState createState() => _ProductDetailState(_documentId, _user);
}

class _ProductDetailState extends State<ProductDetail> {
  String _documentId;
  final User _user;
  _ProductDetailState(this._documentId, this._user);

  Product _productContent;
  PageController pageController;
  List<String> imagesUrl=<String>[];
  List<String> tags=[];
  List<dynamic>imagesHero=<dynamic>[];
  List<Image> images=[];
  Widget image_slider;//Do not change the name to lower camel case. imageSlider already exists. Try providing a new name
  bool cartNotAdded = false;
  bool myProduct=true;
  String sellerAddress="";

  Future<dynamic> _imageLoader;//images are loaded only once
  
  initState() {
    super.initState();
    checkForCart();
    _imageLoader=imageLoader();//called only once. If _imageLoader variable is not created and imageLoader() is called directly. imageLoader() runs each time setState is called.
  }
  @override
  Widget build(BuildContext context) {
    pageController=PageController(initialPage: 1,viewportFraction: 0.8);
    image_slider=new Container(
      height: MediaQuery.of(context).size.height*0.5,
      child:Carousel(
              boxFit:BoxFit.cover,
              dotBgColor: Colors.transparent,
              dotColor: Colors.grey,
              dotIncreasedColor: Colors.grey,
              overlayShadow: true,
              overlayShadowColors: Colors.red,
              images:imagesHero,
              autoplay: false,
              animationCurve: Curves.fastOutSlowIn,
              animationDuration: Duration(milliseconds: 1000),
              dotSize: 4.0,
              indicatorBgPadding: 0.0,
              onImageTap: (int value){
                 Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>ImageHero(images,tags)));
              },

      ),
    );
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(

      //appBar: AppBar(),
      body: SafeArea(
        child: Stack(
          children: <Widget>[

            FutureBuilder(
                future: _imageLoader,
                builder:(BuildContext context, AsyncSnapshot snapshot){
                  if(snapshot.hasData){
//              print(snapshot.data.data.toString()+"jkbgfdb");
//              _productContent=Product.fromMapObject(snapshot.data.data);
                    return new ListView(
//                      physics: NeverScrollableScrollPhysics(),
//                      shrinkWrap: true,
                      //padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      children: <Widget>[
                        Container(
                          //padding: const EdgeInsets.all(4.0),
                          child:Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[


                                image_slider,
                                SizedBox(height: 30.0),
                                _buildProductTitleWidget(),
                                SizedBox(height: 10.0),
                                _buildPriceWidgets(),

                                _buildDivider(screenSize),

                                _buildDetailWidgets(),

                                _buildDivider(screenSize),

                                _buildRatingsHeader(),




                              ],
                            ),
                          ),

                        ),
                        _buildPartRating(),
                        SizedBox(height: 20.0),
                        _buildSimilarProducts(),
                        SizedBox(height: 30.0,),
                      ],
                    );
                  }else{
                    print("Loading");
//              return Container();
                    return Center(child: CircularProgressIndicator());
                  }
                }

            ),
            Container(
                height:screenHeight(context)/15,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black87,
                          Colors.transparent,
                        ]
                    )
                ),
                child:Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.white70,
                          size:30
                      ),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                )
            ),
          ],
        ),
      ),

      bottomNavigationBar: Material(
          elevation: 7.0,
          color: Colors.white,
          child:Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              color: myProduct?Colors.grey:Colors.white,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 10.0),
                    InkWell(
                      onTap: myProduct?null:() {openChat();  },
                      child: Container(
                        height: 50.0,
                        width: 50.0,
//                        color: myProduct?Colors.grey:Colors.white,
                        child: Icon(
                          Icons.chat,
                          color: myProduct?Colors.black:Colors.grey,
                        ),
                      ),
                    ),

                    Container(
                        color: (cartNotAdded&&!myProduct)?Colors.blue:Colors.grey,
                        width: MediaQuery.of(context).size.width - 130.0,
                        child: Center(
                            child: GestureDetector(
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 18.0,
                                    color: (cartNotAdded&&!myProduct)?Colors.white:Colors.black,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              onTap: (cartNotAdded&&!myProduct)?addToCart:null,
                            )
                        )
                    )
                  ]
              )
          )
      ),

    );
  }


  Future imageLoader() async{
    var snapshot=await Firestore.instance.collection('product').document(_documentId).get();
    var address=await Firestore.instance.collection('user').document(snapshot.data['sellerId']).get();
    if(address!=null)
      {
        sellerAddress=address.data['address'];

      }
    _productContent=Product.fromMapObject(snapshot.data);
    _productContent.productId=_documentId;
    if(_user.documentId!=_productContent.sellerId){
      myProduct=false;
    }
    print(myProduct);
    setState(() {

    });
    var s;
    for(int i=1;i<=int.parse(_productContent.imageCount);i++) {
      s=await FirebaseStorage.instance.ref().child(_documentId+i.toString()).getDownloadURL();

      if(s!=null) {
        imagesUrl.add(s.toString());
       // print(s.toString());
        images.add(Image.network(
          s.toString(),
        ));
        imagesHero.add(
//          Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: Image.network(s.toString(),fit:BoxFit.fitHeight),
//          ),
          Hero(
            tag: snapshot.documentID+i.toString(),
            child: images.last,
          ),
        );
        tags.add(snapshot.documentID);

      }
    }
    return snapshot;

  }
  _buildRatingsHeader(){
    if(_productContent.partName.length>0)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Text(
          "Ratings",
          style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight: FontWeight.w600),
        ),
      );
    return Container();
  }
  _buildDivider(Size screenSize) {

    return Column(
      children: <Widget>[
        SizedBox(height: 10.0),
        Container(
          color: Colors.grey[600],
          width: screenSize.width,
          height: 0.25,
        ),
        SizedBox(height: 10.0),
      ],
    );
  }
  _buildDetailWidgets(){

    return Container(
     padding: const EdgeInsets.symmetric(horizontal: 12.0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: <Widget>[

          Text(
            "Details",
            style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0,8.0,0.0,0.0),
            child: Text(
              _productContent.details,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15.0,
                  color: Colors.black87
              ),
            ),
          ),
          SizedBox(height: 10.0),
        ],
      )
    );
  }
  _buildProductTitleWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Text(
          //name,
          _productContent.title,
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        ),


    );
  }
  _buildPriceWidgets() {
    double salePrice=double.parse(_productContent.salePrice);
    double originalPrice=double.parse(_productContent.originalPrice);
    double discount;
    String discountPercentage;
    String salePriceText=rupee()+_productContent.salePrice;
    String originalPriceText;
    if(originalPrice!=0){
      originalPriceText=rupee()+_productContent.originalPrice;
      discount=1-(salePrice/originalPrice);
      discountPercentage=(discount*100).round().toString()+'% off';
    }
    else{
      originalPriceText='';
      discount=0;
      discountPercentage='';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
//        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            salePriceText,
            style: TextStyle(fontSize: 26.0, color: Colors.black,fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            originalPriceText,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            discountPercentage,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.green[700],
            ),
          ),
//          Expanded(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//                Text('THIS ISS'),
//              ],
//            )
//          )
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(Icons.location_on,color: Colors.black45,),
                Text(sellerAddress),
              ],
            ),
          )
        ],
      ),
    );
  }
  _buildPartRating(){
    int count=_productContent.partName.length;
    if(count==0)
      return Container();
    //Here adding shrinkWrap: true removes the error of vertical unbounded viewport.
    //Here adding physics: NeverScrollableScrollPhysics() disables scrolling of ListView
    return ListView.builder(physics: NeverScrollableScrollPhysics(),itemCount: count+1,shrinkWrap: true,itemBuilder: (BuildContext context, int index) {
      if(index!=count) {
        double percent = double.parse(_productContent.partValue[index]);
        percent = percent / 5;
        String percentage = (percent * 100).toString() + '%';
        return Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(_productContent.partName[index]),
              LinearPercentIndicator(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.5,
                animation: true,
                lineHeight: 8.0,
                animationDuration: 1500,
                percent: percent,
                trailing: Text(percentage),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.green,
              ),
            ],
          ),
        );
      }
      else
        return _buildDivider(screenSize(context));
    });
  }

  void openChat() async {
    if(cartNotAdded == true)
      await addToCart();
    if(_productContent != null)
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(_productContent, _user.documentId, false)));
    else
      toast('Wait');
  }
  
  void checkForCart() async {
    QuerySnapshot snapshot = await Firestore.instance.collection('user').document(_user.documentId).collection('cart').getDocuments();
    bool flag = true;
    for(int i=0; i<snapshot.documents.length; i++)
      if(snapshot.documents[i].data['productId'].toString() == _documentId) {
        flag = false;
        break;
      }
    if(flag == true)
      setState(() {
        cartNotAdded = true;
      });
//    setState(() {});
  }
  
  void addToCart() async {
    if(_user.documentId!=_documentId){
      Firestore.instance.collection('user').document(_user.documentId).collection('cart').add({'productId': _documentId});
      setState(() {
        cartNotAdded = false;
      });
    }
  }

  imageSlider(int index){
    return AnimatedBuilder(
      animation:pageController,
      builder: (context,widget){
        double value=1;
        if(pageController.position.haveDimensions){
          value=pageController.page-index;
          value=(1-(value.abs()*0.3)).clamp(0.0,1.0);
        }
        return Center(
          child:SizedBox(
            height:Curves.easeInOut.transform(value)*200,
            width:Curves.easeInOut.transform(value)*300,
            child:widget,
          ),
        );
      },
      child: Container(
        child:Image.network(imagesUrl[index],fit:BoxFit.cover),
      ),
    );

  }

  void _showSecondPage(BuildContext context, String url,PageController pageController) {

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          body: PageView.builder(
            controller: pageController,
            itemCount: imagesUrl.length,
            itemBuilder: (context,position){
               return imageSlider(position);
            },
      ),
        )
      )
    );
  }

  _buildSimilarProducts() {
    String queryTag=_productContent.tag[1];
//    int tagsLength=_productContent.tag.length;
//    for(int i=0;i<tagsLength;i++)
//      queryTags.add(_productContent.tag[i]);
    return FutureBuilder(
      future: Firestore.instance.collection('product').where('tag',arrayContains: queryTag).getDocuments(),
      builder: (context,products){
        if(!products.hasData || products.data.documents.length<=1)
          return Container();
//        print(products.data+'   Hello');
        int similarProductsCount=products.data.documents.length;
        print(similarProductsCount.toString()+products.data.documents[0].documentID.toString());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17.0),
              child: Text(
                "Similar Products",
                style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
//          margin: EdgeInsets.symmetric(vertical: 20.0),
              height: screenHeight(context)/4,
              child: ListView.builder(scrollDirection:Axis.horizontal,shrinkWrap: true,itemCount: similarProductsCount,itemBuilder: (BuildContext context,int index){

                Product similarProduct;
                similarProduct=Product.fromMapObject(products.data.documents[index].data);
                similarProduct.productId=products.data.documents[index].documentID.toString();
//            similarProduct.productId=similarProduct.productId.substring('product/'.length);
//            return Text(similarProduct.title);///YOU ARE HERE!
//            return FutureBuilder(
//              future: FirebaseStorage.instance.ref().child(similarProduct.+'.png').getDownloadURL(),
//            );
                if(similarProduct.productId==_productContent.productId){
                  return Container();
                }
              return FutureBuilder(
                future: FirebaseStorage.instance.ref().child(similarProduct.productId+'1').getDownloadURL(),
                builder: (BuildContext context,AsyncSnapshot<dynamic> urls){
                  if(!urls.hasData)
                    return Container();
                  String currUrl=urls.data.toString();
                  return SizedBox(
                    height:screenHeight(context)/5,
                    width: screenWidth(context)/2.5,
                    child:InkWell(
                      onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(similarProduct.productId, _user))); },
                      child:new Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.0)),
                        elevation: 0.3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(currUrl,height:screenHeight(context)/6),
                            ),
//										SizedBox(
//											height: 2.0,
//										),
                            new Container(
                              margin: EdgeInsets.only(left: 15,),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
//                                  Text(
//                                    similarProduct.title,
//                                    style: TextStyle(fontSize: 16.0, color: Colors.black87),
//                                  ),
                                Expanded(child: autoSizeText(similarProduct.title,1,16.0,Colors.black87)),
//													SizedBox(
//														width: 20.0,
//													),
                                  Expanded(
                                    child: Text(
                                      rupee()+similarProduct.salePrice,
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 15),
                                    ),
                                  ),
//                                  SizedBox(
//                                    height: 2.0,
//                                  ),
                                ],
                              ),
                            )
                          ],
                        ),

                      ),
                    ),
                  );
                },
              );

              }),
            ),
          ],
        );
//        return Row();
      },
    );
  }
}

