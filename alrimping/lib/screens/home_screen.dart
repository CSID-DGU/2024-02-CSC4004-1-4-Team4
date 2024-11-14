import 'package:flutter/material.dart';
import 'setting_screen.dart'; // SettingsScreen 클래스를 import

class AlarmPingScreen extends StatefulWidget {
  @override
  _AlarmPingScreenState createState() => _AlarmPingScreenState();
}

class _AlarmPingScreenState extends State<AlarmPingScreen> {
  bool isAlarmOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2), // 배경색 흰색(#F2F2F2)
      appBar: AppBar(
        backgroundColor: Color(0xFFA61420), // 상단 바 색상 빨간색(#A61420)
        title: Text(
          'Alrimping',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 제목 텍스트 색상 흰색
          ),
        ),
        centerTitle: false, // 왼쪽 정렬
        toolbarHeight: 70, // 상단 바 높이 조정 (기본은 56)
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
                  // 원형 버튼 안의 알림 상태 (아이콘 및 상태 표시)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isAlarmOn = !isAlarmOn; // 버튼을 탭할 때마다 상태 토글
                        });
                      },
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAlarmOn ? Colors.grey[500] : Colors.grey[600],
                          border: Border.all(
                            color: isAlarmOn ? Color(0xFFF23838) : Colors.grey[400]!,
                            width: 8, // 테두리 두께
                          ),
                          // 그림자 효과 추가
                          boxShadow: isAlarmOn
                              ? [
                            BoxShadow(
                              color: Color(0xFFF23838).withOpacity(0.6), // 그림자 색상 #F23838
                              spreadRadius: 30, // 그림자가 퍼지는 정도
                              blurRadius: 40,   // 그림자 흐림 정도
                              offset: Offset(0, 0), // 그림자 위치
                            ),
                          ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 이미지로 아이콘 대체
                            Image.asset(
                              'assets/images/splash_logo.png',
                              width: 200,
                              height: 200,
                            ),
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
                    ),
                  ),
                  SizedBox(height: 60),
                  // 상태 설명 텍스트
                  Text(
                    isAlarmOn
                        ? "경고 알림이 시작됩니다"
                        : "경고 알림이 비활성화 상태입니다",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // 텍스트 색상 검정
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    isAlarmOn
                        ? '버튼을 누르면 경고 알림이 해제됩니다'
                        : '버튼을 눌러 경고 알림을 켜세요',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey, // 텍스트 색상 회색
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // 하단 네비게이션 바 추가
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFA61420), // 하단 바 색상 빨간색(#A61420)
        child: IconButton(
          icon: Icon(
            Icons.settings,
            color: Colors.white,
            size: 50, // 아이콘 크기 (원하는 크기로 설정)
          ),
          onPressed: () {
            // 설정 페이지로 이동하는 로직
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
        ),
      ),
    );
  }
}
