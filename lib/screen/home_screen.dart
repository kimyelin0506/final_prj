import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_prj/screen/chat_list_screen.dart';
import 'package:final_prj/screen/chat_screen.dart';
import 'package:final_prj/screen/payment_screen.dart';
import 'package:final_prj/screen/upload_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../config/NavBar.dart';
import '../config/account.dart';
import '../config/palette.dart';
import '../config/setting.dart';
import 'login_signUp_screen.dart';


//피드가 보일 수 있는 homescreen화면
class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  User? loggedUser; //초기화 시키지 않을 것임
  bool _startApp = false;
  late Timer _timer;
  int _seconds=0;
  File? img;
  String _userName='';

  Future<String> getUserName() async {
    final _userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
      return _userName = _userData.data()!['userName'].toString();
  }

  void getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void iniState() {
    super.initState();
    getCurrentUser();
    getUserName();
  }

  void welcomeMention(){
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds ++;
      });
    });
    if (_seconds >= 5){
      setState(() {
        _startApp = true;
      });
    }
  }

  Widget welcomeWidget(){
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: _startApp ? 0.0 : 1.0,
      child: Stack(
        children: [
          Container(
            color: Palette.backgroundColor,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(text: TextSpan(
                      children: [
                        TextSpan(
                            text: '${_userName}',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 25.0,
                            )
                        ),
                        TextSpan(
                          text: '님 환영합니다',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                        ),
                      ]
                  ),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    welcomeMention();
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('안서s Cat!'),
        centerTitle: true,
        actions: [
          IconButton( //고양이 후원 아이콘
            icon: Icon(Icons.monetization_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return FirstRoute(); //요건 payment_screen.dart에 위치함
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              takeImage(context);
            }, //왼쪽 위 사진추가icon 누르면 사진을 가져오게끔 설정
          ),
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                //화면 전환
                MaterialPageRoute(
                  builder: (context) {
                    return ChatListScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          //환영 위젯
          welcomeWidget(),
          AnimatedOpacity(
            duration: Duration(seconds: 5),
            opacity: _startApp ? 1.0 : 0.0,
            child: SingleChildScrollView(
              //overflow 방지 -> scroll
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView.separated(
                  itemCount: 2,
                  itemBuilder: (BuildContext context,int index){
                    return Get.arguments;
                  },
                  separatorBuilder: (BuildContext context,int index){
                    return SizedBox(height: 5);
                  },
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  //사진추가 버튼 누르면 사진을 찍거나 갤러리에서 가져올 수 있는 함수
  takeImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('글 올리기'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UploadScreen())),
              ),
              SimpleDialogOption(
                child: Text('취소'),
                onPressed: ()=> Navigator.pop(context),
              )
            ],
          );
        }
    );
  }
}