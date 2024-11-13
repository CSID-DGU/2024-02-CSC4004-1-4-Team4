import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double sensitivity = 5; // 초기 민감도 값 (1부터 10까지)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Color(0xFFA61420),
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "소리 민감도 설정",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            // Slider with labels for 1 and 10
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1', style: TextStyle(fontSize: 16)), // 시작 레이블
                Expanded(
                  child: Slider(
                    value: sensitivity,
                    min: 1,
                    max: 5,
                    divisions: 4, // 1부터 10까지 1단위로 나눔
                    label: sensitivity.round().toString(),
                    activeColor: Color(0xFFF26363),
                    onChanged: (double value) {
                      setState(() {
                        sensitivity = value;
                      });
                    },
                  ),
                ),
                Text('5', style: TextStyle(fontSize: 16)), // 끝 레이블
              ],
            ),
            SizedBox(height: 20),
            Text(
              "현재 민감도: ${sensitivity.round()}",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
