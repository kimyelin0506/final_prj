import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//send 버튼을 누를 때 baridation 을 실행하기 위해서 statefull
class NewMassages extends StatefulWidget {
  final String sendUser;
  final String receiveUser;
  const NewMassages({required this.sendUser, required this.receiveUser, super.key});

  @override
  State<NewMassages> createState() => _NewMassagesState(sendUser: sendUser, receiveUser: receiveUser);
}

class _NewMassagesState extends State<NewMassages> {
  String sendUser;
  String receiveUser;
  var _userEnterMessage = '';
  final _controller = TextEditingController();

  _NewMassagesState({required this.sendUser, required this.receiveUser});

  void _sendMessage() async {
    FocusScope.of(context).unfocus(); // textField 포커스 삭제
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('user').doc(user!.uid).get();

    FirebaseFirestore.instance.collection('chat').add({
      'text' : _userEnterMessage,
      'time' : Timestamp.now(),
      'userID' : user!.uid,
      'userName' : userData.data()!['userName'],
      'receiveUser' : receiveUser.toString(),
    });
    _controller.clear(); //sending시 텍스트필드 값을 지움
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          //많은 공간을 차지하려고 해서 에러가 발생
          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'sending Message',
              ),
              onChanged: (value) {
                setState(() {
                  _userEnterMessage = value;
                });
              },
            ),
          ),
          IconButton(
            //문자열의 양 끝을 제거한 경우에 비어있을 경우
            // 괄호가 있다면 메소드가 실행된다는 의미이며 값이 리턴된다는 의미임
            // 반대의 경우 위치를 참조하는 것임ㅗ
              onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
              icon: Icon(Icons.send,
              color: Colors.blue,),
          ),
        ],
      ),
    );
  }
}
