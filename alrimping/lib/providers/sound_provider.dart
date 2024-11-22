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
    _backgroundService.on('update').listen((event) {
      if (event != null && event['decibel'] != null) {
        _currentDecibel = double.parse(event['decibel'].toString());
        notifyListeners();
      }
    });
  }

  void setSensitivity(double value) {
    _sensitivity = value;
    if (_isListening) {
      _backgroundService.invoke(
          'updateSensitivity',
          {'sensitivity': value.toString()}
      );
    }
    notifyListeners();
  }

  void toggleListening() {
    if (!_isListening) {
      _backgroundService.startService();
      _backgroundService.invoke(
          'start',
          {'sensitivity': _sensitivity.toString()}
      );
    } else {
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