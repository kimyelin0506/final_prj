import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_prj/config/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:final_prj/config/account.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../screen/home_screen.dart';
import '../screen/login_signUp_screen.dart';
import 'dart:developer';
import 'package:final_prj/model/usermodel.dart';

enum MenuType {
  english,
  korean,
  japanese,
}

class NavBar extends StatefulWidget {
  const NavBar({Key? key}):super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}



class _NavBarState extends State<NavBar>{



  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language').tr(),
          content: Column(
            children: [
              _buildLanguageOption(MenuType.english, tr('english')),
              _buildLanguageOption(MenuType.korean, tr('korean')),
              _buildLanguageOption(MenuType.japanese, tr('japanese')),
            ],
          ),
        );
      },
    );
  }

  // AlertDialog에서 선택한 언어로 변경
  void _changeLanguage(MenuType type) {
    switch (type) {
      case MenuType.english:
        context.setLocale(Locale('en', 'US'));
        break;
      case MenuType.korean:
        context.setLocale(Locale('ko', 'KR'));
        break;
      case MenuType.japanese:
        context.setLocale(Locale('ja', 'JP'));
        break;
    }
    Navigator.pop(context); // AlertDialog 닫기
  }

  // 언어 옵션 위젯
  Widget _buildLanguageOption(MenuType type, String label) {
    return InkWell(
      onTap: () {
        _changeLanguage(type);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(label),
      ),
    );
  }

  final _authentication = FirebaseAuth.instance;
  User? loggedUser; //초기화 시키지 않을 것임
  UserModel? currentUser;
  late String currentUserUid;
  final firestore = FirebaseFirestore.instance;


  Future<void> getCurrentUser() async {
    var user = FirebaseAuth.instance.currentUser;
    currentUserUid = user!.uid;

    // Firestore에서 사용자 정보 가져오기
    var userData = await firestore.collection('user').doc(currentUserUid).get();
    setState(() {
      currentUser = UserModel.fromMap(userData.data()!);
    });
    log('debug 유저아이디가져오기: $currentUserUid');


  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void showLogOutCheckDialog(){
    showDialog(
        context: context,
        barrierDismissible: false, //dialog를 제외한 다른 화면 터치X
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            shadowColor: Colors.black,
            title: Column(
              children: <Widget>[
                new Text(currentUser?.name ?? ''+tr('dologout')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('movelogin').tr(),
              ],
            ),
            actions: <Widget> [
              new ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black45,
                  onPrimary: Colors.white,
                  shadowColor: Colors.black12,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('notlogout').tr(),
              ),
              new ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[700],
                  onPrimary: Colors.white,
                  shadowColor: Colors.black12,
                ),
                onPressed: () async {
                  // 기본 로그아웃 처리
                  _authentication.signOut();

                  // 소셜 로그아웃 처리
                  await signOut();

                  Navigator.push(
                    context,
                    //화면 전환
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginSignupScreen();
                      },
                    ),
                  );
                },
                child: Text('logout').tr(),
              ),
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser?.name ?? ''), // 사용자 닉네임
            accountEmail: Text(currentUser?.email ?? ''), // 사용자 이메일
            currentAccountPicture: (currentUser?.profilePic == null || currentUser?.profilePic == 'No setting Image')

    ? CircleAvatar(
              backgroundImage: AssetImage('asset/image/animal_neko.png'), // 기본 이미지 설정
            )
                : CircleAvatar(
              backgroundImage: (currentUser!.profilePic != null)
                  ? NetworkImage(currentUser!.profilePic) : null

            ),
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('asset/image/bg_ocean_suiheisen.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home').tr(),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('profile change').tr(),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Account()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('settings').tr(),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Setting()));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('logout').tr(),
            onTap: () {
              showLogOutCheckDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('logouttest').tr(),
            onTap: () {
              signOut();
            },
          ),
        ],
      ),
    );
  }

  signOut() {}


}
