#!/bin/sh
###############################################################################
# Sysdig記事翻訳スクリプト (シンプル版 - macOS互換)
#
# 使用方法:
#   ./translate_simple.sh <article-slug>
#   ./translate_simple.sh neo4j
#
# または引数なしで実行すると、ランダムに未翻訳記事を選択
#   ./translate_simple.sh
###############################################################################

set -e

# ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARTICLES_DIR="$SCRIPT_DIR/articles"
LOGS_DIR="$SCRIPT_DIR/logs"
TRANSLATED_LOG="$SCRIPT_DIR/translated.json"

# 記事リスト (slug|title形式)
# 全36事例 - Sysdig公式サイトより取得（2026-02-23更新）
ARTICLES="
neo4j|Neo4j - Empowering Engineering to Reduce Risk
bigcommerce|BigCommerce - Securing global ecommerce at scale
apree-health|Apree Health - Powering secure, compliant healthcare innovation
syfe|Syfe - cuts compliance time by 75%, boosts CIS score 30 points
jumpcloud|JumpCloud - slashes 80% of vulns and 99.8% of noise
sprout-social|Sprout Social - detects threats 99% faster, cuts noise 98%
immuta|Immuta - gains full visibility in 30 days, cuts false positives 85%
ben-visa-vale|Ben Visa Vale - secures 800K cardholders, remediates 70% faster
rush-street|Rush Street (RSI) - secures 100% of production environments in 6 weeks
healthcare-tech|Healthcare IT Provider - Cuts Alerts by 99.8%, Reduces Vulnerability Noise by 98%
automox|Automox - Cuts False Positives by 80% and Boosts Vulnerability Response Speed by 30%
worldpay-on-aws|Worldpay - operational burden reduction
gini|Gini - Ensures Adherence to Strict EU Compliance Standards
global-tech-company|Global Tech Company - Greater Stability, Smarter Planning
crypto-platform|Crypto Platform - Credential Exposure Detection Before Breach
uidai|UIDAI - Security for 1 Billion People
retail-tech-company|Retail Tech Company - triples threat remediation speed
mezmo|Mezmo - Delivers Higher Uptime and Improved Customer Experience
sap-concur|SAP Concur - Secure Solutions to 50M+ End Users Globally
icg-consulting|ICG Consulting - Leverages Sysdig and AWS
blablacar|BlaBlaCar - Security Team of Four Empowers Developers
worldpay-by-fis|Worldpay by FIS - Faster Delivery of PCI-Compliant Payment Solutions
goldman-sachs|Goldman Sachs - Accelerating Business With Microservices
bloomreach|Bloomreach - Achieves 350% ROI with Sysdig
security-operations-provider|Security Operations Provider - Reduces Vulnerabilities by 95%
game-development-company|Game Development Company - Saves Millions While Scaling 10X
data-productivity|Data Productivity Company - Securing SaaS Delivery
data-notebook|Data Notebook Company - Compliance and Advanced Attack Shutdown
ntt-docomo|NTT DOCOMO - Secures 80+ Million Users
network|Network Company - Journey to Robust Cloud Security
loglass|Loglass - Scales Compliance to Secure Cloud Growth
zero-bank-minna-no-ginko|Zero Bank (Minna no Ginko) - Real-Time Protection and AI-Driven Insights
coindcx|CoinDCX - Triples Threat Remediation Speed
beekeeper|Beekeeper - Secure Communications Across Cloud Environments
bitmex-has-never-lost-a-coin|BitMEX - Has Never Lost a Coin
global-digital-infrastructure-provider|Global Digital Infrastructure Provider - Cloud Security at Scale
partior|Partior - Securing Blockchain-Based Payment Infrastructure
"

# ディレクトリ作成
mkdir -p "$ARTICLES_DIR" "$LOGS_DIR"

# 翻訳済みチェック
is_translated() {
    slug="$1"
    if [ -f "$TRANSLATED_LOG" ]; then
        grep -q "\"slug\": \"$slug\"" "$TRANSLATED_LOG" 2>/dev/null
        return $?
    fi
    return 1
}

# 記事タイトルを取得
get_title() {
    slug="$1"
    echo "$ARTICLES" | grep "^$slug|" | cut -d'|' -f2
}

# 翻訳済みログに追加
mark_as_translated() {
    slug="$1"
    title="$2"
    date="$3"
    output_file="$4"

    if [ ! -f "$TRANSLATED_LOG" ]; then
        echo "[]" > "$TRANSLATED_LOG"
    fi

    # JSONエントリを追加
    temp_file=$(mktemp)
    jq ". += [{\"slug\": \"$slug\", \"title\": \"$title\", \"date\": \"$date\", \"file\": \"$output_file\"}]" \
        "$TRANSLATED_LOG" > "$temp_file" && mv "$temp_file" "$TRANSLATED_LOG"
}

