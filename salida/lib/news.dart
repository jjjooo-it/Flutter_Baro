import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: News(),
    ),
  );
}

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  State<News> createState() => _NewsPageState();
}

class _NewsPageState extends State<News> {
  List<dynamic> myNews = [];
  PageController _pageController = PageController();
  int _currentPage = 0; // 현재 페이지 인덱스

  @override
  void initState() {
    super.initState();
    _listenToServerEvents();
    _pageController.addListener(() { // 페이지 변경 리스너
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _listenToServerEvents() async {
    var url = Uri.parse('http://ec2-3-35-100-8.ap-northeast-2.compute.amazonaws.com:8080/news');
    final response = await http.get(url);

    if(response.statusCode == 200){
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(responseBody);
      setState(() {
        myNews = data;
      });
    }
    else {
      print("연결 실패");
    }
  }
  void _goToFirstPage() {
    _pageController.jumpToPage(0);
  }

  // 마지막 페이지로 이동
  void _goToLastPage() {
    _pageController.jumpToPage((myNews.length / 3).ceil() - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("재난 뉴스", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(indent: 30, endIndent: 30),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: (myNews.length / 3).ceil(),
              itemBuilder: (context, pageIndex) {
                int startIndex = pageIndex * 3;
                int endIndex = startIndex + 3;
                List<dynamic> pageItems = myNews.sublist(
                    startIndex, endIndex > myNews.length ? myNews.length : endIndex);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pageIndex == 0) // 첫 번째 페이지일 때만 중앙에 텍스트 표시
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "가장 최신 재난 뉴스만 모아모아",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ...pageItems.map((newsItem) {
                        return InkWell(
                          onTap: () => _launchURL(newsItem['link']),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          newsItem['title']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        label: Text(newsItem['emergencyType']=='earthquake' ? '지진' : ''),
                                        backgroundColor: Colors.redAccent,
                                        labelStyle: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(newsItem['summary']!),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _goToFirstPage,
                ),
                Text(
                  '페이지 ${_currentPage + 1} / ${(myNews.length / 3).ceil()}',
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _goToLastPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw 'Could not launch $urlString';
    }
  }
}
