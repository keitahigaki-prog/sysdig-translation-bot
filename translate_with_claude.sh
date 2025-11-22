#!/usr/bin/env bash
###############################################################################
# Sysdig記事翻訳スクリプト (Claude Code CLI統合版)
#
# 使用方法:
#   ./translate_with_claude.sh <article-slug>
#   ./translate_with_claude.sh neo4j
#
# または引数なしで実行すると、ランダムに未翻訳記事を選択
#   ./translate_with_claude.sh
###############################################################################

set -e

# Bash 4.0以上が必要 (連想配列のため)
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "❌ エラー: Bash 4.0以上が必要です"
    echo "   現在のバージョン: $BASH_VERSION"
    echo ""
    echo "macOSの場合："
    echo "  brew install bash"
    echo "  その後、以下で実行："
    echo "  /usr/local/bin/bash $0"
    exit 1
fi

# ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTICLES_DIR="$SCRIPT_DIR/articles"
LOGS_DIR="$SCRIPT_DIR/logs"
TRANSLATED_LOG="$SCRIPT_DIR/translated.json"

# 記事リスト
declare -A ARTICLES=(
    ["neo4j"]="Neo4j - Empowering Engineering to Reduce Risk"
    ["bigcommerce"]="BigCommerce - Securing global ecommerce at scale"
    ["apree-health"]="Apree Health - Powering secure, compliant healthcare innovation"
    ["syfe"]="Syfe - cuts compliance time by 75%, boosts CIS score 30 points"
    ["jumpcloud"]="JumpCloud - slashes 80% of vulns and 99.8% of noise"
    ["sprout-social"]="Sprout Social - detects threats 99% faster, cuts noise 98%"
    ["immuta"]="Immuta - gains full visibility in 30 days, cuts false positives 85%"
    ["ben-visa-vale"]="Ben Visa Vale - secures 800K cardholders, remediates 70% faster"
    ["rush-street"]="Rush Street (RSI) - secures 100% of production environments in 6 weeks"
    ["worldpay-on-aws"]="Worldpay - Operational burden reduction"
    ["gini"]="Gini - Multi-environment security operations"
    ["healthcare-tech"]="Healthcare IT Provider - Manual solutions cost comparison"
    ["automox"]="Automox - Vulnerability triage efficiency analysis"
    ["crypto-platform"]="Crypto Platform - Runtime security threat detection"
)

# ディレクトリ作成
mkdir -p "$ARTICLES_DIR" "$LOGS_DIR"

# 翻訳済みチェック
is_translated() {
    local slug="$1"
    if [ -f "$TRANSLATED_LOG" ]; then
        grep -q "\"slug\": \"$slug\"" "$TRANSLATED_LOG" 2>/dev/null
        return $?
    fi
    return 1
}

# 翻訳済みログに追加
mark_as_translated() {
    local slug="$1"
    local title="$2"
    local date="$3"
    local output_file="$4"

    if [ ! -f "$TRANSLATED_LOG" ]; then
        echo "[]" > "$TRANSLATED_LOG"
    fi

    # JSONエントリを追加
    local temp_file=$(mktemp)
    jq ". += [{\"slug\": \"$slug\", \"title\": \"$title\", \"date\": \"$date\", \"file\": \"$output_file\"}]" \
        "$TRANSLATED_LOG" > "$temp_file" && mv "$temp_file" "$TRANSLATED_LOG"
}

