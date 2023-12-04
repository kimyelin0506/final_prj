import 'package:final_prj/config/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_prj/config/account.dart';
import '../screen/home_screen.dart';
import '../screen/login_signUp_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}):super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}
class _NavBarState extends State<NavBar>{
  final _authentication = FirebaseAuth.instance;
  User? loggedUser; //초기화 시키지 않을 것임

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void iniState() {
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
                new Text('${loggedUser?.email}님 로그아웃 하시겠습니까?'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('로그인 화면으로 이동합니다'),
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
                child: Text('고양이 더 구경하기'),
              ),
              new ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[700],
                  onPrimary: Colors.white,
                  shadowColor: Colors.black12,
                ),
                onPressed: () {
                  _authentication.signOut();
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
                child: Text('로그아웃 하기'),
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
            accountName: Text('고양이'),
            accountEmail: Text('meowmeow@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('asset/img/animal_neko.png',
                    width: 80, height: 80),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('asset/img/bg_ocean_suiheisen.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('홈'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('프로필 변경'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Account()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('환경설정'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Setting()));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('로그아웃 하기'),
            onTap: () {
              showLogOutCheckDialog();
            },
          ),
        ],
      ),
    );
  }
}
