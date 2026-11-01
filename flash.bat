@echo off
REM ============================================================
REM  一键烧录：把编译好的固件写入 STM32F103C8Tx（需 ST-Link 已连接）
REM  使用：先确保已在 CLion 里点锤子编译过一次（生成 .bin），再双击本文件
REM ============================================================
set OPENOCD=D:\enviroment\OpenOCD\bin\openocd.exe
set SCRIPTS=D:\enviroment\OpenOCD\share\openocd\scripts
REM 下面的 .bin 路径 = CLion 默认构建目录\工程名.bin，如与实际不符请修改
set BIN=cmake-build-debug\20261025led-0.bin

if not exist "%OPENOCD%" (
    echo [错误] 找不到 openocd：%OPENOCD%
    echo 请确认 openocd 的安装路径，或修改本文件顶部的 OPENOCD 变量。
    pause
    exit /b 1
)

if not exist "%BIN%" (
    echo [错误] 找不到固件：%BIN%
    echo 请先在 CLion 里点锤子编译一次（会生成 .bin），再运行本脚本。
    pause
    exit /b 1
)

echo 正在通过 ST-Link 烧录 %BIN% ...
"%OPENOCD%" -s "%SCRIPTS%" ^
    -f interface/stlink.cfg ^
    -f target/stm32f1x.cfg ^
    -c "program %BIN% verify reset exit 0x08000000"

echo.
echo 烧录完成（上面出现 Verified OK 即成功，芯片已复位运行）。
pause
