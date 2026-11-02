# Brewfile cho MacBook Pro M1: chỉ gồm bản arm64 hoặc Universal (có arm64).
# Cài bằng setup.sh hoặc: brew bundle install --file=Brewfile --no-upgrade
# Java, Node, pnpm và Maven do mise quản lý, nên cố ý không có trong file này.

# ----- Quản lý phiên bản -----
brew "mise"                    # Quản lý Java, Node, pnpm, Maven theo từng dự án

# ----- Dòng lệnh -----
brew "git"
brew "gh"
brew "lazygit"
brew "bat"                     # Thay cat
brew "eza"                     # Thay ls, kiêm luôn tree qua alias
brew "fd"
brew "ripgrep"
brew "fzf"
brew "zoxide"
brew "jq"

# ----- Shell -----
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# ----- Ngôn ngữ và server không thuộc mise -----
brew "python@3.14"             # venv của TeachingHelper và jira-codex-agent trỏ vào đây
brew "tomcat@10"               # Bài Fresher FSoft; kéo theo openjdk của Homebrew, không nằm trên PATH
brew "graphviz"                # Cần cho PlantUML khi vẽ sơ đồ đồ án

# ----- App Store -----
brew "mas"                     # Cần đăng nhập App Store trước
mas "Microsoft Outlook", id: 985367838   # Dùng App Store để không giữ bộ cài 1.3GB trong Caskroom
mas "Windows App", id: 1295203466
mas "Sleep Control Center", id: 946798523

# ----- Docker -----
cask "orbstack"                # Docker nhẹ cho Apple Silicon, đã kèm docker, compose, kubectl

# ----- IDE và công cụ dev -----
cask "intellij-idea"
cask "visual-studio-code"
cask "dbeaver-community"
cask "iterm2"
cask "codex"
cask "claude-code"             # Thay bản npm global, không còn phụ thuộc Node

# ----- Học tập và tài liệu -----
cask "obsidian"
cask "zotero"
cask "anki"

# ----- Liên lạc và công việc -----
cask "google-chrome"
cask "zalo"
cask "microsoft-teams"
cask "anydesk"

# ----- Tiện ích hệ thống -----
cask "raycast"
cask "openkey"                 # Bộ gõ tiếng Việt
cask "betterdisplay"           # Đã bao gồm chỉnh độ sáng, nên bỏ Lunar
cask "mos"
cask "hiddenbar"
cask "stats"
cask "logi-options+"

# ----- Font -----
cask "font-jetbrains-mono"
cask "font-jetbrains-mono-nerd-font"   # Font editor trong VS Code
cask "font-meslo-for-powerlevel10k"    # Cung cấp MesloLGS NF cho terminal
