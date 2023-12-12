import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../chatting/chat/message.dart';
import '../chatting/chat/new_message.dart';
/*ChatScreen : 기존에 있던 메세지와 새롭게 들어오는 메세지를 보여주는 화면
* */
class ChatScreen extends StatefulWidget {
  final String sendUserUid;
  final String rcvUserEmail;
  final String rcvUserUid;
  final String titleUser;
  final bool isSingle;

  const ChatScreen({required this.sendUserUid,
    required this.rcvUserEmail,
    required this.rcvUserUid,
    required this.titleUser,
    required this.isSingle,
    Key? key})
      : super(key: key);

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState(
          sendUserUid: sendUserUid,
          rcvUserEmail: rcvUserEmail,
          rcvUserUid: rcvUserUid,
          titleUser: titleUser,
        isSingle: isSingle,
      );
}
//stream은 지속적으로 받는 데이터를 처리할 때 필요
// 데이터     | 즉시 사용가능 데이터 || 기다려야 사용가능 데이터
// 단일 데이터 | int               || Future<int>
// 복수 데이터 | list<int>         || Stream<int>
//매순간 데이터가 들어왔는지 확인하는데 유용함 -> streambuilder 사용

class _ChatScreenState extends State<ChatScreen> {
 // final _authentication = FirebaseAuth.instance;
 // User? loggedUser; //초기화 시키지 않을 것임
  String sendUserUid;
  String rcvUserEmail;
  String rcvUserUid;
  String rcvUserName = '';
  String titleUser;
  bool isSingle;

  _ChatScreenState(
      {required this.sendUserUid,
      required this.rcvUserEmail,
      required this.rcvUserUid,
      required this.titleUser,
      required this.isSingle,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$titleUser',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                tr('집사님과 대화하기'),
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
            ]),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            child: Column(
              children: [
                //listView가 화면내의 모든 공간을 차지 하기 대문에 expanded 사용
                Expanded(
                  child: Messages( //기존에 있던 메세지를 보여주고
                    sendUserUid: sendUserUid,
                    rcvUserEmail: rcvUserEmail,
                    rcvUserUid: rcvUserUid,
                    isSingle: isSingle,
                  ),
                ),
                NewMessages( //새롭게 들어오는 메세지를 보여줌
                  sendUserUid: sendUserUid,
                  rcvUserEmail: rcvUserEmail,
                  rcvUserUid: rcvUserUid,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
