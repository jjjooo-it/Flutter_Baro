import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';


class FlutterLocalNotification {
  static double mag = 0;
  static String name ="";
  static String place = "";


  FlutterLocalNotification._();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static init() async {
    _listenToServerEvents();
    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('mipmap/ic_launcher');


    DarwinInitializationSettings iosInitializationSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void updateData(String newloc, double newMag) {
    mag = newMag;
    place = newloc;

    showNotification(place, mag);
  }


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
        updateData(data['address'],data['magnitude']);
     }
    );}


  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> showNotification(String place, double mag) async {
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
        '✅위치 | $place \n ✅진도 | $mag', //알림 내용
        notificationDetails);
  }

}
