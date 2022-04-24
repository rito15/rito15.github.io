@echo off

:::::::::::::::::::::::::::::::
:: 깃헙에 자동 업로드        ::
:::::::::::::::::::::::::::::::
chcp 65001
cls

git pull

git add .

git commit -m "[%date%] Update"

git push