# SyncNexus 개인정보 처리방침 — Windows (Microsoft Store 심사 기준)

**시행일**: 2026년 10월 3일  
**배포 플랫폼**: Microsoft Store / Windows 데스크톱 배포  
**개발자**: SyncNexus Team  

SyncNexus는 사용자의 개인정보 보호와 투명성을 위해 최선을 다합니다. 본 개인정보 처리방침은 **Microsoft Store 앱 인증 정책(특히 10.5항 개인 정보)** 을 엄격히 따르며, 데이터를 철저히 로컬에서만 처리하고 텔레메트리를 사용하지 않는 구조를 설명합니다.

---

### 1. 개인정보 선언
* **데이터 수집 없음**: SyncNexus는 개인정보, 기기 식별자, 사용 텔레메트리를 **수집, 전송, 저장, 공유하지 않습니다**.
* **원격 서버 없음**: 동기화는 사용자의 로컬 파일 시스템, 로컬에 마운트된 클라우드 파일 시스템(Google Drive / OneDrive), 외장 이동식 저장소 사이에서만 이루어집니다. 파일 내용은 기기 환경 밖으로 나가지 않습니다.
* **서드파티 분석 없음**: 추적, 광고, 분석, 행동 모니터링을 위한 서드파티 SDK를 포함하지 않습니다.

---

### 2. Windows 기능 및 투명성
1. **파일 시스템 접근**:
   - 사용자가 직접 선택한 폴더를 읽고, 비교하고, 동기화하는 용도로만 사용합니다.
2. **Windows Cloud Files API 연동**:
   - Google Drive와 OneDrive 폴더의 `FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS` 자리 표시자 속성을 확인하는 데에만 사용하며, 캐시되지 않은 파일이 의도치 않게 다운로드(hydration)되는 것을 막습니다.
3. **로컬 기기 검색 (mDNS 멀티캐스트)**:
   - 로컬 Wi-Fi 안에서 멀티캐스트 IP `224.0.0.251:5353`으로 `_syncnexus._tcp.local`을 송수신합니다. **외부 인터넷 서버에는 어떠한 연결도 만들지 않습니다**.
4. **시작 프로그램 설정 (Windows 시작 레지스트리)**:
   - 사용자가 켠 경우에만 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`에 항목을 등록하여 백그라운드 동기화 수호 프로그램을 조용히 실행합니다. 설정이나 Windows 작업 관리자에서 언제든 끌 수 있습니다.

---

### 3. 휴지통과 데이터 안전
* 삭제된 파일은 Win32 `SHFileOperationW`를 사용해 **실제 Windows 휴지통**으로 안전하게 이동됩니다.
* 삭제 전에 `.syncnexus-history`에 보관하여 다중 단계의 데이터 보호를 제공합니다.

---

### 4. 문의
개인정보 관련 문의 또는 Microsoft Store 인증 심사 관련 사항:  
저장소: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
