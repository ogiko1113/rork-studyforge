#!/bin/bash
# StudyForge 設定ファイル配置スクリプト
# 使い方: リポジトリルートで実行
#   bash setup.sh

set -e

echo "=== StudyForge 設定ファイルを配置します ==="

# このスクリプトがあるディレクトリ
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# コピー元（カレントディレクトリ = リポジトリルート想定）
cp "$SCRIPT_DIR/CLAUDE.md" ./CLAUDE.md
cp "$SCRIPT_DIR/AGENTS.md" ./AGENTS.md

mkdir -p .claude/commands
cp "$SCRIPT_DIR/.claude/commands/pre-commit.md" .claude/commands/
cp "$SCRIPT_DIR/.claude/commands/review.md" .claude/commands/
cp "$SCRIPT_DIR/.claude/commands/diagnose.md" .claude/commands/

mkdir -p .claude/skills/phase-gate
cp "$SCRIPT_DIR/.claude/skills/phase-gate/SKILL.md" .claude/skills/phase-gate/

mkdir -p .agents/skills/studyforge-logic-guard
mkdir -p .agents/skills/studyforge-ui-qa
mkdir -p .agents/skills/import-parser-qa
mkdir -p .agents/skills/swift-build-and-test
cp "$SCRIPT_DIR/.agents/skills/studyforge-logic-guard/SKILL.md" .agents/skills/studyforge-logic-guard/
cp "$SCRIPT_DIR/.agents/skills/studyforge-ui-qa/SKILL.md" .agents/skills/studyforge-ui-qa/
cp "$SCRIPT_DIR/.agents/skills/import-parser-qa/SKILL.md" .agents/skills/import-parser-qa/
cp "$SCRIPT_DIR/.agents/skills/swift-build-and-test/SKILL.md" .agents/skills/swift-build-and-test/

echo ""
echo "✅ 配置完了。構成:"
find . -maxdepth 4 \( -name 'CLAUDE.md' -o -name 'AGENTS.md' -o -name '*.md' -path '*/.claude/*' -o -name '*.md' -path '*/.agents/*' \) | sort
