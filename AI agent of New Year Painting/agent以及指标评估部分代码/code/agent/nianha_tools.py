#!/usr/bin/env python3
"""
年画智能系统 - Strands Agent 工具集
使用 @tool 装饰器封装所有模型为可调用的工具
"""

import os
import json
import requests
import subprocess
from typing import Dict, Any, Optional
from strands import tool
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

LLM_SERVER_URL = os.getenv("LLM_SERVER_URL", "http://localhost:8000")


@tool
def nianha_qa(question: str) -> str:
    """
    年画知识问答工具。回答关于年画的各种问题。

    该工具基于Qwen2.5-VL-3B模型，专门训练用于年画知识问答，可以回答：
    - 年画的历史和文化背景
    - 年画的制作工艺和技术
    - 年画的题材和寓意
    - 特定年画作品的介绍
    - 年画艺术流派和风格

    Args:
        question: 关于年画的问题，例如"什么是杨柳青年画？"或"门神年画有什么文化含义？"

    Returns:
        str: 详细的回答
    """
    try:
        response = requests.post(
            f"{LLM_SERVER_URL}/inference",
            json={
                "model": "qa",
                "prompt": question,
                "max_length": 512,
                "temperature": 0.7
            },
            timeout=60
        )
        result = response.json()

        if result.get("success"):
            return result["result"]
        else:
            return f"错误：{result.get('error', '未知错误')}"

    except Exception as e:
        return f"调用失败：{str(e)}"


@tool
def analyze_user_preferences(user_behavior: str) -> str:
    """
    分析用户行为并生成偏好标签。

    该工具基于Qwen3-4B模型，分析用户的浏览历史、点赞、收藏等行为，生成用户偏好标签。

    Args:
        user_behavior: 用户行为数据的描述，应该包括：
            - 用户喜欢/浏览过的年画作品
            - 作品的风格、主题、色彩等特征
            - 用户的互动行为（点赞、收藏、评论等）

            示例格式：
            "用户喜欢过以下作品：
            - 《武将门神》(风格: 线版, 主题: 驱邪纳吉)
            - 《天官赐福》(风格: 套印, 主题: 吉祥寓意)
            - 《年年有余》(风格: 彩印, 主题: 富贵吉祥)"

    Returns:
        str: 用户偏好标签分析结果
    """
    try:
        prompt = f"分析用户偏好:\n{user_behavior}"

        response = requests.post(
            f"{LLM_SERVER_URL}/inference",
            json={
                "model": "tag",
                "prompt": prompt,
                "max_length": 512,
                "temperature": 0.7
            },
            timeout=60
        )
        result = response.json()

        if result.get("success"):
            return result["result"]
        else:
            return f"错误：{result.get('error', '未知错误')}"

    except Exception as e:
        return f"调用失败：{str(e)}"


@tool
def recommend_nianha(user_profile: str) -> str:
    """
    根据用户画像推荐年画作品。

    该工具基于Qwen3-4B模型，根据用户画像和偏好生成个性化的年画推荐。

    Args:
        user_profile: 用户画像和推荐需求描述，应该包括：
            - 用户偏好的风格、主题
            - 用户的历史行为特征
            - 特定的推荐场景或需求

            示例：
            "用户画像：喜欢传统门神题材
            历史偏好：驱邪纳吉、吉祥寓意
            请推荐相关年画作品"

    Returns:
        str: 推荐的年画作品列表和说明
    """
    try:
        response = requests.post(
            f"{LLM_SERVER_URL}/inference",
            json={
                "model": "recommend",
                "prompt": user_profile,
                "max_length": 512,
                "temperature": 0.7
            },
            timeout=60
        )
        result = response.json()

        if result.get("success"):
            return result["result"]
        else:
            return f"错误：{result.get('error', '未知错误')}"

    except Exception as e:
        return f"调用失败：{str(e)}"


@tool
def generate_nianha_image(
    prompt: str,
    steps: int = 30,
    seed: Optional[int] = None,
    width: int = 512,
    height: int = 512
) -> str:
    """
    生成年画风格的图像。

    该工具基于Stable Diffusion + LoRA模型，根据提示词生成年画风格的图像。
    提示词会自动添加触发词"nianha"以激活年画风格。

    Args:
        prompt: 图像生成提示词，描述想要生成的年画内容。
            例如："传统年画，门神形象，威武雄壮，红色调，金色装饰"
        steps: 推理步数，默认30。数值越高质量越好但速度越慢，建议范围20-50
        seed: 随机种子，用于复现相同的结果。不指定则随机生成
        width: 图像宽度，默认512像素
        height: 图像高度，默认512像素

    Returns:
        str: 生成结果，包含图像路径和生成时间
    """
    try:
        # 确保提示词包含触发词
        if "nianha" not in prompt.lower():
            full_prompt = f"nianha, {prompt}"
        else:
            full_prompt = prompt

        # 构建命令
        cmd_parts = [
            "source /etc/network_turbo &&",
            "source /root/miniconda3/bin/activate sd-env &&",
            "cd /root/autodl-tmp/LLaMA-Factory/lora-training &&",
            f"python /root/autodl-tmp/app/sd_tool.py --prompt '{full_prompt}' --json",
            f"--steps {steps}",
            f"--width {width}",
            f"--height {height}"
        ]

        if seed is not None:
            cmd_parts.append(f"--seed {seed}")

        cmd_str = " ".join(cmd_parts)
        cmd = ["bash", "-c", cmd_str]

        # 执行命令
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)

        if result.stdout.strip():
            # 提取JSON部分
            lines = result.stdout.strip().split('\n')
            for i in range(len(lines)-1, -1, -1):
                if lines[i].startswith('{'):
                    json_str = '\n'.join(lines[i:])
                    sd_result = json.loads(json_str)

                    if sd_result.get("success"):
                        return f"图像生成成功！\n路径：{sd_result['path']}\n生成时间：{sd_result['generation_time']}秒"
                    else:
                        return f"生成失败：{sd_result.get('error', '未知错误')}"

        return "生成失败：无法解析输出"

    except subprocess.TimeoutExpired:
        return "生成超时（120秒）"
    except Exception as e:
        return f"调用失败：{str(e)}"


# 导出所有工具
__all__ = [
    'nianha_qa',
    'analyze_user_preferences',
    'recommend_nianha',
    'generate_nianha_image'
]


if __name__ == "__main__":
    # 测试工具
    print("=== 年画智能系统工具测试 ===\n")

    # 测试问答工具
    print("1. 测试问答工具...")
    result = nianha_qa("什么是杨柳青年画？")
    print(f"结果：{result[:100]}...\n")

    # 测试标签工具
    print("2. 测试标签分析工具...")
    user_data = """用户喜欢过以下作品：
    - 《武将门神》(风格: 线版, 主题: 驱邪纳吉)
    - 《天官赐福》(风格: 套印, 主题: 吉祥寓意)"""
    result = analyze_user_preferences(user_data)
    print(f"结果：{result[:100]}...\n")

    # 测试推荐工具
    print("3. 测试推荐工具...")
    profile = """用户画像：喜欢传统门神题材
    历史偏好：驱邪纳吉、吉祥寓意
    请推荐相关年画作品"""
    result = recommend_nianha(profile)
    print(f"结果：{result[:100]}...\n")

    # 测试图像生成工具
    print("4. 测试图像生成工具...")
    result = generate_nianha_image(
        prompt="传统年画，测试图像",
        steps=10
    )
    print(f"结果：{result}\n")
