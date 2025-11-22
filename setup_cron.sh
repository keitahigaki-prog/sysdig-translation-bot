#!/bin/bash
###############################################################################
# Cron設定スクリプト
# 毎日自動で記事翻訳を実行するようにcronを設定
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSLATE_SCRIPT="$SCRIPT_DIR/translate_with_claude.sh"
LOG_FILE="$SCRIPT_DIR/logs/cron.log"

echo "🔧 Cron設定ツール"
echo "================================"
echo ""

# スクリプトが実行可能か確認
if [ ! -x "$TRANSLATE_SCRIPT" ]; then
    echo "❌ エラー: $TRANSLATE_SCRIPT が実行可能ではありません"
    chmod +x "$TRANSLATE_SCRIPT"
    echo "✅ 実行権限を付与しました"
fi

# 実行時刻を選択
echo "翻訳を実行する時刻を選択してください："
echo "  1) 毎朝 9:00"
echo "  2) 毎朝 10:00"
echo "  3) 毎日 12:00 (正午)"
echo "  4) 毎日 18:00 (夕方)"
echo "  5) カスタム時刻"
echo ""
read -p "選択 (1-5): " choice

case $choice in
    1)
        CRON_TIME="0 9 * * *"
        TIME_DESC="毎朝9時"
        ;;
    2)
        CRON_TIME="0 10 * * *"
        TIME_DESC="毎朝10時"
        ;;
    3)
        CRON_TIME="0 12 * * *"
        TIME_DESC="毎日正午"
        ;;
    4)
        CRON_TIME="0 18 * * *"
        TIME_DESC="毎日18時"
        ;;
    5)
        read -p "時間を入力 (0-23): " hour
        read -p "分を入力 (0-59): " minute
        CRON_TIME="$minute $hour * * *"
        TIME_DESC="毎日 ${hour}:${minute}"
        ;;
    *)
        echo "❌ 無効な選択です"
        exit 1
        ;;
esac

echo ""
echo "================================"
echo "📅 Cron設定"
echo "================================"
echo "実行時刻: $TIME_DESC"
echo "スクリプト: $TRANSLATE_SCRIPT"
echo "ログ: $LOG_FILE"
echo "================================"
echo ""

# Cronエントリを作成
CRON_ENTRY="$CRON_TIME $TRANSLATE_SCRIPT >> $LOG_FILE 2>&1"

echo "以下のエントリをcrontabに追加します："
echo ""
echo "  $CRON_ENTRY"
echo ""
read -p "続行しますか？ (y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ キャンセルされました"
    exit 0
fi

# 既存のcrontabをバックアップ
crontab -l > /tmp/crontab.backup 2>/dev/null || true

# 既存のエントリを確認
if crontab -l 2>/dev/null | grep -q "$TRANSLATE_SCRIPT"; then
    echo "⚠️  既存のエントリが見つかりました"
    read -p "既存のエントリを削除して新しいものに置き換えますか？ (y/N): " replace

    if [[ $replace =~ ^[Yy]$ ]]; then
        # 既存のエントリを削除
        crontab -l 2>/dev/null | grep -v "$TRANSLATE_SCRIPT" | crontab -
        echo "✅ 既存のエントリを削除しました"
    else
        echo "❌ キャンセルされました"
        exit 0
    fi
fi

# 新しいエントリを追加
(crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -

echo ""
echo "✅ Cron設定が完了しました！"
echo ""
echo "設定内容:"
echo "  実行時刻: $TIME_DESC"
echo "  スクリプト: $TRANSLATE_SCRIPT"
echo "  ログファイル: $LOG_FILE"
echo ""
echo "現在のcrontab:"
crontab -l | grep "$TRANSLATE_SCRIPT"
echo ""
echo "ログを確認するには:"
echo "  tail -f $LOG_FILE"
echo ""
echo "Cronを無効化するには:"
echo "  crontab -e"
echo "  (該当行を削除または # でコメントアウト)"
echo ""
