@echo off

:::::::::::::::::::::::::::::::
:: 깃헙에 업로드             ::
:::::::::::::::::::::::::::::::
chcp 65001
cls

git pull

git add .

git commit -m "[%date%] Update"

git push

echo.======================
echo. 깃헙 업로드 완료 !
echo.======================

pause > nul