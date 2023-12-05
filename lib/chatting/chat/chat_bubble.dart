import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {

  final String message;
  final bool isMe; // 내가 보랜ㅆ을 때를 구별
  const ChatBubble({ required this.message, required this.isMe, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[200] : Colors.blueAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
              bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
            ),
          ),
          width: 145,
          // 가로/세로 값을 달리 주기 위해
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(message,
          style: TextStyle(
            color: isMe ? Colors.black : Colors.white,
          ),
          ),
        ),
      ],
    );
  }
}
