#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT/bin/ai-dev-grow"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ai-dev-grow-test.XXXXXX")"
TEST_HOME="$TEST_ROOT/home"
CONFLICT_HOME="$TEST_ROOT/conflict-home"
COMMAND_CONFLICT_HOME="$TEST_ROOT/command-conflict-home"
PROJECT_A="$TEST_ROOT/project-a"
PROJECT_B="$TEST_ROOT/project-b"
NON_GIT="$TEST_ROOT/non-git"

cleanup() {
  [[ "$TEST_ROOT" == *ai-dev-grow-test.* ]] || return
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

assert_contains() {
  local value="$1"
  local expected="$2"
  [[ "$value" == *"$expected"* ]] || { echo "expected '$expected' in '$value'" >&2; exit 1; }
}

mkdir -p "$TEST_HOME" "$CONFLICT_HOME/.agents/skills" "$COMMAND_CONFLICT_HOME/.config/opencode/commands" "$PROJECT_A" "$PROJECT_B" "$NON_GIT"
git -C "$PROJECT_A" init -q
git -C "$PROJECT_B" init -q
echo "# Existing project rules" > "$PROJECT_A/AGENTS.md"

HOME="$TEST_HOME" "$CLI" install >/dev/null
[[ -L "$TEST_HOME/.agents/skills/ai-dev-grow" ]]
[[ -L "$TEST_HOME/.local/bin/ai-dev-grow" ]]
[[ -L "$TEST_HOME/.config/opencode/commands/task.md" ]]
[[ -L "$TEST_HOME/.config/opencode/commands/assess.md" ]]
[[ -L "$TEST_HOME/.config/opencode/commands/learn.md" ]]
HOME="$TEST_HOME" "$CLI" install >/dev/null

HOME="$TEST_HOME" "$CLI" init "$PROJECT_A" >/dev/null
[[ -f "$PROJECT_A/.ai-dev-grow/project.yaml" ]]
grep -q 'project_id: "project-a"' "$PROJECT_A/.ai-dev-grow/project.yaml"
grep -q 'version: 1' "$PROJECT_A/.ai-dev-grow/project.yaml"
grep -q '^# Existing project rules$' "$PROJECT_A/AGENTS.md"
grep -q '^<!-- AI_DEV_GROW_START -->$' "$PROJECT_A/AGENTS.md"
grep -q '^<!-- AI_DEV_GROW_END -->$' "$PROJECT_A/AGENTS.md"
rules_before="$(cksum "$PROJECT_A/AGENTS.md")"
HOME="$TEST_HOME" "$CLI" init "$PROJECT_A" >/dev/null
rules_after="$(cksum "$PROJECT_A/AGENTS.md")"
[[ "$rules_before" = "$rules_after" ]]

resolved="$(HOME="$TEST_HOME" "$CLI" resolve "$PROJECT_A")"
assert_contains "$resolved" "project_id=project-a"
assert_contains "$resolved" "hub_root=$ROOT"
assert_contains "$resolved" "graph_path=$ROOT/skills/graph.yaml"
assert_contains "$resolved" "learn_command_path=$ROOT/commands/learn.md"

HOME="$TEST_HOME" "$CLI" init --id team-project-b "$PROJECT_B" >/dev/null
resolved_b="$(HOME="$TEST_HOME" "$CLI" resolve "$PROJECT_B")"
assert_contains "$resolved_b" "project_id=team-project-b"
assert_contains "$resolved_b" "graph_path=$ROOT/skills/graph.yaml"
[[ ! -e "$PROJECT_A/skills/graph.yaml" ]]
[[ ! -e "$PROJECT_B/skills/graph.yaml" ]]
[[ -f "$PROJECT_B/AGENTS.md" ]]
grep -q '^<!-- AI_DEV_GROW_START -->$' "$PROJECT_B/AGENTS.md"

HOME="$TEST_HOME" "$CLI" doctor "$PROJECT_A" >/dev/null

if HOME="$TEST_HOME" "$CLI" init --id other-project "$PROJECT_A" >/dev/null 2>&1; then
  echo "expected conflicting init to fail" >&2
  exit 1
fi

if HOME="$TEST_HOME" "$CLI" init "$NON_GIT" >/dev/null 2>&1; then
  echo "expected non-Git init to fail" >&2
  exit 1
fi

if HOME="$TEST_HOME" "$CLI" init . "$PROJECT_A" >/dev/null 2>&1; then
  echo "expected multiple project paths to fail" >&2
  exit 1
fi

mkdir -p "$CONFLICT_HOME/.agents/skills/ai-dev-grow"
if HOME="$CONFLICT_HOME" "$CLI" install >/dev/null 2>&1; then
  echo "expected conflicting install to fail" >&2
  exit 1
fi
[[ ! -e "$CONFLICT_HOME/.local/bin/ai-dev-grow" ]]

echo "unrelated command" > "$COMMAND_CONFLICT_HOME/.config/opencode/commands/task.md"
if HOME="$COMMAND_CONFLICT_HOME" "$CLI" install >/dev/null 2>&1; then
  echo "expected OpenCode command conflict to fail" >&2
  exit 1
fi
[[ ! -e "$COMMAND_CONFLICT_HOME/.agents/skills/ai-dev-grow" ]]
[[ ! -e "$COMMAND_CONFLICT_HOME/.local/bin/ai-dev-grow" ]]
[[ ! -e "$COMMAND_CONFLICT_HOME/.config/opencode/commands/assess.md" ]]
[[ ! -e "$COMMAND_CONFLICT_HOME/.config/opencode/commands/learn.md" ]]

sed -i.bak 's/version: 1/version: 2/' "$PROJECT_A/.ai-dev-grow/project.yaml"
if HOME="$TEST_HOME" "$CLI" resolve "$PROJECT_A" >/dev/null 2>&1; then
  echo "expected unsupported config version to fail" >&2
  exit 1
fi

echo "test-cli: OK"
