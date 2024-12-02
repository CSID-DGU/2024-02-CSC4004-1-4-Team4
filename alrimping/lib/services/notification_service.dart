import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'danger_detection_channel',
    '위험 소리 감지',
    description: '주변의 위험한 소리를 감지하여 알립니다.',
    importance: Importance.high,
    enableVibration: true,
    enableLights: true,
    ledColor: Color.fromARGB(255, 255, 0, 0),
  );

  Future<void> initialize() async {
    if (_isInitialized) return;

    // iOS 권한 요청
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      critical: true,
    );

    // 안드로이드 알림 채널 생성
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 알림 초기화
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        ),
      ),
    );

    _isInitialized = true;
  }

  Future<void> showDangerAlert(String soundType) async {
    if (!_isInitialized) await initialize();

    await _notifications.show(
      0,
      '⚠️ 위험 소리 감지!',
      '$soundType 소리가 감지되었습니다.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.red,
          ledOnMs: 1000,
          ledOffMs: 500,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'critical_alert.aiff',
          interruptionLevel: InterruptionLevel.critical,
          categoryIdentifier: 'danger',
        ),
      ),
    );

    await _triggerVibrationPattern();
  }

  Future<void> _triggerVibrationPattern() async {
    if (await Vibration.hasVibrator() ?? false) {
      try {
        // 독특한 패턴: 짧게-짧게-길게 형태의 진동
        // [대기시간, 진동시간, 대기시간, 진동시간, ...] 순서로 배열 구성
        await Vibration.vibrate(
          pattern: [
            0,      // 시작 전 대기
            100,    // 첫 번째 짧은 진동 (100ms)
            100,    // 대기
            100,    // 두 번째 짧은 진동 (100ms)
            100,    // 대기
            400     // 마지막 긴 진동 (400ms)
          ],
          intensities: [0, 255, 0, 255, 0, 255],  // 각 구간의 진동 강도
        );
      } catch (e) {
        debugPrint('진동 실행 중 오류: $e');
      }
    }
  }

  // NotificationService 클래스 내부에 추가
  Future<void> showServiceNotification(bool isActive) async {
    if (!_isInitialized) await initialize();

    if (isActive) {
      await _notifications.show(
        1,  // 서비스 알림용 고유 ID (위험 알림은 ID 0을 사용)
        '소리 감지 서비스 실행 중',
        '주변의 위험한 소리를 감지하고 있습니다',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.low,  // 낮은 중요도로 설정
            priority: Priority.low,
            ongoing: true,  // 지속적인 알림으로 설정
            icon: '@mipmap/ic_launcher',
            showWhen: false,  // 시간 표시 비활성화
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: false,  // iOS에서는 조용히 처리
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
    } else {
      await _notifications.cancel(1);  // 서비스 알림 제거
    }
  }
}