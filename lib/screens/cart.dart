//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/chatScreen.dart';
import 'package:sale_spot/screens/product_detail.dart';
import 'package:sale_spot/services/shimmerLayout.dart';
import 'package:sale_spot/services/toast.dart';

import 'chooseCategory.dart';

class Cart extends StatefulWidget {
	final User _user;
	Cart(this._user);

	@override
	_CartState createState() => _CartState(_user);
}

class _CartState extends State<Cart> {
	final User _user;
	_CartState(this._user);

	@override
	Widget build(BuildContext context) {


		final tabTitle = <Tab>[
			Tab(text: 'Buy'),
			Tab(text: 'Sell'),
		];

		return DefaultTabController(
			length: tabTitle.length,
			child: Scaffold(
				appBar: AppBar(
					title: Text('Cart'),
					bottom: TabBar(
						labelColor: Colors.white,
						tabs: tabTitle
					),
				),
				body: TabBarView(
					children: <Widget>[
						buyList(),
						sellList()
					],
				),
			),
		);
	}

	Widget buyList() {
		return StreamBuilder<QuerySnapshot> (
			stream: Firestore.instance.collection('user').document(_user.documentId).collection('cart').snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if(!snapshot.hasData)
					return Center(
						child: CircularProgressIndicator(),
					);
				return getList(snapshot);
			},
		);
	}

	Widget getList(AsyncSnapshot<QuerySnapshot> snapshotList) {


		var listView = ListView.builder(itemBuilder: (context, index) {
			Product product;
			String sellerName;
			String imageURL;
			if(index<snapshotList.data.documents.length) {
				return StreamBuilder<DocumentSnapshot> (
					stream: Firestore.instance.collection('product').document(snapshotList.data.documents[index].data['productId']).snapshots(),
					builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
						try {
							if (!snapshot.hasData || snapshot.data == null)
								return Padding(
									padding: const EdgeInsets.all(8.0),
									child: Center(
										child: CircularProgressIndicator()
									),
								);
							product = Product.fromMapObject(snapshot.data.data);
							product.productId = snapshot.data.documentID;
							return StreamBuilder<DocumentSnapshot>(
								stream: Firestore.instance.collection('user')
									.document(product.sellerId)
									.snapshots(),
								builder: (BuildContext context, AsyncSnapshot<
									DocumentSnapshot> sellerInfoSnapshot) {
									if (!sellerInfoSnapshot.hasData)
										return Padding(
											padding: const EdgeInsets.all(8.0),
											child: Center(
												child: CircularProgressIndicator()
											),
										);
									return StreamBuilder<QuerySnapshot>(
										stream: Firestore.instance.collection(
											'product').document(
											product.productId).collection(
											'chat')
											.where('buyer',
											isEqualTo: _user.documentId)
											.snapshots(),
										builder: (BuildContext context,
											AsyncSnapshot<
												QuerySnapshot> readSnapshot) {
											if (!readSnapshot.hasData)
												return Padding(
													padding: const EdgeInsets
														.all(8.0),
													child: Center(
														child: CircularProgressIndicator()
													),
												);
											sellerName = sellerInfoSnapshot.data
												.data['name'];
											return Card(
												elevation: 0.0,
											  child: Slidable(
											  	actionPane: SlidableDrawerActionPane(),
											    actionExtentRatio: 0.15,
											    closeOnScroll: true,
											    secondaryActions: <Widget>[
//											  	IconButton(
//													icon: Icon(Icons.delete),
//													onPressed: () {
//														deleteChats(product, snapshotList.data.documents[index].documentID);
//													},
//												)

											  		IconSlideAction(
											  			caption: 'Delete',
											  			color: Colors.redAccent	,
											  			icon: Icons.delete,
											  			onTap: () => deleteChats(product, snapshotList.data.documents[index].documentID),
											  		),
											    ],
											    child: GestureDetector(
											    	child: ListTile(
											    		leading: GestureDetector(
											    			onTap: () {
											    				if (sellerName !=
											    					null &&
											    					imageURL !=
											    						null)
											    					Navigator
											    						.push(
											    						context,
											    						MaterialPageRoute(
											    							builder: (
											    								context) =>
											    								ProductDetail(
											    									product
											    										.productId,
											    									_user)));
											    			},
											    			child: FutureBuilder(
																	future: FirebaseStorage.instance.ref().child(product.productId + '1').getDownloadURL(),
											    				builder: (BuildContext context, AsyncSnapshot<dynamic> downloadUrl) {
											    					if (!downloadUrl.hasData)
																			return CircleAvatar(
																					radius: 30,
																					backgroundColor: Colors.grey[100],);
											    					imageURL = downloadUrl.data;
											    					return CircleAvatar(
											    						radius: 30,
											    						backgroundImage: NetworkImage(downloadUrl.data));
//																return networkImageWithoutHeightConstraint(downloadUrl.data);
											    				},
											    			),
											    		),
											    		title: Text(
											    			product.title),
											    		subtitle: Text(
											    			sellerInfoSnapshot
											    				.data
											    				.data['name']),
											    		trailing: Icon(
											    			Icons.brightness_1,
											    			color: readSnapshot
											    				.data.documents
											    				.length == 0 ||
											    				readSnapshot
											    					.data
											    					.documents[0]
											    					.data['buyerRead']
											    				? Colors
											    				.transparent
											    				: Colors.green,
											    			size: 15.0,),
											    	),
											    	onTap: () {
											    		if (sellerName != null &&
											    			imageURL != null)
											    			Navigator.push(context,
											    				MaterialPageRoute(
											    					builder: (
											    						context) =>
											    						ChatScreen(
											    							product,
											    							_user
											    								.documentId,
											    							false,
											    							sellerName,
											    							imageURL)));
											    	},
											    ),
											  ),
											);
										},
									);
								},
							);
						} catch (e) {
							return CircularProgressIndicator();
						}
					}
				);
			}
			else
				return null;
		});
		return listView;
	}

	Widget sellList() {
		return StreamBuilder<QuerySnapshot> (
			stream: Firestore.instance.collection('product').where('sellerId', isEqualTo: _user.documentId).snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if(!snapshot.hasData)
					return Center(
						child: CircularProgressIndicator(),
					);
				int itemCount=snapshot.data.documents.length;
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
				return ListView.builder(
					itemBuilder: (context, index) {
						if(index<snapshot.data.documents.length) {
							return StreamBuilder<QuerySnapshot> (
								stream: Firestore.instance.collection('product').document(snapshot.data.documents[index].documentID).collection('chat').snapshots(),
								builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> buyerSnapshot) {
									if(!buyerSnapshot.hasData)
										return Center(
//											child: CircularProgressIndicator(),
										);
									Product product = Product.fromMapObject(snapshot.data.documents[index].data);
									product.productId = snapshot.data.documents[index].documentID;
									return ListView.builder(
										shrinkWrap: true,
										itemBuilder: (context, index) {
											if(index<buyerSnapshot.data.documents.length) {
												String userDocumentID = buyerSnapshot.data.documents[index].data['buyer'];
												return StreamBuilder<DocumentSnapshot> (
													stream: Firestore.instance.collection('user').document(userDocumentID).snapshots(),
													builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> buyerInfoSnapshot) {
														if(!buyerInfoSnapshot.hasData)
															return Center(
																child: CircularProgressIndicator(),
															);
														return StreamBuilder<QuerySnapshot> (
															stream: Firestore.instance.collection('product').document(product.productId).collection('chat').where('buyer', isEqualTo: userDocumentID).snapshots(),
															builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> readSnapshot) {
																String imageURL;
																String buyerName;
																buyerName=buyerInfoSnapshot.data.data['name'];
																if(!readSnapshot.hasData)
																	return Padding(
																		padding: const EdgeInsets.all(8.0),
																		child: Center(
																			child: CircularProgressIndicator()
																		),
																	);
																return GestureDetector(
																	child: Card(
																		elevation: 0.0,
																		child: ListTile(
																			leading: FutureBuilder(
																				future: FirebaseStorage.instance.ref().child(product.productId+'1').getDownloadURL(),
																				builder: (BuildContext context, AsyncSnapshot<dynamic> downloadUrl) {
																					if(!downloadUrl.hasData)
																						return networkImageWithoutHeightConstraint('https://camo.githubusercontent.com/f5819c1f163c1265924b27bd0c3cc3e9a7776cef/68747470733a2f2f73332e65752d63656e7472616c2d312e616d617a6f6e6177732e636f6d2f626572736c696e672f696d616765732f7370696e6e6572332e676966');
																					imageURL=downloadUrl.data;
																					return CircleAvatar(
																							radius: 20,
																							backgroundImage: NetworkImage(downloadUrl.data)
																					);
//																						return networkImageWithoutHeightConstraint(downloadUrl.data);
																				},
																			),
																			title: Text(product.title),
																			subtitle: Text(buyerInfoSnapshot.data.data['name']),
																			trailing: Icon(Icons.brightness_1, color: readSnapshot.data.documents[0].data['sellerRead']?Colors.transparent:Colors.green, size: 15.0,),
																		),
																	),
																	onTap: () {
																	  if(buyerName!=null && imageURL!=null)
																		  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(product, userDocumentID, true,buyerName,imageURL)));
																	},
																);
															},
														);
													},
												);
											}
											else
												return null;
										}
									);
								},
							);
						}
						else
							return null;
					}
				);
			},
		);
	}

	void deleteChats(Product product, String userCartId) async {
//		print('--------------------'+userCartId);
	await Firestore.instance.collection('user').document(_user.documentId).collection('cart').document(userCartId).delete();
	QuerySnapshot documentSnapshot = await Firestore.instance.collection('product').document(product.productId).collection('chat').where('buyer', isEqualTo: _user.documentId).getDocuments();
//	print('-------------------'+documentSnapshot.documents[0].documentID);
	Firestore.instance.collection('product').document(product.productId).collection('chat').document(documentSnapshot.documents[0].documentID).collection('messages').getDocuments().then((toBeDeleted) {
		for(DocumentSnapshot ds in toBeDeleted.documents) {
			ds.reference.delete();
		}
	});
	documentSnapshot.documents[0].reference.delete();
	}
}