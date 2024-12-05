import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/audio_detection_manager.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // 핵심 서비스 관리자들
  final AudioDetectionManager _audioManager = AudioDetectionManager();
  final NotificationService _notificationService = NotificationService();

  // 상태 변수들
  bool _isRecording = false;
  final List<double> _soundLevels = [];  // 음성 파형을 위한 데이터
  double _currentDecibel = 0;  // 현재 데시벨
  double _sensitivity = 3.0;  // 기본 민감도 (중간)
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    // 버튼 애니메이션을 위한 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 1.0,
      upperBound: 1.2,
    );
  }

  Future<void> _initializeComponents() async {
    try {
      await _audioManager.initialize();

      // 오디오 레벨 업데이트 콜백
      _audioManager.onAudioLevelUpdate = (level) {
        setState(() {
          _currentDecibel = level * 100;  // 0~1 값을 0~100으로 변환
          if (_soundLevels.length > 50) _soundLevels.removeAt(0);
          _soundLevels.add(_currentDecibel);
        });
      };

      // 초기 민감도 설정
      _audioManager.setSensitivity(_sensitivity);

    } catch (e) {
      debugPrint('컴포넌트 초기화 실패: $e');
    }
  }

<<<<<<< HEAD
  bool _isTogglingRecording = false;  // 토글 작업의 중복 실행을 방지하기 위한 플래그

  void _toggleRecording() async {
    // 이미 토글 작업이 진행 중이라면 추가 실행을 방지합니다
=======
  bool _isTogglingRecording = false;

  void _toggleRecording() async {
    // 중복 실행 방지
>>>>>>> a83704204ae2e734dfd68e5a84a8a0e004aae596
    if (_isTogglingRecording) return;
    _isTogglingRecording = true;

    try {
      if (!_isRecording) {
        // 녹음 시작 시퀀스
        try {
          await _audioManager.startDetection();
<<<<<<< HEAD
          // 백그라운드 알림 설정 및 애니메이션 시작
=======
>>>>>>> a83704204ae2e734dfd68e5a84a8a0e004aae596
          await _notificationService.showServiceNotification(true);
          _animationController.repeat(reverse: true);
        } catch (startError) {
          debugPrint('녹음 시작 실패: $startError');
<<<<<<< HEAD
          // 시작 실패 시 사용자에게 알림
=======
          // 시작 실패시에만 사용자에게 알림
>>>>>>> a83704204ae2e734dfd68e5a84a8a0e004aae596
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('녹음을 시작할 수 없습니다. 권한을 확인해주세요.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      } else {
        // 녹음 중지 시퀀스
<<<<<<< HEAD
        // 애니메이션을 먼저 중지하여 UI 응답성 향상
        _animationController.reset();

        // 오디오 매니저와 알림 서비스 정리
        await Future.wait([
          _audioManager.stopDetection(),
          _notificationService.showServiceNotification(false),
        ]);
      }

      // 위젯이 여전히 유효한 상태인지 확인 후 상태 업데이트
=======
        _animationController.reset();

        // 중지 과정의 오류는 조용히 처리
        try {
          await Future.wait([
            _audioManager.stopDetection(),
            _notificationService.showServiceNotification(false),
          ]);
        } catch (stopError) {
          // 로그만 남기고 사용자에게는 알리지 않음
          debugPrint('녹음 중지 중 비치명적 오류: $stopError');
        }
      }

      // 상태 업데이트
>>>>>>> a83704204ae2e734dfd68e5a84a8a0e004aae596
      if (mounted) {
        setState(() {
          _isRecording = _audioManager.isRecording;
        });
      }
    } catch (e) {
<<<<<<< HEAD
      debugPrint('녹음 토글 중 오류: $e');
      // 오류 발생 시 안전하게 상태 복구
=======
      // 정말 치명적인 오류일 경우에만 사용자에게 알림
      debugPrint('심각한 오류 발생: $e');
>>>>>>> a83704204ae2e734dfd68e5a84a8a0e004aae596
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
<<<<<<< HEAD
      // 사용자에게 오류 알림
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('녹음 처리 중 오류가 발생했습니다. 다시 시도해주세요.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // 작업 완료 후 반드시 토글 플래그를 리셋
=======
    } finally {
>>>>>>> a83704204ae2e734dfd68e5a84a8a0e004aae596
      _isTogglingRecording = false;
    }
  }

  Future<void> _openSettings() async {
    final newSensitivity = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(initialSensitivity: _sensitivity),
      ),
    );

    if (newSensitivity != null) {
      setState(() {
        _sensitivity = newSensitivity;
        _audioManager.setSensitivity(newSensitivity);
      });
    }
  }

  @override
  void dispose() {
    _audioManager.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          'AI Sound Detection',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // 현재 데시벨과 민감도 표시 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Current Level: ${(_currentDecibel).toStringAsFixed(1)} dB\n'  // 100으로 나누지 않음
                      '민감도: ${_sensitivity.toStringAsFixed(0)}단계',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // 녹음 시작/중지 버튼
          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _animationController.value : 1.0,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isRecording ? 'Stop' : 'Start',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 상태 메시지
          Text(
            _isRecording
                ? '소리를 감지 중입니다.\n백그라운드에서도 실행됩니다.'
                : '소리 감지가 시작됩니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // 음성 파형 그래프
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _soundLevels
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}