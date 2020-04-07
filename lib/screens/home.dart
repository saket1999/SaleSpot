import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/cart.dart';
import 'package:sale_spot/screens/chooseCategory.dart';
import 'package:sale_spot/screens/editProfile.dart';
import 'package:sale_spot/screens/product_detail.dart';
import 'package:sale_spot/screens/promote.dart';
import 'package:sale_spot/screens/subCategory.dart';
import 'package:sale_spot/services/slideTransition.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'faq.dart';
import 'feedback.dart';
import 'myProductList.dart';
import 'login.dart';

class Home extends StatefulWidget {
	User _user;
	Home(this._user);

	@override
	_HomeState createState() => _HomeState(_user);
}

class _HomeState extends State<Home> {
	User _user;
	_HomeState(this._user);

	GoogleSignIn _googleSignIn = GoogleSignIn();

	FirebaseMessaging _fcm = FirebaseMessaging();

	String token;
	Timer timer;
	var connectivityResult;

	void initState() {
		super.initState();
		checkForBlock();
		storeSharedPreferences();
		_fcm.configure(
			onMessage: (Map<String, dynamic> message) async {
				print('onMessage: $message');
			},
			onResume: (Map<String, dynamic> message) async {
				print('onResume: $message');
			},
			onLaunch: (Map<String, dynamic> message) async {
				print('onLaunch: $message');
			},

		);
		getToken();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
//			backgroundColor: Colors.white,
			appBar: AppBar (
//				backgroundColor: Colors.cyan,
				title: new Text("SaleSpot",style:TextStyle(letterSpacing: 1.0,fontSize: 22.0),),
//				centerTitle: true,

			),
			drawer: Drawer(
				child: ListView(
					children: <Widget>[
						UserAccountsDrawerHeader(
							accountEmail: Text(_user.email,style: TextStyle(color: Colors.white),),
							accountName: Text(_user.name,style: TextStyle(color: Colors.white),),
							currentAccountPicture: Container(
//								child: Image.network(userDetails.photoUrl),
								decoration: _user.photoUrl==null?BoxDecoration():BoxDecoration(
									shape: BoxShape.circle,
									image: DecorationImage(
										fit: BoxFit.fill,
										image: NetworkImage(_user.photoUrl)
									)
								),
							),
						),

            ListTile(
              leading: Icon(Icons.assignment_turned_in),
              title: Text('My Products'),
              onTap: () {
								Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>myProductList( _user)));
              },
            ),
						ListTile(
							leading: Icon(Icons.shopping_cart),
							title: Text('Cart'),
							onTap: () {
								Navigator.pop(context);
								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Cart(_user)));
							},
						),
            ListTile(
              leading: Icon(Icons.call_made),
              title: Text('Promote'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Promote(_user)));
              },
            ),
						ListTile(
							leading: Icon(Icons.person),
							title: Text('Profile'),
							onTap: () {
								_openProfilePage(context);
							},
						),
						ListTile(
							leading: Icon(Icons.assignment),
							title: Text('Feedback'),
							onTap: () {
								Navigator.pop(context);
								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>FeedBack(_user)));
							},
						),
						ListTile(
							leading: Icon(Icons.question_answer),
							title: Text('FAQ'),
							onTap: () {
								Navigator.pop(context);
								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>Faq()));
							},
						),
						ListTile(
							leading: Icon(Icons.exit_to_app),
							title: Text('Log Out'),
							onTap: () {
								_googleSignIn.signOut();
								clearSharedPrefs();
								Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
							},
						),

					],
				),
			),
				body:	Container(
						height:screenHeight(context),
						width:screenWidth(context),
//						color: Colors.grey[200],
						child:CustomScrollView(
								slivers:<Widget>[
									SliverToBoxAdapter(
										child: ListTile(
											leading: Icon(Icons.apps),
												title:Text("Category",style: TextStyle(fontSize: 18,color: Colors.black45,fontWeight: FontWeight.w500),),

											),

									),

										SliverPadding(
												padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
												sliver: _categoryData(context),
										),

									SliverToBoxAdapter(
										child: Padding(
										  padding: EdgeInsets.symmetric(horizontal:0.0),
											child: ListTile(
												leading: Icon(Icons.home),
												title:Text("Shop",style: TextStyle(fontSize: 18,color: Colors.black45,fontWeight: FontWeight.w500),),

											),
										),

									),

									SliverPadding(
										padding: EdgeInsets.only(top: 0.0),
										sliver: _productList(),
									),

								]
						)
				),
				floatingActionButton: FloatingActionButton(
//					backgroundColor: Colors.blue,
					onPressed: () {
//						Navigator.push(context,SlideBottomRoute( page:ChooseCategory( _user)));
						Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ChooseCategory(_user)));


					},
