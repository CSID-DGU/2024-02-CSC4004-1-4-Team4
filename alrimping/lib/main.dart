import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import './screens/home_screen.dart';
import './providers/sound_provider.dart';
import 'package:noise_meter/noise_meter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.microphone.request();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: 'alrimping_channel',
      initialNotificationTitle: 'Alrimping',
      initialNotificationContent: '초기화 중...',
      foregroundServiceNotificationId: 888,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  NoiseMeter? noiseMeter;
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
    if (event != null && event['sensitivity'] != null) {
      sensitivity = double.parse(event['sensitivity'].toString());
    }

    try {
      noiseMeter = NoiseMeter();
      noiseMeter?.noise.listen(
            (NoiseReading reading) {
          double decibel = reading.maxDecibel * (sensitivity / 3.0);

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
      );
    } catch (e) {
      debugPrint('Error starting noise meter: $e');
    }
  });

  service.on('stop').listen((event) {
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