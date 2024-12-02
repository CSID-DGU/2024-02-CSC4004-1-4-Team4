import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  final List<double> _soundLevels = [];
  StreamSubscription? _recordingStream;
  double _currentDecibel = 0;
  double _sensitivity = 3; // 기본 민감도
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
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
    }
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  void _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/temp_recording.aac';

    await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);

    _recordingStream = _recorder.onProgress?.listen((event) {
      final amplitude = event.decibels ?? 0;
      setState(() {
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
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _recordingStream?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