//					child: Icon(Icons.add,color: Colors.white,),
						child: Text("SELL",style: TextStyle(
							fontSize: 15.0,
							color: Colors.white,
						),),
		),



		);

	}
	_openProfilePage(BuildContext context) async{
		_user=await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EditProfile(_user)));
	}
	Widget headerCategoryItem(String name,String iconUrl,String documentId) {
		return GestureDetector(
				onTap: () {
//					Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>SubCategory(documentId,name, _user)));
					Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>SubCategory(documentId,name, _user,"visitPost")));
				},
				child: Container(
//					color: Colors.lightBlueAccent,
					decoration: BoxDecoration(
						color: Colors.white,
						border: Border.all(color: Colors.grey,width: 0.1),
						borderRadius: BorderRadius.all(
								Radius.circular(10.0) //                 <--- border radius here
						),



					),

					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: <Widget>[
							SizedBox(
								height: screenHeight(context)/20,
								child:Center(
//																	color:Colors.blueGrey,
									child: networkImageWithoutHeightConstraint(iconUrl),
								),

							),
//
							Padding(
							  padding: EdgeInsets.only(top: 5.0),
							  child: SizedBox(
							  	height: screenHeight(context)/30,
//							  	child:Text("Study Material1",maxLines:3),
//									child:Text(name,maxLines:3),
//										child: autoSizeText("Study Material1233333333333333", 2)
										child: autoSizeText(name, 2)
//								child:Expanded(child: autoSizeText(name, 1, 10.0, Colors.black87)),
							  ),
							),
						],
					),
				)

		);
	}

	void clearSharedPrefs() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		prefs.setString('storedObject', '');
		prefs.setString('storedId', '');
		prefs.setString('storedPhoto', '');
	}

	void storeSharedPreferences() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		prefs.setString('storedObject', json.encode(_user.toMap()));
		prefs.setString('storedId', _user.documentId);
		prefs.setString('storePhoto', _user.photoUrl);
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
//					gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3),
				gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
					childAspectRatio: 0.9,
						maxCrossAxisExtent: 100.0,
						mainAxisSpacing: 10.0,
						crossAxisSpacing: 10.0,
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
										child: Center(
												child: CircularProgressIndicator()
										),
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

	_productList(){
		return StreamBuilder(
				stream:Firestore.instance.collection('product').where('soldFlag',isEqualTo: '0').where('waitingFlag',isEqualTo: '0').orderBy('priority',descending: true).limit(10).snapshots(),
				builder:(BuildContext context,AsyncSnapshot<QuerySnapshot> querySnapshots){
					if(!querySnapshots.hasData)
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
					return SliverGrid(
						gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2 ,childAspectRatio: 0.75,crossAxisSpacing: 2.0,mainAxisSpacing: 2.0),

							delegate: SliverChildBuilderDelegate((BuildContext context, int index){
//							print(querySnapshots.data.documents.length.toString()+'  document');
							DocumentSnapshot documentSnapshot=querySnapshots.data.documents[index];
							Product product=Product.fromMapObject(documentSnapshot.data);
							product.productId=documentSnapshot.documentID;
							double salePrice=double.parse(product.salePrice);
							double originalPrice=double.parse(product.originalPrice);
							double discount;
							String discountPercentage;
							String originalPriceText;
							if(originalPrice!=0){
								originalPriceText=rupee()+product.originalPrice;
								discount=1-(salePrice/originalPrice);
								discountPercentage=(discount*100).round().toString()+'% off';
							}
							else{
								originalPriceText='';
								discountPercentage='';
							}

							return FutureBuilder(
									future: FirebaseStorage.instance.ref().child(product.productId.toString()+'1').getDownloadURL(),
									builder: (BuildContext context,AsyncSnapshot<dynamic> downloadUrl){
										String currUrl=downloadUrl.data.toString();
										if(!downloadUrl.hasData)
											return Padding(
												padding: const EdgeInsets.all(20.0),
												child: Center(
														child:CircularProgressIndicator()
												),
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
														Padding(
														  padding: EdgeInsets.only(bottom:8.0),
														  child: ClipRRect(
														  	borderRadius: BorderRadius.circular(8.0),
														    child: networkImage(currUrl,screenHeight(context)/5),
														  ),
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
//														SizedBox(
//															height: screenWidth(context)/20,
//															child:	autoSizeText(rupee()+product.salePrice, 1, 18.0, Colors.black87),
//														),
														Row(
														mainAxisAlignment: MainAxisAlignment.center,
														children: <Widget>[
															Text(
															rupee()+product.salePrice,
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
									}
							);


						},
							childCount: querySnapshots.hasData ? querySnapshots.data.documents.length : 0,),

					);
				}

		);
	}

		Widget buildHeader(String text){
			return SliverList(
				delegate: SliverChildListDelegate([Container(
					margin: EdgeInsets.all(5),
					padding: EdgeInsets.all(15),
					decoration: BoxDecoration(
//															border: Border.all(color: Colors.grey,width: 0.5),
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

		void getToken() async {
			token = await _fcm.getToken();
			Firestore.instance.collection('user').document(_user.documentId).updateData({'token': token});
		}

		void checkForBlock() async {
		var newData = await Firestore.instance.collection('user').document(_user.documentId).get();
		if(newData.data['blockedNo'] > 2) {
			_googleSignIn.signOut();
			clearSharedPrefs();
			Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
		}
		}






}


