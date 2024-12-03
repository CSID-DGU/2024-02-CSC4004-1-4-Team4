import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'notification_service.dart';  // 이 줄을 import 목록 맨 아래에 추가

class AudioDetectionManager {
  // YAMNet 모델이 요구하는 설정값들
  static const int sampleRate = 16000;  // 16kHz 샘플레이트
  static const int waveformLength = 15600;  // 모델 입력 길이
  static const int labelCount = 521;  // 클래스 수
  static const double confidenceThreshold = 0.3;  // 신뢰도 임계값

  // 위험 소리 인덱스 정의
  static const Set<int> dangerousSoundIndices = {
    // 긴급상황 관련
    317, // Ambulance (siren)
    318, // Police car (siren)
    319, // Fire engine, fire truck (siren)
    390, // Siren
    391, // Civil defense siren
    394, // Fire alarm
    393, // Smoke detector, smoke alarm

    // 차량 경고음 관련
    302, // Vehicle horn, car horn, honking
    303, // Toot
    312, // Air horn, truck horn

    // 폭발/충돌 관련
    463, // Smash, crash
    464, // Breaking

    // 인간 비상상황
    11,  // Screaming
    19,  // Crying, sobbing
    22,  // Wail, moan

    // 기계 위험
    341, // Chainsaw
    414, // Jackhammer
    418  // Power tool
  };

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamSubscription<RecordingDisposition>? _recorderSubscription;
  late final Interpreter _interpreter;
  final List<String> _labels = [];
  final Queue<double> _audioBuffer = Queue<double>();
  StreamController<Uint8List>? _audioStreamController;

  // 기존 필드들 아래에 다음 필드들 추가
  final NotificationService _notificationService = NotificationService();
  DateTime? _lastNotificationTime;
  static const Duration _minimumNotificationInterval = Duration(seconds: 3);

  Function(double)? onAudioLevelUpdate;
  Function(String, double)? onSoundDetected;
  Function(String, double)? onDangerousSoundDetected;  // 위험 소리 감지 콜백 추가

  bool _isInitialized = false;
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  int _totalSamplesReceived = 0;

  Future<void> initialize() async {
    try {
      // 마이크 권한 요청
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        throw Exception('마이크 권한이 필요합니다.');
      }

      // YAMNet 모델 초기화
      final interpreterOptions = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        'yamnet.tflite',
        options: interpreterOptions,
      );

      // 레이블 파일 로드
      final labelData = await rootBundle.loadString('assets/yamnet_labels.txt');
      _labels.addAll(labelData.split('\n'));

      // 오디오 레코더 초기화
      await _recorder.openRecorder();
      await _recorder.setSubscriptionDuration(
          const Duration(milliseconds: 30)  // 30ms 간격으로 데이터 수신
      );

