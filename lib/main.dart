import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: FirestoreSlideshow()
        )
    );
  }
}

class FirestoreSlideshow extends StatefulWidget {

  @override
  createState() => FirestoreSlideshowState();
}

class FirestoreSlideshowState extends State<FirestoreSlideshow> {

  final PageController ctrl = PageController(viewportFraction: 0.8);
  final Firestore db = Firestore.instance;
  Stream slides ;
  String activeTag = 'awesome' ;
  int currentPage = 0 ;

  void initState () {
    _queryDb();

    ctrl.addListener (() {
      int next = ctrl.page.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  Widget build (BuildContext context ) {
    return StreamBuilder(
        stream: slides,
        initialData: [],
        builder: (context, AsyncSnapshot snap) {
          List slideList = snap.data.toList();
          return PageView.builder(
            controller: ctrl,
            itemCount: slideList.length + 1,
            itemBuilder: (context, int currentIdx) {
              if (currentIdx == 0) {
                return _buildTagPage ();
              }
              else if (slideList.length >= currentIdx){
                bool active = currentIdx == currentPage;
                return _buildStoryPage(slideList[currentIdx - 1], active);
              }
            },
          );
        }
    );
  }

  Stream _queryDb({String tag = 'awesome'}){

    Query query = db.collection('stories').where('tags', arrayContains : tag);
    slides = query.snapshots().map((list) => list.documents.map((doc) => doc.data));

    setState(() {
      activeTag = tag;
    });
  }
  _buildStoryPage(Map data , bool active){
    final double blur = active ? 30:0 ;
    final double offset = active ? 20:0;
    final double top = active ? 100:200;

    return AnimatedContainer(
      duration: Duration(microseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top , bottom: 50, right: 30),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image : DecorationImage(
            image: NetworkImage(data['img']),
            fit : BoxFit.cover,
          ),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: blur, offset: Offset(offset, offset))]
      ),
      child: Text(data['title'], style: TextStyle(fontSize: 40, color: Colors.white),),
    );
  }

  _buildTagPage(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text ('Your Stories', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
          Text('Filter' , style: TextStyle(color: Colors.black26),),
          _buildButton('awesome'),
          _buildButton('NYC'),
          _buildButton('GGB'),
        ],
      ),
    );
  }
  _buildButton (tag){
    Color color = tag ==activeTag ? Colors.pink : Colors.white;
    return FlatButton(color: color,child: Text('#$tag'), onPressed: ()=> _queryDb(tag: tag),);


  }
}
