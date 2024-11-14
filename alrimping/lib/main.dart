import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // home_screen.dart 파일 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화 (5초 동안 회전)
    _controller = AnimationController(
      duration: Duration(seconds: 5), // 전체 회전 지속 시간을 5초로 설정
      vsync: this,
    );

    // 3바퀴 회전을 위해 Tween 범위를 0.0에서 3.0으로 설정
    _rotationAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );

    // 애니메이션 시작
    _controller?.forward();

    // 애니메이션 종료 후 5초 후에 메인 화면으로 이동
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AlarmPingScreen()), // 메인 화면으로 이동
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose(); // 애니메이션 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Column을 사용하여 이미지 아래에 텍스트 추가
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Transform을 사용하여 회전 애니메이션 적용
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 3D 효과를 위한 perspective 설정
                    ..rotateY(_rotationAnimation!.value * 2 * 3.14159), // Y축을 중심으로 회전
                  child: child,
                );
              },
              // Image.asset에 직접 width, height 적용
              child: Image.asset(
                'assets/images/splash_logo.png',
                width: 400, // 원하는 너비로 설정
                height: 400, // 원하는 높이로 설정
                fit: BoxFit.contain, // 이미지 크기를 부모에 맞춰 조정
              ),
            ),
            SizedBox(height: 10), // 이미지와 텍스트 사이의 간격
            Text(
              'Alrimping', // 텍스트 추가
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
