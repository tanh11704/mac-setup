# Audit MacBook Pro M1

Ngày kiểm tra: 2026-11-01. Bối cảnh: Java developer (Spring/Maven), có làm Frontend, sinh viên năm cuối đang làm đồ án TeachMate. Fresher FSoft còn tiếp tục, thực tập FSA đã xong.

## Tóm tắt

- **Rủi ro lớn nhất không nằm ở dung lượng:** máy không có bản sao lưu nào, pin đã báo cần bảo dưỡng, và nhiều việc đồ án mới chỉ nằm trên máy này (mục 8, P0).
- **Ổ đĩa chưa đầy:** còn 57.6GB trống trên 245GB. Có thể lấy lại khoảng 55GB, chưa tính phần 14GB bản clone của Chrome.
- **RAM 8GB là nút thắt thật sự:** đang swap 3.5GB chỉ với Chrome, VS Code và một container Postgres.
- **Rosetta gần như không còn là vấn đề:** không tiến trình nào đang chạy qua Rosetta. Chỉ JDK 8 và Sideloadly là bản Intel.
- **Có một lỗ hổng mạng cần đóng:** Postgres mở trên mọi địa chỉ mạng trong khi firewall đang tắt.

---

## 1. Hệ thống và dung lượng

| Mục | Giá trị |
|---|---|
| macOS | 26.6.2 (25G83) |
| Chip | Apple M1, 8 nhân |
| RAM | 8GB |
| Swap | Đã dùng 3.5GB / 5GB |
| Pageouts | 1.12 triệu sau 5 ngày chạy liên tục |
| Ổ đĩa | 245.1GB, trống 57.6GB |
| Pin | 795 chu kỳ, còn 79%, trạng thái **Service Recommended** |
| Bản cập nhật chờ cài | macOS 26.7.2 (3GB), macOS 27.2 (11GB), Safari 27.2, Command Line Tools 26.6 |

**Phân bổ theo volume APFS:** Data 158.9GB, System 12.6GB, Preboot 9.0GB, VM 5.4GB, Recovery 1.3GB.

### Các vùng chiếm nhiều dung lượng

| Vị trí | Dung lượng | Ghi chú |
|---|---|---|
| `/Users/Shared/.../BlueStacks/Engine` | 17GB | Đĩa ảo Android, phục vụ game |
| OrbStack `data.img.raw` | 16GB | Dung lượng thật. `ls` hiện 245GB vì là file sparse |
| `/private/var/folders/.../X/com.google.Chrome.code_sign_clone` | 14GB theo `du` | Khoảng 10 bản clone 1.4GB. Xem ghi chú bên dưới |
| Chrome `Application Support` | 9.7GB | Model AI 4.0GB, Service Worker 4.2GB, phần còn lại là profile |
| Chrome cache | 6.3GB | 4 profile |
| Homebrew cache | 5.3GB | Rider 2.1GB (app không còn trên máy), Outlook 1.35GB |
| VS Code `workspaceStorage` | 4.5GB | 84 thư mục, 35 thư mục có `redhat.java` |
| Docker build cache | 4.4GB | Không cái nào đang dùng |
| IntelliJ IDEA.app | 4.1GB | Đang dùng |
| ZaloData | 3.2GB | Media 1.6GB, Database 861MB |
| Teams | 2.7GB | Cache 1.5GB |
| `~/.codex` | 2.6GB | Sessions 1.1GB, packages 747MB |
| `~/.vscode/extensions` | 2.3GB | ChatGPT 1.0GB, Claude Code có 2 phiên bản |
| JetBrains cache | 2.2GB | |
| `/Library/Developer` | 1.9GB | Command Line Tools, cần giữ |
| `~/.npm` | 1.7GB | Cache |
| `~/.m2` | 1.3GB | Nên giữ để build nhanh và build được khi offline |
| `/Library/Application Support/Logi` | 1.2GB | Có một file cache 852MB |
| `/Library/Caches` | 1.1GB | Chủ yếu là bộ cài Word 16.78 chưa được áp dụng |
| `/Library/Updates` | 1.1GB | Bản cập nhật Apple đã tải sẵn |
| `~/.local/share/jira-codex-agent` | 1.0GB | 3 worktree, **chứa việc chưa commit** |

