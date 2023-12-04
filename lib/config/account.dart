// 필요한 패키지 및 파일을 가져오기
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'NavBar.dart';

// 'Account' 화면을 위한 StatefulWidget 생성
class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

// 'Account' 화면의 상태를 관리하는 클래스 생성
class _AccountState extends State<Account> {
  PickedFile? _imageFile;
  final ImagePicker _picker = ImagePicker();


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
                    // 프로필 사진을 원 모양의 테두리로 감싼 원형 컨테이너
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey, // 테두리 색상
                          width: 2.0, // 테두리 두께
                        ),
                      ),
                      // ClipOval은 자식(프로필 사진)을 원 모양으로 자름
                      child: ClipOval(
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: _imageFile == null
                              ? AssetImage('asset/img/animal_neko.png')
                              : FileImage(
                              File(_imageFile!.path)) as ImageProvider<Object>?,
                        ),
                      ),
                    ),
                    // Positioned 위젯은 특정 위치에 자식을 배치할 수 있음
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(context: context,
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
              buildTextField("이름", "고양이"),
              buildTextField("이메일", "meowmeow@gmail.com"),
              buildTextField("최애 고양이", "온순이"),
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
                      onPressed: () {
                        Navigator.pop(context, _imageFile);
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

    //텍스트입력
  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: TextField(
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 5),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            )),
      ),
    );
  }

  getImage() {
    return Container(
      height: 100,
      width: MediaQuery
          .of(context)
          .size
          .width,
      margin: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20
      ),
      child: Column(
        children: <Widget>[
          Text('변경할 프로필 사진을 골라주세요',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                icon: Icon(Icons.camera, size: 30,),
                label: Text('촬영하기', style: TextStyle(fontSize: 20),),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                icon: Icon(Icons.photo_album, size: 30,),
                label: Text('파일 가져오기', style: TextStyle(fontSize: 20),),
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
