import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class SoundProvider with ChangeNotifier {
  bool _isListening = false;
  double _currentDecibel = 0.0;
  double _sensitivity = 3.0;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  bool get isListening => _isListening;
  double get currentDecibel => _currentDecibel;
  double get sensitivity => _sensitivity;

  void initialize() {
    _backgroundService.isRunning().then((isRunning) {
      if (!isRunning) {
        debugPrint('Background service is not running. Attempting to start.');
        _backgroundService.startService();
      }
    });

    _backgroundService.on('update').listen((event) {
      if (event != null && event['decibel'] != null) {
        double decibel = double.tryParse(event['decibel'].toString()) ?? 0.0;
        _currentDecibel = decibel;
        debugPrint('Decibel updated: $_currentDecibel');
        notifyListeners();
      }
    });
  }

  void setSensitivity(double value) {
    _sensitivity = value;
    if (_isListening) {
      _backgroundService.invoke(
        'updateSensitivity',
        {'sensitivity': value.toString()},
      );
    }
    notifyListeners();
  }

  Future<void> toggleListening() async {
    bool isRunning = await _backgroundService.isRunning(); // 백그라운드 서비스 실행 상태 확인
    if (!_isListening && !isRunning) {
      _backgroundService.startService();
      _backgroundService.invoke(
        'start',
        {'sensitivity': _sensitivity.toString()},
      );
    } else if (_isListening) {
      _backgroundService.invoke('stop');
    }
    _isListening = !_isListening;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isListening) {
      _backgroundService.invoke('stop');
    }
    super.dispose();
  }
}
