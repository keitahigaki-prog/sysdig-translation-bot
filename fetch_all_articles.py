#!/usr/bin/env python3
"""
Sysdig全顧客事例リスト取得スクリプト
https://www.sysdig.com/customers から全104事例を取得
"""

import requests
from bs4 import BeautifulSoup
import json
import re
from typing import List, Dict

def fetch_all_customer_stories() -> List[Dict]:
    """
    Sysdig顧客事例ページから全事例を取得
    """
    base_url = "https://www.sysdig.com"
    customers_url = f"{base_url}/customers"

    print(f"🌐 {customers_url} にアクセス中...")

    try:
        # ヘッダーを設定してアクセス
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
        response = requests.get(customers_url, headers=headers, timeout=30)
        response.raise_for_status()

        print(f"✅ ページ取得成功 (ステータス: {response.status_code})")

        # HTMLをパース
        soup = BeautifulSoup(response.content, 'html.parser')

        # 顧客事例のリンクを探す
        articles = []

        # パターン1: /customers/で始まるリンク
        for link in soup.find_all('a', href=True):
            href = link.get('href')

            if href and '/customers/' in href and href != '/customers' and href != '/customers/':
                # URLを正規化
                if href.startswith('/'):
                    full_url = base_url + href
                    slug = href.replace('/customers/', '').strip('/')
                elif href.startswith('http'):
                    full_url = href
                    slug = href.split('/customers/')[-1].strip('/')
                else:
                    continue

                # クエリパラメータを削除
                slug = slug.split('?')[0].split('#')[0]
                full_url = full_url.split('?')[0].split('#')[0]

                if not slug or slug == 'customers':
                    continue

                # タイトルを取得
                title = link.get_text(strip=True)
                if not title:
                    # リンクの親要素からタイトルを探す
                    parent = link.find_parent(['div', 'article', 'section'])
                    if parent:
                        title_elem = parent.find(['h1', 'h2', 'h3', 'h4'])
                        if title_elem:
                            title = title_elem.get_text(strip=True)

                if not title or len(title) < 3:
                    # slugから推測
                    title = slug.replace('-', ' ').title()

                # 重複チェック
                if not any(a['slug'] == slug for a in articles):
                    articles.append({
                        'slug': slug,
                        'title': title,
                        'url': full_url
                    })

        print(f"📊 {len(articles)} 件の事例を発見")

        # ユニーク化とソート
        unique_articles = []
        seen_slugs = set()

        for article in articles:
            if article['slug'] not in seen_slugs:
                unique_articles.append(article)
                seen_slugs.add(article['slug'])

        unique_articles.sort(key=lambda x: x['slug'])

        return unique_articles

    except requests.exceptions.RequestException as e:
        print(f"❌ エラー: {e}")
        return []

def save_to_json(articles: List[Dict], filename: str = "all_articles.json"):
    """記事リストをJSONファイルに保存"""
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(articles, f, ensure_ascii=False, indent=2)
    print(f"💾 {filename} に保存しました ({len(articles)}件)")

def update_shell_script(articles: List[Dict]):
    """translate_simple.sh を更新"""

    # ARTICLES変数を生成
    articles_lines = []
    for article in articles:
        # タイトルをエスケープ
        title = article['title'].replace('"', '\\"')
        articles_lines.append(f'{article["slug"]}|{title}')

    articles_content = '\n'.join(articles_lines)

    print(f"\n📝 translate_simple.sh 用の ARTICLES 変数:")
    print(f"\nARTICLES=\"")
    print(articles_content)
    print(f"\"")
    print(f"\n全 {len(articles)} 件")

def main():
    print("🚀 Sysdig全顧客事例取得ツール")
    print("="*60)
    print()

    # 全事例を取得
    articles = fetch_all_customer_stories()

    if not articles:
        print("⚠️  事例が見つかりませんでした")
        return

    # JSONに保存
    save_to_json(articles)

    # シェルスクリプト用の出力
    update_shell_script(articles)

    # サマリー
    print("\n" + "="*60)
    print("📊 サマリー")
    print("="*60)
    print(f"発見した事例数: {len(articles)}")
    print(f"保存先: all_articles.json")
    print("\n次のステップ:")
    print("  1. all_articles.json を確認")
    print("  2. translate_simple.sh の ARTICLES 変数を更新")
    print("  3. 翻訳を実行")

if __name__ == "__main__":
    main()
