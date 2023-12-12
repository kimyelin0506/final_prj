import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:final_prj/screen/chat_list_screen.dart';
import 'package:final_prj/screen/map_screen.dart';
import 'package:final_prj/screen/payment_screen.dart';
import 'package:final_prj/screen/upload_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import '../config/NavBar.dart';
import '../config/palette.dart';

//피드가 보일 수 있는 homescreen화면
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CollectionReference _reference =
      FirebaseFirestore.instance.collection('uploadImgTest');
  late Stream<QuerySnapshot> _stream = _reference.snapshots();
  User? loggedUser; //초기화 시키지 않을 것임
  bool _startApp = false;
  late Timer _timer;
  int _seconds = 0;
  File? img;
  final String _userEmail = FirebaseAuth.instance.currentUser!.email.toString();


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
        _seconds++;
      });
    });
    if (_seconds >= 5) {
      setState(() {
        _startApp = true;
      });
    }
  }

  Widget welcomeWidget() {
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
                                      '${_userDocs[index]['userName']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      tr('환영합니다'),
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
                                    '${_userDocs[index]['userName']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    tr('환영합니다'),
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

  AppBar AppBarStyle() {
    return AppBar(
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
                  return ChatListScreen(
                    user: FirebaseAuth.instance.currentUser,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    welcomeMention();
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBarStyle(),
      body: Stack(
        children: [
          //환영 위젯
          welcomeWidget(),
          AnimatedOpacity(
              duration: Duration(seconds: 5),
              opacity: _startApp ? 1.0 : 0.0,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('uploadImgTest')
                    .orderBy('datePublished', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //오류 체크
                  if (snapshot.hasError) {
                    return Center(child: Text('오류발생 ${snapshot.error}'));
                  }
                  //get data
                  QuerySnapshot querySnapshot = snapshot.data;
                  List<QueryDocumentSnapshot> documents = querySnapshot.docs;

                  //doc -> Maps
                  List<Map> items =
                      documents.map((e) => e.data() as Map).toList();

                  //list보여주기
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map thisItem = items[index]; //get the item at this index
                      Timestamp time = thisItem['datePublished'];
                      DateTime dt = DateTime.fromMicrosecondsSinceEpoch(
                          time.microsecondsSinceEpoch);
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              bool likePost = false;
                              showPost(
                                _userEmail,
                                thisItem['description'],
                                dt,
                                thisItem['postUrl'],
                                thisItem['like'],
                                thisItem['postId'],
                                likePost,
                              );
                            },
                            child: ListTile(
                              tileColor: Colors.white38,
                              title: Text('유저 이름 : ${thisItem['user']}'),
                              titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
                              subtitle: Text('내용 : ${thisItem['description']}', maxLines: 2,),
                              leading:
                                  Container(
                                      height: 200,
                                      width: 150,
                                      child: thisItem.containsKey('postUrl')
                                          ? Image.network('${thisItem['postUrl']}')
                                          : Container()),
                              trailing: Column(
                                children: [
                                  Icon(Icons.favorite,color: Colors.red,),
                                  Text('${thisItem['like'].toString()}'),
                                ],
                              ),
                            ),
                          ),
                          Divider()
                        ],
                      );
                    },
                  );
                },
              )),
        ],
      ),
    );
  }

  void showPost(String userName, String contents
      , DateTime time, String ImageUrl, int likes, String postId, bool likePost) async {
    await FirebaseFirestore.instance.collection('uploadImgTest').where('postId', isEqualTo: postId).get().then((value) {
      for (var snap in value.docs) {
        print('-------likeUser------');
        for (var i in snap['likeUser']) {
          print(i);
          if (i == _userEmail) {
            print(i==_userEmail);
            setState(() {
              likePost = true;
            });
          }
        }
      }
    });
    print(likePost);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder:(BuildContext conext, StateSetter setState) {
              return SingleChildScrollView(
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  shadowColor: Colors.black,
                  title:
                  new Column(
                    children: <Widget>[
                      new Text(
                        '유저 이름 : ${userName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                          '업로드 날짜 : ${time.year}년 ${time.month}월 ${time
                              .day}일 ${time.hour}시 ${time.minute}분',
                          style: TextStyle(fontSize: 15, color: Colors.black)),
                      new Image.network(
                        ImageUrl,
                        scale: 1.0,
                      ),
                      new Text(
                        '내용 : ${contents} ',
                        style: TextStyle(fontSize: 15.0, color: Colors.black45),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    new Column(
                      children: [
                        Text(
                          '$likes',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        new GestureDetector(
                          onDoubleTap: () async {
                            if (likePost == false) {
                              _reference
                                  .where('postId', isEqualTo: postId)
                                  .get()
                                  .then((value) {
                                for (var docs in value.docs){
                                  Map<String, int> addLike = {
                                    'like': docs['like'] + 1
                                  };
                                  Map<String, dynamic> userLike = {
                                    'likeUser': FieldValue.arrayUnion(
                                        [userName]),
                                  };
                                  _reference.doc(postId).update(addLike);
                                  _reference.doc(postId).update(userLike);
                                  setState(() {
                                    likePost = true;
                                    likes +=1;
                                  });
                                }
                              });
                            }
                            print(likePost);
                          },
                          onTap: () {
                            if (likePost == true) {
                                _reference
                                    .where('postId', isEqualTo: postId)
                                    .get()
                                    .then((value) {
                                  for (var docs in value.docs) {
                                    Map<String, int> addLike = {
                                      'like': docs['like'] - 1
                                    };
                                    Map<String, dynamic> userDisLike = {
                                      'likeUser':
                                      FieldValue.arrayRemove([userName]),
                                    };
                                    _reference.doc(postId).update(addLike);
                                    _reference.doc(postId).update(userDisLike);
                                    setState(() {
                                      likePost = false;
                                      likes -=1;
                                    });
                                  }
                                });
                                print(likePost);
                            }
                          },
                          child: likePost
                              ? new Container(
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                          )
                              : new Container(
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            new ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black45,
                                onPrimary: Colors.white,
                                shadowColor: Colors.black12,
                              ),
                              onPressed: () {
                                //사진 저장
                              },
                              child: Text('사진 저장하기'),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            new ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red[700],
                                  onPrimary: Colors.white,
                                  shadowColor: Colors.black12,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('고양이 더 구경하기')),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            }
          );
        });
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
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context){
                        return UploadScreen();
                      }));
                }
              ),
              SimpleDialogOption(
                child: Text('취소'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }
}