# ランダムに未翻訳記事を選択
select_random_article() {
    untranslated=""

    # 未翻訳記事をリストアップ
    echo "$ARTICLES" | grep -v "^$" | while IFS='|' read -r slug title; do
        if ! is_translated "$slug"; then
            echo "$slug"
        fi
    done > /tmp/untranslated_articles.txt

    # ファイルが空かチェック
    if [ ! -s /tmp/untranslated_articles.txt ]; then
        echo ""
        return
    fi

    # ランダムに1つ選択 (shufがあれば使用、なければheadとtail)
    if command -v shuf > /dev/null 2>&1; then
        shuf -n 1 /tmp/untranslated_articles.txt
    else
        # shufがない場合の代替方法
        count=$(wc -l < /tmp/untranslated_articles.txt | tr -d ' ')
        if [ "$count" -gt 0 ]; then
            line=$(($(date +%s) % count + 1))
            sed -n "${line}p" /tmp/untranslated_articles.txt
        fi
    fi

    rm -f /tmp/untranslated_articles.txt
}

# 記事を翻訳
translate_article() {
    slug="$1"
    title=$(get_title "$slug")

    if [ -z "$title" ]; then
        echo "❌ エラー: 記事 '$slug' が見つかりません"
        return 1
    fi

    url="https://www.sysdig.com/customers/$slug"
    date=$(date +%Y-%m-%d)
    output_file="$ARTICLES_DIR/${date}_${slug}.md"
    log_file="$LOGS_DIR/${date}_${slug}.log"

    echo "================================"
    echo "📄 翻訳開始"
    echo "================================"
    echo "記事: $title"
    echo "URL: $url"
    echo "出力: $output_file"
    echo "================================"
    echo ""

    # 翻訳プロンプトをログファイルに保存
    cat > "$log_file" <<EOF
翻訳対象URL: $url
記事タイトル: $title

以下のプロンプトをClaude Codeに入力してください:

---

以下のSysdig顧客事例を日本語で魅力的な記事に翻訳してください：

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

完成した記事を $output_file に保存してください。
EOF

    echo "📝 プロンプトをログに保存しました: $log_file"
    echo ""

    # プレースホルダー記事を作成
    cat > "$output_file" <<EOF
# $title - 日本語版

> 元記事: [$url]($url)
> 翻訳日: $date

## 翻訳ステータス

⚠️ この記事は自動生成されたプレースホルダーです。

実際の翻訳を完了するには：

1. **URLにアクセス**: $url
2. **Claude Codeで翻訳**: プロンプトは \`$log_file\` を参照
3. **このファイルを編集**: 翻訳結果をここに貼り付け

---

## 次のステップ

\`\`\`bash
# プロンプトを確認
cat $log_file

# VS Codeでこのファイルを開く
code $output_file
\`\`\`

---

*自動生成日時: $(date '+%Y-%m-%d %H:%M:%S')*
EOF

    # 翻訳済みとしてマーク
    mark_as_translated "$slug" "$title" "$date" "$output_file"

    echo "✅ プレースホルダー作成完了: $output_file"
    echo ""
    echo "次のステップ:"
    echo "  1. cat $log_file"
    echo "  2. 上記プロンプトをClaude Codeに入力"
    echo "  3. 翻訳結果を $output_file に保存"
    echo ""
}

# 進捗レポート
show_progress() {
    total=$(echo "$ARTICLES" | grep -v "^$" | wc -l | tr -d ' ')
    translated=0

    if [ -f "$TRANSLATED_LOG" ]; then
        translated=$(jq '. | length' "$TRANSLATED_LOG")
    fi

    remaining=$((total - translated))
    if [ "$total" -gt 0 ]; then
        percentage=$((translated * 100 / total))
    else
        percentage=0
    fi

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
    if ! command -v jq > /dev/null 2>&1; then
        echo "❌ エラー: jq がインストールされていません"
        echo "   macOS: brew install jq"
        echo "   Ubuntu: sudo apt-get install jq"
        exit 1
    fi

    show_progress

    # 引数があればそれを使用、なければランダム選択
    if [ $# -eq 0 ]; then
        echo "🎲 ランダムに記事を選択中..."
        slug=$(select_random_article)

        if [ -z "$slug" ]; then
            echo "⚠️  全ての記事が翻訳済みです"
            exit 0
        fi
    else
        slug="$1"
        title=$(get_title "$slug")

        if [ -z "$title" ]; then
            echo "❌ エラー: 記事 '$slug' が見つかりません"
            echo ""
            echo "利用可能な記事:"
            echo "$ARTICLES" | grep -v "^$" | while IFS='|' read -r s t; do
                echo "  - $s: $t"
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
