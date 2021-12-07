@echo off
chcp 65001
setlocal enabledelayedexpansion
echo ***********************
echo *AbemaTV ダウンローダー*
echo ***********************
echo.
echo 引数1には ??-??_s?_p
echo までを入力してください。
echo.
echo 引数2には保存先フォルダ名を入力してください
echo.

echo %1
echo %~2

set EPTEXT=%1.txt
if "%3" EQU "" (
  if not exist %EPTEXT% echo 1 > %EPTEXT%
  for /f %%a in (%EPTEXT%) do (
    set ep=%%a
  )
) else (
  echo %3
  set ep=%3
)

set URL=https://abema.tv/video/episode/%1%ep%
 
for /f "usebackq" %%c in (`"wsl echo %1 ^| sed -e "s/_s._p//""`) do set code=%%c

set TITLEURL=https://abema.tv/video/title/%code%

echo.
echo ========================================
echo.
echo 対象URL : %URL%
echo.

set ABEMATITLE= (アニメ) ^| 無料動画・見逃し配信を見るなら ^| ABEMA
for /f "usebackq delims=" %%b in (`"wsl curl -s %TITLEURL% ^| grep -o '^<title^>.*^</title^>' ^| sed 's#^<title^>\(.*\)^</title^>#\1#' ^| sed  -e 's/(アニメ) ^| 無料動画・見逃し配信を見るなら ^| ABEMA//'"`) do set TITLE=%%b
set TS="%~2\%TITLE%第%ep%話.ts"
set MP4="%~2\%TITLE%第%ep%話.mp4"
echo 番組名 : %TITLE%
echo.
echo TS保存先 : %TS%
echo.
echo MP4保存先 : %MP4%

echo.
echo ========================================
echo ダウンロード開始



streamlink %URL% best -o %TS%
ffmpeg -i %TS% -c:v copy -c:a copy %MP4% && del %TS%

if "%3" EQU "" (
  set /a nextep=%ep%+1
  echo !nextep!
  del %EPTEXT%
  echo !nextep! >> %EPTEXT%
)

set EPTITLE=%TITLE%第%ep%話

wsl curl -H "Content-Type: application/json" -X POST -d '{"content": "ダウンロードが完了しました。\n%EPTITLE%"}' https://discord.com/api/webhooks/858715880874311700/sj6hvXmwYWidUsIQkz6FHTClsKDVgx7BbGBKTcGWoBBIrFrg9jWYZmV5YK9-8e-tBbKk
