import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // TFLite 모델 로드
    final interpreter = await Interpreter.fromAsset('assets/yamnet.tflite');
    print('✅ YamNet 모델 로드 성공');

    // 레이블 파일 로드
    final labelData = await rootBundle.loadString('assets/yamnet_labels.txt');
    final labels = labelData.split('\n');
    print('✅ 레이블 파일 로드 성공 (총 ${labels.length}개의 레이블)');

    // 모델 정보 출력
    print('✅ 모델 입력 텐서 정보: ${interpreter.getInputTensor(0)}');
    print('✅ 모델 출력 텐서 정보: ${interpreter.getOutputTensor(0)}');

    // 테스트 데이터 생성 (예: 랜덤 값)
    final input = Float32List(15600); // YamNet 모델 요구 입력 크기
    for (int i = 0; i < input.length; i++) {
      input[i] = 0.0; // 0으로 채움
    }

    final output = List<double>.filled(521, 0.0); // YamNet 출력 크기
    interpreter.run(input, output);

    // 결과 출력
    final maxIndex = output.indexOf(output.reduce((a, b) => a > b ? a : b));
    print('✅ 테스트 완료: 가장 높은 확률의 레이블 = ${labels[maxIndex]} (신뢰도: ${output[maxIndex]})');

  } catch (e) {
    print('❌ 테스트 실패: $e');
  }
}
