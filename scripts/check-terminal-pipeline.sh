#!/usr/bin/env bash
set -euo pipefail

fail=0

ok() {
  printf '[OK] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1"
}

err() {
  printf '[FAIL] %s\n' "$1"
  fail=1
}

has_match() {
  local pattern="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern"
  else
    grep -Eq "$pattern"
  fi
}

check_tmux_version() {
  if ! command -v tmux >/dev/null 2>&1; then
    err "tmux is not installed"
    return
  fi

  local version_raw version_num major minor
  version_raw="$(tmux -V 2>/dev/null || true)"
  version_num="$(printf '%s\n' "$version_raw" | awk '{print $2}')"
  major="${version_num%%.*}"
  minor="${version_num#*.}"
  minor="${minor%%[^0-9]*}"

  if [[ -z "$major" || -z "$minor" ]]; then
    err "could not parse tmux version: $version_raw"
    return
  fi

  if (( major > 3 || (major == 3 && minor >= 2) )); then
    ok "tmux version $version_num (>= 3.2)"
  else
    err "tmux version $version_num is below required 3.2 baseline"
  fi
}

check_terminfo() {
  if infocmp -x tmux-256color >/dev/null 2>&1; then
    ok "terminfo entry exists: tmux-256color"
  else
    err "missing terminfo entry tmux-256color (install ncurses-term or equivalent)"
  fi
}

check_term_chain() {
  local term_value="${TERM:-}"
  if [[ -z "$term_value" ]]; then
    err "TERM is empty"
    return
  fi

  if [[ -n "${TMUX:-}" ]]; then
    if [[ "$term_value" == "tmux-256color" ]]; then
      ok "inside tmux with TERM=$term_value"
    else
      err "inside tmux but TERM=$term_value (expected tmux-256color)"
    fi
  else
    if [[ "$term_value" == "xterm-ghostty" || "$term_value" == "xterm-256color" ]]; then
      ok "outside tmux with TERM=$term_value"
    else
      warn "outside tmux with TERM=$term_value (expected xterm-ghostty or xterm-256color)"
    fi
  fi
}

check_tmux_features() {
  if ! command -v tmux >/dev/null 2>&1; then
    err "tmux is not installed"
    return
  fi

  local info tmux_conf tmux_opts
  tmux_conf="${HOME}/.config/tmux/tmux.conf"

  if [[ -f "$tmux_conf" ]]; then
    if tmux_opts="$(tmux -f "$tmux_conf" start-server \; show-options -gs 2>/dev/null)"; then
      if printf '%s\n' "$tmux_opts" | has_match '^set-clipboard external'; then
        ok "tmux config sets set-clipboard external"
      else
        warn "tmux config does not set set-clipboard external"
      fi
    else
      warn "could not read tmux options from $tmux_conf"
    fi
  else
    warn "tmux config not found at $tmux_conf"
  fi

  if info="$(tmux start-server \; info 2>/dev/null)"; then
    if printf '%s\n' "$info" | has_match 'Ms:'; then
      ok "tmux reports Ms capability"
    else
      warn "tmux info does not show Ms capability"
    fi

    if printf '%s\n' "$info" | has_match 'RGB|Tc'; then
      ok "tmux reports RGB/truecolor capability"
    else
      warn "tmux info does not show RGB/Tc capability"
    fi
  else
    warn "could not query tmux info"
  fi
}

main() {
  printf 'Checking Ghostty/tmux/neovim pipeline prerequisites...\n'
  check_tmux_version
  check_terminfo
  check_term_chain
  check_tmux_features

  if (( fail == 0 )); then
    printf '\nAll required checks passed.\n'
  else
    printf '\nOne or more required checks failed.\n'
    exit 1
  fi
}

main "$@"
