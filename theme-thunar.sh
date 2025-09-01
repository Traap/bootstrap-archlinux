#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Tokyo Night "Night" variant — apply & persist on Arch (XFCE/GTK apps)
# - Applies via xfconf (if available)
# - Writes GTK3/GTK4 settings.ini
# - Restarts xfsettingsd
# - Supports --revert
# ---------------------------------------------------------------------------

# Desired theme names (make sure these match what you have installed)
GTK_THEME="Tokyonight-Dark"
ICON_THEME="TokyoNight-SE"
CURSOR_THEME="tokyo-night"     # package: xcursor-simp1e-tokyo-night

BACKUP_FILE="${HOME}/.config/tokyonight-theme.backup"

need() { command -v "$1" &>/dev/null || { echo "Missing: $1"; exit 1; }; }
ensure_dir() { mkdir -p "$1"; }
has() { command -v "$1" &>/dev/null; }

# --- Detect current values (for backup/revert) --------------------------------
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
  write_gtk_ini "${THEME:-$GTK_THEME}" "${ICONS:-$ICON_THEME}" "${CURSOR:-$CURSOR_THEME}"
  cursor_fallback "${CURSOR:-$CURSOR_THEME}"
  restart_xfsettingsd
  echo "Reverted to: theme='${THEME:-}' icons='${ICONS:-}' cursor='${CURSOR:-}'"
}

# --- Apply helpers -------------------------------------------------------------
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

# --- Mode selection ------------------------------------------------------------
if [[ "${1:-}" == "--revert" ]]; then
  restore_settings
  thunar -q || true
  exit 0
fi

# --- Sanity: verify themes exist somewhere the system can see ------------------
found_theme=""; found_icons=""; found_cursor="$CURSOR_THEME"
for d in "$HOME/.themes" "/usr/share/themes"; do
  [[ -d "$d/$GTK_THEME" ]] && found_theme="$d/$GTK_THEME"
done
for d in "$HOME/.local/share/icons" "$HOME/.icons" "/usr/share/icons"; do
  [[ -d "$d/$ICON_THEME" ]] && found_icons="$d/$ICON_THEME"
done

if [[ -z "$found_theme" ]]; then
  echo "Warning: GTK theme '$GTK_THEME' not found under ~/.themes or /usr/share/themes"
fi
if [[ -z "$found_icons" ]]; then
  echo "Warning: Icon theme '$ICON_THEME' not found under ~/.local/share/icons, ~/.icons, or /usr/share/icons"
fi

# --- Apply ---------------------------------------------------------------------
backup_settings

set_xfconf "/Net/ThemeName"        "$GTK_THEME"
set_xfconf "/Net/IconThemeName"    "$ICON_THEME"
set_xfconf "/Gtk/CursorThemeName"  "$CURSOR_THEME"

write_gtk_ini "$GTK_THEME" "$ICON_THEME" "$CURSOR_THEME"
cursor_fallback "$CURSOR_THEME"
restart_xfsettingsd

# Nudge Thunar to reload icons/theme
thunar -q || true

show_effective

echo
echo "✅ Applied Tokyo Night (Night):"
echo "  GTK   : $GTK_THEME"
echo "  Icons : $ICON_THEME"
echo "  Cursor: $CURSOR_THEME"
echo
echo "Tip (bspwm/Hyprland): autostart 'xfsettingsd' to keep settings active in non-XFCE sessions."
echo "Revert anytime:  $(basename "$0") --revert"

