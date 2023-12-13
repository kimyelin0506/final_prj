import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//send 버튼을 누를 때 baridation 을 실행하기 위해서 statefull
/*NewMessages : 텍스트필드에서 값을 받아 파베에 새로운 메세지를 등록
<기능>
-파베에 collection(chat) 하위 문서로 새로운 메세지들을 등록
-구성 : (메세지 내용),(보낸 유저 Uid),(보낸 유저 이메일),(받는 유저 이름),(받는 유저 이메일),
(받는 유저 Uid), (보낸 시간),(좋아요 유무)
* */
class NewMessages extends StatefulWidget {
  final String sendUserUid;
  final String rcvUserEmail;
  final String rcvUserUid;

  const NewMessages(
      {required this.sendUserUid,
        required this.rcvUserEmail,
        required this.rcvUserUid});

  @override
  State<NewMessages> createState() => _NewMessagesState(
      sendUserUid: sendUserUid,
      rcvUserEmail: rcvUserEmail,
      rcvUserUid: rcvUserUid);
}

class _NewMessagesState extends State<NewMessages> {
  final String sendUserUid;
  final String rcvUserEmail;
  final String rcvUserUid;
  var _userEnterMessage = '';
  final _controller = TextEditingController();

  _NewMessagesState(
      {required this.sendUserUid,
        required this.rcvUserEmail,
        required this.rcvUserUid});

  void _sendMessage() async {
    FocusScope.of(context).unfocus(); // textField 포커스 삭제

    final sendUserData = await FirebaseFirestore.instance
        .collection('user')
        .doc(sendUserUid)
        .get();
    final rcvUserData = await FirebaseFirestore.instance.collection('user').doc(rcvUserUid).get();

    //새로운 메세지 생성
    await FirebaseFirestore.instance.collection('chat').add({
      'text': _userEnterMessage,
      'time': Timestamp.now(),
      'sendUserUid': sendUserUid,
      'sendUserName': sendUserData.data()!['userName'],
      'rcvUserEmail': rcvUserEmail.toString(),
      'rcvUserUid' : rcvUserUid.toString(),
      'rcvUserName' : rcvUserData.data()!['userName'],
      'likeMessage' : false,
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
            // 반대의 경우 위치를 참조하는 것임
            onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
            icon: Icon(
              Icons.send,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
