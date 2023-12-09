// 필요한 패키지 및 파일을 가져오기
import 'dart:developer';
import 'dart:ffi';

import 'package:final_prj/model/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import '../resources/add_data.dart';
import 'NavBar.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

// 'Account' 화면을 위한 StatefulWidget 생성
class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

// 'Account' 화면의 상태를 관리하는 클래스 생성
class _AccountState extends State<Account> {
  PickedFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserUid;
  bool _isLoading = false;
  Uint8List? _image;

  TextEditingController _facatController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  UserModel? currentUser;

  Future<void> getCurrentUser() async {
    var user = FirebaseAuth.instance.currentUser;

    currentUserUid = user!.uid;

    // Firestore에서 사용자 정보 가져오기
    var userData = await firestore.collection('user').doc(currentUserUid).get();
    print('Debug: Firestore 데이터 - $userData');

    setState(() {
      currentUser = UserModel.fromMap(userData.data()!);
      // 이미지 URL이 있으면 해당 이미지를 표시하고, 없으면 기본 이미지를 표시
      if (currentUser?.profilePic != null) {
        _imageFile = null; // 이미지 파일을 null로 설정하여 기본 이미지 표시
      } else {
        _imageFile = PickedFile(
            'asset/image/animal_neko.png'); // 또는 여기에 기본 이미지를 설정하는 코드를 추가할 수 있음
      }
    });
    log(' debug 유저아이디가져오기: $currentUserUid');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getCurrentUser();
    });
  }

  Future<String> uploadImageToStorage(Uint8List file) async {
    Reference ref =
        _storage.ref().child('profile').child('$currentUserUid.jpg');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

//uploadImageToStorage('profileImage',file);

  @override
  Widget build(BuildContext context) {
    // Scaffold 위젯은 기본적인 재료 디자인 시각적 구조를 나타냄
    return Scaffold(
      // AppBar은 화면 상단에 제목 및 선택적 작업을 표시
      appBar: AppBar(
        title: Text('프로필 변경'), // AppBar 제목 설정
        centerTitle: true, // 제목 가운데 정렬
        elevation: 0.0, // AppBar 아래 그림자 없음
      ),
      drawer: NavBar(), // 드로어 (사이드 메뉴)에 NavBar 위젯 사용
      // 화면의 본문
      body: Container(
        // 컨테이너 내부의 콘텐츠에 대한 패딩
        padding: EdgeInsets.only(left: 15, top: 20, right: 15),
        // GestureDetector는 텍스트 필드 외부를 탭할 때 키보드를 해제하는 기능 제공
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // 키보드 해제
          },
          // ListView는 콘텐츠가 화면을 벗어날 때 스크롤 가능하게 함
          child: ListView(
            children: [
              // 프로필 사진 섹션
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: ClipOval(
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: (_imageFile == null &&
                                  currentUser?.profilePic == null)
                              ? AssetImage(
                                  'asset/image/animal_neko.png') // 기본 이미지 설정
                              : (_imageFile != null)
                                  ? FileImage(File(_imageFile!.path))
                                      as ImageProvider<Object>?
                                  : NetworkImage(currentUser!
                                      .profilePic!), // Firebase의 이미지 URL 사용
                        ),
                      ),
                    ),
                    // Positioned 위젯은 특정 위치에 자식을 배치할 수 있음
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: ((builder) => getImage()));
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 4, color: Colors.white),
                              color: Colors.blue),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30), // 레이아웃을 위한 빈 공간
              // 사용자 정보를 입력받는 텍스트 필드
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 5),
                    labelText: tr('name'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: currentUser?.name ?? '',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    )),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 5),
                    labelText: tr('email'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: currentUser?.email ?? '',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    )),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _facatController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 5),
                    labelText: tr('facat'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: currentUser?.facat ?? '',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    )),
              ),
              SizedBox(height: 30), // 레이아웃을 위한 빈 공간
              // 변경 내용을 취소하거나 저장하기 위한 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 취소 버튼
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("CANCEL",
                        style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 2,
                            color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  // 저장 버튼
                  ElevatedButton(
                      onPressed: () async {
                        String nameText = _nameController.text;
                        String emailText = _emailController.text;
                        String facatText = _facatController.text;

                        if (_imageFile != null) {
                          Uint8List file = await _imageFile!
                              .readAsBytes(); // PickedFile을 Uint8List로 변환
                          String imageUrl = await uploadImageToStorage(file);

                          // 이미지 URL을 Firestore에 저장
                          var userDocRef =
                              firestore.collection('user').doc(currentUserUid);
                          await userDocRef
                              .update({'profileImageUrl': imageUrl});
                        }

                        if (nameText.isNotEmpty) {
                          // Firestore에 저장
                          var userDocRef =
                              firestore.collection('user').doc(currentUserUid);
                          await userDocRef.update({'userName': nameText});
                        }

                        if (emailText.isNotEmpty) {
                          var userDocRef =
                              firestore.collection('user').doc(currentUserUid);
                          await userDocRef.update({'email': emailText});
                        }

                        if (facatText.isNotEmpty) {
                          var userDocRef =
                              firestore.collection('user').doc(currentUserUid);
                          await userDocRef.update({'facat': facatText});
                        }

                        await getCurrentUser();
                        Navigator.pop(context);
                      },
                      child: Text("SAVE",
                          style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 2,
                            color: Colors.white,
                          )),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  getImage() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          Text(
            '변경할 프로필 사진을 골라주세요',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                icon: Icon(
                  Icons.camera,
                  size: 30,
                ),
                label: Text(
                  '촬영하기',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                icon: Icon(
                  Icons.photo_album,
                  size: 30,
                ),
                label: Text(
                  '파일 가져오기',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }
}
