
msbuild .\BezierPatch.sln /p:Configuration=Debug /p:Platform=x64 || exit /b
start .\x64\Debug\BezierPatch.exe
