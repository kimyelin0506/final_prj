import 'package:final_prj/chatting/chat/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*Message : 파베에 저장된 메세지를 불러옴
* */
class Messages extends StatefulWidget {
  final String sendUserUid;
  final String rcvUserEmail;
  final String rcvUserUid;
  final bool isSingle; //개인채팅방/단체채팅방 구현 시 쓰는 bool형(아직 구현 X)

  const Messages(
      {required this.sendUserUid,
      required this.rcvUserEmail,
      required this.rcvUserUid,
        required this.isSingle,
      super.key});

  @override
  State<Messages> createState() => _MessagesState(
      sendUserUid: sendUserUid,
      rcvUserEmail: rcvUserEmail,
      rcvUserUid: rcvUserUid,
    isSingle: isSingle
  );
}

class _MessagesState extends State<Messages> {
  final String sendUserUid;
  final String rcvUserEmail;
  final String rcvUserUid;
  final bool isSingle;

  _MessagesState({
    required this.sendUserUid,
    required this.rcvUserEmail,
    required this.rcvUserUid,
    required this.isSingle,
  });


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //정렬 방식 : ascending/descending 방식(0)
        stream: FirebaseFirestore.instance
            .collection('chat')
        .orderBy('time', descending: true) //가장 최근에 들어온 채팅을 먼저 나열
           .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {  //최신의 snapshot을 가져오기 위함
          if (snapshot.connectionState == ConnectionState.waiting) { //로딩중일때 돌아가는 위젯
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final chatDocs = snapshot.data!.docs;
          return ListView.builder(
            reverse: true, // 메세지의 생성 위치가 아래에서 위로 올라감
            itemCount: chatDocs.length, //null값이면 안됨
            itemBuilder: (context, index) {
              print(index);
              print(chatDocs[index]['text']);
              Timestamp time = chatDocs[index]['time'];
              DateTime dt = DateTime.fromMicrosecondsSinceEpoch(
                  time.microsecondsSinceEpoch);
              //채팅방 찾기-보낸사람과 받는 사람들로만 구성된 메세지만을 찾음
              if ((sendUserUid == chatDocs[index]['sendUserUid'].toString())
                  && (rcvUserUid == chatDocs[index]['rcvUserUid'].toString()))
                return ChatBubbles(
                  message: chatDocs[index]['text'],
                  isMe: chatDocs[index]['sendUserUid'] == sendUserUid,
                  sendUserName: chatDocs[index]['sendUserName'],
                  rcvUserName: chatDocs[index]['rcvUserName'],
                  time: dt,
                  userUid: chatDocs[index]['sendUserUid'],
                );
              //상대방이 나한테 보낸 메세지 찾음
              if ((rcvUserUid == chatDocs[index]['sendUserUid'].toString())
                  && (sendUserUid == chatDocs[index]['rcvUserUid'].toString()))
                return ChatBubbles(
                  message: chatDocs[index]['text'],
                  isMe: false,
                  sendUserName: chatDocs[index]['rcvUserName'],
                  rcvUserName: chatDocs[index]['sendUserName'],
                  time: dt,
                  userUid: rcvUserUid,
                );
              return Container();
             },
          );
        });
  }
}