### Các mục bạn hỏi nhưng không đáng ngại

| Mục | Kết quả |
|---|---|
| `~/.gradle` | Không tồn tại |
| Xcode DerivedData | Không có. Máy không cài Xcode, chỉ có Command Line Tools |
| `node_modules` | Lớn nhất: mock-project 336MB, TeachMate 249MB, mỗi worktree khoảng 230MB |
| Dữ liệu cá nhân | Documents 362MB, Desktop 307MB, Downloads 106MB, Pictures 490MB. Không có file lớn đáng kể |

> **Lưu ý về Chrome clone:** APFS cho phép các bản clone dùng chung block với app gốc, nên `du` có thể đếm cao hơn thực tế. Tôi không xác định được dung lượng thật sẽ lấy lại, vì vậy con số 14GB không được cộng vào tổng ước tính.

---

## 2. Chạy nền và khởi động cùng máy

### Login Items

Lunar, Zalo, Raycast, BetterDisplay, Mos.

### LaunchAgents và LaunchDaemons

| Mục | Trạng thái | Nhận xét |
|---|---|---|
| `com.teachinghelper.app` | Đang chạy, ~23MB, KeepAlive | Giữ nguyên theo lựa chọn của bạn |
| `com.jira-codex-agent` | Đã đăng ký, không chạy lúc kiểm tra | Dự án cá nhân, tạo các worktree TeachMate |
| `com.microsoft.OneDrive*` (3 mục) | Lần chạy cuối thoát mã 78 | **Mồ côi**, không có OneDrive.app trên máy |
| `com.now.gg.BlueStacks.cleanup` | Daemon đã bật | Sẽ mất khi gỡ BlueStacks |
| `com.microsoft.update.agent`, `autoupdate.helper`, `licensingV2.helper` | Đã bật | Cần cho Word và Outlook |
| `com.logi.optionsplus`, `LogiRightSight`, updater | Đã bật | Logi agent dùng ~134MB. RightSight chỉ cần cho webcam Logitech |
| `com.microsoft.teams2.agent` | Đang chạy | Cần nếu dùng Teams |
| GoogleUpdater, keystone | Đã bật | Bình thường |
| OrbStack privhelper | Đã bật | Bình thường. App không tự mở khi đăng nhập |
| `com.tuyenmai.OpenKeyHelper` | Đang chạy | Bộ gõ tiếng Việt, cần giữ |

Lunar và BetterDisplay chồng chéo chức năng, chỉ nên giữ một nếu bạn không cần tính năng riêng của từng app.

### Tiến trình ăn RAM và CPU

| Tiến trình | RAM | Ghi chú |
|---|---|---|
| Chrome (nhiều helper) | Trên 2GB | Một helper dùng tới 1GB. Đang dùng nhiều nhất |
| Code Helper (Plugin) | ~750MB | Extension host của VS Code |
| OrbStack Helper | ~520MB | Lúc đó chỉ chạy 1 container `dev-postgres` |
| WindowServer | ~345MB | Bình thường |
| Claude Code | ~230-270MB | Chính phiên audit này |
| iTerm2 | ~140MB | CPU ~14% khi lệnh đang xuất nhiều output |

Số liệu là ảnh chụp tại một thời điểm, lúc IntelliJ không chạy. Khi mở thêm IntelliJ, áp lực RAM sẽ cao hơn nhiều.

---

## 3. Native arm64 và Rosetta

**Kết quả:** 0 tiến trình đang chạy qua Rosetta. Phép kiểm tra đã được xác nhận hoạt động bằng cách chạy thử một tiến trình x86_64.

