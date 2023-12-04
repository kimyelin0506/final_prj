
import 'package:final_prj/screen/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'locate_screen.dart';


//전체 큰틀인 RootScreen
//이 안에 homescreen, profileScreen, LocationScreen 이 위치해 있음
class RootScreen extends StatefulWidget{
  const RootScreen({Key? key}):super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin{
  TabController? controller;

  @override
  void initState(){
    super.initState();

    controller = TabController(length: 3, vsync: this);
    controller!.addListener(tabListener);
  }
  tabListener(){
    setState(() {});
  }
  @override
  dispose(){
    controller!.removeListener(tabListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: renderChildren(),
      ),
      bottomNavigationBar: renderBottomNavigation(),
    );
  }

  //bottomNavigationBar
  BottomNavigationBar renderBottomNavigation(){
    return BottomNavigationBar(
        //showSelectedLabels: false, //글자 없애기
        //showUnselectedLabels: false,
        currentIndex: controller!.index,
        onTap: (int index){
          setState(() {
            controller!.animateTo(index);
          });
        },

        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
              ),
              label: '홈'
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.pin_drop,
              ),
              label: '위치'
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.account_circle_outlined
              ),
            label: '프로필'
          )
        ]
    );
  }

  List<Widget> renderChildren(){
    return [
      HomeScreen(),   //홈화면 (피드보이는 곳)
      LocationScreen(),  //설정
      ProfileScreen(),  //프로필
    ];
  }
}