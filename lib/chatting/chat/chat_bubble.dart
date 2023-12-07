import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatBubbles extends StatefulWidget {
  final String rcvUserName;
  final String message;
  final String sendUserName;
  final bool isMe; // 내가 보냈을 때를 구별
  final DateTime time;

  const ChatBubbles(
      {required this.rcvUserName,
      required this.message,
      required this.sendUserName,
      required this.isMe,
      required this.time,
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
  final String rcvUserName;
  final String message;
  final String sendUserName;
  final bool isMe; // 내가 보냈을 때를 구별
  final DateTime time;
  bool likeMessage = false;
  var ex;
  final GlobalKey _containerSize = GlobalKey();
  Size? size;

  _ChatBubblesState({
    required this.message,
    required this.isMe,
    required this.sendUserName,
    required this.rcvUserName,
    required this.time,
  });

  Size? _getSize() {
    if (_containerSize.currentContext != null) {
      final RenderBox renderBox =
          _containerSize.currentContext!.findRenderObject() as RenderBox;
      Size returnSize = renderBox.size;
      return returnSize;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        size = _getSize();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isMe)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
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
        if (!isMe)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: ChatBubble(
                      clipper:
                          ChatBubbleClipper8(type: BubbleType.receiverBubble),
                      backGroundColor: Color(0xffE7E7ED),
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        key: _containerSize,
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              sendUserName,
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
                      setState(() {
                        Map<String, bool> map = {
                          'likeMessage' : true,
                        };
                       // FirebaseFirestore.instance.collection('chat').doc().update(map);
                       // ex = FirebaseFirestore.instance.collection('chat').doc('likeMessage').get().then((value) => value);
                      });
                      //print(ex);
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
                            color: Colors.black12,
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
    );
  }
}


