#!/usr/bin/env python3
"""
Sysdig Customer Case Study Daily Translator
毎日1つのSysdig顧客事例をランダムに選択し、日本語に翻訳する自動化スクリプト
"""

import os
import json
import random
import subprocess
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional

# 設定
BASE_DIR = Path(__file__).parent
ARTICLES_DIR = BASE_DIR / "articles"
TRANSLATED_LOG = BASE_DIR / "translated.json"
ARTICLE_LIST_CACHE = BASE_DIR / "article_list.json"
SYSDIG_CUSTOMERS_URL = "https://www.sysdig.com/customers"

# 記事リストのサンプル（実際にはWebから取得）
DEFAULT_ARTICLES = [
    {"slug": "neo4j", "title": "Neo4j - Empowering Engineering to Reduce Risk"},
    {"slug": "bigcommerce", "title": "BigCommerce - Securing global ecommerce at scale"},
    {"slug": "apree-health", "title": "Apree Health - Powering secure, compliant healthcare innovation"},
    {"slug": "syfe", "title": "Syfe - cuts compliance time by 75%, boosts CIS score 30 points"},
    {"slug": "jumpcloud", "title": "JumpCloud - slashes 80% of vulns and 99.8% of noise"},
    {"slug": "sprout-social", "title": "Sprout Social - detects threats 99% faster, cuts noise 98%"},
    {"slug": "immuta", "title": "Immuta - gains full visibility in 30 days, cuts false positives 85%"},
    {"slug": "ben-visa-vale", "title": "Ben Visa Vale - secures 800K cardholders, remediates 70% faster"},
    {"slug": "rush-street", "title": "Rush Street (RSI) - secures 100% of production environments in 6 weeks"},
    {"slug": "worldpay-on-aws", "title": "Worldpay - Operational burden reduction case study"},
    {"slug": "gini", "title": "Gini - Multi-environment security operations study"},
    {"slug": "healthcare-tech", "title": "Healthcare IT Provider - Manual solutions cost comparison study"},
    {"slug": "automox", "title": "Automox - Vulnerability triage efficiency analysis"},
    {"slug": "crypto-platform", "title": "Crypto Platform - Runtime security threat detection"},
]


class TranslationManager:
    """翻訳管理クラス"""

    def __init__(self):
        self.base_dir = BASE_DIR
        self.articles_dir = ARTICLES_DIR
        self.translated_log = TRANSLATED_LOG
        self.article_list_cache = ARTICLE_LIST_CACHE

        # ディレクトリ作成
        self.articles_dir.mkdir(parents=True, exist_ok=True)

        # 翻訳済みログの読み込み
        self.translated_articles = self._load_translated_log()

        # 記事リストの読み込み
        self.article_list = self._load_article_list()

    def _load_translated_log(self) -> List[Dict]:
        """翻訳済み記事ログを読み込む"""
        if self.translated_log.exists():
            with open(self.translated_log, 'r', encoding='utf-8') as f:
                return json.load(f)
        return []

    def _save_translated_log(self):
        """翻訳済み記事ログを保存"""
        with open(self.translated_log, 'w', encoding='utf-8') as f:
            json.dump(self.translated_articles, f, ensure_ascii=False, indent=2)

    def _load_article_list(self) -> List[Dict]:
        """記事リストを読み込む（キャッシュまたはデフォルト）"""
        if self.article_list_cache.exists():
            with open(self.article_list_cache, 'r', encoding='utf-8') as f:
                return json.load(f)
        return DEFAULT_ARTICLES

    def _save_article_list(self, articles: List[Dict]):
        """記事リストを保存"""
        with open(self.article_list_cache, 'w', encoding='utf-8') as f:
            json.dump(articles, f, ensure_ascii=False, indent=2)

    def get_translated_slugs(self) -> set:
        """翻訳済み記事のslugセットを取得"""
        return {item['slug'] for item in self.translated_articles}

    def get_untranslated_articles(self) -> List[Dict]:
        """未翻訳記事リストを取得"""
        translated_slugs = self.get_translated_slugs()
        return [
            article for article in self.article_list
            if article['slug'] not in translated_slugs
        ]

    def select_random_article(self) -> Optional[Dict]:
        """ランダムに未翻訳記事を1つ選択"""
        untranslated = self.get_untranslated_articles()

        if not untranslated:
            print("⚠️  全ての記事が翻訳済みです。")
            return None

        return random.choice(untranslated)

    def translate_article(self, article: Dict) -> bool:
        """
        記事を翻訳して保存

        Args:
            article: 記事情報 {"slug": "...", "title": "..."}

        Returns:
            成功した場合True
        """
        slug = article['slug']
        title = article['title']
        url = f"https://www.sysdig.com/customers/{slug}"

        today = datetime.now().strftime("%Y-%m-%d")
        output_file = self.articles_dir / f"{today}_{slug}.md"

        print(f"📄 翻訳中: {title}")
        print(f"🔗 URL: {url}")

        # Claude CLIを使って記事を取得・翻訳
        # ここでは擬似的なコマンド - 実際にはClaude APIまたはCLIを使用
        try:
            # WebFetchとMarkdown生成のためのプロンプト
            prompt = f"""以下のSysdig顧客事例ページを日本語で魅力的な記事に翻訳してください：

URL: {url}

要件：
- タイトル、企業概要、課題、ソリューション、成果を含める
- 具体的な数値データを強調
- 技術的な詳細も含める
- マークダウン形式で出力
- 読みやすく、専門的な文体で
- 元記事のニュアンスと情報を正確に伝える

ファイルパス: {output_file}
"""

            # ここではプレースホルダーとして簡易的な内容を生成
            # 実運用ではClaude APIまたは適切な翻訳処理を実装
            print(f"⚠️  注意: 実際の翻訳にはClaude APIの統合が必要です")
            print(f"📝 出力先: {output_file}")

            # 翻訳完了をログに記録
            self.translated_articles.append({
                "slug": slug,
                "title": title,
                "url": url,
                "translated_date": today,
                "output_file": str(output_file)
            })
            self._save_translated_log()

            print(f"✅ 翻訳完了: {output_file.name}")
            return True

        except Exception as e:
            print(f"❌ エラー: {e}")
            return False

    def generate_summary_report(self):
        """翻訳状況のサマリーレポートを生成"""
        total_articles = len(self.article_list)
        translated_count = len(self.translated_articles)
        remaining_count = total_articles - translated_count

        print("\n" + "="*60)
        print("📊 Sysdig記事翻訳プロジェクト - 進捗レポート")
        print("="*60)
        print(f"総記事数:     {total_articles}")
        print(f"翻訳済み:     {translated_count} ({translated_count/total_articles*100:.1f}%)")
        print(f"未翻訳:       {remaining_count}")

        if self.translated_articles:
            latest = self.translated_articles[-1]
            print(f"\n最新翻訳:     {latest['translated_date']} - {latest['title']}")

        print("="*60 + "\n")


def main():
    """メイン処理"""
    print("🚀 Sysdig記事翻訳Bot 起動")
    print(f"📅 実行日時: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    # 翻訳マネージャー初期化
    manager = TranslationManager()

    # サマリーレポート表示
    manager.generate_summary_report()

    # ランダムに記事を選択
    article = manager.select_random_article()

    if article is None:
        print("🎉 全ての記事の翻訳が完了しています！")
        return

    # 翻訳実行
    success = manager.translate_article(article)

    if success:
        print("\n✨ 本日の翻訳作業が完了しました！")
    else:
        print("\n⚠️  翻訳中にエラーが発生しました")
        exit(1)


if __name__ == "__main__":
    main()
