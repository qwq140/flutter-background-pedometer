import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:pedometer/pedometer.dart';
import 'package:steps_counting_app/service/notification_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,

      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Step App',
      initialNotificationContent: '백그라운드 실행중입니다.'
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}


@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  print('background onStart');
  DartPluginRegistrant.ensureInitialized();
  if(service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsBackgroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  Pedometer.stepCountStream.listen((event) {
    print('stepCountStream');
    String title = 'Step App';
    String content = '걸음 수 ${event.steps}걸음';
    NotificationService().showNotification(title: title, content: content);
  },);
}