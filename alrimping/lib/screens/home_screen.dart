import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'settings_screen.dart';

class SoundDetectionScreen extends StatefulWidget {
  const SoundDetectionScreen({super.key});

  @override
  State<SoundDetectionScreen> createState() => _SoundDetectionScreenState();
}

class _SoundDetectionScreenState extends State<SoundDetectionScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _initializeSoundComponents();
  }

  Future<void> _initializeSoundComponents() async {
    try {
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        throw Exception('Microphone permission not granted');
      }

      await _recorder.openRecorder();
      await _player.openPlayer();
      await _backgroundService.startService();
    } catch (e) {
      debugPrint('Error initializing components: $e');
    }
  }

  Future<String> _getRecordingPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/temp_recording.aac';
  }

  void _toggleRecording() async {
    try {
      if (_isRecording) {
        if (_recorder.isRecording) {
          _recordingPath = await _recorder.stopRecorder();
        }
        _backgroundService.invoke('stopListening');
      } else {
        _recordingPath = await _getRecordingPath();
        _backgroundService.invoke('startListening');
        await _recorder.startRecorder(
          toFile: _recordingPath,
          codec: Codec.aacADTS,
        );
      }

      setState(() {
        _isRecording = !_isRecording;
        if (!_isRecording) _isPlaying = false;
      });
    } catch (e) {
      debugPrint('Error during recording toggle: $e');
    }
  }

  void _togglePlayback() async {
    if (_recordingPath == null) return;

    try {
      if (_isPlaying) {
        await _player.stopPlayer();
        setState(() {
          _isPlaying = false;
        });
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
        setState(() {
          _isPlaying = true;
        });
      }
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
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA61420),
        title: const Text(
          'Sound Detection',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.grey[500] : Colors.grey[600],
                        border: Border.all(
                          color: _isRecording ? const Color(0xFFF23838) : Colors.grey[400]!,
                          width: 8,
                        ),
                        boxShadow: _isRecording ? [
                          BoxShadow(
                            color: const Color(0xFFF23838).withOpacity(0.6),
                            spreadRadius: 30,
                            blurRadius: 40,
                          ),
                        ] : [],
                      ),
                      child: Center(
                        child: Text(
                          _isRecording ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _isRecording ? Colors.yellow : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_recordingPath != null)
                    ElevatedButton.icon(
                      onPressed: _togglePlayback,
                      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                      label: Text(_isPlaying ? '중지' : '재생'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA61420),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12
                        ),
                      ),
                    ),
                  const SizedBox(height: 60),
                  Text(
                    _isRecording ? "녹음이 진행 중입니다" : "녹음이 중지되었습니다",
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isRecording ? '버튼을 누르면 녹음이 중지됩니다' : '버튼을 눌러 녹음을 시작하세요',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
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