| Thành phần | Kiến trúc |
|---|---|
| IntelliJ, DBeaver, VS Code, OrbStack, Raycast | arm64 |
| Chrome, iTerm, Teams, Outlook, Word, Zalo, Obsidian, Zotero | Universal, chạy arm64 |
| Temurin 21, Corretto 17 | arm64 |
| Node 26.5, git, Python, Docker client | arm64 |
| Homebrew | `/opt/homebrew`, đúng chuẩn Apple Silicon |
| **Temurin 8** | **x86_64, chạy qua Rosetta khi dùng** |
| **Sideloadly** | **x86_64** |

Các image `hanbay-hotel-*:amd64` nếu chạy sẽ phải giả lập, nhưng hiện không có container nào dùng chúng.

---

## 4. Toolchain

| Công cụ | Phiên bản | Nhận xét |
|---|---|---|
| Homebrew | 7.0.11 | 56 gói có bản mới hơn |
| Java mặc định | Temurin 21.0.11 | Khớp với TeachMate (Java 21) |
| JDK khác | Corretto 17.0.20, Temurin 8u502 | Java 17 phục vụ mock-project, Java 8 phục vụ jsp/hr và NetCafe |
| Homebrew openjdk | 27 | Phụ thuộc của Maven và Tomcat, không nằm trên PATH. Maven vẫn chạy bằng Java 21 |
| Maven | 3.9.16 | Tốt |
| Gradle | Chưa cài | Không thấy dự án Gradle nào trong Workspace và Documents |
| Node / npm / pnpm | 26.5.0 / 11.17.0 / 10.17.1 | Không có trình quản lý phiên bản Node |
| yarn | Chưa cài | |
| Docker | 29.8.2 qua OrbStack 2.2.5 | VM báo 3.9GB RAM, 8 CPU |
| Tomcat | 10.1.61 | Không chạy thành service |

### Docker

| Loại | Tổng | Có thể lấy lại |
|---|---|---|
| Image | 30 (12.5GB) | 2.4GB |
| Container | 17, 1 đang chạy | 14MB |
| Volume | 37 (718MB) | 267MB, **không nên xóa** |
| Build cache | 119 mục | 4.4GB |

17 volume không gắn với container nào, trong đó có `infrastructure_teachmate-postgres-data`, `-minio-data`, `-redis-data`. Đây có thể là dữ liệu đồ án.

### Git

Đã có `user.name`, `user.email`, `init.defaultBranch=main`, `credential.helper=osxkeychain`, `pull.rebase=false`.

Còn thiếu: global gitignore (dễ commit nhầm `.DS_Store`), `fetch.prune` (TeachMate có 32/41 nhánh local mà nhánh remote đã bị xóa), `push.autoSetupRemote`.

### Shell

- Zsh 5.9 với Oh My Zsh và Powerlevel10k, khởi động 0.16-0.18 giây. **Nhanh, không cần tối ưu.**
- `brew shellenv` chạy cả trong `.zprofile` và `.zshrc`.
- `atuin` đã cài nhưng không được khởi tạo trong shell, nên hiện không có tác dụng.
- `.zshrc.backup` (8KB) còn sót lại.

### PATH

Có 21 mục, trong đó có các mục trùng:

| Đường dẫn | Số lần |
|---|---|
| `/opt/homebrew/bin` | 3 |
| `/opt/homebrew/sbin` | 3 |
| `temurin-21.jdk/.../bin` | 2 |
| `~/.orbstack/bin` | 2 |

Một phần trùng lặp có thể do PATH được kế thừa từ phiên terminal cha, nên terminal mới có thể ít trùng hơn. Không ảnh hưởng hiệu năng đáng kể.

4 mục trỏ tới thư mục không tồn tại: 3 mục `cryptexd` do macOS quản lý, và `/pkg/env/global/bin` đến từ `/etc/paths.d/10-pmk-global`. Tôi chưa rõ công cụ nào đã tạo file này.

---

## 5. Cấu hình công cụ

| File | Trạng thái |
|---|---|
| `~/.gradle/gradle.properties` | Không tồn tại |
| `~/.m2/settings.xml` | Không tồn tại, Maven dùng mặc định |
| `~/.npmrc`, `~/.mavenrc` | Không tồn tại |
| `MAVEN_OPTS`, `GRADLE_OPTS`, `JAVA_TOOL_OPTIONS` | Chưa đặt |

