import 'dart:async';
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
  final status = await Permission.microphone.status;
  if (!status.isGranted) {
    debugPrint('Microphone permission not granted.');
    await Permission.microphone.request();
  }
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
  StreamSubscription<NoiseReading>? noiseSubscription;
  double sensitivity = 3.0;

  void stopNoiseMeter() {
    noiseSubscription?.cancel();
    noiseSubscription = null;
    noiseMeter = null;
  }

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  service.on('start').listen((event) {
    stopNoiseMeter();
    try {
      noiseMeter = NoiseMeter();
      noiseSubscription = noiseMeter!.noise.listen(
            (NoiseReading? reading) {
          if (reading == null || reading.maxDecibel.isNaN || reading.maxDecibel.isInfinite) {
            debugPrint('Invalid NoiseReading received.');
            service.invoke('update', {'decibel': '0.0'});
            return;
          }
          double decibel = reading.maxDecibel * (sensitivity / 3.0);
          debugPrint('Current decibel: $decibel');
          service.invoke('update', {'decibel': decibel.toString()});
        },
      );
      debugPrint('NoiseMeter initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing NoiseMeter: $e');
    }
  });

  service.on('stop').listen((event) {
    stopNoiseMeter();
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
