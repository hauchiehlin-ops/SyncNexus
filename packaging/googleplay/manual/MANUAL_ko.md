# Sync-Nexus 사용 설명서 (Android 버전)

## 1. 개요 및 소개
**Sync-Nexus for Android**는 Android 스마트폰 및 태블릿을 위해 설계된 오프라인 P2P 양방향 폴더 동기화 도구입니다. 내부 저장소 폴더, SD 카드, USB-OTG 외장 드라이브 및 동일 Wi-Fi 로컬 네트워크 내의 Mac과의 P2P 직결 동기화를 지원합니다.

![Sync-Nexus Android 인터페이스 화면](/Users/barretlin/.gemini/antigravity/brain/a78dbd7e-b8d4-4059-8ea4-510ecb66c712/android_screen_ui_1790946598473.jpg)

---

## 2. Android 전용 핵심 기능
* **저장소 접근 프레임워크(SAF)**: Google Play의 Scoped Storage 정책을 100% 준수하며, 심사 거절 위험이 높은 `MANAGE_EXTERNAL_STORAGE` 권한을 요구하지 않습니다.
* **배터리 및 전원 스마트 감지**: 배터리 잔량이 15% 미만이고 충전 중이 아닐 때 무거운 전송 작업을 자동으로 연기합니다.
* **OTG USB 드라이브 즉시 인식**: USB 드라이브 연결 시 즉각 감지하여 동기화 엔드포인트로 추가할 수 있습니다.
* **포그라운드 서비스(Foreground Service)**: 장시간 대용량 파일 전송 중에도 Android Doze 모드에 의해 프로세스가 종료되지 않도록 보장합니다.
* **Wi-Fi 로컬 P2P 직결**: NSD를 통해 동일 네트워크 내 Mac을 자동으로 탐색하여 직접 연결을 엽니다.

---

## 3. 단계별 사용 방법

### 1단계: SAF를 통한 폴더 추가
1. Android 기기에서 **Sync-Nexus**를 엽니다.
2. 메인 화면의 **폴더 추가…**를 탭합니다.
3. 시스템 파일 선택 창에서 동기화할 폴더를 선택하고 권한을 허용합니다 (최소 2개 폴더 등록).

### 2단계: 즉시 대조 및 동기화
1. **지금 대조 및 동기화**를 탭하여 양방향 동기화를 시작합니다.
2. 실시간 상태 및 활동 로그를 확인합니다.
