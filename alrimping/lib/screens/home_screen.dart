import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/sound_provider.dart';
import './settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();
    Provider.of<SoundProvider>(context, listen: false).initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndRequestPermission();
    }
  }

  Future<void> _checkAndRequestPermission() async {
    if (!mounted) return;

    final status = await Permission.microphone.request();
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
      });

      if (!status.isGranted && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('마이크 권한 필요'),
              content: const Text('음성 감지를 위해 마이크 권한이 필요합니다.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('설정으로 이동'),
                  onPressed: () async {
                    await openAppSettings();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 버튼 처리
        final soundProvider = Provider.of<SoundProvider>(context, listen: false);
        if (soundProvider.isListening) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('알림'),
              content: const Text('소리 감지가 진행 중입니다. 정말 종료하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('종료'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: const Color(0xFFA61420),
          title: const Text(
            'Alrimping',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          toolbarHeight: 70,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: !_hasPermission
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '마이크 권한이 필요합니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkAndRequestPermission,
                child: const Text('권한 요청'),
              ),
            ],
          ),
        )
            : Consumer<SoundProvider>(
          builder: (context, soundProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          soundProvider.isListening
                              ? "${soundProvider.currentDecibel.toStringAsFixed(1)} dB"
                              : "-- dB",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => soundProvider.toggleListening(),
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: soundProvider.isListening ? Colors.grey[500] : Colors.grey[600],
                              border: Border.all(
                                color: soundProvider.isListening ? const Color(0xFFF23838) : Colors.grey[400]!,
                                width: 8,
                              ),
                              boxShadow: soundProvider.isListening
                                  ? [
                                BoxShadow(
                                  color: const Color(0xFFF23838).withOpacity(0.6),
                                  spreadRadius: 30,
                                  blurRadius: 40,
                                ),
                              ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                soundProvider.isListening ? 'ON' : 'OFF',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: soundProvider.isListening ? Colors.yellow : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          soundProvider.isListening
                              ? "경고 알림이 시작됩니다"
                              : "경고 알림이 비활성화 상태입니다",
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          soundProvider.isListening
                              ? '버튼을 누르면 경고 알림이 해제됩니다'
                              : '버튼을 눌러 경고 알림을 켜세요',
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
            );
          },
        ),
      ),
    );
  }
}