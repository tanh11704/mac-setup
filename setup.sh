#!/usr/bin/env bash
# Cài lại môi trường dev trên máy Apple Silicon mới. Chạy: bash setup.sh
# Có thể chạy lại nhiều lần; bước đã xong sẽ được bỏ qua.
# Script dừng nếu chạy dưới Rosetta và kiểm tra lại arm64 ở cuối.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"
FAILED=0

log()  { printf '\n==> %s\n' "$1"; }
warn() { printf 'CẢNH BÁO: %s\n' "$1" >&2; FAILED=1; }
die()  { printf 'LỖI: %s\n' "$1" >&2; exit 1; }

# Thêm một dòng vào file nếu chưa có dòng trùng khớp.
ensure_line() {
  touch "$1"
  grep -qxF "$2" "$1" || printf '%s\n' "$2" >> "$1"
}

# ----- 1. Kiểm tra máy -----
log "Kiểm tra máy"
[[ "$(uname -s)" == "Darwin" ]] || die "Script chỉ dành cho macOS."
[[ "$(uname -m)" == "arm64" ]] || die "Terminal đang chạy dưới Rosetta hoặc máy không phải Apple Silicon."
[[ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" == "0" ]] || die "Terminal đang chạy dưới Rosetta."
[[ -f "$BREWFILE" ]] || die "Không tìm thấy $BREWFILE."

# ----- 2. Homebrew -----
log "Homebrew"
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# ----- 3. Ứng dụng và công cụ từ Brewfile -----
log "Cài từ Brewfile (không nâng cấp gói đã có)"
if ! brew bundle install --file="$BREWFILE" --no-upgrade; then
  warn "Một số mục trong Brewfile chưa cài được. App Store cần đăng nhập trước; sửa xong hãy chạy lại."
fi

# ----- 4. Shell -----
log "Oh My Zsh và Powerlevel10k"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
[[ -d "$P10K_DIR" ]] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"

log "Tích hợp Homebrew và mise vào zsh"
touch "$HOME/.zprofile" "$HOME/.zshrc"
grep -q 'brew shellenv' "$HOME/.zprofile" || ensure_line "$HOME/.zprofile" 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"'
ensure_line "$HOME/.zprofile" 'eval "$(mise activate zsh --shims)"'   # Cho app GUI và shell không tương tác
ensure_line "$HOME/.zshrc" 'eval "$(mise activate zsh)"'              # Cho terminal tương tác

# Hai dòng JAVA_HOME cũ sẽ ghi đè Java của mise, nên được comment lại kèm bản sao lưu.
if grep -q '^export JAVA_HOME=$(/usr/libexec/java_home' "$HOME/.zshrc"; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.before-mise"
  sed -i '' \
    -e '/^export JAVA_HOME=$(\/usr\/libexec\/java_home/s/^/# /' \
    -e '/^export PATH=$JAVA_HOME\/bin:$PATH$/s/^/# /' \
    "$HOME/.zshrc"
fi

# ----- 5. Runtime qua mise -----
log "Cài JDK, Node, pnpm và Maven"
# Mặc định toàn máy: Java 21, Node 22, pnpm 10.17.1 khớp với CI và package.json của TeachMate.
mise use -g java@temurin-21 node@22 pnpm@10.17.1 maven@3.9
# JDK phụ cho bài Fresher (Java 8) và mock-project (Java 17); bật theo từng dự án bằng mise.toml.
mise install java@corretto-17 java@corretto-8

# ----- 6. Kiểm tra arm64 -----
log "Kiểm tra kiến trúc"
check_arch() {
  local spec="$1" bin="$2" archs
  archs="$(mise exec "$spec" -- bash -c "lipo -archs \"\$(command -v $bin)\"" 2>/dev/null || echo 'không đọc được')"
  if [[ " $archs " == *" arm64 "* ]]; then
    printf 'OK   %-22s %s\n' "$spec" "$archs"
  else
    warn "$spec không phải arm64: $archs"
  fi
}
check_arch java@temurin-21 java
check_arch java@corretto-17 java
check_arch java@corretto-8 java
check_arch node@22 node
brew bundle check --file="$BREWFILE" || warn "Brewfile chưa được cài đủ."

# ----- 7. Việc cần làm thủ công -----
cat <<'EOF'

Việc cần làm thủ công:
  1. Khôi phục ~/.zshrc, ~/.p10k.zsh, ~/.gitconfig và ~/.ssh từ bản sao lưu, rồi chạy lại script này.
  2. Mở OrbStack một lần, đặt RAM 3GB và CPU 4, rồi chạy:
     orbctl config set docker.expose_ports_to_lan false
  3. Cài Word theo giấy phép của bạn.
  4. Trỏ JDK trong IntelliJ tới: ~/.local/share/mise/installs/java/
  5. Dựng lại venv của TeachingHelper và jira-codex-agent, rồi nạp lại LaunchAgent.
  6. Chạy: bash macos-defaults.sh
EOF

if [[ "$FAILED" -ne 0 ]]; then
  printf '\nHoàn tất nhưng còn lỗi, xem các cảnh báo ở trên.\n' >&2
  exit 1
fi
printf '\nHoàn tất. Mở terminal mới để áp dụng.\n'
