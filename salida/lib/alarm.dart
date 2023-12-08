import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'dart:convert';
import 'dart:async';


class FlutterLocalNotification {
  static double lat = 0;
  static double long = 0;
  static double mag = 0;

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

  static late StreamSubscription _sseSubscription;
  static bool _isConnected = false;

  static void _listenToServerEvents() {
    if(!_isConnected) {
      _isConnected= true;
      _sseSubscription = SSEClient.subscribeToSSE(
          method: SSERequestType.GET,
          url: 'http://ec2-3-35-100-8.ap-northeast-2.compute.amazonaws.com:8080/warn/connect',
          header: {
            "Cookie": '',
            "Accept": "text/event-stream",
            "Cache-Control": "",
          }
      ).listen((event) {
        print("이벤트 리슨");
        var data = json.decode(event.data!);
        updateData(data['latitude'], data['longitude'], data['magnitude']);
        showNotification(lat, long, mag); // 푸시 알림 전송
      },
        onError: (error) {
          _isConnected= false;
          // 에러 발생 시
          print('SSE 연결 오류: $error');
          _reconnect(); // 재연결을 시도합니다.
        },
        onDone: () {
          _isConnected= false;
          // 스트림이 종료될 때
          print('SSE 연결 종료됨');
          _reconnect(); // 재연결을 시도합니다.
        },
      );
    }
}
static void _reconnect() {
  print('재연결을 시도합니다...');
  _sseSubscription.cancel();
  _isConnected = false;
  _listenToServerEvents();
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

  static Future<void> showNotification(double lat, double long,
      double mag) async {
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
