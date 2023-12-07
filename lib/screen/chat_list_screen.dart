import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_prj/screen/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  _ChatListScreenState({required this.user});



  @override
  Widget build(BuildContext context) {
    bool _isSingleChat = true;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('집사들과 대화하기'),
        centerTitle: true,
      ),
      body: StreamBuilder(
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
                                  '[개인 채팅방] UserName : ',
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
    );
  }
}
