import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget{
  const ChatScreen({Key? key}): super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
//stream은 지속적으로 받는 데이터를 처리할 때 필요
// 데이터     | 즉시 사용가능 데이터 || 기다려야 사용가능 데이터
// 단일 데이터 | int               || Future<int>
// 복수 데이터 | list<int>         || Stream<int>
//매순간 데이터가 들어왔는지 확인하는데 유용함 -> streambuilder 사용

class _ChatScreenState extends State<ChatScreen>{
  final _authentication = FirebaseAuth.instance;
  User? loggedUser; //초기화 시키지 않을 것임

  // 채팅방으로 이동할 때마다 실행할것임
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('smu_cats_SNS/chats/message')
                .snapshots(),
            // 가장 최근의 스트림에서 스냅샷을 가져오기 위해 사용
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              //데이터를 불러오는 중 데이터가 없으므로 나타나는 초기 오류 해결
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final docs =
                  snapshot.data!.docs; //data를 가지고 있어야 하기 때문에 !, 문서를 가져옴
              return ListView.builder(
                  itemCount: docs.length, //문서 내에 텍스트 개수가 매번 바뀜
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        docs[index]['text'],
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    );
                  },
              );
            },
          ),
        ],
      ),
    );
  }
}
