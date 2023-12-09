import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatBubbles extends StatefulWidget {
  String rcvUserName;
  String message;
  String sendUserName;
  bool isMe; // 내가 보냈을 때를 구별
  DateTime time;
  String userUid;

  ChatBubbles(
      {required this.rcvUserName,
      required this.message,
      required this.sendUserName,
      required this.isMe,
      required this.time,
        required this.userUid,
      super.key});

  @override
  State<ChatBubbles> createState() => _ChatBubblesState(
        rcvUserName: rcvUserName,
        message: message,
        sendUserName: sendUserName,
        isMe: isMe,
        time: time,
      );
}

class _ChatBubblesState extends State<ChatBubbles> {
  String rcvUserName;
  String message;
  String sendUserName;
  bool isMe; // 내가 보냈을 때를 구별
  DateTime time;
  bool likeMessage = false;

  void searchMessage(){
    FirebaseFirestore.instance.collection('chat')
        .where('text' ,isEqualTo: message).get().then((value) {
      print('------likemessage ------');
      for (var docSnapshot in value.docs){
        setState(() {
          likeMessage = docSnapshot['likeMessage'];
        });
      }
      onError: (e) => print("Error completing: $e");
    });
  }

  _ChatBubblesState({
    required this.message,
    required this.isMe,
    required this.sendUserName,
    required this.rcvUserName,
    required this.time,
  });

  @override
  void initState() {
    super.initState();
    searchMessage();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isMe)
          Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 45, 0),
                    child: ChatBubble(
                      clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(top: 20),
                      backGroundColor: Colors.blue,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              sendUserName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              message,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 23, 0),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Text(
                        '${time.year}년 ${time.month}월 ${time.day}일 ${time.hour}시 ${time.minute}분',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 20,
                right: 5,
                child: CircleAvatar(
                  child: ClipOval(
                  child: Image.asset('asset/image/animal_neko.png',
                      width: 80, height: 80),
                ),
                ),
              ),
            ],
          ),
        if (!isMe)
          Stack(
            children: [
              Positioned(
                top: 20,
                left: 5,
                child: CircleAvatar(
                  child: ClipOval(
                    child: Image.asset('asset/image/animal_neko.png',
                        width: 80, height: 80),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
                        child: ChatBubble(
                          clipper:
                          ChatBubbleClipper8(type: BubbleType.receiverBubble),
                          backGroundColor: Color(0xffE7E7ED),
                          margin: EdgeInsets.only(top: 20),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rcvUserName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  message,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onDoubleTap: () {
                          if(!likeMessage){
                            setState(() {
                              Map<String, bool> map = {
                                'likeMessage': true,
                              };

                              FirebaseFirestore.instance.collection('chat')
                                  .where('text' ,isEqualTo: message).get().then((value) {
                                print('------likemessage ------');
                                for (var docSnapshot in value.docs){
                                  setState(() {
                                    String chatId = docSnapshot.id;
                                    FirebaseFirestore.instance.collection('chat').doc(chatId).update(map);
                                    likeMessage = docSnapshot['likeMessage'];
                                  });
                                }
                                onError: (e) => print("Error completing: $e");
                              });
                            });
                          }
                          if(likeMessage){
                            setState(() {
                              Map<String, bool> map = {
                                'likeMessage': false,
                              };
                              FirebaseFirestore.instance.collection('chat')
                                  .where('text' ,isEqualTo: message).get().then((value) {
                                print('------likemessage ------');
                                for (var docSnapshot in value.docs){
                                  setState(() {
                                    String chatId = docSnapshot.id;
                                    FirebaseFirestore.instance.collection('chat').doc(chatId).update(map);
                                    likeMessage = docSnapshot['likeMessage'];
                                  });
                                }
                                onError: (e) => print("Error completing: $e");
                              });
                            });
                          }
                        },
                        child: likeMessage
                            ? Container(
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ))
                            : Container(
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.black45,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(23, 0, 0, 0),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Text(
                        '${time.year}년 ${time.month}월 ${time.day}일 ${time.hour}시 ${time.minute}분',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
      ],
    );
  }
}