      await _notificationService.initialize();  // 이 줄 추가
      _isInitialized = true;
      debugPrint('AudioDetectionManager 초기화 완료');
    } catch (e) {
      debugPrint('AudioDetectionManager 초기화 실패: $e');
      rethrow;
    }
  }

  Future<void> startDetection() async {
    if (!_isInitialized) {
      throw Exception('AudioDetectionManager가 초기화되지 않았습니다.');
    }

    if (_isRecording) {
      debugPrint('이미 녹음 중입니다.');
      return;
    }

    try {
      _recordingStartTime = DateTime.now();
      _totalSamplesReceived = 0;
      _audioBuffer.clear();

      // PCM 데이터를 위한 스트림 컨트롤러 초기화
      _audioStreamController = StreamController<Uint8List>();

      // 오디오 녹음 시작
      await _recorder.startRecorder(
        codec: Codec.pcm16,  // 16비트 PCM 포맷
        numChannels: 1,      // 모노 채널
        sampleRate: sampleRate,
        toStream: _audioStreamController?.sink,
      );

      // PCM 데이터 처리를 위한 스트림 구독
      _audioStreamController?.stream.listen((pcmData) {
        final audioData = _convertPcmToDouble(pcmData);
        _processAudioData(audioData);
      });

      // 오디오 레벨 모니터링
      _recorderSubscription = _recorder.onProgress?.listen(
            (RecordingDisposition disposition) {
          if (onAudioLevelUpdate != null) {
            final normalizedLevel = ((disposition.decibels ?? -160) + 160) / 160;
            onAudioLevelUpdate!(normalizedLevel);
          }
          _totalSamplesReceived += (sampleRate ~/ 33);
          _updateAudioStats(disposition);
        },
      );

      _isRecording = true;
      debugPrint('소리 감지 시작됨');
    } catch (e) {
      debugPrint('소리 감지 시작 실패: $e');
      rethrow;
    }
  }

  // PCM 바이트 데이터를 double로 변환
  List<double> _convertPcmToDouble(Uint8List pcmData) {
    final doubleData = <double>[];
    for (var i = 0; i < pcmData.length; i += 2) {
      // 16비트 PCM 데이터를 double로 변환 (-1.0 ~ 1.0 범위)
      final int16Value = pcmData[i] | (pcmData[i + 1] << 8);
      doubleData.add(int16Value / 32768.0);
    }
    return doubleData;
  }

  void _processAudioData(List<double> data) {
    _audioBuffer.addAll(data);

    while (_audioBuffer.length >= waveformLength) {
      final inputData = _prepareModelInput();
      if (inputData != null) {
        _runInference(inputData);
      }
    }
  }

  List<double>? _prepareModelInput() {
    if (_audioBuffer.length < waveformLength) return null;

    final modelInput = <double>[];
    for (var i = 0; i < waveformLength; i++) {
      modelInput.add(_audioBuffer.removeFirst());
    }

    // 오디오 데이터 정규화
    final maxAbs = modelInput.map((x) => x.abs()).reduce(
            (max, x) => x > max ? x : max
    );

    if (maxAbs > 0) {
      for (var i = 0; i < modelInput.length; i++) {
        modelInput[i] /= maxAbs;
      }
    }

    return modelInput;
  }

  void _runInference(List<double> audioData) {
    try {
      final input = [audioData];
      final outputShape = [1, labelCount];
      final output = List<List<double>>.filled(
        outputShape[0],
        List<double>.filled(outputShape[1], 0.0),
      );

      _interpreter.run(input, output);
      final predictions = output[0];

      // 임계값 이상의 예측 결과 필터링
      List<MapEntry<int, double>> topPredictions = [];
      for (var i = 0; i < predictions.length; i++) {
        if (predictions[i] >= confidenceThreshold) {
          topPredictions.add(MapEntry(i, predictions[i]));
        }
      }

      // 신뢰도 기준 정렬
      topPredictions.sort((a, b) => b.value.compareTo(a.value));

      if (topPredictions.isNotEmpty) {
        for (final prediction in topPredictions) {
          if (dangerousSoundIndices.contains(prediction.key) &&
              prediction.value >= confidenceThreshold) {
            final dangerLabel = _labels[prediction.key];

            final now = DateTime.now();
            if (_lastNotificationTime == null ||
                now.difference(_lastNotificationTime!) >= _minimumNotificationInterval) {
              _notificationService.showDangerAlert(dangerLabel);
              _lastNotificationTime = now;
            }

            onDangerousSoundDetected?.call(dangerLabel, prediction.value);
          }
        }
      }

      // 위험 소리 감지 및 일반 소리 감지 처리
      if (topPredictions.isNotEmpty) {
        final topPrediction = topPredictions[0];
        final soundLabel = _labels[topPrediction.key];
        final confidence = topPrediction.value;

        // 일반적인 소리 감지 콜백
        onSoundDetected?.call(soundLabel, confidence);

        // 위험 소리인 경우 추가 콜백 실행
        if (dangerousSoundIndices.contains(topPrediction.key)) {
          debugPrint('위험 소리 감지: $soundLabel (신뢰도: ${(confidence * 100).toStringAsFixed(1)}%)');
          onDangerousSoundDetected?.call(soundLabel, confidence);
        }

        // 추가 위험 소리 체크 - 상위 예측 결과들 중 위험 소리가 있는지 확인
        for (final prediction in topPredictions.skip(1)) {
          if (dangerousSoundIndices.contains(prediction.key) &&
              prediction.value >= confidenceThreshold) {
            final additionalDangerLabel = _labels[prediction.key];
            debugPrint('추가 위험 소리 감지: $additionalDangerLabel (신뢰도: ${(prediction.value * 100).toStringAsFixed(1)}%)');
            onDangerousSoundDetected?.call(additionalDangerLabel, prediction.value);
          }
        }
      }
    } catch (e) {
      debugPrint('모델 추론 중 오류: $e');
    }
  }

  void _updateAudioStats(RecordingDisposition event) {
    final duration = DateTime.now().difference(_recordingStartTime!);
    if (duration.inSeconds != (duration - const Duration(milliseconds: 30)).inSeconds) {
      debugPrint('오디오 스트리밍 통계:');
      debugPrint('총 수신 샘플 수: $_totalSamplesReceived');
      debugPrint('현재 오디오 레벨: ${event.decibels} dB');
      debugPrint('경과 시간: ${duration.inSeconds}초');
    }
  }

  Future<void> stopDetection() async {
    if (!_isRecording) return;

    try {
      // 모든 스트림과 구독 정리
      await _recorderSubscription?.cancel();
      _recorderSubscription = null;
      await _audioStreamController?.close();
      _audioStreamController = null;

      await _recorder.stopRecorder();
      _isRecording = false;

      // 최종 통계 출력
      final duration = DateTime.now().difference(_recordingStartTime!);
      debugPrint('녹음 종료 통계:');
      debugPrint('총 녹음 시간: ${duration.inSeconds}초');
      debugPrint('총 수신 샘플 수: $_totalSamplesReceived');
      debugPrint('평균 샘플링 레이트: ${_totalSamplesReceived / duration.inSeconds} Hz');

    } catch (e) {
      debugPrint('소리 감지 중지 중 오류: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await stopDetection();
      await _recorder.closeRecorder();
      _interpreter.close();
      debugPrint('AudioDetectionManager 리소스 정리 완료');
    } catch (e) {
      debugPrint('리소스 정리 중 오류: $e');
    }
  }

  bool get isRecording => _isRecording;
}