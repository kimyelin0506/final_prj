import 'dart:async';
import 'dart:io';
import 'package:final_prj/screen/chat_screen.dart';
import 'package:final_prj/screen/upload_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../card/PostCard.dart';
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
  final _authentication = FirebaseAuth.instance;
  User? loggedUser; //초기화 시키지 않을 것임
  bool _startApp = false;
  late Timer _timer;
  int _seconds=0;
  File? img;

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void iniState() {
    super.initState();
    getCurrentUser();
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
                            text: '${loggedUser?.email}',
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
                    return ChatScreen();
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
              child: Column(
                children: [
                  PostCard(), //1개의 피드를 리턴
                ],
              ),
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
                child: Text('게시글 올리기'),
                onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadScreen()));},
              )
            ],
          );
        }
    );
  }



  /* 프로필을 누르면 밑에서 사진찍기/갤러리에서 가져오기 를 나타낼 수있는 버튼
  _showBottomSheet(){
    return showModalBottomSheet(

      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)
        )
      ),
      builder: (context){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => _getCameraImage(), child: const Text('사진 찍기')),
            const SizedBox(height:10),
            ElevatedButton(onPressed: ()=> _getPhotoImage(), child: const Text('이미지에서 가져오기')),
            const SizedBox(height: 10)
          ],
        );
      }
    );
  }

  //사진 찍기 버튼 눌렀을때
  _getCameraImage() async{
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if(pickedFile != null){
      setState(() {
        _pickedFile = pickedFile;
      });
    }else{
      if(kDebugMode){
        print('이미지 선택 안함');
      }
    }
  }

  //이미지에서 선택하기 버튼 눌렀을때
  _getPhotoImage() async{
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      setState(() {
        _pickedFile = pickedFile;
      });
    }else{
      if(kDebugMode){
        print('이미지 선택안함');
      }
    }
  }*/
}