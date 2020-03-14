import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

void toast(String message) {
	Fluttertoast.showToast(
		msg: message,
		toastLength: Toast.LENGTH_SHORT,
		gravity: ToastGravity.BOTTOM,
		backgroundColor: Colors.black,
		textColor: Colors.white,
		fontSize: 10.0
	);
}
double screenWidth(BuildContext context){
	return MediaQuery.of(context).size.width;
}
double screenHeight(BuildContext context){
	return MediaQuery.of(context).size.height;
}
Size screenSize(BuildContext context){
	return MediaQuery.of(context).size;
}
String rupee(){
	return '₹';
}

AutoSizeText autoSizeText(String text,[int maxLines=1,double fontSize=16.0,Color color=Colors.black87]){
	return AutoSizeText(
		text,
		style: TextStyle(fontSize: fontSize, color: color),
		maxLines: maxLines,
		overflow: TextOverflow.ellipsis
	);
}
CachedNetworkImage networkImage(String url,double height){
	return CachedNetworkImage(
		imageUrl: url,
		placeholder: (context, url) => Center(child: CircularProgressIndicator()),
		errorWidget: (context, url, error) => Icon(Icons.error),
		height: height,
	);
}
CachedNetworkImage networkImageWithoutHeightConstraint(String url){
	return CachedNetworkImage(
		imageUrl: url,
//		placeholder: (context, url) => CircularProgressIndicator(),
		errorWidget: (context, url, error) => Icon(Icons.error),
//		height: height,
	);
}