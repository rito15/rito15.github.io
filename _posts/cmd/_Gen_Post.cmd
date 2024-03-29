::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::: 포스팅 파일 예쁘게 만들어주는 유틸 :::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
chcp 65001
cls
echo.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::: 디렉토리 기반으로 카테고리 문자열 생성
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:loop
for /f "tokens=8,9,10 delims=\" %%a in ("%cd%") do (

    set cat1=%%a
    set cat2=%%b
    set cat3=%%c
)

set strCat=%cat1%
if not "%cat2%" == "ECHO is off." ( if not "%cat2%" == "" (set strCat=%cat1%, %cat2%) )
if not "%cat3%" == "ECHO is off." ( if not "%cat3%" == "" (set strCat=%cat1%, %cat2%, %cat3%) )
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::: 제목 직접 입력
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set /p strTitleEn=" 영어 제목 입력 > "
set /p strTitleKr=" 한글 제목 입력 > "
set strFileDir="%date%-%strTitleEn%.md"
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::: 파일 내용 생성
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.--- >> %strFileDir%
echo.title: %strTitleKr% >> %strFileDir%
echo.author: rito15 >> %strFileDir%
echo.date: %date% %time:~0,8% +09:00 >> %strFileDir%
echo.categories: [%strCat%] >> %strFileDir%
echo.tags: [] >> %strFileDir%
echo.math: false >> %strFileDir%
echo.mermaid: false >> %strFileDir%
echo.--- >> %strFileDir%

echo.>> %strFileDir%
echo.# >> %strFileDir%
echo.--- >> %strFileDir%
echo.>> %strFileDir%
echo.## >> %strFileDir%
echo.>> %strFileDir%
echo.>> %strFileDir%
echo.>> %strFileDir%
echo.^<!------------------------------------------------------------------^> >> %strFileDir%

echo.>> %strFileDir%
echo.# References>> %strFileDir%
echo.--- >> %strFileDir%
echo.- ^<^> >> %strFileDir%
echo.>> %strFileDir%
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo. %strFileDir% 파일 생성 완료 !

pause > nul


