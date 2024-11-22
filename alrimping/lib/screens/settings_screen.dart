import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sound_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA61420),
        title: const Text("설정"),
      ),
      body: Consumer<SoundProvider>(
        builder: (context, soundProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "소리 민감도 설정",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('1', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Slider(
                        value: soundProvider.sensitivity,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: soundProvider.sensitivity.round().toString(),
                        activeColor: const Color(0xFFF26363),
                        onChanged: (value) {
                          soundProvider.setSensitivity(value);
                        },
                      ),
                    ),
                    const Text('5', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "현재 민감도: ${soundProvider.sensitivity.round()}",
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}