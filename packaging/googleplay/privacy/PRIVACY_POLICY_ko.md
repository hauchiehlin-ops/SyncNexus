# 개인정보 처리방침 (Android 버전)

**시행일자**: 2026년 10월 2일  
**애플리케이션**: Sync-Nexus for Android (Google Play Store 버전)

Sync-Nexus는 로컬 우선 파일 동기화 유틸리티로, 사용자의 개인정보를 엄격히 보호합니다.

---

### 1. 데이터 수집 및 개인정보 보호 원칙
* **서버리스 및 계정 불필요**: 클라우드 서버를 운영하지 않으며 계정 등록이나 개인정보를 요구하지 않습니다.
* **텔레메트리 및 광고 추적 없음**: 외부 분석(Analytics) 도구나 광고 ID (AAID) 추적이 전혀 없습니다.
* **로컬 파일 격리**: 모든 파일 동기화는 사용자 기기 및 신뢰할 수 있는 로컬 Wi-Fi 내에서만 이루어집니다.

---

### 2. Google Play 스토리지 및 시스템 권한 안내
* **저장소 접근 프레임워크(SAF)**: Google Play의 Scoped Storage 정책을 철저히 준수합니다. 사용자가 명시적으로 선택한 폴더에만 접근하며, 심사 거절 위험이 큰 `MANAGE_EXTERNAL_STORAGE` 권한은 일절 요청하지 않습니다.
* **포그라운드 서비스(`FOREGROUND_SERVICE_DATA_SYNC`)**: 백그라운드 데이터 전송 중 프로세스를 유지하며 알림 바에 진행 상태를 표시합니다.
* **로컬 네트워크 탐색(NSD / mDNS)**: 동일 Wi-Fi 내 Mac 기기와의 직접 연결에만 사용됩니다.

---

### 3. 문의하기
GitHub 저장소: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
