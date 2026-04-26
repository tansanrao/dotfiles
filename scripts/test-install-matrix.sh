#!/usr/bin/env bash
# Run containerized install tests for supported Ubuntu hosts.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/test-lib.sh
. "$REPO_ROOT/scripts/test-lib.sh"
# shellcheck source=tests/container/images.env
. "$REPO_ROOT/tests/container/images.env"

SUITE="all"
IMAGES_FILTER=""
KEEP_CONTAINERS=false
JSON_REPORT=""
MAX_PARALLEL=2

ARTIFACT_ROOT="$REPO_ROOT/tests/artifacts/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$ARTIFACT_ROOT"

usage() {
  cat <<'USAGE'
Usage: scripts/test-install-matrix.sh [options]

Options:
  --suite all|root|noroot|guards   Test suite to run (default: all)
  --images a,b,c                    Matrix subset by key (ubuntu2204,ubuntu2404)
  --keep-containers                 Keep failed/success containers for debugging
  --json-report <path>              Write JSON report to path
  --max-parallel <n>                Maximum parallel jobs (currently executed sequentially)
  -h, --help                        Show this help message
USAGE
}

while (( "$#" > 0 )); do
  case "$1" in
    --suite)
      SUITE="$2"
      shift
      ;;
    --images)
      IMAGES_FILTER="$2"
      shift
      ;;
    --keep-containers)
      KEEP_CONTAINERS=true
      ;;
    --json-report)
      JSON_REPORT="$2"
      shift
      ;;
    --max-parallel)
      MAX_PARALLEL="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      test_err "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

case "$SUITE" in
  all|root|noroot|guards)
    ;;
  *)
    test_err "Invalid --suite value: $SUITE"
    exit 1
    ;;
esac

if ! command -v docker >/dev/null 2>&1; then
  test_err "docker is required"
  exit 1
fi

if [[ "$MAX_PARALLEL" != "1" ]]; then
  test_warn "--max-parallel is accepted but cases currently run sequentially"
fi

declare -a MATRIX_KEYS=(ubuntu2404)
declare -a GUARD_KEYS=(ubuntu2204)

image_for_key() {
  case "$1" in
    ubuntu2204) echo "$UBUNTU2204_IMAGE" ;;
    ubuntu2404) echo "$UBUNTU2404_IMAGE" ;;
    *) return 1 ;;
  esac
}

key_in_list() {
  local needle="$1"
  shift
  local candidate
  for candidate in "$@"; do
    if [[ "$candidate" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

select_keys() {
  local -a defaults=("$@")
  if [[ -z "$IMAGES_FILTER" ]]; then
    printf '%s\n' "${defaults[@]}"
    return
  fi

  local chosen=()
  local entry
  IFS=',' read -r -a chosen <<< "$IMAGES_FILTER"
  for entry in "${chosen[@]}"; do
    entry="${entry//[[:space:]]/}"
    [[ -n "$entry" ]] || continue
    case "$entry" in
      ubuntu2204|ubuntu2404)
        if key_in_list "$entry" "${defaults[@]}"; then
          printf '%s\n' "$entry"
        fi
        ;;
      *)
        test_err "Unknown image key in --images: $entry"
        exit 1
        ;;
    esac
  done
}

ROOT_CASE_SCRIPT='set -euo pipefail
/repo/tests/container/prepare.sh
cd /repo
./install.sh | tee /tmp/install-first.log
./install.sh | tee /tmp/install-second.log
! grep -q "INFO: Installing rustup" /tmp/install-second.log || { echo "rerun attempted to reinstall rustup" >&2; exit 1; }
! grep -q "INFO: Installing fnm" /tmp/install-second.log || { echo "rerun attempted to reinstall fnm" >&2; exit 1; }
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:${XDG_DATA_HOME:-$HOME/.local/share}/fnm:$PATH"
semver_ge() {
  local a="${1#v}"
  local b="${2#v}"
  [[ "$(printf "%s\n%s\n" "$b" "$a" | sort -V | tail -n1)" == "$a" ]]
}
need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing required command: $1" >&2; exit 1; }
}
for cmd in git zsh tmux nvim stow cargo rustup node npm corepack pnpm fzf zoxide eza; do
  need_cmd "$cmd"
done
node_version="$(node -v)"
[[ "$node_version" == v24.* ]] || { echo "Node is not v24.x: $node_version" >&2; exit 1; }
if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
  echo "missing fd/fdfind" >&2
  exit 1
fi
nvim_version="$(nvim --version | awk "NR==1 {print \$2}")"
nvim_version="${nvim_version#v}"
semver_ge "$nvim_version" "0.11.2" || { echo "Neovim too old: $nvim_version" >&2; exit 1; }
[[ -e "$HOME/.config/git/config" ]] || { echo "missing git config link" >&2; exit 1; }
[[ -e "$HOME/.config/zsh/.zshrc" ]] || { echo "missing zsh config link" >&2; exit 1; }
[[ -e "$HOME/.config/tmux/tmux.conf" ]] || { echo "missing tmux config link" >&2; exit 1; }
[[ -e "$HOME/.config/nvim/init.lua" ]] || { echo "missing nvim config link" >&2; exit 1; }
[[ -d "$HOME/.local/share/dotfiles/plugins/zsh/pure" ]] || { echo "missing pure plugin" >&2; exit 1; }
[[ -d "$HOME/.local/share/tmux/plugins/tpm" ]] || { echo "missing tpm plugin" >&2; exit 1; }
'

