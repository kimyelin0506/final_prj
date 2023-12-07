import 'package:final_prj/chatting/chat/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Messages extends StatefulWidget {
  final String sendUserUid;
  final String rcvUserEmail;
  final String rcvUserUid;

  const Messages(
      {required this.sendUserUid,
      required this.rcvUserEmail,
      required this.rcvUserUid,
      super.key});

  @override
  State<Messages> createState() => _MessagesState(
      sendUserUid: sendUserUid,
      rcvUserEmail: rcvUserEmail,
      rcvUserUid: rcvUserUid);
}

class _MessagesState extends State<Messages> {
  final String sendUserUid;
  final String rcvUserEmail;
  final String rcvUserUid;

  _MessagesState({
    required this.sendUserUid,
    required this.rcvUserEmail,
    required this.rcvUserUid,
  });


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //정렬 방식 : ascending/descending 방식(0)
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, //최신의 snapshot을 가져오기 위함
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(), //로딩중일때 돌아가는 위젯
            );
          }
          final chatDocs = snapshot.data!.docs;
          return ListView.builder(
            reverse: true, // 메세지의 위치가아래에서 위로 올라감
            itemCount: chatDocs.length, //null값이면 안됨
            itemBuilder: (context, index) {
              print(index);
              print(chatDocs[index]['text']);
              Timestamp time = chatDocs[index]['time'];
              DateTime dt = DateTime.fromMicrosecondsSinceEpoch(
                  time.microsecondsSinceEpoch);
              //채팅방 찾기
              if ((sendUserUid == chatDocs[index]['sendUserUid'].toString())
                  && (rcvUserUid == chatDocs[index]['rcvUserUid'].toString()))
                return ChatBubbles(
                  message: chatDocs[index]['text'],
                  isMe: true,
                  sendUserName: chatDocs[index]['sendUserName'],
                  rcvUserName: chatDocs[index]['rcvUserName'],
                  time: dt,
                );
              if ((rcvUserUid == chatDocs[index]['sendUserUid'].toString())
                  && (sendUserUid == chatDocs[index]['rcvUserUid'].toString()))
                return ChatBubbles(
                  message: chatDocs[index]['text'],
                  isMe: false,
                  sendUserName: chatDocs[index]['rcvUserName'],
                  rcvUserName: chatDocs[index]['sendUserName'],
                  time: dt,
                );
              return Container();
            },
          );
        });
  }
}
