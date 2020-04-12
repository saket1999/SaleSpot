
import 'package:flutter/material.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerCategory(context,double h,double w){
  return Center(
      child:Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        baseColor: Colors.grey[200],
        highlightColor: Colors.grey[100],
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: h,
              color: Colors.white,
            ),
            Container(
              width:w/2,
              height: h/6,
              color: Colors.white,
            ),


          ],
        ),
      )
  );

}
Widget shimmerLayout(context){
  return Center(
      child:Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        baseColor: Colors.grey[200],
        highlightColor: Colors.grey[100],
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: screenHeight(context)/5,
              color: Colors.white,
            ),
            Container(
              width:screenWidth(context)/4,
              height: 8.0,
              color: Colors.white,
            ),
            Container(
              width:screenWidth(context)/5,
              height: 8.0,
              color: Colors.white,
            ),
          ],
        ),
      )
  );
}