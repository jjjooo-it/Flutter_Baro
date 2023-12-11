import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SSE Demo',
      home:  HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _event = 'Waiting for events...';
  String _eventData = '';

  @override
  void initState() {
    super.initState();
    _listenToServerEvents();
  }

  void _listenToServerEvents() {
    SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: 'http://ec2-3-35-100-8.ap-northeast-2.compute.amazonaws.com:8080/warn/connect',
        header: {
          "Cookie": '',
          "Accept": "text/event-stream",
          "Cache-Control": "",
        }).listen((event) {
      // 데이터를 JSON으로 파싱
      var data = json.decode(event.data!);
      setState(() {
        _eventData = data['warnInfo']; // 'warnInfo' 필드의 데이터 사용
      });
    }, onError: (error) {
      setState(() {
        _event = 'Error';
        _eventData = error.toString();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter SSE Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Event: $_event'),
            Text('Data: $_eventData'),
          ],
        ),
      ),
    );
  }
}