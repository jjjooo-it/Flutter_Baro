import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanguageSelection extends StatelessWidget {
  final Function(String) onLanguageSelected;
  LanguageSelection({required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('언어 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('한국어'),
            onTap: () => onLanguageSelected('한국어'),
          ),
          ListTile(
            title: Text('English'),
            onTap: () => onLanguageSelected('English'),
          ),

          /*ListTile(
            title: Text('日本語'),
            onTap: () => onLanguageSelected('日本語'),
          ),
          ListTile(
            title: Text('中文'),
            onTap: () => onLanguageSelected('中文'),
          ),
           */
        ],
      ),
    );
  }
}