### IntelliJ IDEA Ultimate 2026.1.3

- Heap đặt `-Xmx1536m`, thấp hơn mặc định 2048MB. Hợp lý với máy 8GB.
- Plugin: DBNavigator, GitToolBox, Rainbow Brackets, Key Promoter X, MavenHelper, SonarLint, StringManipulation, `ej`, `ml-llm`.
- Không thấy cấu hình riêng cho Power Save hoặc heap của build process.

### VS Code 1.144

- Hơn 60 extension, gồm cả nhóm ít liên quan như Bootstrap 4, jQuery snippets, Live Server.
- `java.server.launchMode` là `Standard`, nên VS Code chạy thêm một Java language server song song nếu IntelliJ cũng đang mở.
- `rsp-ui.enableStartServerOnActivation` bật tự khởi động Community Server Connector, thêm một tiến trình Java nữa.
- Có 2 phiên bản `anthropic.claude-code` (2.1.312 và 2.1.314).

---

## 6. macOS defaults

"Mặc định" nghĩa là key chưa được đặt, macOS dùng giá trị gốc.

| Thiết lập | Hiện tại | Đề xuất cho lập trình |
|---|---|---|
| `KeyRepeat` | Mặc định | `2` |
| `InitialKeyRepeat` | Mặc định | `15` |
| `ApplePressAndHoldEnabled` | Mặc định | `false` |
| Tự sửa chính tả | Mặc định | Tắt |
| Tự viết hoa | **Bật** | Tắt |
| Dấu chấm khi nhấn đúp Space | **Bật** | Tắt |
| Smart quotes | Mặc định | Tắt |
| Smart dashes | Mặc định | Tắt |
| Hiện đuôi file | Đã bật | Giữ |
| Finder hiện file ẩn | Mặc định | Tùy chọn (Cmd+Shift+. để bật tạm) |
| Finder Path bar, Status bar | Mặc định | Bật |
| Finder đường dẫn trên tiêu đề | Mặc định | Bật |
| Finder thư mục xếp trước | Mặc định | Bật |
| Finder chế độ xem | List | Giữ |
| Dock tự ẩn | Đã bật, độ trễ mặc định | Giảm độ trễ nếu muốn |
| Dock show-recents | Mặc định | Tắt |
| Không tạo `.DS_Store` trên ổ mạng/USB | Mặc định | Bật |
| Nơi lưu ảnh chụp màn hình | Mặc định (Desktop) | `~/Pictures/Screenshots` |
| Tap to click | Đã bật | Giữ |

### Bảo mật và hệ thống

| Mục | Trạng thái |
|---|---|
| FileVault | Bật |
| SIP | Bật |
| Gatekeeper | Bật |
| **Firewall** | **Tắt** |
| **Time Machine** | **Chưa cấu hình** |
| AirPlay Receiver | Bật, chiếm cổng **5000** và **7000** |

---

## 7. Dữ liệu nên giữ

| Mục | Lý do |
|---|---|
| `~/Workspace/University/DATN` | Đồ án |
| `~/.local/share/jira-codex-agent/worktrees` | Có 94 file chưa commit |
| Toàn bộ Docker volume | Có thể chứa dữ liệu đồ án |
| `Documents/exam-cheating`, `Desktop/fake` | Theo lựa chọn của bạn |
| JDK 8, Tomcat, Teams, Windows App | Fresher FSoft còn tiếp tục |
| `~/.m2`, `~/.ssh`, Zotero, Obsidian | Dữ liệu làm việc |
| `/Library/Developer/CommandLineTools` | Git và Homebrew cần đến |

---

## 8. Vấn đề theo mức ưu tiên và đề xuất (chưa thực hiện)

### P0: Bảo vệ đồ án, làm trước mọi việc dọn dẹp

**1. Không có bản sao lưu nào, trong khi pin đã báo Service Recommended.**
Nếu máy hỏng, những thứ sau sẽ mất:

| Dữ liệu | Tình trạng |
|---|---|
| Worktree tm-140 | 39 file chưa commit |
| Worktree tm-142 | 34 file chưa commit |
| Worktree tm-171 | 21 file chưa commit |
| `git stash` TeachMate | 3 stash |
| Nhánh local TeachMate | 60 commit chưa có trên remote |
| `DATN/teachmate-research` | Không dùng git |
| Docker volume của TeachMate | Không có bản sao |

Nhánh `develop` đã khớp hoàn toàn với remote. Phần lớn 60 commit kia nằm trên các nhánh có remote đã bị xóa, nên có thể đã được squash-merge, nhưng tôi chưa xác minh.

Đề xuất:
- Commit và push việc đang dở trong 3 worktree.
- Tạo bản sao toàn bộ repo: `git bundle create teachmate.bundle --all`, rồi lưu ra ngoài máy. Stash nên được chuyển thành nhánh trước, vì bundle chỉ giữ stash mới nhất.
- Đưa `teachmate-research` vào git hoặc lưu lên cloud.
- Bật Time Machine với một ổ ngoài.
- Dump database từ volume nếu dữ liệu có giá trị, dùng `pg_dump`.

**2. Pin đã xuống 79% sau 795 chu kỳ.**
Nên đi kiểm tra và thay pin, nhưng chỉ sau khi đã sao lưu, và tốt nhất là tránh giai đoạn sát ngày bảo vệ.

### P1: Ảnh hưởng trực tiếp tới công việc

**3. Postgres mở trên mạng trong khi firewall tắt.**
Cổng `*:5432` nhận kết nối từ mọi địa chỉ và OrbStack đang để `docker.expose_ports_to_lan: true`. Trên Wi-Fi công cộng hoặc ở trường, máy khác có thể kết nối tới database.
- `orbctl config set docker.expose_ports_to_lan false`
- Hoặc map cổng theo dạng `127.0.0.1:5432:5432` trong compose.
- Bật Firewall trong System Settings → Network → Firewall.

**4. Thiếu RAM.**
Theo cách bạn chạy (database, Redis, MinIO, đôi khi Kafka):
- Đặt giới hạn OrbStack khoảng 3GB RAM và 4 CPU trong Settings → System.
- Giới hạn heap Kafka khoảng 512MB khi bật nó.
- Chỉ bật compose profile cần thiết, không chạy OpenSearch, ClickHouse, Grafana trừ khi đang demo.
- Dùng một IDE Java tại một thời điểm. Nếu IntelliJ là chính, đặt `"java.server.launchMode": "LightWeight"` trong VS Code và tắt tự khởi động Community Server Connector.
- Giữ `-Xmx1536m` cho IntelliJ.
- Giảm số profile Chrome đang mở, bật Memory Saver trong Chrome.
- Khi demo đồ án, tắt Chrome profile phụ, Teams, Zalo và các app không cần.

**5. Giữ môi trường ổn định tới ngày bảo vệ.**
- Sau khi sao lưu, cài macOS **26.7.2** để nhận bản vá bảo mật.
- Hoãn **macOS 27** tới sau khi bảo vệ. Bản này tốn 11GB và là nâng cấp lớn, rủi ro với công cụ dev.
- Không chạy `brew upgrade` toàn bộ. Chỉ nâng từng gói khi cần, vì `node`, `openssl@3` và `netpbm` đang có thay đổi phiên bản đáng chú ý.
- Đặt `HOMEBREW_NO_AUTO_UPDATE=1` để tránh tự cập nhật.

**6. Microsoft Word 16.55 đã rất cũ.**
Bộ cài 16.78 đã tải về (1.1GB) nhưng chưa được áp dụng. Nên chạy Microsoft AutoUpdate, nhưng hãy lưu bản sao báo cáo đồ án và tránh làm việc này ngay sát hạn nộp.

**7. Giải phóng ổ đĩa.** Xem bảng ở mục 9.

### P2: Tối ưu môi trường dev

