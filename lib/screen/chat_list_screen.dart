import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_prj/screen/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../config/palette.dart';

class ChatListScreen extends StatefulWidget {
  final user;
  const ChatListScreen({required this.user, super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState(user: user);
}

class _ChatListScreenState extends State<ChatListScreen> {
  var user;
  String sendUserUid = '';
  String rcvUserEmail = '';
  String rcvUserUid = '';
  String titleUser='';
  bool _isSingleChat = true;
  var searchUserEmail;
  final _controller = TextEditingController();
  bool _isSearchUser=false;

  _ChatListScreenState({required this.user});

   Future<void> _searchUser() async {
     _isSearchUser=false;
     print('//////////////$_isSearchUser/////////////');
    await FirebaseFirestore.instance.collection('user')
        .where('email', isEqualTo: searchUserEmail).get().then((value){
      for (var snapshot in value.docs){
        if(snapshot['email'] == searchUserEmail){
          setState(() {
            _isSearchUser = true;
            rcvUserUid = snapshot['userUid'];
            titleUser = snapshot['userName'];
          });
        }
      }
     print('//////////////$_isSearchUser/////////////');
    });
  }

  Future<Widget> showSearchRes()async{
    FocusScope.of(context).unfocus(); // textField 포커스 삭제
    await _searchUser();
    print('//////////////$_isSearchUser/////////////');
    if(_isSearchUser == true){
      showDialog(
          context: context,
          barrierDismissible: false, //dialog를 제외한 다른 화면 터치X
          builder: (BuildContext context){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: Colors.black,
              title: Column(
                children: <Widget>[
                  new Text('대화 할 집사를 찾았습니다.'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${searchUserEmail}님과 대화하시겠습니까?'),
                ],
              ),
              actions: <Widget> [
                new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black45,
                    onPrimary: Colors.white,
                    shadowColor: Colors.black12,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      sendUserUid = '';
                      rcvUserEmail = '';
                      rcvUserUid = '';
                      titleUser='';
                    });
                    Navigator.of(context).pop();
                    print(sendUserUid);
                    print(rcvUserUid);
                  },
                  child: Text('더 생각해볼게요..'),
                ),
                new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red[700],
                    onPrimary: Colors.white,
                    shadowColor: Colors.black12,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      //화면 전환
                      MaterialPageRoute(
                        builder: (context) {
                          return ChatScreen(
                            sendUserUid: user!.uid.toString(),
                            rcvUserEmail: searchUserEmail,
                            rcvUserUid: rcvUserUid,
                            titleUser: titleUser,
                            isSingle: _isSingleChat,
                          );
                        },
                      ),
                    );
                      _controller.clear();
                  },
                  child: Text('네!!'),
                ),
              ],
            );
          }
      );
    }
    if(_isSearchUser == false){
      showDialog(
          context: context,
          barrierDismissible: false, //dialog를 제외한 다른 화면 터치X
          builder: (BuildContext context){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: Colors.black,
              title: Column(
                children: <Widget>[
                  new Text('대화 할 집사를 찾지 못했습니다'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('입력하신 ${searchUserEmail}가 맞나요?'),
                ],
              ),
              actions: <Widget> [
                new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black45,
                    onPrimary: Colors.white,
                    shadowColor: Colors.black12,
                  ),
                  onPressed: () {
                    print(rcvUserUid);
                    print(titleUser);
                  setState(() {
                    _controller.clear();
                    sendUserUid = '';
                    rcvUserEmail = '';
                    rcvUserUid = '';
                    titleUser='';
                  });
                  Navigator.of(context).pop();
                  },
                  child: Text('앗 다시 입력할게요..'),
                ),
              ],
            );
          }
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('집사들과 대화하기'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  height: 10,
                ),
                IconButton(
                  onPressed: (){
                    searchUserEmail.trim().isEmpty ? null : showSearchRes();
                    print(searchUserEmail);
                  },
                    icon : Icon(Icons.search),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: ' 집사 찾기',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Palette.textColor1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        //클릭 있을 시 테두리 설정
                        borderSide: BorderSide(
                          color: Palette.textColor1,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35.0),
                        ),
                      ),
                      hintText: '집사 이메일을 입력해 주세요',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Palette.textColor1,
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchUserEmail = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection('user').snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(), //로딩중일때 돌아가는 위젯
                    );
                  }
                  final userDoc = snapshot.data!.docs;
                  return SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: userDoc.length,
                        itemBuilder: (context, index) {
                          if (user!.email.toString() !=
                              userDoc[index]['email'].toString())
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: 70,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(3, 10, 3, 10),
                                child: TextButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      sendUserUid = user!.uid.toString();
                                      rcvUserEmail =
                                          userDoc[index]['email'].toString();
                                      rcvUserUid =
                                          userDoc[index]['userUid'].toString();
                                      titleUser =
                                          userDoc[index]['userName'].toString();
                                      print(sendUserUid);
                                      print(rcvUserUid);
                                    });
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatScreen(
                                        sendUserUid: sendUserUid,
                                        rcvUserEmail: rcvUserEmail,
                                        rcvUserUid: rcvUserUid,
                                        titleUser: titleUser,
                                        isSingle: _isSingleChat,
                                      );
                                    }));
                                  },
                                  style: TextButton.styleFrom(
                                    primary: Colors.red[200],
                                    shadowColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor: Colors.black38,
                                  ),
                                  icon: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 10, right: 5),
                                    child: Icon(
                                      Icons.mark_unread_chat_alt_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  label: Row(
                                    children: [
                                      Text(
                                        _isSingleChat ?
                                        '[개인 채팅방] UserName : ' :
                                        '[단체 채팅방] UserName : '
                                        ,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        '${userDoc[index]['userName']}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          return Container();
                        },
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
