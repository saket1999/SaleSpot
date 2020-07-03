
import 'package:flutter/material.dart';
import 'package:sale_spot/services/toast.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerImage(context,double h){
  return Center(
      child:Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        baseColor: Colors.grey[200],
        highlightColor: Colors.grey[100],
        child:Container(
          height: h,
          color: Colors.white,
        ),
      )
  );

}
Widget shimmerImageHeightWidth(context,double h,double w){
  return Center(
      child:Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        baseColor: Colors.grey[200],
        highlightColor: Colors.grey[100],
        child:Container(
          height: h,
          width:w,
          color: Colors.white,
        ),
      )
  );

}
Widget shimmerItemHorizontal(context,double h,double w){
  return Center(
      child:Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        baseColor: Colors.grey[200],
        highlightColor: Colors.grey[100],
        child:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: h,
              width:h,
              color: Colors.white,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin:EdgeInsets.only(left:10.0,bottom:10.0),
                  height:h/12,
                  width: w/2,
                  color: Colors.white,
                ),
                Container(
                  margin:EdgeInsets.only(left:10.0),
                  height:h/12,
                  width: w/2.2,
                  color: Colors.white,
                ),
              ],
            ),


          ],
        ),
      )
  );

}
Widget shimmerCategory(context,double h,double w){
  return Center(
    child: Shimmer.fromColors(
      direction: ShimmerDirection.ltr,
      baseColor: Colors.grey[200],
      highlightColor: Colors.grey[100],
      child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: h,

            decoration:BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            )
          ),



        ],
      ),
    ),
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