import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../main.dart';  // initializeService를 import

class SoundProvider with ChangeNotifier {
  bool _isListening = false;
  double _currentDecibel = 0.0;
  double _sensitivity = 3.0;
  FlutterBackgroundService? _backgroundService;

  bool get isListening => _isListening;
  double get currentDecibel => _currentDecibel;
  double get sensitivity => _sensitivity;

  Future<void> initialize() async {
    _backgroundService = await initializeService();

    _backgroundService?.on('update').listen((event) {
      if (event != null && event['decibel'] != null) {
        try {
          _currentDecibel = double.parse(event['decibel'].toString());
          notifyListeners();
        } catch (e) {
          debugPrint('Error parsing decibel: $e');
        }
      }
    });
  }

  void setSensitivity(double value) {
    _sensitivity = value;
    if (_isListening) {
      _backgroundService?.invoke(
          'updateSensitivity',
          {'sensitivity': value.toString()}
      );
    }
    notifyListeners();
  }

  Future<void> toggleListening() async {
    try {
      if (!_isListening) {
        _backgroundService ??= await initializeService();  // null-aware 수정

        var service = _backgroundService;
        if (service != null) {  // null check
          await service.startService();
          service.invoke(
              'start',
              {'sensitivity': _sensitivity.toString()}
          );
        }
      } else {
        _backgroundService?.invoke('stop');
        _backgroundService = null;
      }
      _isListening = !_isListening;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling service: $e');
    }
  }

  @override
  void dispose() {
    if (_isListening) {
      _backgroundService?.invoke('stop');
    }
    super.dispose();
  }
}