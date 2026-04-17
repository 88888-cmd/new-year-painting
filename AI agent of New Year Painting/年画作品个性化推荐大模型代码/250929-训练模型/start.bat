@echo off

REM 天津杨柳青年画智能系统启动脚本
REM 此脚本适用于Windows系统

REM 设置中文显示
chcp 65001 >nul

REM 检查Python是否安装
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到Python。请先安装Python 3.8或更高版本。
    pause
    exit /b 1
)

REM 设置默认参数
set API_KEY=
set MODE=cli
set HOST=0.0.0.0
set PORT=8000
set RELOAD=false
set PROMPTS_FILE=
set OUTPUT_DIR=./batch_output

REM 解析命令行参数
:parse_args
if "%1"=="--api-key" (
    set API_KEY=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--mode" (
    set MODE=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--host" (
    set HOST=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--port" (
    set PORT=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--reload" (
    set RELOAD=true
    shift
    goto parse_args
)
if "%1"=="--prompts-file" (
    set PROMPTS_FILE=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--output-dir" (
    set OUTPUT_DIR=%2
    shift
    shift
    goto parse_args
)
if "%1"=="help" (
    call :show_help
    exit /b 0
)

REM 显示欢迎信息
echo.
echo =====================================
echo       天津杨柳青年画智能系统
 echo =====================================
echo.

REM 检查是否已设置API密钥
if "%API_KEY%"=="" (
    echo 请输入您的OpenAI API密钥: 
    set /p API_KEY=
    if "%API_KEY%"=="" (
        echo 错误: API密钥不能为空。
        pause
        exit /b 1
    )
)

REM 安装依赖
echo.
echo 正在检查并安装依赖包...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo 错误: 依赖包安装失败。
    pause
    exit /b 1
)

REM 根据模式启动系统
echo.
echo 正在启动天津杨柳青年画智能系统（%MODE%模式）...
echo.

if "%MODE%"=="cli" (
    python main.py --mode cli --api-key %API_KEY%
) else if "%MODE%"=="api" (
    python main.py --mode api --api-key %API_KEY% --host %HOST% --port %PORT% --reload %RELOAD%
) else if "%MODE%"=="batch" (
    if "%PROMPTS_FILE%"=="" (
        echo 请输入提示词文件路径: 
        set /p PROMPTS_FILE=
        if "%PROMPTS_FILE%"=="" (
            echo 错误: 提示词文件路径不能为空。
            pause
            exit /b 1
        )
    )
    python main.py --mode batch --api-key %API_KEY% --prompts-file %PROMPTS_FILE% --output-dir %OUTPUT_DIR%
) else (
    echo 错误: 不支持的模式: %MODE%
    call :show_help
    pause
    exit /b 1
)

if %errorlevel% neq 0 (
    echo.
echo 系统启动失败，请检查错误信息。
pause
    exit /b 1
)

echo.
echo 系统已成功关闭。
pause

exit /b 0

:show_help
echo 天津杨柳青年画智能系统使用帮助
echo.
echo 命令格式:
echo   start.bat [选项]
echo.
echo 选项:
echo   --api-key [key]       设置OpenAI API密钥
echo   --mode [mode]         设置运行模式 (cli/api/batch，默认: cli)
echo   --host [host]         API服务主机地址 (默认: 0.0.0.0)
echo   --port [port]         API服务端口 (默认: 8000)
echo   --reload [true/false] API服务是否启用热重载 (默认: false)
echo   --prompts-file [file] 批量生成的提示词文件路径 (batch模式)
echo   --output-dir [dir]    批量生成的输出目录 (默认: ./batch_output)
echo   help                  显示帮助信息
echo.
echo 示例:
echo   start.bat --api-key your_api_key_here
echo   start.bat --api-key your_api_key_here --mode api --port 8888
echo   start.bat --api-key your_api_key_here --mode batch --prompts-file prompts.txt

exit /b 0