import 'dart:io';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';



class PostNewAd extends StatefulWidget {
  final String _category;
  final String _subCategory;
  final User _user;
  PostNewAd(this._category,this._subCategory,this._user);
  @override
  _PostNewAdState createState() => _PostNewAdState(_category,_subCategory,_user);
}

class _PostNewAdState extends State<PostNewAd> {

  String _category;
  String _subCategory;
  final User _user;
  _PostNewAdState(this._category,this._subCategory,this._user);

  List<Widget> _productImageSlides;
  Widget _productImageSlider;
  Widget _productImageSelect;

  Widget _categorySubcategory;
  Widget _productTitle;
  Widget _productSalePrice;
  Widget _productOriginalPrice;
  Widget _productDetails;
  Widget _productState;
  List<Widget> _productStateList=<Widget>[];
  List<double> _productStateValueList;
  List<String> _productStateTitleList;
  Widget _productEnsured;
  var _productForm = GlobalKey<FormState>();
  var _productImageSelectCount;
  double _sliderValue1=2;
  double _sliderValue2=2;
  double _sliderValue3=2;
  bool _slider1=false;
  bool _slider2=false;
  bool _slider3=false;
  List<File> _images=[];
  int _currIndex=0;
  int _prevIndex=0;
  Product _product;
  bool _isUploading=false;







  @override
  void initState() {
    super.initState();
    _productImageSelectCount=0;
    _productImageSlides=List<Widget>();
  }


