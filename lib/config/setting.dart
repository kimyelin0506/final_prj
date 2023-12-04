import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'NavBar.dart';


bool vibration = false;
bool darkMode = false;
final supportedLocales = [
  Locale('en', 'US'),
  Locale('ko', 'KR'),
  Locale('ja', 'JP')
];

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Locale _appLocale = Locale('ko', '');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: darkMode ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(
          appBar: AppBar(
            title: Text('테스트'),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: SettingsList(
            sections: [
              SettingsSection(
                title: Text(
                  '공통',
                ),
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                    title: Text('다크모드'),
                    initialValue: darkMode,
                    onToggle: (value) {
                      setState(() {
                        darkMode = value;
                      });
                    },
                    leading: Icon(Icons.nightlight_sharp),
                  ),
                  SettingsTile.navigation(
                    leading: Icon(Icons.language),
                    title: Text('언어'),
                    value: Text('한국어'),
                    onPressed: ((context) {}),
                  ),
                  SettingsTile.switchTile(
                    title: Text('진동'),
                    initialValue: vibration,
                    onToggle: (value) {
                      setState(() {
                        vibration = !vibration;
                      });
                    },
                    leading: Icon(Icons.vibration),
                  ),
                ],
              ),
              SettingsSection(
                title: Text('계정'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: Icon(Icons.logout),
                    title: Text('로그아웃'),
                    onPressed: ((context) {}),
                  ),
                ],
              ),
              SettingsSection(
                title: Text('기타'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: Icon(Icons.star),
                    title: Text('앱 평가하기'),
                    onPressed: ((context) {}),
                  ),
                ],
              ),
            ],
          ),
          drawer: NavBar(),
        ),
        localizationsDelegates: const[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const[
        Locale('ko', ''),
        Locale('en', ''),
      ],
    );
  }
}