**8. Tắt AirPlay Receiver** để giải phóng cổng 5000 và 7000 (System Settings → General → AirDrop & Handoff).

**9. Thay JDK 8 x86_64 bằng bản arm64** như Corretto 8 hoặc Zulu 8 cho các bài Fresher. Build sẽ nhanh hơn và không cần Rosetta cho Java.

**10. Áp dụng defaults ở mục 6:** phím lặp nhanh và tắt tự sửa văn bản có tác dụng rõ nhất.

**11. Chuẩn hóa shell và git:**
- Bỏ một lần gọi `brew shellenv`, chỉ giữ ở `.zprofile`.
- Khởi tạo `atuin` trong `.zshrc` hoặc gỡ nó.
- Thêm `~/.gitignore_global` chứa `.DS_Store`, `.idea/`, `.vscode/`.
- `git config --global fetch.prune true`
- `git config --global push.autoSetupRemote true`

**12. Dùng trình quản lý phiên bản Node** như `fnm` hoặc `mise`, để `brew upgrade` không đổi phiên bản Node của đồ án.

**13. Đặt giới hạn Maven:** `export MAVEN_OPTS="-Xmx1g"`, để build không tranh RAM với IDE.

**14. Loại `~/Workspace` khỏi Spotlight**, hoặc ít nhất các thư mục `node_modules` và `target`, để giảm việc đánh chỉ mục.

### P3: Dọn dẹp nhỏ

**15. Gỡ các mục mồ côi:** daemon OneDrive, `~/Library/Application Support/GitKrakenCLI` (226MB), `MockExamAI` (41MB), hai thư mục lỗi `~/Library/Application%20Support` và `Application%2520Support`, `~/.zshrc.backup`.

**16. Bỏ bớt extension VS Code** không dùng cho stack hiện tại.

**17. Giữ một trong hai app màn hình:** Lunar hoặc BetterDisplay.

**18. Tìm nguồn của `/pkg/env/global/bin`:** kiểm tra `/etc/paths.d/10-pmk-global`, gỡ nếu không dùng.

**19. Cân nhắc Anki** (hơn 890MB cả dữ liệu, mở lần cuối 17/09) và AnyDesk nếu không còn cần.

---

## 9. Kế hoạch giải phóng dung lượng

Hãy hoàn thành P0 trước khi làm mục này.

### Nhóm A: An toàn, chỉ là cache hoặc bộ cài (khoảng 26GB)

| Mục | Lấy lại | Cách làm |
|---|---|---|
| Homebrew cache | 5.1GB | `brew cleanup -s` |
| Chrome cache | 6.3GB | Chrome → Delete browsing data → chỉ chọn Cached images and files |
| Model AI của Chrome | 4.1GB | Tắt On-device AI hoặc `chrome://flags/#optimization-guide-on-device-model`, nếu không nó sẽ tự tải lại |
| Docker build cache | 4.4GB | `docker builder prune -a` |
| npm cache | 1.7GB | `npm cache clean --force` |
| Bộ cài Word | 1.1GB | Tự mất sau khi cập nhật Word |
| VS Code `CachedExtensionVSIXs` | 0.9GB | Xóa khi đã đóng VS Code |
| Logi cache | 0.85GB | Qua Logi Options+ hoặc gỡ app nếu không dùng thiết bị Logitech |
| GoogleUpdater `crx_cache` | 0.77GB | Xóa khi đã đóng Chrome |
| Bộ cài Zalo trùng | 0.65GB | Hai file zip cập nhật 327MB |
| Extension Claude Code cũ | 0.27GB | Xóa bản 2.1.312 |

Chrome clone (tối đa 14GB, thực tế có thể ít hơn): thoát hẳn Chrome bằng Cmd+Q rồi khởi động lại máy. Nếu vẫn còn, xóa khi Chrome đã tắt:

```sh
rm -rf "$(getconf DARWIN_USER_TEMP_DIR)../X/com.google.Chrome.code_sign_clone"
```

### Nhóm B: Cần quyết định, có thể phải cài hoặc tải lại (khoảng 29GB)

