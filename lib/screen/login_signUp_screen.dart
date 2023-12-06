import 'package:final_prj/add_image/add_image.dart';
import 'package:final_prj/screen/chat_screen.dart';
import 'package:final_prj/screen/home_screen.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../config/palette.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import '../../config/login_platform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //userID는 엑스트라데이터이므로


// class 안에서 변화되는 인스턴스를 적용하기 위해 statefulwidget 사용
class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

// 로그인/ 회원 가입 하는 창 보여주는 Screen 구성
class _LoginSignupScreenState extends State<LoginSignupScreen> {
  //소셜 로그인
  bool _loginStatus = false; //로그인 상태
  LoginPlatform _loginPlatform = LoginPlatform.none;
  //일반 로그인
  bool isSignupScreen = true; // login창 선택인지  signup 창 선택인지 판단하는 변수
  final _formKey = GlobalKey<FormState>(); //form에서 사용하는 전역키
  String userName = '';
  String userEmail = '';
  String userPassWord = '';
  final _authentication = FirebaseAuth.instance; //사용자의 등록/인증

  bool showSpinner = false;

  void showAlert(BuildContext context) {
    //호출되면 위젯트리에 삽입되어야 하므로 인자ㄱ밧이 context
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: AddImage()
          );
        });
  }

  //form이 유효한지 확인 -> 유효하면 null값 전달됨
  void _tryValidation() {
    //모든 텍스트필드에 있는 validate를 실행 시킬 수 있음
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      print('name = ${googleUser.displayName}');
      print('email = ${googleUser.email}');
      print('id = ${googleUser.id}');

      setState(() {
        _loginPlatform = LoginPlatform.google;
        _loginStatus = true;
      });
    }
  }

  void signInWithKakao() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      final url = Uri.https('kapi.kakao.com', '/v2/user/me');

      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}'
        },
      );

      final profileInfo = json.decode(response.body);
      print(profileInfo.toString());

      setState(() {
        _loginPlatform = LoginPlatform.kakao;
        _loginStatus = true;
      });
    } catch (error) {
      print('카카오톡으로 로그인 실패: $error');
    }
  }

  void signInWithNaver() async {
    final NaverLoginResult result = await FlutterNaverLogin.logIn();

    if (result.status == NaverLoginStatus.loggedIn) {
      print('accessToken = ${result.accessToken}');
      print('id = ${result.account.id}');
      print('email = ${result.account.email}');
      print('name = ${result.account.name}');

      setState(() {
        _loginPlatform = LoginPlatform.naver;
        _loginStatus = true;
      });
    } else {
      print('Naver login failed. Status: ${result.status}');
    }
  }

  void signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final url = Uri.https('graph.facebook.com', '/v2.12/me', {
        'fields': 'id, email, name',
        'access_token': result.accessToken!.token
      });

      final response = await http.get(url);

      final profileInfo = json.decode(response.body);
      print(profileInfo.toString());

      setState(() {
        _loginPlatform = LoginPlatform.facebook;
        _loginStatus = true;
      });
    } else {
      print('Facebook login failed. Status: ${result.status}');
    }
  }

  signOut() async {
    switch (_loginPlatform) {
      case LoginPlatform.google:
        await GoogleSignIn().signOut();
        break;
      case LoginPlatform.kakao:
        await UserApi.instance.logout();
        break;
      case LoginPlatform.naver:
        await FlutterNaverLogin.logOut();
        break;
      case LoginPlatform.facebook:
        await FacebookAuth.instance.logOut();
        break;
      case LoginPlatform.none :
        await _authentication.signOut();
        break;
    }
    setState(() {
      _loginPlatform = LoginPlatform.none;
      _loginStatus = false;
    });
  }

  Widget _logoutButton() {
    return ElevatedButton(
      onPressed: signOut,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          const Color(0xff0165E1),
        ),
      ),
      child: const Text('로그아웃'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      // Column과 row는 두 개의 도형이나 사진이 겹쳐있는 듯한 위젯을 구현하기 어려움
      // 원하는 곳에 배치하는 stack/Positioned 사용
      body: ModalProgressHUD(
        inAsyncCall: showSpinner, //전송버튼을 누르면 스피너가 true로 실행되어야함
        child: GestureDetector(
          onTap: (){ //다른 곳을 눌렀을 떄 키보드 내려감
            FocusScope.of(context).unfocus();
          },
          child: Stack( //세개의 position
            children: [
              // 배경
              Positioned(
                //맨 위부터 위치
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  //배경 이미지 보여주는 Container
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('asset/image/ex_image1.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Container(
                    //어플 이름/제목을 보여주는 Container
                    padding: EdgeInsets.only(top: 90, left: 20),
                    child: Column(
                      //대제목과 소제목의 textStyle을 다르게 하고 배치하기 위해
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          //다양한 스타일이 혼합된 텍스트를 사용하기 위해
                          text: TextSpan(
                            children: [
                              TextSpan(
                                //앱 이름 강조
                                text: '안서동 고양이 SNS',
                                style: TextStyle(
                                  letterSpacing: 1.0,
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold, //text의 굵기를 두껍게
                                ),
                              ),
                              TextSpan(
                                text: '에 오신 걸 환영합니다!',
                                style: TextStyle(
                                  letterSpacing: 1.0,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          //다음 줄에 간격 부여
                          height: 5.0,
                        ),
                        Text(
                          //소제목
                          '안서동 고양이와 함께하고 싶다면 로그인을 해주세요.',
                          style: TextStyle(
                            letterSpacing: 1.0,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // login/sign up 필드
              AnimatedPositioned( //애니메이션 효과
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: 180.0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  padding: EdgeInsets.all(20.0),
                  //요소들을 Container안에 위아래양옆 간격을 줌
                  height: isSignupScreen ? 250.0 : 190.0,
                  width: MediaQuery.of(context).size.width - 40,
                  // 각 디바이스의 실제 넓이 불러옴 - 40 이유 : 전체크기에서 -20-20
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  //대칭적으로 수평(horizontal), 수직(vertical) 기준으로 여백 지정 가능
                  // 좌우 여백
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0), // 모서리 둥글게
                    boxShadow: [
                      //그림자 효과, 여러 색을 처리하므로 리스트 형태
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), //투명도 조절
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Row(
                          //login / sign up 양옆으로 배치
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //login gesture 처리
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = false;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      // 삼항 연산자를 통해 onTap시 바뀌는 isSignupScreen의 bool값에 따라 색이 변함
                                      color: isSignupScreen
                                          ? Palette.textColor1
                                          : Palette.activeColor,
                                    ),
                                  ),
                                  if (!isSignupScreen)
                                    Container(
                                      margin: EdgeInsets.only(top: 3),
                                      height: 2,
                                      width: 55,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                            ),
                            //sign up gesture 처리
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = true;
                                });
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSignupScreen
                                              ? Palette.activeColor
                                              : Palette.textColor1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          showAlert(context);
                                        },
                                        child: Icon(Icons.image,
                                        color: isSignupScreen ? Colors.cyan : Colors.grey[300],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSignupScreen)
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0,3,35,0),
                                      height: 2,
                                      width: 55,
                                      color: Colors.orange,
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!isSignupScreen)
                          Container(
                            margin: EdgeInsets.only(top: 20), //위의 간격
                            child: Form(
                              //값을 여러개 받기 때문에 form으로 처리
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    //이메일용 키보드 타입 불러오기
                                    keyboardType: TextInputType.emailAddress,
                                    key: ValueKey(1),
                                    validator: (value){
                                      if(value!.isEmpty || value.length <4){
                                        return '4글자 이상 입력해 주세요';
                                      }
                                      return null;
                                    },
                                    //사용자가 입력한 value값 저장하는 메소드
                                    onSaved: (value){
                                      userEmail = value!;
                                    },
                                    onChanged: (value){
                                      userEmail = value;
                                    },
                                    //여러개의 컨트롤러를 사용하기 쉬움
                                    decoration: InputDecoration(
                                      //icon 넣어주는 기능
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        //클릭 없이 평소 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        //클릭 있을 시 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: '이메일을 입력하세요',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10), //
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    //비밀번호 가리기
                                    obscureText: true,
                                    key: ValueKey(2),
                                    validator: (value){
                                      if(value!.isEmpty || value.length < 6){  //파이어베이스 최소 길이
                                        return '비밀번호는 최소 6글자 이상이여야 합니다';
                                      }
                                      return null;
                                    },
                                    onSaved: (value){
                                      userPassWord = value!;
                                    },
                                    onChanged: (value){
                                      userPassWord = value;
                                    },
                                    //여러개의 컨트롤러를 사용하기 쉬움
                                    decoration: InputDecoration(
                                      //icon 넣어주는 기능
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        //클릭 없이 평소 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        //클릭 있을 시 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: '비밀번호를 입력하세요',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10), //
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (isSignupScreen)
                          Container(
                            margin: EdgeInsets.only(top: 20), //위의 간격
                            child: Form(
                              //값을 여러개 받기 때문에 form으로 처리
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: ValueKey(3),
                                    validator: (value){ //유효성 검사
                                      if(value!.isEmpty || value.length < 4){
                                        return '4글자 이상 입력해 주세요';
                                      }
                                      return null;
                                    },
                                    onSaved: (value){
                                      userName = value!;
                                    },
                                    onChanged: (value){
                                      userName = value;
                                    },
                                    //여러개의 컨트롤러를 사용하기 쉬움
                                    decoration: InputDecoration(
                                      //icon 넣어주는 기능
                                      prefixIcon: Icon(
                                        Icons.account_circle,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        //클릭 없이 평소 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        //클릭 있을 시 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: '이름을 입력하세요',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10), //
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    key: ValueKey(4),
                                    validator: (value){
                                      if(value!.isEmpty || !value.contains('@')){
                                        return '이메일의 형식으로 입력해 주세요';
                                      }
                                      return null;
                                    },
                                    onSaved: (value){
                                      userEmail = value!;
                                    },
                                    onChanged: (value){
                                      userEmail = value;
                                    },
                                    //여러개의 컨트롤러를 사용하기 쉬움
                                    decoration: InputDecoration(
                                      //icon 넣어주는 기능
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        //클릭 없이 평소 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        //클릭 있을 시 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: '이메일을 입력하세요',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10), //
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    key: ValueKey(5),
                                    validator: (value){
                                      if(value!.isEmpty || value.length < 6){  //파이어베이스 최소 길이
                                        return '비밀번호는 최소 6글자 이상이여야 합니다';
                                      }
                                      return null;
                                    },
                                    onSaved: (value){
                                      userPassWord = value!;
                                    },
                                    onChanged: (value){
                                      userPassWord = value;
                                    },
                                    //여러개의 컨트롤러를 사용하기 쉬움
                                    decoration: InputDecoration(
                                      //icon 넣어주는 기능
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        //클릭 없이 평소 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        //클릭 있을 시 테두리 설정
                                        borderSide: BorderSide(
                                          color: Palette.textColor1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(35.0),
                                        ),
                                      ),
                                      hintText: '비밀번호를 입력하세요',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Palette.textColor1,
                                      ),
                                      contentPadding: EdgeInsets.all(10), //
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // 전송 버튼
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: isSignupScreen ? 410 : 350,
                right: 0,
                left: 0,
                child: Center(
                  child: GestureDetector( //터치 처리
                    onTap: () async { //새로운 사용자 등록이 끝난 후에 그 다음 과정이 진행되어야 하므로
                      setState(() {
                        showSpinner = true; //spinner end
                      });
                      if(isSignupScreen){
                        _tryValidation();
                        // try catch를 사용하여 오류가 났을 경우 앱이 다운되거나 멈추는 것을 방지하고 사용자에게 이유를 설명함
                        try{
                          final newUser = await _authentication.createUserWithEmailAndPassword(
                            email: userEmail,
                            password: userPassWord,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('가입 되셨습니다! 로그인을 진행해 주세요.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          //data의 형태는 map
                          await FirebaseFirestore.instance.collection('user')
                              .doc(newUser.user!.uid).set({
                            'userName' : userName,
                            'email' : userEmail,
                          });
                          setState(() {
                            showSpinner = false; //spinner end
                          });
                        }catch(e){
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('가입 입력 양식을 확인해주세요'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            showSpinner = false; //spinner end
                          });
                        }
                      }
                      //loginScreen
                      if(!isSignupScreen){
                        _tryValidation();
                        try{
                          final newUser =
                          await _authentication.signInWithEmailAndPassword(
                            email: userEmail,
                            password: userPassWord,
                          );
                          if (newUser.user != null) {
                            _loginStatus = true;
                            Navigator.push(
                              context,
                              //화면 전환
                              MaterialPageRoute(
                                builder: (context) {
                                  return HomeScreen();
                                },
                              ),
                            );
                            setState(() {
                              showSpinner = false; //spinner end
                            });
                          }
                        }catch(e){
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('등록되지 않은 계정입니다'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            showSpinner = false; //spinner end
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 60,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.white,],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0,1)//한 지점에서 다른 지점에서의 거리
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 소셜 로그인
              AnimatedPositioned(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    top: isSignupScreen
                        ? MediaQuery.of(context).size.height - 180
                        : MediaQuery.of(context).size.height - 200,
                    right: 0,
                    left: 0,
                    child: Column(
                      children: [
                        Text(isSignupScreen
                            ? 'or Sign Up With'
                            : 'or Sign in With'),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                signInWithGoogle();
                              },
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                minimumSize: Size(155, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Palette.googleColor,
                              ),
                              icon: Icon(Icons.add),
                              label: Text('Google'),
                            ),
                            SizedBox(
                              height: 5,
                              width: 10,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                signInWithKakao();
                              },
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                minimumSize: Size(155, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Palette.googleColor,
                              ),
                              icon: Icon(Icons.add),
                              label: Text('Kakao'),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                signInWithNaver();
                              },
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                minimumSize: Size(155, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Palette.googleColor,
                              ),
                              icon: Icon(Icons.add),
                              label: Text('Naver'),
                            ),
                            SizedBox(
                              height: 5,
                              width: 10,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                // signInWithFacebook();
                              },
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                minimumSize: Size(155, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Palette.googleColor,
                              ),
                              icon: Icon(Icons.add),
                              label: Text('FaceBook'),
                            )
                          ],
                        ),
                      ],
                    ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
/*

 */