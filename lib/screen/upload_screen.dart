import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

//사용자가 게시물 올릴때 작성하는 화면

//final storage = FirebaseFirestore.instance; //cloud storage에 access 하는 객체 생성

class UploadScreen extends StatefulWidget{

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<UploadScreen> {
  int num=0;

  //텍스트필드를 수정할때마다 값이 업데이트 & 컨트롤러는 해당 listener에게 알림
  final textEditingController = TextEditingController();

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
            onSave(context);  //사용자가 쓴 사진과 게시글을 가지고 홈스크린으로 가져가야하는데 아직 구현못했음
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
                onPressed: () {
                  getImage(ImageSource.camera);
                },
              ),

              // 갤러리에서 이미지를 가져오는 버튼
              FloatingActionButton(
                child: Icon(Icons.wallpaper),
                backgroundColor: Colors.black,
                //tooltip: 'pick Iamge',
                heroTag: 'gallery',
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
              ),
            ],
          )
      ],
      )
    );
  }

  File? _image;
  final _picker = ImagePicker();

  //이미지를 어디서 가져올지?
  Future getImage(ImageSource imageSource) async {
    final image = await _picker.pickImage(source: imageSource);

    setState(() {
      _image = File(image!.path); // 가져온 이미지를 _image에 저장
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

  void onSave(BuildContext context) async{
    //파베이용해서 구현해야함

    /*final feed = UploadModel(
      text: text!
    );

    await FirebaseFirestore.instance
        .collection('Feed')
        .doc(feed.text)
        .set(feed.toJson());
    */
    Navigator.pop(context);
  }
}
