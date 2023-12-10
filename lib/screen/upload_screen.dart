import 'dart:io';

import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:final_prj/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_prj/resources/add_data.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:final_prj/resources/add_data.dart';


//사용자가 게시물 올릴때 작성하는 화면

class UploadScreen extends StatefulWidget{

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<UploadScreen> {
  Uint8List? _file;
  bool _isLoading = false;

  int num=0;
  final textEditingController = TextEditingController();  //텍스트필드를 수정할때마다 값이 업데이트 & 컨트롤러는 해당 listener에게 알림
  String fromWhere='';
  final _authentication = FirebaseAuth.instance;


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
        title: Text('오늘 본 고양이 소개해주세요!').tr(),
        centerTitle: true,
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: Icon(Icons.add_box_outlined, size: 30.0),
          onPressed: (){
            postImage();
            num++;
            Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
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
                  Uint8List file = await getImage(ImageSource.camera);
                  setState(() {
                    _file = file;
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
                  Uint8List file = await getImage(ImageSource.gallery);
                  setState(() {
                   _file =file;
                  });
                },
              ),
            ],
          )
      ],
      )
    );
  }

  showSnackBar(String content,BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
  }

  //upload 되었나?
  void postImage() async{
    setState(() {
      _isLoading = true;
    });

    try{
      String res = await ImageStoreMethods().uploadPost(textEditingController.text, _file!, _authentication.currentUser!.email!);
      if(res == 'success'){
        showSnackBar('posted', context);
       setState((){
          _isLoading = false;
        });
      }else{
        setState(() {
          _isLoading = false;
        });
      }
    }catch(e){
      showSnackBar(e.toString(), context);
    }
  }


  //이미지를 어디서 가져올지?
  Future getImage(ImageSource imageSource) async {
   final ImagePicker imagePicker = ImagePicker();
   XFile? file = await imagePicker.pickImage(source: imageSource);
   if(file != null){
     return await file.readAsBytes();
   }
   print('no image selected');
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
              child: _file == null?
                Text('No image') :
              Container(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  image: DecorationImage(
                  image: MemoryImage(_file!),
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.topCenter,
              )) ,),
            ),
          ),
          TextField(
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(hintText: tr('오늘의 고양이에 대해 입력해주세요')),
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
        _isLoading == true? const LinearProgressIndicator() : const Padding(padding: EdgeInsets.only(top: 0)),
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
                Text('${_authentication.currentUser!.email}',style: TextStyle(fontSize: 25),),  //인스타ID
              ]
          ),
        ),
        //게시글 보이는 곳
        Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(_file!),
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.center,
                      )
                    ),
                  ),
                ),
                const Divider(),
                SizedBox(
                  width: MediaQuery.of(context).size.width *0.35,
                  child: Text(textEditingController.text,style: TextStyle(fontStyle: FontStyle.italic ),),
                ),
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


