@echo off
setlocal
pushd "%~dp0"

echo Creating build output directory...
if not exist "build_output" mkdir build_output

echo Building 21 variants...
for /L %%i in (1,1,21) do (
    echo Building variant %%i...
    flutter build web ^
        --dart-define=PERSON_ID=%%i ^
        --output=build_output\person_%%i
)

echo All 21 variants built successfully!
popd
pause
