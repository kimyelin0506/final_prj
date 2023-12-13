import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'NavBar.dart';
import 'account.dart';

bool vibration = false;
bool darkMode = false;

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

enum MenuType {
  english,
  korean,
  japanese,
}

class _SettingState extends State<Setting> {
  // AlertDialog 표시 메서드
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
    Navigator.pop(context);
  }

  // 언어 옵션 위젯
  Widget _buildLanguageOption(MenuType type, String label) {
    return InkWell(
      onTap: () {
        _changeLanguage(type);
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: darkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('test').tr(),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: Text('test').tr(),
              tiles: <SettingsTile>[
                SettingsTile.switchTile(
                  title: Text('dark mode').tr(),
                  initialValue: darkMode,
                  onToggle: (value) {
                    setState(() {
                      darkMode = value;
                    });
                  },
                  leading: Icon(Icons.nightlight_sharp),
                ),
                SettingsTile.navigation(
                    title: Text('language').tr(),
                    trailing: Text('nowlanguage').tr(),
                    onPressed: (BuildContext context) {
                      _showLanguageDialog(); // 언어 선택 AlertDialog 표시
                    },
                    leading: Icon(Icons.language_outlined)
                ),
                SettingsTile.switchTile(
                  title: Text('vibration').tr(),
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
              title: Text('account').tr(),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.account_circle),
                  title: Text('profile change').tr(),
                  onPressed: ((context) {Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Account()));}),
                ),
              ],
            ),
            SettingsSection(
              title: Text('etc').tr(),
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
    );
  }
}
