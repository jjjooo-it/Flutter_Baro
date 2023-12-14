// Setting 및 Widget 파일
// 1. widget 파일 lib 안에 넣기
// 2. ionicons 라이브러리 설치

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:salida/widget/setting_item.dart';
import 'package:salida/widget/setting_switch.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Setting(),
      )
  );
}

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "유관 기관",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SettingItem(
                title: "행정안전부",
                icon: Ionicons.aperture,
                bgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
                onTap: () {
                  _launchURL('https://www.mois.go.kr/');  // 행정안전부 웹사이트 URL
                },
              ),
              const SizedBox(height: 10),
              SettingItem(
                title: "국민재난안전포털",
                icon: Ionicons.briefcase,
                bgColor: Colors.pink.shade100,
                iconColor: Colors.pink,
                onTap: () {
                  _launchURL("https://www.safekorea.go.kr/idsiSFK/neo/main/main.html");
                },
              ),

              const SizedBox(height: 20),
              const Text(
                "환경설정",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SettingItem(
                title: "언어",
                icon: Ionicons.globe,
                bgColor: Colors.orange.shade100,
                iconColor: Colors.orange,
                value: "한국어",
                onTap: () {},
              ),


              const SizedBox(height: 20),
              const Text(
                "앱 정보",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SettingItem(
                title: "앱 버전",
                icon: Ionicons.apps,
                bgColor: Colors.green.shade100,
                iconColor: Colors.green,
                value: '1.0.0',
                onTap: () {
                  _launchURL("https://play.google.com/store/apps/details?id=kr.go.nema.disasteralert_new");
                },
              ),
              const SizedBox(height: 10),
              SettingItem(
                title: "문제 신고",
                icon: Ionicons.mail,
                bgColor: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: () {
                  _launchURL("https://mail.google.com/");
                },
              ),
              const SizedBox(height: 10),
              SettingItem(
                title: "개인정보처리방침",
                icon: Ionicons.reader,
                bgColor: Colors.deepPurple.shade100,
                iconColor: Colors.deepPurple,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}