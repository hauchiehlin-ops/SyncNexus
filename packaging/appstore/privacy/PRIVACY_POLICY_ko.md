# 개인정보 처리방침 (macOS 버전)

**시행일자**: 2026년 10월 2일  
**애플리케이션**: Sync-Nexus for Mac (Mac App Store 버전)

Sync-Nexus는 로컬 우선 파일 동기화 유틸리티로, 사용자의 개인정보를 엄격히 보호합니다.

---

### 1. 데이터 수집 및 개인정보 보호 원칙
* **서버리스 및 계정 불필요**: 클라우드 서버를 운영하지 않으며 계정 등록이나 개인정보를 요구하지 않습니다.
* **텔레메트리 및 추적 없음**: 외부 분석(Analytics) 도구나 추적 SDK가 전혀 포함되어 있지 않습니다.
* **로컬 파일 격리**: 모든 파일 동기화는 사용자 기기 및 신뢰할 수 있는 로컬 Wi-Fi 내에서만 이루어집니다.

---

### 2. Apple App Store 샌드박스 및 권한 안내
* **사용자 선택 파일 접근 (`com.apple.security.files.user-selected.read-write`)**: 사용자가 직접 대화 상자에서 선택한 폴더에만 접근합니다.
* **보안 범위 북마크 (`com.apple.security.files.bookmarks.app-scope`)**: 앱 재실행 후에도 선택된 폴더 권한을 안전하게 유지합니다.
* **이동식 볼륨 접근 (`com.apple.security.files.volumes.read-write`)**: 외장 USB-C 및 SD 카드를 감지하고 동기화합니다.
* **Bonjour 로컬 네트워크 탐색 (`_syncnexus._tcp`)**: 로컬 Wi-Fi 내 기기 간 직결 통신에만 사용됩니다.

---

### 3. 문의하기
GitHub 저장소: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
