import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _sensitivity = 3.0;

  Widget _buildSensitivityCard() {
    return _SettingsCard(
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
    );
  }

  Widget _buildNotificationCard() {
    return _SettingsCard(
      title: "알림 설정",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotificationSwitch(
            title: "진동 알림",
            value: true,
            onChanged: (bool value) {
              // 나중에 구현할 기능
            },
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFEEEEEE),
          ),
          _buildNotificationSwitch(
            title: "소리 알림",
            value: true,
            onChanged: (bool value) {
              // 나중에 구현할 기능
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFF23838),
      ),
    );
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSensitivityCard(),
            const SizedBox(height: 30),
            _buildNotificationCard(),
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