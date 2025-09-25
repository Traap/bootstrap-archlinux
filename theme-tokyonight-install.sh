#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Tokyo Night (Night variant) — Arch Linux: INSTALL + APPLY for Thunar/XFCE/GTK
# Installs prerequisites, GTK theme, icon theme, and cursor; applies via xfconf;
# writes GTK3/GTK4 settings; restarts xfsettingsd. Includes --revert.
# ---------------------------------------------------------------------------

# ===== User-tunable (per request, set to "Night" variants) ==================
ICON_MODE="tokyonight-se"          # options: tokyonight-se | papirus (kept for future)
CURSOR_VARIANT="tokyo-night"       # xcursor-simp1e-tokyo-night
GTK_THEME_NAME="Tokyonight-Dark"   # provided by tokyonight-gtk-theme-git
ICON_THEME_NAME="TokyoNight-SE"    # installed under ~/.local/share/icons
AUR_HELPER="${AUR_HELPER:-yay}"    # or set AUR_HELPER=paru before running

BACKUP_FILE="${HOME}/.config/tokyonight-theme.backup"

# ===== Helpers ===============================================================
need() { command -v "$1" &>/dev/null || { echo "Missing: $1"; exit 1; }; }
ensure_dir() { mkdir -p "$1"; }
has() { command -v "$1" &>/dev/null; }

get_current() {
  local key="$1" default="${2:-}"
  if has xfconf-query; then
    xfconf-query -c xsettings -p "$key" 2>/dev/null || echo "$default"
  else
    echo "$default"
  fi
}

backup_settings() {
  local cur_theme cur_icons cur_cursor
  cur_theme="$(get_current /Net/ThemeName "")"
  cur_icons="$(get_current /Net/IconThemeName "")"
  cur_cursor="$(get_current /Gtk/CursorThemeName "")"
  ensure_dir "$(dirname "$BACKUP_FILE")"
  {
    echo "THEME=${cur_theme}"
    echo "ICONS=${cur_icons}"
    echo "CURSOR=${cur_cursor}"
  } > "$BACKUP_FILE"
  echo "Backed up current settings to $BACKUP_FILE"
}

restore_settings() {
  if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "No backup at $BACKUP_FILE"; exit 1
  fi
  # shellcheck disable=SC1090
  source "$BACKUP_FILE"
  [[ -n "${THEME:-}"  ]] && set_xfconf "/Net/ThemeName" "$THEME"
  [[ -n "${ICONS:-}"  ]] && set_xfconf "/Net/IconThemeName" "$ICONS"
  [[ -n "${CURSOR:-}" ]] && set_xfconf "/Gtk/CursorThemeName" "$CURSOR"
  write_gtk_ini "${THEME:-$GTK_THEME_NAME}" "${ICONS:-$ICON_THEME_NAME}" "${CURSOR:-$CURSOR_VARIANT}"
  cursor_fallback "${CURSOR:-$CURSOR_VARIANT}"
  restart_xfsettingsd
  echo "Reverted to: theme='${THEME:-}' icons='${ICONS:-}' cursor='${CURSOR:-}'"
}

set_xfconf() {
  local key="$1" val="$2"
  if has xfconf-query; then
    xfconf-query -c xsettings -p "$key" -s "$val" || true
  fi
}

write_gtk_ini() {
  local theme="$1" icons="$2" cursor="$3"
  local gtk3="$HOME/.config/gtk-3.0/settings.ini"
  local gtk4="$HOME/.config/gtk-4.0/settings.ini"
  ensure_dir "$(dirname "$gtk3")"
  ensure_dir "$(dirname "$gtk4")"
  for ini in "$gtk3" "$gtk4"; do
    cat >"$ini" <<EOF
[Settings]
gtk-theme-name=$theme
gtk-icon-theme-name=$icons
gtk-cursor-theme-name=$cursor
EOF
  done
}

cursor_fallback() {
  local cursor="$1"
  ensure_dir "$HOME/.icons/default"
  cat > "$HOME/.icons/default/index.theme" <<EOF
[Icon Theme]
Name=Default
Inherits=$cursor
EOF
}

restart_xfsettingsd() {
  # If xfsettingsd exists, restart it to enforce changes
  if pkill -x xfsettingsd 2>/dev/null; then
    sleep 0.5
  fi
  if has xfsettingsd; then
    nohup xfsettingsd >/dev/null 2>&1 &
  fi
}

show_effective() {
  echo "Current (xfconf if available):"
  echo "  Theme : $(get_current /Net/ThemeName "(unknown)")"
  echo "  Icons : $(get_current /Net/IconThemeName "(unknown)")"
  echo "  Cursor: $(get_current /Gtk/CursorThemeName "(unknown)")"
  echo
  echo "GTK3 ini:"
  grep -E '^(gtk-(theme|icon|cursor).*)' "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null || true
  echo
  echo "GTK4 ini:"
  grep -E '^(gtk-(theme|icon|cursor).*)' "$HOME/.config/gtk-4.0/settings.ini" 2>/dev/null || true
}

