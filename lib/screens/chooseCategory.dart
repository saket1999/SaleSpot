import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sale_spot/classes/user.dart';
import 'package:sale_spot/screens/postNewAd.dart';
import 'package:sale_spot/services/toast.dart';

class ChooseCategory extends StatefulWidget {
  final User _user;

  ChooseCategory(this._user);

  @override
  _ChooseCategoryState createState() => _ChooseCategoryState(_user);
}

class _ChooseCategoryState extends State<ChooseCategory> {
  final User _user;
  _ChooseCategoryState(this._user);

  String _category;
  String _subCategory;
  bool _categoryChanged=false;
  Map<String,String> _categoryDocumentId=Map<String,String>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: Text('Category'),
          titleSpacing: 2.0,
          elevation: 0.0,
        ),
            body:	Container(
              alignment: Alignment.center,

              child: StreamBuilder(
                stream: Firestore.instance.collection('category').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return new Text('Loading...');
                  List<String> categories=_dropDownCategoryItems(snapshot);
                  if(categories.length==0)
                    return Text('Loading');
                  return ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal:50.0,vertical: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey,width: 0.5),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(5.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButton<String>(
                                elevation: 1,
                                isExpanded: true,
                                underline:Container() ,
                                items: categories.map((String dropDownStringItem){
                                  return DropdownMenuItem<String>(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem,style: TextStyle(fontSize: 20.0)),
                                  );
                                }).toList(),
                                onChanged: (value){
                                  setState(() {
                                    _categoryChanged=true;
                                    _category=value;
                                  });
                                },
                                value: _category,
                              ),
                            ),
                          ),
                        ),
                      ),
                      StreamBuilder(
                        stream: Firestore.instance.collection('category').document(_categoryDocumentId[_category]).collection('subCategory').snapshots(),//Firestore.instance.collectionGroup('subCategory').snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot2){
                          if (!snapshot2.hasData) return new Text('Loading...');
                          List<String> subCategories=_dropDownSubCategoryItems(snapshot2);
                          if(subCategories.length==0)
                            return Text('Loading');
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 50.0,vertical: 20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey,width: 0.5),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(5.0) //                 <--- border radius here
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButton<String>(
                                    elevation: 1,
                                    isExpanded: true,
                                    underline:Container() ,
                                    items: subCategories.map((String dropDownStringItem){
                                      return DropdownMenuItem<String>(
                                        value: dropDownStringItem,
                                        child: Text(dropDownStringItem,style: TextStyle(fontSize: 20.0)),
                                      );
                                    }).toList(),
                                    onChanged: (value){
                                      setState(() {
                                        _subCategory=value;
                                      });
                                    },
                                    value: _subCategory,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Row(
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.pink,
                            textColor: Colors.white,
                            child:Text('Submit'),
                            onPressed: (){
                              if(_category==null || _subCategory==null || _subCategory=='Subcategory')
                                toast('Invalid selection');
                              else
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>PostNewAd(_category,_subCategory,_user)));

                            },
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,)

                    ],
                  );
                },
              ),
            )


    );
  }

  _dropDownCategoryItems(AsyncSnapshot<QuerySnapshot> snapshot){
    List<String> items=[];
    var documents=snapshot.data.documents;
    for(int i=0;i<documents.length;i++){
      items.add(documents[i]['name'].toString());
      _categoryDocumentId.putIfAbsent(documents[i]['name'].toString(), ()=>documents[i].documentID);
    }

    if(_category==null)
      _category=documents[0]['name'].toString();
    return items;
  }


  _dropDownSubCategoryItems(AsyncSnapshot<QuerySnapshot> snapshot){
    List<String> items=['Subcategory'];
    var documents=snapshot.data.documents;
    for(int i=0;i<documents.length;i++){
      items.add(documents[i]['name'].toString());
    }
    if(_categoryChanged==true){
//      _subCategory=documents[0]['name'].toString();
    _subCategory=items[0];
      _categoryChanged=false;
    }
    if(_subCategory==null)
//      _subCategory=documents[0]['name'].toString();
      _subCategory=items[0];
    return items;
  }



}
