import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'screens/home_screen.dart';

// 알림 채널 설정
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'persistent_channel',
  'Sound Detection Notifications',
  description: 'Shows the status of sound detection.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  if (Platform.isAndroid) {
    // 알림 채널 초기화
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 서비스 구성
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, // 앱 시작 시 자동 실행 방지
        isForegroundMode: false, // Foreground Service 모드 해제
        notificationChannelId: channel.id,
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Foreground Service를 즉시 시작하지 않음

  service.on('startListening').listen((event) {
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: 'Sound Detection Active',
        content: 'Recording in progress...',
      );
    }
  });

  service.on('stopListening').listen((event) {
    if (service is AndroidServiceInstance) {
      flutterLocalNotificationsPlugin.cancel(888);
      service.setAsBackgroundService();
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Detection App',
      theme: ThemeData(
        primaryColor: const Color(0xFFA61420),
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
      ),
      home: const SoundDetectionScreen(),
    );
  }
}
