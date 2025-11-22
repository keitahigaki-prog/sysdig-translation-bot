# Sysdig記事翻訳Bot 🤖

Sysdigの顧客事例ページから毎日1記事をランダムに選択し、日本語に翻訳して配信する自動化システムです。

## 📋 概要

- **対象**: Sysdig顧客事例 (34記事、順次拡大予定)
- **頻度**: 1日1記事
- **選定方法**: ランダム選択（翻訳済み記事は除外）
- **出力形式**: マークダウン (YYYY-MM-DD_企業名.md)
- **実行方式**: GitHub Actions による自動実行（毎日 JST 10:00）

## 🚀 セットアップ

### 1. GitHub Actionsによる自動実行（推奨）

このリポジトリをGitHubにpushするだけで、毎日 JST 10:00 に自動的に翻訳が実行されます。

```bash
# 1. リポジトリをクローンまたはフォーク
git clone https://github.com/YOUR_USERNAME/sysdig-translation-bot.git
cd sysdig-translation-bot

# 2. GitHubにpush
git push origin main
```

**自動実行設定:**
- `.github/workflows/translate-daily.yml` により自動設定済み
- 毎日 JST 10:00 (UTC 01:00) に自動実行
- 翻訳結果は自動的にコミット＆プッシュされます

**手動実行:**
- GitHub UI: `Actions` タブ → `Daily Sysdig Translation` → `Run workflow`

### 2. ローカルでの手動実行

```bash
# 必要なツール
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# ランダムに1記事を翻訳
./translate_simple.sh

# 特定の記事を指定して実行
./translate_simple.sh neo4j
```

### 3. ディレクトリ構造

```
sysdig-translation-bot/
├── .github/
│   └── workflows/
│       └── translate-daily.yml  # GitHub Actions設定
├── translate_simple.sh          # メイン翻訳スクリプト
├── articles/                    # 翻訳記事の保存先
├── logs/                        # 実行ログ
├── translated.json              # 翻訳済み記事の管理
├── .gitignore                   # Git除外設定
└── README.md                    # このファイル
```

## 📝 使用方法

### 手動実行

```bash
# ランダムに1記事を翻訳
./translate_with_claude.sh

# 特定の記事を翻訳
./translate_with_claude.sh jumpcloud

# 進捗状況を確認
grep -c "slug" translated.json  # 翻訳済み記事数
```

### 翻訳済み記事の確認

```bash
# 翻訳済みリストを表示
cat translated.json | jq '.[] | "\(.date) - \(.title)"'

# 最新の翻訳記事
cat translated.json | jq '.[-1]'

# 未翻訳記事数を確認
echo "未翻訳: $((34 - $(cat translated.json | jq '. | length')))"
```

### ログの確認

```bash
# Cron実行ログをリアルタイム監視
tail -f logs/cron.log

# 特定日のログを確認
cat logs/2025-11-13_neo4j.log
```

## 🎯 対象記事リスト

| Slug | タイトル | 特徴 |
|------|---------|------|
| `neo4j` | Neo4j | データベース業界 |
| `bigcommerce` | BigCommerce | Eコマース |
| `apree-health` | Apree Health | ヘルスケア |
| `syfe` | Syfe | フィンテック、コンプライアンス75%削減 |
| `jumpcloud` | JumpCloud | 脆弱性80%削減 |
| `sprout-social` | Sprout Social | 脅威検知99%高速化 |
| `immuta` | Immuta | 誤検知85%削減 |
| `ben-visa-vale` | Ben Visa Vale | 80万カード会員保護 |
| `rush-street` | Rush Street (RSI) | 6週間で100%保護 |
| `worldpay-on-aws` | Worldpay | 運用負荷削減 |
| `gini` | Gini | マルチ環境セキュリティ |
| `healthcare-tech` | Healthcare IT | コスト比較 |
| `automox` | Automox | 脆弱性トリアージ |
| `crypto-platform` | Crypto Platform | ランタイムセキュリティ |

## 📊 翻訳記事の品質基準

各記事には以下の要素が含まれます：

### 必須セクション
1. ✅ **エグゼクティブサマリー** - 数値で成果を強調
2. ✅ **企業プロファイル** - 業種、規模、技術スタック
3. ✅ **課題** - 導入前の具体的な問題
4. ✅ **ソリューション** - Sysdigの活用方法
5. ✅ **成果** - ROI、時間短縮、コスト削減など
6. ✅ **技術詳細** - アーキテクチャ図、実装内容
7. ✅ **学び** - 他社への応用可能な知見
8. ✅ **まとめ**

