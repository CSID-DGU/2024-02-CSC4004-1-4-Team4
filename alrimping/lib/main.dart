import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import './screens/home_screen.dart';
import './providers/sound_provider.dart';
import 'package:noise_meter/noise_meter.dart';
import 'dart:async';  // StreamSubscription을 위해 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.microphone.request();
  await initializeService();
  runApp(const MyApp());
}

Future<FlutterBackgroundService> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'alrimping_channel',
      initialNotificationTitle: 'Alrimping',
      initialNotificationContent: '초기화 중...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  return service;  // 초기화된 서비스 반환
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  NoiseMeter? noiseMeter;
  StreamSubscription? noiseSubscription;
  double sensitivity = 3.0;

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  service.on('updateSensitivity').listen((event) {
    if (event != null && event['sensitivity'] != null) {
      sensitivity = double.parse(event['sensitivity'].toString());
    }
  });

  service.on('start').listen((event) {
    // 서비스를 foreground로 설정
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }

    if (event != null && event['sensitivity'] != null) {
      sensitivity = double.parse(event['sensitivity'].toString());
    }

    try {
      // 기존 리소스 정리
      noiseSubscription?.cancel();
      noiseMeter = null;

      // 새로운 인스턴스 생성 및 측정 시작
      noiseMeter = NoiseMeter();
      noiseSubscription = noiseMeter?.noise.listen(
            (NoiseReading reading) {
          double decibel = reading.maxDecibel;

          if (decibel.isFinite && decibel > -double.infinity) {
            decibel = decibel * (sensitivity / 3.0);
            if (decibel < 0) decibel = 0;
          } else {
            decibel = 0.0;
          }

          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "Alrimping is running",
              content: "현재 데시벨: ${decibel.toStringAsFixed(1)} dB",
            );
          }

          service.invoke(
            'update',
            {'decibel': decibel.toString()},
          );
        },
        onError: (e) {
          debugPrint('Noise measurement error: $e');
          // 에러 발생 시 리소스 정리
          noiseSubscription?.cancel();
          noiseMeter = null;

          // 잠시 후 재시작
          Future.delayed(const Duration(milliseconds: 500), () {
            service.invoke(
                'start',
                {'sensitivity': sensitivity.toString()}
            );
          });
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Error starting noise meter: $e');
    }
  });

  service.on('stop').listen((event) {
    noiseSubscription?.cancel();
    noiseMeter = null;
    if (service is AndroidServiceInstance) {
      service.stopSelf();
    }
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SoundProvider(),
      child: MaterialApp(
        title: 'Alrimping',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}