NOROOT_CASE_SCRIPT='set -euo pipefail
/repo/tests/container/prepare.sh
command -v su >/dev/null 2>&1 || { echo "su is required for no-root tests" >&2; exit 1; }
useradd -m -s /bin/bash tester >/dev/null 2>&1 || true
su - tester -c "cd /repo && ./install.sh"
su - tester -c "cd /repo && ./install.sh"
su - tester -c "test -e \"\$HOME/.config/git/config\""
su - tester -c "test -e \"\$HOME/.config/zsh/.zshrc\""
su - tester -c "test -e \"\$HOME/.config/tmux/tmux.conf\""
su - tester -c "test -e \"\$HOME/.config/nvim/init.lua\""
su - tester -c "! test -e \"\$HOME/.cargo/env\""
su - tester -c "! command -v node >/dev/null 2>&1"
su - tester -c "! test -d \"\$HOME/.local/share/dotfiles/plugins/zsh/pure\""
su - tester -c "! test -d \"\$HOME/.local/share/tmux/plugins/tpm\""
'

GUARDS_CASE_SCRIPT='set -euo pipefail
/repo/tests/container/prepare.sh
cd /repo
set +e
./install.sh --skip-plugins >/tmp/ubuntu_guard.log 2>&1
status=$?
set -e
[[ $status -ne 0 ]] || { echo "expected Ubuntu <24 to be rejected" >&2; exit 1; }
grep -q "expected major version 24 or newer" /tmp/ubuntu_guard.log || {
  cat /tmp/ubuntu_guard.log >&2
  echo "missing Ubuntu version guard message" >&2
  exit 1
}
'

declare -a RESULTS=()
FAILED=0

run_case() {
  local suite_name="$1"
  local key="$2"
  local image="$3"
  local script_body="$4"

  local case_id="${suite_name}-${key}"
  local log_file="$ARTIFACT_ROOT/${case_id}.log"
  local start_ts end_ts elapsed status
  start_ts="$(date +%s)"

  local container_name="dotfiles-${case_id//[^a-zA-Z0-9]/-}-${RANDOM}"
  local docker_cmd=(docker run -i -v "$REPO_ROOT:/repo:ro")

  if [[ "$KEEP_CONTAINERS" != "true" ]]; then
    docker_cmd+=(--rm)
  else
    docker_cmd+=(--name "$container_name")
  fi

  docker_cmd+=("$image" bash -lc "$script_body")

  test_info "Running $case_id on $image"
  if "${docker_cmd[@]}" >"$log_file" 2>&1; then
    status="pass"
  else
    status="fail"
    FAILED=1
  fi

  end_ts="$(date +%s)"
  elapsed="$((end_ts - start_ts))"
  RESULTS+=("$case_id|$status|$elapsed|$log_file|$image")

  if [[ "$status" == "pass" ]]; then
    test_info "PASS $case_id (${elapsed}s)"
  else
    test_err "FAIL $case_id (${elapsed}s) - see $log_file"
  fi
}

emit_json_report() {
  local out_path="$1"
  local row first=true

  {
    printf '[\n'
    for row in "${RESULTS[@]}"; do
      IFS='|' read -r case_id status elapsed log_file image <<< "$row"
      if [[ "$first" == "true" ]]; then
        first=false
      else
        printf ',\n'
      fi
      printf '  {"case":"%s","status":"%s","elapsed_seconds":%s,"image":"%s","log":"%s"}' \
        "$(json_escape "$case_id")" \
        "$(json_escape "$status")" \
        "$elapsed" \
        "$(json_escape "$image")" \
        "$(json_escape "$log_file")"
    done
    printf '\n]\n'
  } > "$out_path"
}

if [[ "$SUITE" == "all" || "$SUITE" == "root" || "$SUITE" == "noroot" ]]; then
  SELECTED_KEYS=()
  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    SELECTED_KEYS+=("$key")
  done < <(select_keys "${MATRIX_KEYS[@]}")

  for key in "${SELECTED_KEYS[@]}"; do
    image="$(image_for_key "$key")"
    if [[ "$SUITE" == "all" || "$SUITE" == "root" ]]; then
      run_case "root" "$key" "$image" "$ROOT_CASE_SCRIPT"
    fi
    if [[ "$SUITE" == "all" || "$SUITE" == "noroot" ]]; then
      run_case "noroot" "$key" "$image" "$NOROOT_CASE_SCRIPT"
    fi
  done
fi

if [[ "$SUITE" == "all" || "$SUITE" == "guards" ]]; then
  SELECTED_GUARDS=()
  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    SELECTED_GUARDS+=("$key")
  done < <(select_keys "${GUARD_KEYS[@]}")

  for key in "${SELECTED_GUARDS[@]}"; do
    image="$(image_for_key "$key")"
    run_case "guards" "$key" "$image" "$GUARDS_CASE_SCRIPT"
  done
fi

printf '\n%-22s %-6s %-8s %s\n' "CASE" "STATUS" "ELAPSED" "LOG"
for row in "${RESULTS[@]}"; do
  IFS='|' read -r case_id status elapsed log_file _image <<< "$row"
  printf '%-22s %-6s %-8ss %s\n' "$case_id" "$status" "$elapsed" "$log_file"
done

if [[ -n "$JSON_REPORT" ]]; then
  emit_json_report "$JSON_REPORT"
  test_info "JSON report written to $JSON_REPORT"
fi

if (( FAILED != 0 )); then
  exit 1
fi