download_tokyonight_icons() {
  # Download latest release tarball of TokyoNight-SE icons into ~/.local/share/icons
  local dest="$HOME/.local/share/icons"
  ensure_dir "$dest"
  local tmpdir; tmpdir="$(mktemp -d)"
  echo "Downloading TokyoNight-SE icon theme (latest release)…"
  local url
  if command -v jq >/dev/null; then
    url="$(curl -s https://api.github.com/repos/ljmill/tokyo-night-icons/releases/latest \
      | jq -r '.assets[] | select(.name|endswith(".tar.bz2")) | .browser_download_url' | head -n1)"
  else
    url="$(curl -s https://api.github.com/repos/ljmill/tokyo-night-icons/releases/latest \
      | grep -Eo 'https://[^"]+\.tar\.bz2' | head -n1)"
  fi
  if [[ -z "${url:-}" ]]; then
    echo "Could not determine TokyoNight-SE icon release URL. Install manually and re-run."; exit 1
  fi
  curl -L "$url" -o "$tmpdir/tokyonight-icons.tar.bz2"
  tar -xjf "$tmpdir/tokyonight-icons.tar.bz2" -C "$dest"
  rm -rf "$tmpdir"
}

# ===== Install prerequisites and themes (Arch only) ===========================
install_all() {
  need pacman
  # core tools + GTK engines + XFCE settings bits
  sudo pacman -S --needed --noconfirm curl tar bzip2 coreutils \
      gtk-engine-murrine gnome-themes-extra xfconf xfce4-settings thunar

  # AUR helper check
  if ! command -v "$AUR_HELPER" >/dev/null; then
    echo "AUR helper '$AUR_HELPER' not found. Install yay or set AUR_HELPER=paru and re-run." >&2
    exit 1
  fi

  # GTK theme + cursor from AUR
  "$AUR_HELPER" -S --needed --noconfirm tokyonight-gtk-theme-git "xcursor-simp1e-${CURSOR_VARIANT}"

  # Icons (TokyoNight-SE) via GitHub release
  if [[ "$ICON_MODE" == "tokyonight-se" ]]; then
    download_tokyonight_icons
  else
    # Optional Papirus path (kept for completeness)
    sudo pacman -S --needed --noconfirm papirus-icon-theme
    "$AUR_HELPER" -S --needed --noconfirm papirus-folders-git
    papirus-folders -C bluegrey --theme Papirus-Dark || true
  fi
}

# ===== Main modes ==============================================================
usage() {
  cat <<EOF
Usage: $(basename "$0") [--install] [--apply] [--revert]

  --install  Install prerequisites + GTK theme + icons + cursor
  --apply    Apply configured themes (GTK=${GTK_THEME_NAME}, Icons=${ICON_THEME_NAME}, Cursor=${CURSOR_VARIANT})
  --revert   Restore previous theme/icon/cursor from backup

Typical first run on a new machine:
  $(basename "$0") --install --apply
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

DO_INSTALL=0
DO_APPLY=0
DO_REVERT=0
for arg in "$@"; do
  case "$arg" in
    --install) DO_INSTALL=1 ;;
    --apply)   DO_APPLY=1   ;;
    --revert)  DO_REVERT=1  ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $arg"; usage; exit 1 ;;
  esac
done

if [[ $DO_REVERT -eq 1 ]]; then
  restore_settings
  thunar -q || true
  exit 0
fi

if [[ $DO_INSTALL -eq 1 ]]; then
  install_all
fi

if [[ $DO_APPLY -eq 1 ]]; then
  # Sanity presence checks (non-fatal warnings)
  found_theme=""; found_icons=""
  for d in "$HOME/.themes" "/usr/share/themes"; do
    [[ -d "$d/$GTK_THEME_NAME" ]] && found_theme="$d/$GTK_THEME_NAME"
  done
  for d in "$HOME/.local/share/icons" "$HOME/.icons" "/usr/share/icons"; do
    [[ -d "$d/$ICON_THEME_NAME" ]] && found_icons="$d/$ICON_THEME_NAME"
  done
  [[ -z "$found_theme" ]] && echo "Warning: GTK theme '$GTK_THEME_NAME' not found under ~/.themes or /usr/share/themes"
  [[ -z "$found_icons" ]] && echo "Warning: Icon theme '$ICON_THEME_NAME' not found under ~/.local/share/icons, ~/.icons, or /usr/share/icons"

  backup_settings

  set_xfconf "/Net/ThemeName"        "$GTK_THEME_NAME"
  set_xfconf "/Net/IconThemeName"    "$ICON_THEME_NAME"
  set_xfconf "/Gtk/CursorThemeName"  "$CURSOR_VARIANT"

  write_gtk_ini "$GTK_THEME_NAME" "$ICON_THEME_NAME" "$CURSOR_VARIANT"
  cursor_fallback "$CURSOR_VARIANT"
  restart_xfsettingsd

  thunar -q || true

  show_effective

  echo
  echo "✅ Applied Tokyo Night (Night):"
  echo "  GTK   : $GTK_THEME_NAME"
  echo "  Icons : $ICON_THEME_NAME"
  echo "  Cursor: $CURSOR_VARIANT"
  echo
  echo "Revert anytime:  $(basename "$0") --revert"
fi
