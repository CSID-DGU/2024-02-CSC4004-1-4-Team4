import 'package:flutter/material.dart';

class AlarmPingScreen extends StatefulWidget {
  @override
  _AlarmPingScreenState createState() => _AlarmPingScreenState();
}

class _AlarmPingScreenState extends State<AlarmPingScreen> {
  bool isAlarmOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 제목
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Text(
              'Alrimping',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 흰색 글자색
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 원형 버튼 안의 알림 상태 (아이콘 및 상태 표시)
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAlarmOn ? Colors.grey[700] : Colors.grey[800],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications,
                                color: isAlarmOn ? Colors.yellow : Colors.grey,
                                size: 80,
                              ),
                              SizedBox(height: 20),
                              Text(
                                isAlarmOn ? 'ON' : 'OFF',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isAlarmOn ? Colors.yellow : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  // 스위치 버튼
                  Switch(
                    value: isAlarmOn,
                    onChanged: (value) {
                      setState(() {
                        isAlarmOn = value;
                      });
                    },
                    activeColor: Colors.blue,
                    inactiveThumbColor: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  // 상태 설명 텍스트
                  Text(
                    "소리 경고가 시작됩니다",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 흰색 글자색
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    isAlarmOn
                        ? '알람이 활성화되었습니다'
                        : '알람이 비활성화되었습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey, // 회색 글자색
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
