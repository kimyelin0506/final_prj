import 'dart:io';

import 'package:bootpay/model/user.dart';
import 'package:final_prj/screen/home_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

//사용자가 게시물 올릴때 작성하는 화면

class UploadScreen extends StatefulWidget{

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<UploadScreen> {
  int num=0;
  User? loggedUser; //초기화 시키지 않을 것임
  final textEditingController = TextEditingController();  //텍스트필드를 수정할때마다 값이 업데이트 & 컨트롤러는 해당 listener에게 알림
  String fromWhere='';


  //위젯이 dispose될때 textEditingController도 dispose 되도록 설정
  @override
  void dispose(){
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //세로로만 찍을 수 있게
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return Scaffold(
      appBar:AppBar(
        title: Text('오늘 본 고양이 소개해주세요!'),
        centerTitle: true,
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: Icon(
            Icons.add_box_outlined,
            size: 30.0,
          ),
          onPressed: (){
            num++;
            Get.to(HomeScreen(),arguments: uploadPost());
          },
        ),
      ) ,
      resizeToAvoidBottomInset: false, //타자 칠때 bottom overflow 방지

        body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          showImage(),  //사진 보여주기
          SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                child: Icon(Icons.add_a_photo),
                backgroundColor: Colors.black,
                //tooltip: 'pick Iamge',
                heroTag: 'camera',
                onPressed: () async{
                  fromWhere = 'camera';
                  getImage(ImageSource.camera);
                  setState(() {
                    _image = XFile(_image!.path); // 가져온 이미지를 _image에 저장
                    print(_image!.path);
                  });
                },
              ),

              // 갤러리에서 이미지를 가져오는 버튼
              FloatingActionButton(
                child: Icon(Icons.wallpaper),
                backgroundColor: Colors.black,
                //tooltip: 'pick Iamge',
                heroTag: 'gallery',
                onPressed: () async{
                  fromWhere = 'gallery';
                  getImage(ImageSource.gallery);
                  setState(() {
                    _image = XFile(_image!.path);
                    print(_image!.path);
                  });
                },
              ),
            ],
          )
      ],
      )
    );
  }

  XFile? _image;
  final _picker = ImagePicker();

  //이미지를 어디서 가져올지?
  Future getImage(ImageSource imageSource) async {
    final image = await _picker.pickImage(source: imageSource);

    setState(() {
      _image = XFile(image!.path); // 가져온 이미지를 _image에 저장
      print('가져온 이미지 경로: ${image.path}');
    });
  }

  //이미지&게시글 보여주기
  Widget showImage(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: const Color(0xffd0cece),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Center(
              child: _image == null? Text('No image') : Image.file(File(_image!.path)),
            ),
          ),
          TextField(
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(hintText: '오늘의 고양이에 대해 입력해주세요'),
            controller: textEditingController,
          )
        ],
      ),
    );


  }
  // 하나의 게시글 해당
  Widget uploadPost() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 80,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Row(
              children: [
                CircleAvatar(  //프로필
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text('${loggedUser}',style: TextStyle(fontSize: 25),),  //인스타ID
              ]
          ),
        ),
        //게시글 보이는 곳
        Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  color: Colors.grey,
                  child: Image.file(File(_image!.path)), //사진 보여줄 곳
                ),
                Container(
                  color: Colors.black54,
                  width: MediaQuery.of(context).size.width,
                  height: 20,
                  child: Text(textEditingController.text), //쓴 글 보여주기
                )
              ],
            )
        ),
        Container(
          height: 45,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Icon(Icons.favorite_border,),
              SizedBox(width:7),
              Icon(Icons.chat_outlined),
              SizedBox(width:7),
            ],
          ),
        ), //좋아요
        Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            color: Colors.black26,
            child: TextField(style: TextStyle(fontSize: 18,fontWeight: FontWeight.normal),)
        ),
      ],
    );
  }
}
