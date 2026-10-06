# SyncNexus 개인정보 처리방침 — Apple (App Store 심사 기준)

**시행일**: 2026년 10월 3일  
**배포 플랫폼**: Apple App Store (macOS / iOS / iPadOS)  
**개발자**: SyncNexus Team  

SyncNexus는 개인정보 보호가 기본적 인권이라는 원칙을 따릅니다. 본 개인정보 처리방침은 **Apple App Store 심사 지침(특히 지침 5.1.1 데이터 수집 및 저장)** 을 엄격히 따르며, 데이터를 수집하지 않고 로컬 처리를 최우선으로 하는 구조를 설명합니다.

---

### 1. 데이터 수집 없음 및 텔레메트리 없음
* **원격 데이터 전송 없음**: SyncNexus에는 원격 서버가 없습니다. 파일 내용, 파일 이름, 폴더 계층 구조, 암호화 체크섬(SHA-256)은 **사용자의 기기와 사용자가 선택한 동기화 폴더에만 저장됩니다**.
* **서드파티 SDK 및 분석 없음**: 추적, 광고, 분석, 행동 텔레메트리를 위한 서드파티 SDK를 포함하지 않습니다.
* **계정 불필요**: SyncNexus를 사용하는 데 계정 생성, 이메일 등록, 개인 신원 공개가 필요하지 않습니다.

---

### 2. Apple App Sandbox 및 권한(Entitlements) 준수
SyncNexus는 Apple App Sandbox 환경 안에서만 실행되며, 로컬 파일 동기화에 꼭 필요한 최소한의 권한만 요청합니다:
1. **사용자가 선택한 파일 및 폴더 (`com.apple.security.files.user-selected.read-write`)**:
   - 접근은 사용자가 기본 `NSOpenPanel`로 직접 선택한 디렉터리로만 제한됩니다.
2. **보안 범위 북마크 (`com.apple.security.files.bookmarks.app-scope`)**:
   - 샌드박스 안에서 사용자가 선택한 폴더의 권한 정보를 앱을 다시 시작해도 유지하기 위해 사용합니다.
3. **로컬 네트워크 통신 (`com.apple.security.network.client` / `network.server`)**:
   - 같은 Wi-Fi 네트워크의 다른 SyncNexus 노드(Mac, Windows, Android)를 찾기 위한 Apple Bonjour(mDNS 멀티캐스트)에만 사용합니다. **공용 인터넷으로는 어떠한 데이터도 전송되지 않습니다**.

---

### 3. 데이터 무결성 및 보호 장치
* **삭제 가드**: 대량 삭제(25개 초과 또는 추적 항목의 25% 초과)를 자동으로 차단하여 이동식 저장장치 연결이 끊겼을 때의 우발적인 손실을 막습니다.
* **버전 기록**: 교체되거나 휴지통으로 이동된 파일을 보관 폴더에 자동으로 보존하여 즉시 되돌릴 수 있습니다.

---

### 4. 문의
개인정보 관련 문의 또는 App Store 심사 관련 확인 사항:  
저장소: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