| Mục | Lấy lại | Lưu ý |
|---|---|---|
| **BlueStacks** | **~20GB** | Gỡ bằng trình gỡ cài đặt của app. Kiểm tra game đã liên kết tài khoản, vì dữ liệu nằm trong đĩa ảo |
| Dữ liệu `redhat.java` cũ trong VS Code | Tối đa ~3GB (ước tính) | Không xóa cả `workspaceStorage`, vì có lịch sử chat. Sẽ phải index lại |
| Docker image không dùng | 2.4GB | `docker image prune -a`, phải tải lại khi cần |
| 3 worktree jira-codex | 1.0GB | **Chỉ sau khi đã push hết** |
| `~/.dotnet`, `~/.nuget` | 0.65GB | Rider đã gỡ. Chỉ xóa nếu không còn dùng .NET |
| Artifact FSA | 0.55GB | `mock-project` `target` và `node_modules`, `fee-01/node_modules` |
| Playwright | 0.57GB | Chỉ xóa nếu đồ án không dùng E2E |
| Sideloadly, cache và file `.ipa` | 0.6GB | Không liên quan công việc. Xóa cả `Downloads/(iPhone) ModDP250.ipa` |
| Mục mồ côi (P3-15) | 0.27GB | |

Mock-project của FSA có nhiều commit chỉ nằm ở local (nhiều nhánh). Hãy push trước khi lưu trữ hoặc xóa repo.

### Không nên làm

- **`docker system prune --volumes`** hoặc `docker volume prune`: có thể xóa dữ liệu TeachMate.
- **Xóa `data.img.raw` của OrbStack:** mất toàn bộ image, container và volume.
- **Xóa `~/.m2`:** tải lại mất nhiều thời gian và cần mạng.
- **Xóa cả thư mục `Chrome/Default` hoặc `Profile *`:** mất dữ liệu đăng nhập và extension.
- **Xóa cả `ZaloData`:** mất lịch sử tin nhắn. Dùng công cụ quản lý dung lượng trong Zalo.
- **Dùng app "dọn máy" tự động:** dễ xóa nhầm dữ liệu dev.

---

## 10. Phạm vi và hạn chế của audit

**Những thay đổi đã xảy ra ngoài ý muốn:** lệnh `brew outdated` đã kích hoạt auto-update của Homebrew, cập nhật metadata (`/opt/homebrew/.git/FETCH_HEAD` và `~/Library/Caches/Homebrew/api`). Điều này trái với yêu cầu chỉ đọc. Không có gói nào được cài hoặc nâng cấp, vì `Cellar` không có thay đổi. Các lệnh `brew` sau đó đều chạy với auto-update đã tắt.

**Các tác động nhỏ khác:**
- Khởi động thử zsh để đo thời gian, có thể chạm tới file cache của shell.
- Chạy `arch -x86_64 /bin/sleep` trong 3 giây để kiểm chứng phép dò Rosetta.
- `softwareupdate -l` truy vấn máy chủ Apple.
- `brew cleanup` chỉ chạy ở chế độ dry-run.
- File duy nhất được tạo là `audit.md`, chưa commit.

**Giới hạn:**
- Không có Full Disk Access và không dùng sudo, nên **dung lượng Thùng rác chưa đo được**.
- Dung lượng lấy từ `du` có thể đếm cao với file clone APFS.
- RAM và CPU là ảnh chụp tại thời điểm kiểm tra, không phải số liệu trung bình.
- `node_modules` và `target` chỉ được liệt kê từ 80 thư mục đầu tiên tìm thấy.
- Danh sách file trên 100MB chỉ lấy 70 file đầu tiên tìm thấy, nên có thể sót file. Các thư mục lớn vẫn được đo bằng `du`, và tổng đo được khớp với mức Data đã dùng.

**Bảo mật:** các giá trị token và password được che khi đọc cấu hình. Không đọc `.zsh_history` hay nội dung private key. Kết quả khớp duy nhất trong `.zshrc` chỉ là một dòng comment của Powerlevel10k.
