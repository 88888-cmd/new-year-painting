#!/bin/bash
# 启动年画智能系统服务

echo "======================================"
echo "年画智能系统 - 服务启动脚本"
echo "======================================"

# 启用网络
echo "启用网络加速..."
source /etc/network_turbo

# 检查环境
if [ "$1" = "llm" ] || [ "$1" = "" ]; then
    echo ""
    echo "启动LLM服务器..."
    echo "======================================"
    source /root/miniconda3/bin/activate sd-lora

    if [ "$2" = "background" ]; then
        echo "以后台模式启动..."
        nohup python /root/autodl-tmp/app/llm_server.py > llm_server.log 2>&1 &
        echo "LLM服务器已在后台启动"
        echo "查看日志: tail -f llm_server.log"
        echo "API地址: http://localhost:8000"
    else
        echo "以前台模式启动（Ctrl+C退出）..."
        python /root/autodl-tmp/app/llm_server.py
    fi
fi

if [ "$1" = "test-sd" ]; then
    echo ""
    echo "测试SD工具..."
    echo "======================================"
    source /root/miniconda3/bin/activate sd-env

    # 测试命令
    python /root/autodl-tmp/app/sd_tool.py \
        --prompt "nianha, 传统年画，门神形象，威武雄壮，红色调" \
        --steps 10 \
        --output test_output.png

    echo ""
    echo "测试完成，查看: test_output.png"
fi

if [ "$1" = "client" ]; then
    echo ""
    echo "运行客户端示例..."
    echo "======================================"
    source /root/miniconda3/bin/activate sd-lora
    python /root/autodl-tmp/app/llm_client_example.py
fi

if [ "$1" = "help" ] || [ "$1" = "-h" ]; then
    echo ""
    echo "使用方法:"
    echo "  ./start_services.sh           # 前台启动LLM服务器"
    echo "  ./start_services.sh llm       # 前台启动LLM服务器"
    echo "  ./start_services.sh llm background  # 后台启动LLM服务器"
    echo "  ./start_services.sh test-sd   # 测试SD工具"
    echo "  ./start_services.sh client    # 运行客户端示例"
    echo "  ./start_services.sh help      # 显示帮助"
fi