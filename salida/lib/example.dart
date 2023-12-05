import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
    String url = 'httpㄴ://ec2-3-35-100-8.ap-northeast-2.compute.amazonaws.com:8080';
    // GET Request
    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: url,
      header: {
        "Cookie": '',
        "Accept": "text/event-stream",
        "Cache-Control": "",
      }).listen((event) {
      var data = json.decode(event.data!);
      setState(() {
        _event = data['event'];
        _eventData = data['data'];
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
