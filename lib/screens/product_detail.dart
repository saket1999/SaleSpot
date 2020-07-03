import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:line_icons/line_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/chatScreen.dart';
import 'package:sale_spot/screens/imageHero.dart';
import 'package:sale_spot/services/toast.dart';

import 'cart.dart';
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
  String sellerName;

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
      color: Color(int.parse('0xffececec')),
      height: MediaQuery.of(context).size.height*0.5,
      child:Carousel(
              boxFit:BoxFit.cover,
              dotSize: 4.0,
              dotVerticalPadding: 20.0,
              indicatorBgPadding: 0.0,
              dotBgColor: Colors.transparent,
              overlayShadow: true,
              dotColor: Colors.white,
              dotIncreasedColor: Colors.white,

              overlayShadowColors: Colors.red,
              images:imagesHero,
              autoplay: false,
              animationCurve: Curves.fastOutSlowIn,
              animationDuration: Duration(milliseconds: 1000),


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



                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical:8.0),
                                  child: Divider(thickness: 2,color: Colors.grey[200],),
                                ),

                                _buildDetailWidgets(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical:8.0),
                                  child: Divider(thickness: 2,color: Colors.grey[200],),
                                ),
                                _buildSellerInfo(),

                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical:8.0),
                                  child: Divider(thickness: 2,color: Colors.grey[200],),
                                ),

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    IconButton(
                      icon: Icon(LineIcons.shopping_cart,
                          color: Colors.white70,
                          size:30
                      ),
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Cart(_user)));
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
              margin:EdgeInsets.only(left:4.0,right:4.0,bottom: 2.0),
              height: screenHeight(context)/15,
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
                          color: myProduct?Colors.black:Color(int.parse('0xff0288D1')).withOpacity(0.8),
                        ),
                      ),
                    ),

                    Container(
                        decoration:BoxDecoration(

                          borderRadius:BorderRadius.circular(10),
                          color: (cartNotAdded&&!myProduct)?Color(int.parse('0xff0288D1')).withOpacity(0.8):Colors.grey,
                        ),

                        width: MediaQuery.of(context).size.width - 130.0,
                        child: Center(
                            child: GestureDetector(
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: (cartNotAdded&&!myProduct)?Colors.white:Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              onTap: (cartNotAdded&&!myProduct)?addToCart:(){toast("Already added to cart");},
                            )
                        )
                    )
                  ]
              )
          )
      ),

    );
  }
  _buildSellerInfo()
  {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 12.0),
        margin: EdgeInsets.symmetric(horizontal: 2.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Text(
              "Seller Address",
              style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.location_on,color: Colors.black54,),
              Expanded(
                  child: Text(sellerAddress,maxLines: 3,style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15.0,
                    color: Colors.black87
                ),)
              ),
            ],
          ),
            SizedBox(height: 10.0),
          ],
        )
    );
  }

  Future imageLoader() async{
    var snapshot=await Firestore.instance.collection('product').document(_documentId).get();
    var seller=await Firestore.instance.collection('user').document(snapshot.data['sellerId']).get();
    if(seller!=null)
      {
        sellerAddress=seller.data['address'];
        sellerName=seller.data['name'];

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
          style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.w400),
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
            "Product Description",
            style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(5.0,8.0,0.0,0.0),
            child: Text(
              _productContent.details,
              style: TextStyle(

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
          style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight:FontWeight.w500),
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
            style: TextStyle(fontSize: 25.0, color: Colors.black,fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            originalPriceText,
            style: TextStyle(
              fontSize: 19.0,
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
              fontSize: 18.0,
              backgroundColor: Colors.green[100],
              color: Colors.green[700],
            ),
          ),

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
    if(_productContent != null && imagesUrl.isNotEmpty && sellerName!=null) {
//      var seller = await Firestore.instance.collection('user').document(_productContent.sellerId).get();
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          ChatScreen(
              _productContent, _user.documentId, false, sellerName, imagesUrl[0])));
    }
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
              height: screenHeight(context)/3.2,
              child: ListView.builder(scrollDirection:Axis.horizontal,shrinkWrap: true,itemCount: similarProductsCount,itemBuilder: (BuildContext context,int index){

                Product similarProduct;
                similarProduct=Product.fromMapObject(products.data.documents[index].data);
                similarProduct.productId=products.data.documents[index].documentID.toString();
//            similarProduct.productId=similarProduct.productId.substring('product/'.length);
//            return Text(similarProduct.title);///YOU ARE HERE!
//            return FutureBuilder(
//              future: FirebaseStorage.instance.ref().child(similarProduct.+'.png').getDownloadURL(),
//            );
                double salePrice=double.parse(similarProduct.salePrice);
                double originalPrice=double.parse(similarProduct.originalPrice);
                double discount;
                String discountPercentage;
                String originalPriceText;
                if(originalPrice!=0){
                  originalPriceText=rupee()+similarProduct.originalPrice;
                  discount=1-(salePrice/originalPrice);
                  discountPercentage=(discount*100).round().toString()+'% off';
                }
                else{
                  originalPriceText='';
                  discountPercentage='';
                }
                if(similarProduct.productId==_productContent.productId){
                  return Container();
                }
              return FutureBuilder(
                future: FirebaseStorage.instance.ref().child(similarProduct.productId+'1').getDownloadURL(),
                builder: (BuildContext context,AsyncSnapshot<dynamic> urls){
                  if(!urls.hasData)
                    return Container();
                  String currUrl=urls.data.toString();
                  return InkWell(
                    onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(similarProduct.productId, _user))); },
                    child:new Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      elevation: 0.3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: networkImage(currUrl,screenHeight(context)/5),
                            ),
                          ),

                          SizedBox(
                            height: screenWidth(context)/20,
                            child:autoSizeText(similarProduct.title, 1, 15.0, Colors.black87),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                rupee()+similarProduct.salePrice,
                                style: TextStyle(fontSize: 18.0, color: Colors.black87),
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                originalPriceText,
                                style: TextStyle(
                                  fontSize: 15.0,
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

                            ],
                          ),


                        ],
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

