import 'package:easy_localization/easy_localization.dart';
import 'package:final_prj/screen/home_screen.dart';
import 'package:final_prj/screen/root_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_prj/resources/add_data.dart';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';


//사용자가 게시물 올릴때 작성하는 화면

class UploadScreen extends StatefulWidget{

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<UploadScreen> {
  Uint8List? _file;
  bool _isLoading = false;
  double _longitude=0;
  double _latitude=0;
  int num=0;
  final textEditingController = TextEditingController();  //텍스트필드를 수정할때마다 값이 업데이트 & 컨트롤러는 해당 listener에게 알림
  String fromWhere='';
  final _authentication = FirebaseAuth.instance;
  var _controller;


  @override
  void initState() {
    // TODO: implement initState
    _currentLocation();
    super.initState();
  }

  //위젯이 dispose될때 textEditingController도 dispose 되도록 설정
  @override
  void dispose(){
    textEditingController.dispose();
    _controller.dispose();
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
            Navigator.push(context, MaterialPageRoute(builder: (context)=> RootScreen()));
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

  void _currentLocation() async {
    //GoogleMapController controller = await _controller.future;
    Location location = Location();
    var currentLocation = await location.getLocation();
    if(this.mounted){
      setState(() {
        _latitude = currentLocation.latitude!;
        _longitude =currentLocation.longitude!;
      });
    }

  }


  //upload 되었나?
  void postImage() async{
    setState(() {
      _isLoading = true;
    });

    try{
      String res = await ImageStoreMethods()
          .uploadPost(
          textEditingController.text, _file!,
          _authentication.currentUser!.email!,
          _longitude ,_latitude
      );
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

  void selectLocation(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            shadowColor: Colors.black,
            title:
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  '고양이 위치 저장하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content:   new Text('고양이를 본 위치를 저장해 주세요',
                style: TextStyle(fontSize: 15, color: Colors.black)),
            actions: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new ElevatedButton(
                    onPressed: () {
                      //_currentLocation();
                      print(_longitude );
                      print(_latitude);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '현재 위치',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 15,),
                  new ElevatedButton(
                    onPressed: () {
                      mapDialog();
                    },
                    child: Text(
                      '위치 지정',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }


  mapDialog(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            shadowColor: Colors.black,
            title:
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  '고양이 위치 지정하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Container(child: selectLocationWithMap(),),
            actions: <Widget>[
              new ElevatedButton(
                onPressed: () {

                },
                child: Text(
                  '여기에요!',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              )
            ],
          );
        });
  }
  GoogleMap selectLocationWithMap(){
    CameraPosition _select =CameraPosition(target: LatLng(_latitude, _longitude), zoom: 15);
    return GoogleMap(
      initialCameraPosition: _select,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
  //이미지&게시글 보여주기
  Widget showImage(){
    return SingleChildScrollView(
      child: Column(
        children: [
          TextButton(
            onPressed: (){
              selectLocation();
              },
              child: Text('고양이 위치 저장하기'),
          ),
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


