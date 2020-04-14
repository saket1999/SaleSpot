import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sale_spot/classes/product.dart';
import 'package:sale_spot/classes/user.dart';

class ChatScreen extends StatefulWidget {
	final Product product;
	final String userDocumentID;
	final bool isSeller;
	final String sellerName,imageURL;
	ChatScreen(this.product, this.userDocumentID, this.isSeller,this.sellerName,this.imageURL);

	@override
	_ChatScreenState createState() => _ChatScreenState(product, userDocumentID, isSeller, sellerName, imageURL);
}

class _ChatScreenState extends State<ChatScreen> {
	Product product;
	String userDocumentID;
	bool isSeller;
	final String sellerName,imageURL;
	_ChatScreenState(this.product, this.userDocumentID, this.isSeller,this. sellerName, this.imageURL);

	String chatId;

	void initState() {
		super.initState();
		changeReadVariable();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Row(
					children: <Widget>[
						CircleAvatar(
								radius: 20,
								backgroundImage: NetworkImage(imageURL)
						),
						Padding(
						  padding: const EdgeInsets.all(15.0),
						  child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
						    children: <Widget>[
						      Text(product.title),
									Text(sellerName,style: TextStyle(fontSize: 13.0),)

						    ],
						  ),
						)
					],
				),
			),
			body: Column(
				children: <Widget>[
					Flexible(
						child: StreamBuilder<QuerySnapshot> (
							stream: Firestore.instance.collection('product').document(product.productId).collection('chat').where('buyer', isEqualTo: userDocumentID).snapshots(),
							builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
								if(!snapshot.hasData)
									return Center(
										child: CircularProgressIndicator(),
									);
								if(snapshot.data.documents.length==0) {
									createChatUser();
									return Container();
								}
								chatId = snapshot.data.documents[0].documentID;
								return StreamBuilder<QuerySnapshot> (
									stream: Firestore.instance.collection('product').document(product.productId).collection('chat').document(chatId).collection('messages').orderBy('time', descending: true).snapshots(),
									builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
										if(!chatSnapshot.hasData)
											return Center(
												child: CircularProgressIndicator(),
											);
										return getChatList(chatSnapshot);
									},
								);
							},
						)
					),
					Divider(
						height: 1.0,
					),
					Container(
						padding: EdgeInsets.only(bottom: 5.0),
						child: chatEnvironment(),
					)
				],
			),
		);
	}

	Widget getChatList(AsyncSnapshot<QuerySnapshot> snapshot) {
		var listView = ListView.builder(itemBuilder: (context, index) {
			if(snapshot.hasData && index == snapshot.data.documents.length-1) {
				Timestamp time = snapshot.data.documents[index].data['time'];
				return Padding(
					padding: EdgeInsets.all(4.0),
					child: Column(
						children: <Widget>[
							isSeller ?Container() :Padding(
								padding: EdgeInsets.only(bottom: 10.0),
								child: Bubble(
									color: Colors.red[200],
									child: Text('You can remove Products from cart using Left Swipe'),
								),
							),
							Padding(
							  padding: const EdgeInsets.only(bottom: 5.0),
							  child: Bubble(
							  	color: Color.fromRGBO(212, 234, 244, 1.0),
							  	child: Text(DateFormat('d MMM y').format(time.toDate()).toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0),),
							  ),
							),
							Bubble(
								margin: snapshot.data.documents[index].data['isSeller'] ^ isSeller?BubbleEdges.only(right: 20.0):BubbleEdges.only(left: 20.0),
								alignment: snapshot.data.documents[index].data['isSeller'] ^ isSeller?Alignment.topLeft:Alignment.topRight,
								color: Color.fromRGBO(225, 255, 199, 1.0),
								nip: index==snapshot.data.documents.length-1?(snapshot.data.documents[index].data['isSeller']^ isSeller?BubbleNip.leftTop:BubbleNip.rightTop):(snapshot.data.documents[index].data['isSeller']==snapshot.data.documents[index+1].data['isSeller']?BubbleNip.no:(snapshot.data.documents[index].data['isSeller']^ isSeller?BubbleNip.leftTop:BubbleNip.rightTop)),
								child: RichText(
									textAlign: TextAlign.end,
									text: TextSpan(
										style: DefaultTextStyle.of(context).style,
										children: <TextSpan>[
											TextSpan(
												text: snapshot.data.documents[index].data['message'],
												style: TextStyle(
													fontSize: 14.0
												)
											),
											TextSpan(text: '  '),
											TextSpan(
												text: time.toDate().hour.toString()+':'+time.toDate().minute.toString().padLeft(2,'0'),
												style: TextStyle(
													fontSize: 8.5,
													color: Colors.grey
												)
											)
										]
									),
								)
							)
						],
					)
				);
			}
			else if(snapshot.hasData && index < snapshot.data.documents.length-1) {
//        print(snapshot.data.documents[index].data['isSeller'].runtimeType.toString()+' '+ (snapshot.data.documents[index].data['isSeller']).toString());
				Timestamp time = snapshot.data.documents[index].data['time'];
//				print(snapshot.data.documents[index].data['message']+'  '+(time.toDate().day-snapshot.data.documents[index+1].data['time'].toDate().day).toString());
				return Padding(
					padding: EdgeInsets.all(4.0),
					child: (time.toDate().day-snapshot.data.documents[index+1].data['time'].toDate().day)==0?
					Bubble(
						margin: snapshot.data.documents[index].data['isSeller'] ^ isSeller?BubbleEdges.only(right: 20.0):BubbleEdges.only(left: 20.0),
						alignment: snapshot.data.documents[index].data['isSeller'] ^ isSeller?Alignment.topLeft:Alignment.topRight,
						color: Color.fromRGBO(225, 255, 199, 1.0),
						nip: index==snapshot.data.documents.length-1?(snapshot.data.documents[index].data['isSeller']^ isSeller?BubbleNip.leftTop:BubbleNip.rightTop):(snapshot.data.documents[index].data['isSeller']==snapshot.data.documents[index+1].data['isSeller']?BubbleNip.no:(snapshot.data.documents[index].data['isSeller']^ isSeller?BubbleNip.leftTop:BubbleNip.rightTop)),
						child: RichText(
							textAlign: TextAlign.end,
							text: TextSpan(
								style: DefaultTextStyle.of(context).style,
								children: <TextSpan>[
									TextSpan(
										text: snapshot.data.documents[index].data['message'],
										style: TextStyle(
											fontSize: 14.0
										)
									),
									TextSpan(text: '  '),
									TextSpan(
										text: time.toDate().hour.toString()+':'+time.toDate().minute.toString().padLeft(2,'0'),
										style: TextStyle(
											fontSize: 8.5,
											color: Colors.grey
										)
									)
								]
							),
						)
					):
					Column(
						children: <Widget>[
							Padding(
							  padding: const EdgeInsets.only(bottom: 5.0),
							  child: Bubble(
							  	color: Color.fromRGBO(212, 234, 244, 1.0),
							  	child: Text(DateFormat('d MMM y').format(time.toDate()).toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0),),
							  ),
							),
							Bubble(
								margin: snapshot.data.documents[index].data['isSeller'] ^ isSeller?BubbleEdges.only(right: 20.0):BubbleEdges.only(left: 20.0),
								alignment: snapshot.data.documents[index].data['isSeller'] ^ isSeller?Alignment.topLeft:Alignment.topRight,
								color: Color.fromRGBO(225, 255, 199, 1.0),
								nip: index==snapshot.data.documents.length-1?(snapshot.data.documents[index].data['isSeller']^ isSeller?BubbleNip.leftTop:BubbleNip.rightTop):(snapshot.data.documents[index].data['isSeller']==snapshot.data.documents[index+1].data['isSeller']?BubbleNip.no:(snapshot.data.documents[index].data['isSeller']^ isSeller?BubbleNip.leftTop:BubbleNip.rightTop)),
								child: RichText(
									textAlign: TextAlign.end,
									text: TextSpan(
										style: DefaultTextStyle.of(context).style,
										children: <TextSpan>[
											TextSpan(
												text: snapshot.data.documents[index].data['message'],
												style: TextStyle(
													fontSize: 14.0
												)
											),
											TextSpan(text: '  '),
											TextSpan(
												text: time.toDate().hour.toString()+':'+time.toDate().minute.toString().padLeft(2,'0'),
												style: TextStyle(
													fontSize: 8.5,
													color: Colors.grey
												)
											)
										]
									),
								)
							)
						],
					)
				);
			}
			else
				return null;
		},
			reverse: true,
		);
		return listView;
	}

	Widget chatEnvironment() {

		TextEditingController textEditingController = TextEditingController();

		return IconTheme(
			data: IconThemeData(color: Colors.blue),
			child: Container(
				margin: EdgeInsets.symmetric(horizontal: 8.0),
				child: Row(
					children: <Widget>[
						Flexible(
							child: TextField(
								decoration: InputDecoration.collapsed(hintText: 'Start typing ...'),
								controller: textEditingController,
							),
						),
						Container(
							margin: EdgeInsets.symmetric(horizontal: 4.0),
							child: IconButton(
								icon: Icon(Icons.send),
								onPressed: () {
									_onSubmitted(textEditingController);
								},
							),
						)
					],
				),
			),
		);
	}

	void _onSubmitted(TextEditingController textEditingController) {

		String text = textEditingController.text.trim();
		if(text.isNotEmpty) {
			print('inside');
			Firestore.instance.collection('product').document(product.productId)
				.collection('chat').document(chatId).collection('messages')
				.add({
				'isSeller': isSeller,
				'message': text,
				'time': Timestamp.now()
			});
			textEditingController.clear();
		}

	}

	void createChatUser() async {
		Firestore.instance.collection('product').document(product.productId).collection('chat').add({'buyer': userDocumentID, 'sellerRead': true, 'buyerRead': true});
	}

	void changeReadVariable() async {
		var querySnapshot = await Firestore.instance.collection('product').document(product.productId).collection('chat').where('buyer', isEqualTo: userDocumentID).getDocuments();
		if(querySnapshot.documents.length>0) {
			if(isSeller)
				Firestore.instance.collection('product').document(product.productId)
					.collection('chat').document(
					querySnapshot.documents[0].documentID)
					.updateData({'sellerRead': true});
			else
				Firestore.instance.collection('product').document(product.productId)
					.collection('chat').document(
					querySnapshot.documents[0].documentID)
					.updateData({'buyerRead': true});
		}
	}
}
