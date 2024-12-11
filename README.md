### 2024-02-CSC4004-1-4-Team4

# 🚀 Alrimping  

**"위험한 소리, 놓치지 마세요!"**  
AI 기반으로 주변의 위험 소리를 감지하여 사용자에게 경고를 주는 스마트 안전 앱입니다.

<div style="display: flex; flex-direction: column; align-items: center; gap: 20px; margin-bottom: 40px; background-color: #f9f9f9; padding: 40px; border-radius: 20px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); max-width: 600px; margin: 0 auto;">
    <img src="alrimping/assets/images/app_icon.png" alt="App logo" style="width: 150px; height: 150px; border-radius: 20px; border: 4px solid #333; box-shadow: 0 2px 12px rgba(0, 0, 0, 0.3);">
    <div style="text-align: center;">
      </span>
    </div>
</div>



---

## 📱 앱 소개  

Alrimping은 다음과 같은 기능을 제공합니다:  
- **AI 소리 감지**: 위험한 소리(차 경적, 비명 등)를 실시간 분석.  
- **스마트 알림**: 배경에서 동작하며 팝업으로 사용자에게 경고.  
- **디자인 중심 UI**: 사용하기 쉬운 직관적인 인터페이스.

![App Preview](alrimping/assets/images/app_preview.png)

---


## ⚙️ 기술 스택 


- **프론트엔드**: Flutter  
- **백엔드**: TensorFlow 기반 AI 모델  
- **사운드 감지**: Noise Meter 패키지  
- **디자인 툴**: Figma  


---


## 📂 프로젝트 구조

### file struct
#### /lib  ######
 #### ── main.dart                  // 앱의 진입점
 #### ── screens                    // 앱의 각 화면 폴더
 ###### │   ── home_screen.dart
 ###### │   ── settings_screen.dart
 #### ── services                   // API 및 AI 모델 관련 서비스 폴더
 ###### │   ── audio_detection_manager.dart   // 소리 감지 및 AI 분석 기능
 ###### │   ── notification_service.dart      // 팝업 알림 관리


---

## 👨‍👩‍👧‍👦 팀원 소개  

| 팀원 명   | 역할       |  
|-----------|------------|  
| **서동건** | 팀장 : 프로젝트 설계, 디자인(ui) 및 프론트, 백엔드, 출시 및 발표  |  
| **이준원** | 팀원 : 백엔드 개발 총괄 (음성 AI모델 YAMNet연동, 음성스트리밍등)  |  
| **홍준표** | 팀원 : 백엔드(마이크 권한 획득, 마이크 테스트) YAMNet적용 ,인식률 테스트    | 
| **이예림** | 팀원 : Ui디자인 및 모바일 프론트엔드, 자료조사 및 백엔드 보조      |  
| **떠진코** | 팀원 : 전반적인 진행 과정 테스트, 자료조사      |  
