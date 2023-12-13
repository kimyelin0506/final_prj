import 'package:flutter/material.dart';

import 'home_screen.dart';
//import 'map_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgets = <Widget>[
    HomeScreen(),
//    MapScreen(),
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBar renderBottomNavigation() {
    return BottomNavigationBar(items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: '커뮤니티'),
      BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: '고양이 지도'),
    ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      onTap: _onItemTapped,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgets.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: renderBottomNavigation(),
    );
  }
}