  @override
  Widget build(BuildContext context) {
    _productImageSelect=Container(
        height:screenHeight(context)*0.3,
        width:screenWidth(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(mainAxisAlignment:MainAxisAlignment.center,children: <Widget>[Icon(Icons.file_upload),Text('Upload Image'),],),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.black,
                  textColor: Colors.white,
                  child:Icon(Icons.camera),
                  onPressed: (){_imagePickCamera();},
                ),
                Container(width: 20.0,),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.black,
                  textColor: Colors.white,
                  child:Icon(Icons.photo_library),
                  onPressed: (){_imagePickGallery();},
                ),

            ],
            )
          ],
        )
    );

    if(_productImageSlides.length==0)
      _productImageSlides.add(_productImageSelect);

    _productImageSlider=Container(
        height: screenHeight(context)*0.3,
        child: Carousel(
          boxFit: BoxFit.cover,
          dotBgColor: Colors.transparent,
          dotColor: Colors.black,
          dotIncreasedColor: Colors.black,
          dotSize: 4.0,
          indicatorBgPadding: 0.0,
          autoplay: false,
          animationCurve: Curves.fastOutSlowIn,
          animationDuration: Duration(milliseconds: 1000),
          images: _productImageSlides,
          onImageChange: (prev,curr){
            _prevIndex=prev;
            _currIndex=curr;
          },
        )
    );

    _categorySubcategory=Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Disclaimer: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),),
            Text('Advertisement will expire in 30 days',style: TextStyle(fontSize: 15.0),),
          ],
        ),
        Container(height: 10.0,),
        Row(
          children: <Widget>[
            Text('Category: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
            Text(_category,style: TextStyle(fontSize: 20.0),),
          ],
        ),
        Container(height: 10.0,),
        Row(
          children: <Widget>[
            Text('Subcategory: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
            Text(_subCategory,style: TextStyle(fontSize: 20.0),),
        ]
          ,)
      ],
    );

    _productTitle=TextFormField(
      onSaved: (value){
        _product.title=value;
      },
      validator: (value){
        if(value.length==0)
          return 'Enter valid title';
        else
          return null;
      },
      decoration: InputDecoration(
          labelText: 'Title',
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
          )
      ),
    );

    _productSalePrice=TextFormField(
      keyboardType: TextInputType.number,//opens number type keyboard
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],//limits to inserting numbers only
      onSaved: (value){
        _product.salePrice=value.padLeft(5,'0');
      },
      validator: (value){
        if(value.length==0)
          return 'Enter valid sale price';
        else
          return null;
      },
      decoration: InputDecoration(
          labelText: 'Sale price',
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
          )
      ),
    );

    _productOriginalPrice=TextFormField(
      keyboardType: TextInputType.number,//opens number type keyboard
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],//limits to inserting numbers only
      onSaved: (value){
        if(value=='')
          _product.originalPrice='0';
        else
          _product.originalPrice=value;
      },
      decoration: InputDecoration(
          labelText: 'Original price',
          hintText: 'May leave blank',
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
          )
      ),
    );

    _productDetails=TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 9,
      minLines: 3,
      onSaved: (value){
        _product.details=value;
      },
      validator: (value){
        if(value.length==0)
          return 'Enter details';
        else
          return null;
      },
      decoration: InputDecoration(
          labelText: 'Details',
          alignLabelWithHint: true, //Aligns label to the start
          hintText: 'Enter details',
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)
          )
      ),
    );


    _productStateList=[
      Row(
        children: <Widget>[
          Flexible(
            child: TextFormField(
              onChanged: (value){
                if(value==''){
                  setState(() {
                    _slider1=false;
                  });
                }
                else {
                  setState(() {
                    _slider1 = true;
                  });
                }
              },
              onSaved: (value){
                if(_slider1==true)
                  _product.partName.add(value);

              },
              decoration: InputDecoration(
                  labelText: 'Part',
                  hintText: 'Eg. Body, Battery etc.',
                  errorStyle: TextStyle(color: Colors.red),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                  )
              ),
            ),
          ),

          Flexible(
            child: Slider(
              onChanged: _slider1?(value){
                setState(() {
                  _sliderValue1=value;
                });
              }:null,
              value: _sliderValue1,
              activeColor: Colors.black,
              min: 0,
              max: 5,
              divisions: 5,
            ),
          )
        ],
      ),

      Container(height: 10.0,),

      Row(
        children: <Widget>[
          Flexible(
            child: TextFormField(
              onChanged: (value){
                if(value==''){
                  setState(() {
                    _slider2=false;
                  });
                }
                else {
                  setState(() {
                    _slider2 = true;
                  });
                }},
              onSaved: (value){
                if(_slider2==true)
                  _product.partName.add(value);
              },
              decoration: InputDecoration(
                  labelText: 'Part',
                  hintText: 'Eg. Body, Battery etc.',
                  errorStyle: TextStyle(color: Colors.red),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                  )
              ),
            ),
          ),

          Flexible(
            child: Slider(
              onChanged: _slider2?(value){
                setState(() {
                  _sliderValue2=value;
                });
              }:null,
              value: _sliderValue2,
              activeColor: Colors.black,
              min: 0,
              max: 5,
              divisions: 5,
            ),
          )
        ],
      ),

      Container(height: 10.0,),

      Row(
        children: <Widget>[
          Flexible(
            child: TextFormField(
              onChanged: (value){
                if(value==''){
                  setState(() {
                    _slider3=false;
                  });
                }
                else {
                  setState(() {
                    _slider3 = true;
                  });
                }},
              onSaved: (value){
                if(_slider3==true)
                  _product.partName.add(value);

              },
              decoration: InputDecoration(
                  labelText: 'Part',
                  hintText: 'Eg. Body, Battery etc.',
                  errorStyle: TextStyle(color: Colors.red),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                  )
              ),
            ),
          ),

          Expanded(
            child: Slider(
              onChanged: _slider3?(value){
                setState(() {
                  _sliderValue3=value;
                });
              }:null,
              value: _sliderValue3,
              activeColor: Colors.black,
              min: 0,
              max: 5,
              divisions: 5,
            ),
          )
        ],
      ),
    ];


    return Scaffold(
        appBar: AppBar(
          title: Text('Post Ad'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _productForm,
            child: ListView(
              children: <Widget>[
                _productImageSlider,

                Container(height: 10.0,),

                _categorySubcategory,

                Container(height: 10.0,),

                _productTitle,

                Container(height:10.0),

                //Sale price
                Row(
                  children: <Widget>[
                    Flexible(
                        child: _productSalePrice
                    ),

                    Container(width: 10.0,),

                    Flexible(
                        child: _productOriginalPrice
                    ),
                  ],
                ),

                Container(height:10.0),

                _productDetails,

                Container(height: 10.0,),

                Text('Rate the parts of the item',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0),),

                Container(height: 10.0,),

                Column(
                  children: _productStateList,
                ),

                Container(height: 10.0,),

                Row(
                  children: <Widget>[
                    RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.black)),

                      color: Colors.black,
                      textColor: Colors.white,
                      child:_isUploading?Center(child: Loading(indicator: BallPulseIndicator(), size: 30.0)):Text('Submit'),
                      onPressed: _isUploading?(){}:(){
                        if(!_productForm.currentState.validate() || _images.length==0) {
                          if(_images.length==0)
                            toast('Select atleast one image');
                          return;
                        }
                        setState(() {
                          _isUploading=true;
                        });
                        _product=Product();
                        _product.priority=0;
                        _product.tag=List<String>();
                        _product.partName=List<String>();
                        _product.partValue=List<String>();
                        _productForm.currentState.save();
                        _product.soldFlag='0';
                        _product.waitingFlag='1';
                        _product.tag.add(_category);
                        _product.tag.add(_subCategory);
                        _product.sellerId=_user.documentId;
                        _product.date=Timestamp.now().toDate().toString();
                        _product.imageCount=_images.length.toString();
                        print(_product.partName);
                        if(_slider1==true)
                          _product.partValue.add(_sliderValue1.toString());
                        if(_slider2==true)
                          _product.partValue.add(_sliderValue2.toString());
                        if(_slider3==true)
                          _product.partValue.add(_sliderValue3.toString());
                        if(_product.originalPrice==null || double.parse(_product.originalPrice)==0.0)
                          _product.originalPrice='0';
                        print('Sliders value considered');
                        Firestore.instance.collection('product').add(_product.toMap()).then((snapshot){
                          _product.productId=snapshot.documentID.toString();
                          _uploadPic(_product.productId);
                          //_updateMyProduct(_product.productId);
                        });
//                        print('Uploaded pictures');
                      },
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,),


              ],

            ),
          ),
        )
    );
  }

  Future _uploadPic(String docId) async {
    await Firestore.instance.collection('user').document(_user.documentId).collection('myProduct').add({'productId':docId});

    for(int i=1;i<=_images.length;i++){
      String fileName = docId+i.toString();
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_images[i-1]);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    }
    setState(() {
      _isUploading=false;
    });
    toast('Ad successfully uploaded');
    successDialog(context);
