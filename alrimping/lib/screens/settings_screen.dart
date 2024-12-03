<<<<<<< HEAD
=======
//screens/settings_screen.dart
>>>>>>> 849047cba10491d28e72d1e61f195cf1919ab9c0
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final double initialSensitivity;

  const SettingsScreen({super.key, required this.initialSensitivity});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _sensitivity;

  @override
  void initState() {
    super.initState();
    _sensitivity = widget.initialSensitivity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA61420),
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, _sensitivity); // 민감도 값을 반환
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _SettingsCard(
              title: "소리 감지 설정",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "민감도 조절",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('낮음', style: TextStyle(color: Colors.grey)),
                      Expanded(
                        child: Slider(
                          value: _sensitivity,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          activeColor: const Color(0xFFF23838),
                          inactiveColor: Colors.grey.withOpacity(0.3),
                          label: _sensitivity.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              _sensitivity = value;
                            });
                          },
                        ),
                      ),
                      const Text('높음', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "현재 민감도: ${_sensitivity.round()}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 설정 카드를 위한 재사용 가능한 위젯
class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA61420),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
