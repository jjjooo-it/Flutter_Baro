import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재난 뉴스', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: const Text('재난 뉴스만 모아모아', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            )
            ),
          ),
        ],
      ),
    );
  }
}