# ランダムに未翻訳記事を選択
select_random_article() {
    local untranslated=()

    for slug in "${!ARTICLES[@]}"; do
        if ! is_translated "$slug"; then
            untranslated+=("$slug")
        fi
    done

    if [ ${#untranslated[@]} -eq 0 ]; then
        echo "⚠️  全ての記事が翻訳済みです"
        exit 0
    fi

    # ランダムに1つ選択
    local random_index=$((RANDOM % ${#untranslated[@]}))
    echo "${untranslated[$random_index]}"
}

# 記事を翻訳
translate_article() {
    local slug="$1"
    local title="${ARTICLES[$slug]}"
    local url="https://www.sysdig.com/customers/$slug"
    local date=$(date +%Y-%m-%d)
    local output_file="$ARTICLES_DIR/${date}_${slug}.md"
    local log_file="$LOGS_DIR/${date}_${slug}.log"

    echo "================================"
    echo "📄 翻訳開始"
    echo "================================"
    echo "記事: $title"
    echo "URL: $url"
    echo "出力: $output_file"
    echo "================================"
    echo ""

    # 翻訳プロンプトを作成
    local prompt="以下のSysdig顧客事例を日本語で魅力的な記事に翻訳してください：

URL: $url

## 要件

### 記事構成
1. **エグゼクティブサマリー** - 成果を数値で強調
2. **企業プロファイル** - 業種、規模、インフラ構成
3. **直面していた課題** - 具体的な問題点
4. **ソリューション** - Sysdigの導入と実装内容
5. **導入成果** - 定量的・定性的な効果
6. **技術的詳細** - アーキテクチャや技術スタック
7. **学びと教訓** - 他社にも応用できる知見
8. **まとめ**

### スタイルガイド
- 具体的な数値データを強調（％、時間、金額など）
- 引用文は日本語として自然な表現に
- 技術用語は適切に日本語化
- マークダウン形式で構造化
- 見出し、箇条書き、表を効果的に使用
- 専門的だが読みやすい文体

### 強調ポイント
- ROI（投資対効果）
- 時間短縮率
- コスト削減
- セキュリティ向上

完成した記事を $output_file に保存してください。"

    # Claude Code CLIで翻訳実行
    # 注: 実際の実行には適切なClaude Code CLIコマンドを使用
    echo "$prompt" > "$log_file"

    echo "⚠️  注意: Claude Code CLIとの統合が必要です"
    echo ""
    echo "手動で以下を実行してください："
    echo "  1. URLにアクセス: $url"
    echo "  2. Claude Codeに翻訳を依頼"
    echo "  3. 結果を $output_file に保存"
    echo ""
    echo "プロンプトは $log_file に保存されました"

    # プレースホルダー記事を作成
    cat > "$output_file" <<EOF
# $title - 日本語版

> 元記事: [$url]($url)
> 翻訳日: $date

## 概要

この記事は自動翻訳システムによって生成される予定です。

## 実装メモ

実際の翻訳を実行するには、以下のいずれかの方法を使用：

1. **Pythonスクリプト + Anthropic API**
   \`\`\`bash
   python translate_daily.py --api-key YOUR_API_KEY
   \`\`\`

2. **Claude Code CLI (推奨)**
   \`\`\`bash
   # 対話的に翻訳
   claude-code translate "$url"
   \`\`\`

3. **手動翻訳**
   - URLにアクセスして内容を確認
   - Claude Codeで翻訳を依頼
   - このファイルを編集して結果を貼り付け

---

*自動生成されたプレースホルダーです*
EOF

    # 翻訳済みとしてマーク
    mark_as_translated "$slug" "$title" "$date" "$output_file"

    echo "✅ 処理完了: $output_file"
    echo ""
}

# 進捗レポート
show_progress() {
    local total=${#ARTICLES[@]}
    local translated=0

    for slug in "${!ARTICLES[@]}"; do
        if is_translated "$slug"; then
            ((translated++))
        fi
    done

    local remaining=$((total - translated))
    local percentage=$((translated * 100 / total))

    echo ""
    echo "======================================"
    echo "📊 翻訳進捗レポート"
    echo "======================================"
    echo "総記事数:   $total"
    echo "翻訳済み:   $translated ($percentage%)"
    echo "未翻訳:     $remaining"
    echo "======================================"
    echo ""
}

# メイン処理
main() {
    echo "🚀 Sysdig記事翻訳Bot"
    echo "実行日時: $(date '+%Y-%m-%d %H:%M:%S')"

    # jqがインストールされているか確認
    if ! command -v jq &> /dev/null; then
        echo "❌ エラー: jq がインストールされていません"
        echo "   macOS: brew install jq"
        echo "   Ubuntu: sudo apt-get install jq"
        exit 1
    fi

    show_progress

    # 引数があればそれを使用、なければランダム選択
    local slug
    if [ $# -eq 0 ]; then
        echo "🎲 ランダムに記事を選択中..."
        slug=$(select_random_article)
    else
        slug="$1"
        if [ -z "${ARTICLES[$slug]}" ]; then
            echo "❌ エラー: 記事 '$slug' が見つかりません"
            echo ""
            echo "利用可能な記事:"
            for key in "${!ARTICLES[@]}"; do
                echo "  - $key: ${ARTICLES[$key]}"
            done
            exit 1
        fi
    fi

    if is_translated "$slug"; then
        echo "⚠️  記事 '$slug' は既に翻訳済みです"
        exit 0
    fi

    translate_article "$slug"
    show_progress
}

main "$@"
