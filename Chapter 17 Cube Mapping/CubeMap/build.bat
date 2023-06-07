@echo off
set FLAGS=-nologo -verbosity:quiet
msbuild .\CubeMap.sln /p:Configuration=Debug /p:Platform=x64 %FLAGS% || exit /b
start .\x64\Debug\CubeMap.exe
