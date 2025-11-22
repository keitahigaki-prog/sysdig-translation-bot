#!/usr/bin/env python3
"""
記事翻訳モジュール
Claude APIを使用してSysdig記事を日本語に翻訳
"""

import os
import subprocess
from pathlib import Path
from typing import Optional


class ArticleTranslator:
    """記事翻訳クラス"""

    def __init__(self):
        self.translation_template = """以下のSysdig顧客事例ページを日本語で魅力的な記事に翻訳してください：

URL: {url}

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
- 技術用語は適切に日本語化（カタカナ表記含む）
- マークダウン形式で構造化
- 見出し、箇条書き、表を効果的に使用
- 専門的だが読みやすい文体
- 元記事の情報を正確に伝える

### 強調すべきポイント
- ROI（投資対効果）
- 時間短縮率
- コスト削減
- セキュリティ向上
- コンプライアンス対応

### 含めるべき要素
✅ 導入前後の比較
✅ 実際の担当者のコメント（引用）
✅ 技術的なアーキテクチャ図（テキストベース）
✅ 業界特有の課題とソリューション
✅ 今後の展開や推奨事項

出力は完全なマークダウンファイルとして、すぐに公開できる品質で作成してください。
"""

    def fetch_and_translate(self, url: str, output_file: Path) -> bool:
        """
        URLから記事を取得して翻訳し、ファイルに保存

        Args:
            url: 翻訳対象のURL
            output_file: 出力先ファイルパス

        Returns:
            成功した場合True
        """
        try:
            print(f"🌐 記事を取得中: {url}")

            # プロンプトを生成
            prompt = self.translation_template.format(url=url)

            # Claude CLIを使用して翻訳を実行
            # まずURLの内容を取得
            fetch_result = self._fetch_url_content(url)

            if not fetch_result:
                print("❌ URLの内容取得に失敗しました")
                return False

            # 翻訳を実行
            translated_content = self._translate_content(fetch_result, url)

            if not translated_content:
                print("❌ 翻訳に失敗しました")
                return False

            # ファイルに保存
            output_file.parent.mkdir(parents=True, exist_ok=True)
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(translated_content)

            print(f"✅ 翻訳完了: {output_file}")
            return True

        except Exception as e:
            print(f"❌ エラーが発生しました: {e}")
            return False

    def _fetch_url_content(self, url: str) -> Optional[str]:
        """
        URLの内容を取得（WebFetch相当の処理）

        Args:
            url: 対象URL

        Returns:
            取得した内容、失敗時はNone
        """
        try:
            # curlまたはwgetを使用してHTMLを取得
            # 実際にはBeautifulSoupやRequestsを使う方が良い
            result = subprocess.run(
                ['curl', '-s', '-L', url],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                return result.stdout
            else:
                return None

        except Exception as e:
            print(f"⚠️  URL取得エラー: {e}")
            return None

    def _translate_content(self, content: str, url: str) -> Optional[str]:
        """
        コンテンツを翻訳

        実際の実装では、Claude APIを直接呼び出すか、
        subprocess経由でclaude-codeコマンドを使用します

        Args:
            content: 元のHTML/テキストコンテンツ
            url: 元のURL

        Returns:
            翻訳されたマークダウン、失敗時はNone
        """
        # プレースホルダー実装
        # 実運用では以下のいずれかの方法で実装：
        # 1. anthropic Python SDKを使用
        # 2. subprocess経由でclaude-codeコマンドを実行
        # 3. HTTP API直接呼び出し

        print("⚠️  注意: 翻訳機能は実装中です")
        print(f"    実際の翻訳にはClaude APIの統合が必要です")
        print(f"    URL: {url}")

        # デモ用のプレースホルダーコンテンツ
        return f"""# {url} の翻訳記事

この記事は自動翻訳システムによって生成されました。

## 概要

（ここに翻訳された内容が入ります）

## 実装が必要

実際の翻訳機能を使用するには、以下のいずれかが必要です：

1. **Anthropic API Key** - `ANTHROPIC_API_KEY`環境変数を設定
2. **Claude Code CLI** - コマンドラインから呼び出し
3. **カスタム実装** - 独自の翻訳ロジック

---

*元記事: {url}*
"""

    def translate_with_api(self, url: str, output_file: Path, api_key: str) -> bool:
        """
        Anthropic APIを使用して翻訳（実装例）

        Args:
            url: 翻訳対象URL
            output_file: 出力先
            api_key: Anthropic API Key

        Returns:
            成功した場合True
        """
        try:
            import anthropic

            client = anthropic.Anthropic(api_key=api_key)

            # URLコンテンツを取得
            content = self._fetch_url_content(url)
            if not content:
                return False

            # プロンプトを作成
            prompt = self.translation_template.format(url=url)
            full_prompt = f"{prompt}\n\n元のコンテンツ:\n{content[:10000]}"  # 最初の10000文字

            # Claude APIで翻訳
            message = client.messages.create(
                model="claude-sonnet-4-5-20250929",
                max_tokens=8000,
                messages=[
                    {"role": "user", "content": full_prompt}
                ]
            )

            translated_content = message.content[0].text

            # ファイルに保存
            output_file.parent.mkdir(parents=True, exist_ok=True)
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(translated_content)

            print(f"✅ API翻訳完了: {output_file}")
            return True

        except ImportError:
            print("❌ anthropic パッケージがインストールされていません")
            print("   pip install anthropic を実行してください")
            return False
        except Exception as e:
            print(f"❌ API翻訳エラー: {e}")
            return False
