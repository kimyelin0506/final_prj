import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatBubbles extends StatelessWidget {
  final String receiveUser;
  final String message;
  final String userName;
  final bool isMe; // 내가 보랜ㅆ을 때를 구별
  const ChatBubbles({ required this.message, required this.isMe, required this.userName, required this.receiveUser, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
       if(isMe)
         Padding(
           padding: const EdgeInsets.fromLTRB(0,0,5,0),
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
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
        if (!isMe)
          Padding(
            padding: const EdgeInsets.fromLTRB(5,0,0,0),
            child: ChatBubble(
              clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
              backGroundColor: Color(0xffE7E7ED),
              margin: EdgeInsets.only(top: 20),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
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
      ],
    );
  }
}
