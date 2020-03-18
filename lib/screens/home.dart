import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/cart.dart';
import 'package:sale_spot/screens/chooseCategory.dart';
import 'package:sale_spot/screens/editProfile.dart';
import 'package:sale_spot/screens/product_detail.dart';
import 'package:sale_spot/screens/subCategory.dart';
import 'package:sale_spot/services/slideTransition.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
			backgroundColor: Colors.white,
			appBar: AppBar(
				title: Text('Home'),
			),
			drawer: Drawer(
				child: ListView(
					children: <Widget>[
						UserAccountsDrawerHeader(
							accountEmail: Text(_user.email),
							accountName: Text(_user.name),
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
//						ListTile(
//							leading: Icon(Icons.add),
//							title: Text('Post Ad'),
//							onTap: () {
//								Navigator.pop(context);
//								Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ChooseCategory( _user)));
//							},
//						),
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
							leading: Icon(Icons.person),
							title: Text('Profile'),
							onTap: () {
								_openProfilePage(context);
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
						color: Colors.grey[200],
						child:CustomScrollView(
								slivers:<Widget>[

									buildHeader('Categories'),
									_categoryData(context),
									buildHeader('Recommendations'),
//									_productListView,
									_productList(),
								]
						)
				),
				floatingActionButton: FloatingActionButton(
					backgroundColor: Colors.blue,
					onPressed: () {
//						Navigator.push(context,SlideBottomRoute( page:ChooseCategory( _user)));
						Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ChooseCategory(_user)));


					},
					child: Icon(Icons.add),
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
					//color: Colors.lightBlueAccent,
					decoration: BoxDecoration(
//						color: Colors.white,
						border: Border.all(color: Colors.white,width: 2.0),
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
										child: Center(
												child: CircularProgressIndicator()
										),
									);
								return Card(
//										elevation: 10.0,
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
				stream:Firestore.instance.collection('product').where('soldFlag',isEqualTo: '0').where('waitingFlag',isEqualTo: '0').limit(10).snapshots(),
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
						gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2 ,childAspectRatio: 0.8,crossAxisSpacing: 1.0,mainAxisSpacing: 1.0),
						delegate: SliverChildBuilderDelegate((BuildContext context, int index){
							print(querySnapshots.data.documents.length.toString()+'  document');
						DocumentSnapshot documentSnapshot=querySnapshots.data.documents[index];
						Product product=Product.fromMapObject(documentSnapshot.data);
						product.productId=documentSnapshot.documentID;
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
															SizedBox(
																height: screenWidth(context)/2,
																child:networkImage(currUrl,screenHeight(context)/4),

															),
															SizedBox(
																height: screenWidth(context)/10,
																child:Padding(
																	padding: const EdgeInsets.symmetric(horizontal:15.0),
																	child: Row(
																		crossAxisAlignment: CrossAxisAlignment.center,
																		mainAxisAlignment: MainAxisAlignment.spaceAround,
																		mainAxisSize: MainAxisSize.min,
																		children: <Widget>[
																			Expanded(child: autoSizeText(product.title, 1, 17.0, Colors.black87)),
																			autoSizeText(rupee()+product.salePrice, 1, 18.0, Colors.black87),
																		],
																	),
																),
															),
//															Padding(
//															  padding: const EdgeInsets.all(8.0),
//															  child: Hero(
//															    tag: product.productId,
//															    child: networkImage(currUrl,screenHeight(context)/4),
//															  ),
//															),
//															Row(
//																crossAxisAlignment: CrossAxisAlignment.center,
//																mainAxisAlignment: MainAxisAlignment.spaceAround,
//																mainAxisSize: MainAxisSize.min,
//																children: <Widget>[
////																			Text(
////																				product.title[0].toUpperCase() + product.title.substring(1),
////																				style: TextStyle(fontSize: 16.0, color: Colors.black87),
////																			),
//																	Expanded(child: autoSizeText(product.title, 1, 16.0, Colors.black87)),
//
////													SizedBox(
////														width: 2.0,
////													),
//																	autoSizeText(rupee()+product.salePrice, 1, 16.0, Colors.black87),
////																			SizedBox(
////																				height: 2.0,
////																			),
//																],
//															),
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


//	getProductData() async {
//
//		QuerySnapshot snapshot=await Firestore.instance.collection('product').orderBy('date').limit(20).getDocuments();
//		List<String> urls=<String>[];
//
//		for(int i=0;i<snapshot.documents.length;i++) {
//			var s=await FirebaseStorage.instance.ref().child(snapshot.documents[i].documentID+"1").getDownloadURL();
//			if(s!=null) {
//				urls.add(s.toString());
//
//				//print(s.toString());
//			}
//		}
//
//		_productListView=SliverGrid (
//
//			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2 ,childAspectRatio: 0.8,crossAxisSpacing: 1.0,mainAxisSpacing: 1.0),
//			delegate: SliverChildBuilderDelegate((BuildContext context, int index){
//				DocumentSnapshot ds = snapshot.documents[index];
//				String currUrl=urls[index];
//				return SizedBox(
//					height:screenHeight(context)/8,
//						child:InkWell(
//							onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>ProductDetail(snapshot.documents[index].documentID.toString(), _user))); },
//							child:new Card(
//								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//								elevation: 0.3,
//								child: Column(
//									mainAxisSize: MainAxisSize.min,
//									children: <Widget>[
//										new Container(
//											padding: const EdgeInsets.all(8.0),
//											child: Hero(
//												tag: ds.documentID,
//												child: Image.network(
//														currUrl,
//														height:screenHeight(context)/4
//
//												),
//											),
//										),
//										new Container(
//											margin: EdgeInsets.only(left: 15,),
//
//											child: Row(
//												crossAxisAlignment: CrossAxisAlignment.center,
//												mainAxisAlignment: MainAxisAlignment.spaceBetween,
//												mainAxisSize: MainAxisSize.max,
//												children: <Widget>[
//													Text(
//														ds['title'][0].toUpperCase() + ds['title'].substring(1),
//														style: TextStyle(fontSize: 16.0, color: Colors.black87),
//													),
////													SizedBox(
////														width: 2.0,
////													),
//													Text(rupee()+ds['salePrice'],
//														style: TextStyle(
//																color: Colors.grey[800],
//																fontSize: 15),
//													),
//													SizedBox(
//														height: 2.0,
//													),
//												],
//											),
//										)
//									],
//								),
//
//							),
//						),
//				);
//			},
//				childCount: snapshot.documents.length,
//			),
//		);
//
//		setState(() {
//
//		});
//		}



}


