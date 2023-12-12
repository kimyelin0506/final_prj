import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';


/*ChatBubbles : firebase에서 가져온 메세지 정보를채팅창에 내가 보냈을 경우와
상대방이 보냈을 경우를 판단하여 채팅메세지를 꾸며줌
<기능>
-채팅 구성 : (유저이름),(메세지 내용),(날짜),(좋아요),(프로필 이미지)
-내가 보냈을 경우/상대방이 보냈을 경우 --> 두가지 형식의 버블챗 구현
-다른 유저가 보낸 메세지의 경우 : (연속 두번 탭) 메세지 좋아요 기능 구현
-프로필에서 설정한 각자의 이미지 보여줌
*/

class ChatBubbles extends StatefulWidget {
  final String rcvUserName; //받는 유저 이름
  final String message; //메세지 내용
  final String sendUserName; //보낸 유저 이름
  final bool isMe; // 내가 보냈을 때를 구별
  final DateTime time;
  final String userUid;

  const ChatBubbles(
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
      userUid: userUid);
}

class _ChatBubblesState extends State<ChatBubbles> {
  String rcvUserName;
  String message;
  String sendUserName;
  bool isMe; // 내가 보냈을 때를 구별
  DateTime time;
  bool likeMessage = false;
  String userUid;
  String userProfileImage = ''; //유저들의 이미지 링크를 처음 초기화
  bool _isProfile = false; //파일의 유무를 초기화

  //유저의 프로필 사진이 세팅되어 있을 경우 가져오고, 아닐 경우 기본 이미지 보여줌
  void setUserProfile() async {
    FirebaseFirestore.instance
        .collection('user')
        .where('userUid', isEqualTo: userUid)
        .get()
        .then((value) {
      for (var snapshot in value.docs) {
        //셋팅되어 있는경우
        if(snapshot['profileImageUrl'].toString() != 'No setting Image'){
          setState(() {
            userProfileImage = snapshot['profileImageUrl'];
            _isProfile = true;
          });
        }
          print('---------Profile--------');
          print(snapshot['profileImageUrl']);
          print('${userUid} : $userProfileImage');
          print('isProfile : ${_isProfile}');
      }
    });
  }

  //유저가 이전에 메세지의 좋아요를 눌렀는지 확인하는 함수
  void searchMessage() {
    FirebaseFirestore.instance
        .collection('chat')
        .where('text', isEqualTo: message)
        .get()
        .then((value) {
      print('------likemessage ------');
      for (var docSnapshot in value.docs) {
        setState(() {
          likeMessage = docSnapshot['likeMessage'];
        });
      }
      onError:
      (e) => print("Error completing: $e");
    });
  }

  _ChatBubblesState({
    required this.message,
    required this.isMe,
    required this.sendUserName,
    required this.rcvUserName,
    required this.time,
    required this.userUid,
  });

  @override
  void initState() {
    super.initState();
    searchMessage();
    setUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isMe) //내가 보낸 경우의 채팅형식
              Stack(
                children:
                [
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
                  if (_isProfile) //나의 프로필이 세팅되어 있으면
                    Positioned(
                      top: 20,
                      right: 5,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(userProfileImage),
                      ),
                    ),
                  if (!_isProfile) //나의 프로필이 세팅되어 있지 않으면
                    Positioned(
                      top: 20,
                      right: 5,
                      child: CircleAvatar(
                        child : Image.asset('asset/image/animal_neko.png'),
                      ),
                    ),]
              ),
            if (!isMe) //상대방이 보낸 경우
              Stack(
                children:
                [
                  if (_isProfile) //상대방의 프로필이 설정되어 있는 경우
                    Positioned(
                      top: 20,
                      left: 5,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(userProfileImage),
                      ),
                    ),
                  if (!_isProfile) //상대방의 프로필이 설정되어 있지 않은 경우
                    Positioned(
                      top: 20,
                      left: 5,
                      child: CircleAvatar(
                        child : Image.asset('asset/image/animal_neko.png'),
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
                            clipper: ChatBubbleClipper8(
                                type: BubbleType.receiverBubble),
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
                        GestureDetector( //상대방의 메세지에 좋아요 누르는 기능
                          onDoubleTap: () {
                            if (!likeMessage) { //좋아요가 안되어있으면 파베에 저장
                              setState(() {
                                Map<String, bool> map = {
                                  'likeMessage': true,
                                };
                                FirebaseFirestore.instance
                                    .collection('chat')
                                    .where('text', isEqualTo: message)
                                    .get()
                                    .then((value) {
                                  print('------likemessage ------');
                                  for (var docSnapshot in value.docs) {
                                    setState(() {
                                      String chatId = docSnapshot.id;
                                      FirebaseFirestore.instance
                                          .collection('chat')
                                          .doc(chatId)
                                          .update(map);
                                      likeMessage = docSnapshot['likeMessage'];
                                    });
                                  }
                                  onError:
                                  (e) => print("Error completing: $e");
                                });
                              });
                            }
                            if (likeMessage) { //좋아요가 되어있으면 파베에서 삭제
                              setState(() {
                                Map<String, bool> map = {
                                  'likeMessage': false,
                                };
                                FirebaseFirestore.instance
                                    .collection('chat')
                                    .where('text', isEqualTo: message)
                                    .get()
                                    .then((value) {
                                  print('------likemessage ------');
                                  for (var docSnapshot in value.docs) {
                                    setState(() {
                                      String chatId = docSnapshot.id;
                                      FirebaseFirestore.instance
                                          .collection('chat')
                                          .doc(chatId)
                                          .update(map);
                                      likeMessage = docSnapshot['likeMessage'];
                                    });
                                  }
                                  onError:
                                  (e) => print("Error completing: $e");
                                });
                              });
                            }
                          },
                          child: likeMessage //좋아요의 상태에 따라 보여주는 이모티콘
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
                ),]
              ),
          ],
    );
  }
}
