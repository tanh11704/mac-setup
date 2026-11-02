#!/usr/bin/env bash
# Thiết lập macOS cho developer, dựa trên mục 6 của audit.md.
# Chạy: bash macos-defaults.sh
# Mỗi thiết lập có dòng "Hoàn tác" đưa về đúng trạng thái ghi nhận trong audit ngày 2026-11-01.
# "defaults delete" nghĩa là xóa key để macOS dùng lại giá trị gốc.

set -euo pipefail

# ----- Bàn phím -----

# Lặp phím nhanh nhất mà thanh trượt System Settings cho phép (2 = khoảng 30ms mỗi ký tự).
# Hoàn tác: defaults delete NSGlobalDomain KeyRepeat
defaults write NSGlobalDomain KeyRepeat -int 2

# Giảm thời gian chờ trước khi bắt đầu lặp phím (15 = khoảng 225ms).
# Hoàn tác: defaults delete NSGlobalDomain InitialKeyRepeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Giữ phím sẽ lặp ký tự thay vì hiện bảng dấu; OpenKey không bị ảnh hưởng.
# Hoàn tác: defaults delete NSGlobalDomain ApplePressAndHoldEnabled
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ----- Tự sửa văn bản -----

# Tắt tự sửa chính tả, tránh đổi tên biến và lệnh khi gõ.
# Hoàn tác: defaults delete NSGlobalDomain NSAutomaticSpellingCorrectionEnabled
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Tắt tự viết hoa chữ đầu câu.
# Hoàn tác: defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Tắt chèn dấu chấm khi nhấn đúp phím Space.
# Hoàn tác: defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Tắt smart quotes, tránh dấu nháy cong làm hỏng code và lệnh khi copy.
# Hoàn tác: defaults delete NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Tắt smart dashes, tránh "--" bị đổi thành dấu gạch dài.
# Hoàn tác: defaults delete NSGlobalDomain NSAutomaticDashSubstitutionEnabled
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# ----- Finder -----

# Hiện thanh đường dẫn ở cuối cửa sổ Finder.
# Hoàn tác: defaults delete com.apple.finder ShowPathbar
defaults write com.apple.finder ShowPathbar -bool true

# Hiện thanh trạng thái với số mục và dung lượng còn trống.
# Hoàn tác: defaults delete com.apple.finder ShowStatusBar
defaults write com.apple.finder ShowStatusBar -bool true

# Hiện đường dẫn đầy đủ trên tiêu đề cửa sổ Finder.
# Hoàn tác: defaults delete com.apple.finder _FXShowPosixPathInTitle
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Xếp thư mục lên trước file khi sắp xếp theo tên.
# Hoàn tác: defaults delete com.apple.finder _FXSortFoldersFirst
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Không tạo .DS_Store trên ổ mạng.
# Hoàn tác: defaults delete com.apple.desktopservices DSDontWriteNetworkStores
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Không tạo .DS_Store trên USB và ổ ngoài.
# Hoàn tác: defaults delete com.apple.desktopservices DSDontWriteUSBStores
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ----- Dock -----

# Không hiện app dùng gần đây trên Dock.
# Hoàn tác: defaults delete com.apple.dock show-recents
defaults write com.apple.dock show-recents -bool false

# ----- Ảnh chụp màn hình -----

# Tạo thư mục lưu ảnh chụp để Desktop gọn hơn.
# Hoàn tác: rmdir "$HOME/Pictures/Screenshots" (chỉ thành công khi thư mục trống)
mkdir -p "$HOME/Pictures/Screenshots"

# Lưu ảnh chụp màn hình vào thư mục vừa tạo.
# Hoàn tác: defaults delete com.apple.screencapture location
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# ----- Áp dụng thay đổi -----

# Khởi động lại Finder, Dock và thanh menu để nhận cấu hình mới; cửa sổ Finder sẽ đóng rồi mở lại.
# Hoàn tác: không cần, các tiến trình này tự chạy lại.
killall Finder Dock SystemUIServer

echo "Xong. Đăng xuất rồi đăng nhập lại để thiết lập bàn phím có hiệu lực đầy đủ."
