<<<<<<< HEAD
=======
//main.dart
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
<<<<<<< HEAD
import 'package:permission_handler/permission_handler.dart'; // permission_handler 패키지 추가
import 'screens/home_screen.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'persistent_channel',
  'Sound Detection Notifications',
=======
import 'package:permission_handler/permission_handler.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/audio_detection_manager.dart';

// 알림 채널 설정은 사용자에게 중요한 알림을 보내기 위한 것입니다.
=======
import 'screens/home_screen.dart';

>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'sound_detection_channel',
  'Dangerous Sound Detection',
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
  description: 'Shows the status of sound detection.',
  importance: Importance.high,
);

<<<<<<< HEAD
=======
// 전역 알림 플러그인 인스턴스를 생성합니다.
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
<<<<<<< HEAD
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    // 알림 권한 요청
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    // 블루투스 권한 요청
    final bluetoothStatus = await Permission.bluetoothConnect.status;
    if (!bluetoothStatus.isGranted) {
      await Permission.bluetoothConnect.request();
    }

    // 블루투스 스캔 권한 요청
    final bluetoothScanStatus = await Permission.bluetoothScan.status;
    if (!bluetoothScanStatus.isGranted) {
      await Permission.bluetoothScan.request();
    }

    // 마이크 권한 요청
    final microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
    }
  }

=======
  // Flutter 엔진과 위젯 바인딩을 초기화합니다.
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
  // 안드로이드 플랫폼에서 필요한 권한을 확인합니다.
=======
>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1
  if (Platform.isAndroid) {
    await _requestPermissions();
  }

  // 백그라운드 서비스를 초기화합니다.
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
  await initializeService();
  runApp(const MyApp());
}

<<<<<<< HEAD
=======
// 필요한 권한들을 요청하는 함수입니다.
Future<void> _requestPermissions() async {
  final micStatus = await Permission.microphone.status;
  if (!micStatus.isGranted) {
    await Permission.microphone.request();
  }

  final notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    await Permission.notification.request();
  }
}

// 백그라운드 서비스를 초기화하는 함수입니다.
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  if (Platform.isAndroid) {
<<<<<<< HEAD
=======
    // 알림 플러그인을 초기화합니다.
    final androidNotificationPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidNotificationPlugin != null) {
      await androidNotificationPlugin.createNotificationChannel(channel);
    }

>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

<<<<<<< HEAD
=======
<<<<<<< HEAD
    // 백그라운드 서비스의 설정을 구성합니다.
=======
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

<<<<<<< HEAD
=======
>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
<<<<<<< HEAD
        isForegroundMode: false,
        notificationChannelId: channel.id,
=======
        isForegroundMode: true,
        notificationChannelId: channel.id,
        initialNotificationTitle: 'Sound Detection Service',
        initialNotificationContent: 'Initializing...',
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
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

<<<<<<< HEAD
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
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

=======
// 백그라운드 서비스가 시작될 때 호출되는 함수입니다.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final audioManager = AudioDetectionManager();

  if (service is AndroidServiceInstance) {
    // 서비스를 시작할 때의 동작을 정의합니다.
    service.on('startListening').listen((event) async {
      await audioManager.initialize();

      service.setAsForegroundService();
      await service.setForegroundNotificationInfo(
        title: 'Sound Detection Active',
        content: 'Monitoring for dangerous sounds...',
      );

      await audioManager.startDetection();
    });

    // 서비스를 중지할 때의 동작을 정의합니다.
    service.on('stopListening').listen((event) async {
      await audioManager.stopDetection();
      await flutterLocalNotificationsPlugin.cancel(888);
      service.setAsBackgroundService();
    });
  }
}

// 앱의 메인 위젯입니다.
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Detection App',
      theme: ThemeData(
        primaryColor: const Color(0xFFA61420),
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
<<<<<<< HEAD
=======
        useMaterial3: true,
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
      ),
      home: const HomeScreen(),
    );
  }
}
