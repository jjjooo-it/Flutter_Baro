import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'dart:convert';
import 'dart:async';


class FlutterLocalNotification {
  static double lat = 0;
  static double long = 0;
  static double mag = 0;
  static String name ="";

  FlutterLocalNotification._();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static init() async {
    _listenToServerEvents();
    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('mipmap/ic_launcher');
    DarwinInitializationSettings iosInitializationSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void updateData(double newLat, double newLong, double newMag) {
    lat = newLat;
    long = newLong;
    mag = newMag;
    showNotification(lat, long, mag);
  }

  static Timer? _reconnectTimer;
  static void _listenToServerEvents() {
      SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: 'http://ec2-3-35-100-8.ap-northeast-2.compute.amazonaws.com:8080/warn/connect',
        header: {
          "Cookie": '',
          "Accept": "text/event-stream",
          "Cache-Control": ""
        },
      ).listen((event) {
        var data = json.decode(event.data!);
          updateData(data['latitude'], data['longitude'], data['magnitude']);
        }, onDone: () {
        // 연결이 끊어졌을 때 재연결 타이머 시작
        _startReconnectTimer();
      }, onError: (error) {
        // 오류 발생 시 재연결 타이머 시작
        _startReconnectTimer();
      });
  }
  static void _reconnect() {
    print('재연결을 시도합니다...');
    _listenToServerEvents();
  }
  static void _startReconnectTimer() {
    _reconnectTimer?.cancel();  // 이전 타이머가 있다면 취소
    _reconnectTimer = Timer.periodic(Duration(seconds: 10), (Timer t) => _reconnect());
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> showNotification(double lat, double long, double mag) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel id', 'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    await flutterLocalNotificationsPlugin.show(
        0, //알림 id
        '🚨지진 알림', //알림 제목
        '위도: $lat, 경도: $long, 진도: $mag', //알림 내용
        notificationDetails);
  }
}