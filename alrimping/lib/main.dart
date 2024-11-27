import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'persistent_channel',
  'Sound Detection Notifications',
  description: 'Shows the status of sound detection.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('mipmap/ic_launcher'),
      ),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: channel.id,
        initialNotificationTitle: 'Sound Detection Service',
        initialNotificationContent: 'Ready to start recording...',
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
Future<void> onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    // 즉시 알림 표시
    service.setForegroundNotificationInfo(
      title: 'Sound Detection Service',
      content: 'Ready to start recording...',
    );
  }

  service.on('startListening').listen((event) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'Sound Detection Active',
        content: 'Recording in progress...',
      );
    }
  });

  service.on('stopListening').listen((event) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'Sound Detection Paused',
        content: 'Recording stopped',
      );
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SoundDetectionScreen(),
    );
  }
}

class SoundDetectionScreen extends StatefulWidget {
  const SoundDetectionScreen({super.key});

  @override
  State<SoundDetectionScreen> createState() => _SoundDetectionScreenState();
}

class _SoundDetectionScreenState extends State<SoundDetectionScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isListening = false;
  bool _isPlaying = false;
  String? _recordingPath;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    _initializeSoundComponents();
  }

  Future<void> _initializeSoundComponents() async {
    // 마이크 권한 요청
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      throw Exception('Microphone permission not granted');
    }

    // 녹음기와 플레이어 초기화
    await _recorder.openRecorder();
    await _player.openPlayer();

    // 백그라운드 서비스 시작
    await _backgroundService.startService();
  }

  Future<String> _getRecordingPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/temp_recording.aac';
  }

  Future<void> _toggleListening() async {
    try {
      if (_isListening) {
        // 녹음 중지
        if (_recorder.isRecording) {
          _recordingPath = await _recorder.stopRecorder();
        }
        _backgroundService.invoke('stopListening');
      } else {
        // 녹음 시작
        _recordingPath = await _getRecordingPath();
        _backgroundService.invoke('startListening');
        await _recorder.startRecorder(
          toFile: _recordingPath,
          codec: Codec.aacADTS,
        );
      }

      setState(() {
        _isListening = !_isListening;
      });
    } catch (e) {
      debugPrint('Error during recording toggle: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_recordingPath == null) return;

    try {
      if (_isPlaying) {
        await _player.stopPlayer();
      } else {
        await _player.startPlayer(
            fromURI: _recordingPath,
            codec: Codec.aacADTS,
            whenFinished: () {
              setState(() {
                _isPlaying = false;
              });
            }
        );
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      debugPrint('Error during playback toggle: $e');
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleListening,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                _isListening ? 'Stop Recording' : 'Start Recording',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recordingPath != null ? _togglePlayback : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                _isPlaying ? 'Stop Playing' : 'Play Recording',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}