//    Navigator.pop(context);
//    Navigator.pop(context);
//    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  successDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
//      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        double rad=screenWidth(context)/8;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Stack(

            children: <Widget>[
              //...bottom card part,
              //...top circlular image part,
              Container(
                padding: EdgeInsets.only(
                  top: rad + 20.0,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                margin: EdgeInsets.only(top: rad),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    Text(
                      'Success',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Your Product is sent for verification to admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pop(context);
                          Navigator.pop(context);// To close the dialog
                        },
                        child: Text('Okay'),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check,size: 40.0,color: Colors.white,),
                  radius: rad,
                ),
              ),
            ],
          ),
        );
      },
    );

  }

 _imagePickCamera() async {
    if(_images.length>=3){
      toast('Max images selected');
      return;
    }
    var image =await ImagePicker.pickImage(source: ImageSource.camera);
    toast('Please wait');
    _cropImage(image);
    return;




  }
  _imagePickGallery() async {
    if(_images.length>=3){
      print('Max images selected');
      return;
    }
    var image =await ImagePicker.pickImage(source: ImageSource.gallery);
//    toast('Please wait');
//    print(image.lengthSync());
    _cropImage(image);
    return;

  }
  _cropImage(var image) async {
    if(image==null){
      print('Image not clicked');
      return;
    }
    File croppedFile=await ImageCropper.cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.jpg,
//      compressQuality: 10,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
    );
    if(croppedFile==null){
      toast('Crop undone');
      return;
    }
    File compressedFile= await FlutterImageCompress.compressAndGetFile(croppedFile.path,croppedFile.path.replaceAll('.jpg', _currIndex.toString()+'.jpg'),quality: 30);
    if(compressedFile==null){
      toast('Compress failed');
      return;
    }
    print(croppedFile.path );
    print(croppedFile.lengthSync());
    print(compressedFile.path );
    print(compressedFile.lengthSync());
    _images.add(compressedFile);
    _productImageSlides.insert(_currIndex, _imageSlide());
    setState(() {});
    return;
  }

  Widget _imageSlide(){
    Widget widget=Container(
        child: Stack(
          alignment:AlignmentDirectional.topEnd,
          children: <Widget>[
            Center(
              child: Image.file(_images.last),
            ),
            RaisedButton(
              color: Colors.white,
              child: Icon(Icons.delete),
              onPressed: (){
                print(_currIndex.toString());
                _images.removeAt(_currIndex);
                _productImageSlides.removeAt(_currIndex);
                setState(() {

                });
              },
            ),
          ],
        )
    );
    return widget;
  }

}
