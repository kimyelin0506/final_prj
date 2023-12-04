import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//게시글 하나를 나타내는 클래스
//그냥 UI로 먼저 제작한것임
class PostCard extends StatefulWidget{

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>{

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 50,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Row(
              children: [
                CircleAvatar(  //프로필
                  radius: 15,
                  //backgroundImage: Image.asset('asset/img/img1.jpg')
                ),
                SizedBox(width: 5),
                Text('id'),  //인스타ID
              ]
          ),
        ),
        //게시글 보이는 곳
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey,
          child: Center(
              child: Text('게시물'),
          ), //게시물
        ),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Row(
            children: [
              Icon(Icons.favorite_border,),
              SizedBox(width:7),
              Icon(Icons.chat_outlined),
              SizedBox(width:7),
            ],
          ),
        ), //좋아요
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          color: Colors.black26,
          child: Center(child: Text('댓글')),
        ) //댓글
      ],
    );
  }
}