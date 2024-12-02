import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../services/audio_detection_manager.dart';
import '../services/notification_service.dart';
=======
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'settings_screen.dart';
>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

<<<<<<< HEAD
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AudioDetectionManager _audioManager = AudioDetectionManager();
  bool _isRecording = false;
  double _currentAudioLevel = 0.0;
  String _lastDetectedSound = '';
  double _lastDetectedConfidence = 0.0;

  // 위험 감지 상태 관리를 위한 변수들
  bool _isDangerDetected = false;
  String _dangerousSound = '';
  late final AnimationController _warningAnimationController;
  final List<String> _recentDangerousSound = [];  // 최근 감지된 위험 소리들
=======
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  final List<double> _soundLevels = [];
  StreamSubscription? _recordingStream;
  double _currentDecibel = 0;
  double _sensitivity = 3; // 기본 민감도
  late AnimationController _animationController;
>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _initializeAudioManager();

    // 경고 애니메이션 컨트롤러 초기화
    _warningAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);  // 깜빡이는 효과를 위해 반복
  }

  Future<void> _initializeAudioManager() async {
    try {
      await _audioManager.initialize();

      // 오디오 레벨 업데이트 콜백
      _audioManager.onAudioLevelUpdate = (level) {
        setState(() {
          _currentAudioLevel = level;
        });
      };

      // 일반 소리 감지 콜백
      _audioManager.onSoundDetected = (label, confidence) {
        setState(() {
          _lastDetectedSound = label;
          _lastDetectedConfidence = confidence;
        });
      };

      // 위험 소리 감지 콜백
      _audioManager.onDangerousSoundDetected = (label, confidence) {
        setState(() {
          _isDangerDetected = true;
          _dangerousSound = label;

          // 최근 위험 소리 목록 업데이트
          if (!_recentDangerousSound.contains(label)) {
            _recentDangerousSound.insert(0, label);
            if (_recentDangerousSound.length > 5) {  // 최대 5개까지만 유지
              _recentDangerousSound.removeLast();
            }
          }
        });

        // 3초 후 위험 상태 해제
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isDangerDetected = false;
            });
          }
        });
      };
    } catch (e) {
      debugPrint('오디오 매니저 초기화 실패: $e');
=======
    _initializeSoundComponents();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 1.0,
      upperBound: 1.2,
    );
  }

  Future<void> _initializeSoundComponents() async {
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      throw Exception('Microphone permission not granted');
>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1
    }
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

<<<<<<< HEAD
  void _toggleRecording() async {
    try {
      if (!_isRecording) {
        await _audioManager.startDetection();
        // 서비스 시작 시 지속적 알림 표시
        await NotificationService().showServiceNotification(true);
      } else {
        await _audioManager.stopDetection();
        // 서비스 중지 시 알림 제거
        await NotificationService().showServiceNotification(false);
        // 녹음 중지시 위험 상태 초기화
        setState(() {
          _isDangerDetected = false;
          _recentDangerousSound.clear();
        });
      }
=======
  void _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/temp_recording.aac';

    await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);
>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1

    _recordingStream = _recorder.onProgress?.listen((event) {
      final amplitude = event.decibels ?? 0;
      setState(() {
<<<<<<< HEAD
        _isRecording = _audioManager.isRecording;
      });
    } catch (e) {
      debugPrint('녹음 토글 중 오류: $e');
=======
        if (_soundLevels.length > 50) _soundLevels.removeAt(0);
        _soundLevels.add(amplitude);
        _currentDecibel = amplitude;
      });
    });

    setState(() {
      _isRecording = true;
    });
    _animationController.repeat(reverse: true);
  }

  void _stopRecording() async {
    await _recorder.stopRecorder();
    _recordingStream?.cancel();
    setState(() {
      _isRecording = false;
    });
    _animationController.reset();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
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
      });
>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1
    }
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _audioManager.dispose();
    _warningAnimationController.dispose();
    super.dispose();
  }

  // 위험 경고 위젯
  Widget _buildDangerWarning() {
    return AnimatedBuilder(
      animation: _warningAnimationController,
      builder: (context, child) {
        final color = _isDangerDetected
            ? Color.lerp(
          Colors.red.withOpacity(0.3),
          Colors.red.withOpacity(0.8),
          _warningAnimationController.value,
        )
            : Colors.transparent;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDangerDetected ? Colors.red : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: color,
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isDangerDetected) ...[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  '위험 소리 감지!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dangerousSound,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // 최근 감지된 위험 소리 목록 위젯
  Widget _buildRecentDangersList() {
    if (_recentDangerousSound.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 감지된 위험 소리:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _recentDangerousSound.length,
                (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(_recentDangerousSound[index]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

=======
    _recorder.closeRecorder();
    _recordingStream?.cancel();
    _animationController.dispose();
    super.dispose();
  }

>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
<<<<<<< HEAD
        backgroundColor: const Color(0xFFA61420),
        title: const Text(
          'AI Sound Detection',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          // 위험 경고 표시
          if (_isRecording) _buildDangerWarning(),

          // 메인 녹음 버튼
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.grey[500] : Colors.grey[600],
                    border: Border.all(
                      color: _isRecording
                          ? (_isDangerDetected ? Colors.red : const Color(0xFFF23838))
                          : Colors.grey[400]!,
                      width: 8,
                    ),
                    boxShadow: _isRecording
                        ? [
                      BoxShadow(
                        color: _isDangerDetected
                            ? Colors.red.withOpacity(0.6)
                            : const Color(0xFFF23838).withOpacity(0.6),
                        spreadRadius: 30 * _currentAudioLevel,
                        blurRadius: 40,
                      ),
                    ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isRecording ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isRecording ? Colors.yellow : Colors.grey,
                        ),
                      ),
                      if (_isRecording) ...[
                        const SizedBox(height: 10),
                        Text(
                          '레벨: ${(_currentAudioLevel * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
=======
        backgroundColor: Colors.redAccent,
        title: const Text('AI Sound Detection'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings, // 설정 화면 열기
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
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
                  'Current Decibel: ${_currentDecibel.toStringAsFixed(1)} dB\nSensitivity: $_sensitivity',
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
          GestureDetector(
            onTap: _toggleRecording,
            child: Container(
              width: 250,
              height: 250,
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
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isRecording ? '소리를 감지 중입니다.\n백그라운드에서도 실행됩니다.' : '소리 감지가 시작됩니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            height: 200,
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
>>>>>>> 80351570d5121fe36e7f78f86b8c85e39c8ff7f1
              ),
            ),
          ),

          // 최근 감지된 위험 소리 목록
          if (_isRecording) _buildRecentDangersList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}