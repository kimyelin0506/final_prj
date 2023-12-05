import 'package:final_prj/chatting/chat/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Massages extends StatelessWidget {
  const Massages({super.key});


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data!.docs;
        return ListView.builder(
          reverse: true, // 메세지의 위치가아래에서 위로 올라감
          itemCount: chatDocs.length, //null값이면 안됨
            itemBuilder: (context, index) {
            return ChatBubble(
              message: chatDocs[index]['text'],
              isMe: chatDocs[index]['userID'].toString() == user!.uid,
            );
          },
        );
      },
    );
  }
}