### スタイルガイド
- 📈 **数値の強調**: 具体的な％、時間、金額
- 💬 **引用の活用**: セキュリティ責任者の生の声
- 🔧 **技術的正確性**: 適切な用語使用
- 📖 **読みやすさ**: 見出し、箇条書き、表の活用
- 🎯 **ターゲット**: セキュリティエンジニア、意思決定者

## 🔧 カスタマイズ

### 記事リストの更新

```bash
# article_list.json を編集
vim article_list.json

# または translate_with_claude.sh のARTICLES配列を編集
vim translate_with_claude.sh
```

### 翻訳プロンプトのカスタマイズ

`translator.py` または `translate_with_claude.sh` 内のプロンプトテンプレートを編集：

```python
# translator.py の translation_template を編集
self.translation_template = """
あなたのカスタムプロンプト...
"""
```

### 実行頻度の変更

```bash
# Cron設定を編集
crontab -e

# 例: 1日2回実行 (朝10時と夕方18時)
0 10 * * * /path/to/translate_with_claude.sh >> /path/to/logs/cron.log 2>&1
0 18 * * * /path/to/translate_with_claude.sh >> /path/to/logs/cron.log 2>&1
```

## 🐍 Python版の使用 (API統合)

Anthropic APIを直接使用する場合：

### 1. セットアップ

```bash
# 依存パッケージのインストール
pip install anthropic requests beautifulsoup4

# API Keyの設定
export ANTHROPIC_API_KEY="your-api-key-here"
```

### 2. 実行

```bash
# Python版で実行
python translate_daily.py

# API Key を直接指定
python translate_daily.py --api-key sk-ant-xxxxx
```

## 📈 進捗管理

### ダッシュボードスクリプト

```bash
# 進捗状況を表示
cat << 'EOF' > show_progress.sh
#!/bin/bash
TOTAL=34
TRANSLATED=$(cat translated.json | jq '. | length')
REMAINING=$((TOTAL - TRANSLATED))
PERCENTAGE=$((TRANSLATED * 100 / TOTAL))

echo "================================"
echo "📊 翻訳進捗"
echo "================================"
echo "総記事数:   $TOTAL"
echo "翻訳済み:   $TRANSLATED ($PERCENTAGE%)"
echo "未翻訳:     $REMAINING"
echo "================================"

if [ $TRANSLATED -gt 0 ]; then
    echo ""
    echo "最近の翻訳:"
    cat translated.json | jq -r '.[-5:] | .[] | "  \(.date) - \(.title)"'
fi
EOF

chmod +x show_progress.sh
./show_progress.sh
```

## 🔍 トラブルシューティング

### Cronが実行されない

```bash
# Cronサービスの状態確認
# macOS
sudo launchctl list | grep cron

# Linux
systemctl status cron

# Cronログの確認
tail -f /var/log/syslog | grep CRON  # Linux
tail -f logs/cron.log                # プロジェクトログ
```

### 翻訳が失敗する

```bash
# 個別ログを確認
cat logs/YYYY-MM-DD_article-slug.log

# スクリプトを手動実行してデバッグ
bash -x translate_with_claude.sh article-slug
```

### jqエラー

```bash
# jqがインストールされているか確認
which jq

# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq
```

## 📦 バックアップ

定期的に翻訳済み記事とログをバックアップ：

```bash
# バックアップスクリプト
tar -czf sysdig-translations-$(date +%Y%m%d).tar.gz \
    articles/ \
    logs/ \
    translated.json \
    article_list.json

# クラウドにアップロード (例: Google Drive, Dropbox)
# または git にコミット
```

## 🚀 次のステップ

1. **API統合**: Anthropic APIまたはClaude Code CLIと統合
2. **Webhook通知**: Slack/Discordに翻訳完了を通知
3. **CMS連携**: WordPressなどに自動投稿
4. **品質チェック**: 翻訳品質の自動評価
5. **メトリクス収集**: 翻訳時間、文字数などを記録

## 📄 ライセンス

MIT License

## 🤝 コントリビューション

プルリクエスト歓迎！

## 📞 サポート

問題が発生した場合は Issue を作成してください。

---

**Happy Translating! 🎉**
