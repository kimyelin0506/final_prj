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
  CollectionReference _reference = FirebaseFirestore.instance.collection('uploadImgTest');
  late Stream<QuerySnapshot> _stream = _reference.snapshots();

  final _authentication = FirebaseAuth.instance;
  User? loggedUser; //초기화 시키지 않을 것임
  bool _startApp = false;
  late Timer _timer;
  int _seconds=0;
  File? img;
  final String _userEmail=FirebaseAuth.instance.currentUser!.email.toString();

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
  }

  void welcomeMention() {
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
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('user').snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  final _userDocs = snapshot.data!.docs;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  return ListView.builder(
                      itemCount: _userDocs.length,
                      itemBuilder: (context, index) {
                        if (_userDocs[index]['email'] == _userEmail)
                          return Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            color: Palette.backgroundColor,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_userDocs[index]['userName']} 님 ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '환영합니다',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        return Container();
                      });
                }
                return Container();
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    welcomeMention();
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('안서s Cat!'),
        centerTitle: true,
        actions: [
          IconButton(
            //고양이 후원 아이콘
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
            },
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (BuildContext context, AsyncSnapshot snapshot){
                //오류 체크
                if(snapshot.hasError){
                  return Center(child: Text('오류발생 ${snapshot.error}'));
                }

                //get data
                QuerySnapshot querySnapshot = snapshot.data;
                List<QueryDocumentSnapshot> documents = querySnapshot.docs;

                //doc -> Maps
                List<Map> items = documents.map((e) => e.data() as Map).toList();

                //list보여주기
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context,int index){
                    Map thisItem = items[index];   //get the item at this index
                    return ListTile(
                      title: Text('${thisItem['user']}'),
                      subtitle: Text('${thisItem['description']}'),
                      leading: Container(
                          height: 200,
                          width: 150,
                          child: thisItem.containsKey('postUrl')
                              ?Image.network('${thisItem['postUrl']}')
                              :Container()),
                    );
                  },
                );

              },
            )
          ),
        ],
      ),
    );
  }

  //사진추가 버튼 누르면 사진을 찍거나 갤러리에서 가져올 수 있는 함수
  takeImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
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