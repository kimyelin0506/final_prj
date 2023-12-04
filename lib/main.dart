import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_prj/screen/chat_screen.dart';
import 'package:final_prj/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_prj/screen/login_signUp_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions, Firebase;
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  // 플러터에서 사용하는 플러그인을 초기화 할 때 이 플러그인에
  //초기화 메소드가 비동기 방식일 경우 문제 발생
  // 플러터에서 firebase를 이용하기 위해 사용되는 초기화 메소드인 Firebase.initializeApp()은 비동기 방식
  //따라서 통신을 하기 위해서는 최상위 메소드인 runApp()을 실행하기 전까지 플러터 엔진이 초기화 되지 않아 접근을 할 수 없음
  //--> 따라서 사용하기 위해 플러터 코어 엔진을 초기화 시켜줘야함
  //--> WidgetsFlutterBinding.ensureInitialized();이 그 기능을 처리
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  KakaoSdk.init(
    nativeAppKey: '8a2e2681fe7d5ce926ef755864619db3',
    javaScriptAppKey: '03bf351027d9ff04c740f35cad592c45',
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData){ //인증받은 데이터가 존재할 시
            return HomeScreen();
          }
          return LoginSignupScreen();
        },
      ),
    )
  );
}
