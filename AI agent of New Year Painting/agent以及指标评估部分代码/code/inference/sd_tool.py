#!/usr/bin/env python3
"""
年画智能系统 - SD图像生成工具
离线脚本，接受命令行输入生成年画风格图像
"""

import argparse
import json
import os
import sys
import torch
from diffusers import StableDiffusionPipeline, DPMSolverMultistepScheduler
from safetensors.torch import load_file
from datetime import datetime
import time

# 配置路径
BASE_MODEL_PATH = "/root/autodl-tmp/app/models/stable-diffusion/base/sd-v1-5.safetensors"
LORA_MODEL_PATH = "/root/autodl-tmp/app/models/stable-diffusion/lora/nianha_lora.safetensors"
DEFAULT_OUTPUT_DIR = "/root/autodl-tmp/app/generated_images"

# 默认参数
DEFAULT_CONFIG = {
    "width": 512,
    "height": 512,
    "num_inference_steps": 30,
    "guidance_scale": 7.5,
    "lora_weight": 0.8,
    "negative_prompt": "low quality, blurry, distorted, modern, photograph, realistic, 3d render",
    "seed": None
}

def load_config(config_file):
    """加载JSON配置文件"""
    if config_file and os.path.exists(config_file):
        with open(config_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

def generate_image(
    prompt,
    output_path=None,
    config_file=None,
    **kwargs
):
    """
    生成年画风格图像

    Args:
        prompt: 生成提示词（应包含触发词 "nianha"）
        output_path: 输出路径
        config_file: JSON配置文件路径
        **kwargs: 其他参数覆盖

    Returns:
        dict: 包含结果信息的字典
    """

    # 合并配置
    config = DEFAULT_CONFIG.copy()
    if config_file:
        file_config = load_config(config_file)
        config.update(file_config)
    config.update(kwargs)  # 命令行参数优先级最高

    # 生成输出路径
    if not output_path:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_path = os.path.join(DEFAULT_OUTPUT_DIR, f"nianha_{timestamp}.png")

    # 确保输出目录存在
    output_dir = os.path.dirname(output_path)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    result = {
        "success": False,
        "error": None,
        "path": None,
        "prompt": prompt,
        "config": config,
        "generation_time": 0
    }

    try:
        start_time = time.time()

        # 检查模型文件
        if not os.path.exists(BASE_MODEL_PATH):
            raise FileNotFoundError(f"基础模型不存在: {BASE_MODEL_PATH}")
        if not os.path.exists(LORA_MODEL_PATH):
            raise FileNotFoundError(f"LoRA模型不存在: {LORA_MODEL_PATH}")

        # 设备选择
        device = "cuda" if torch.cuda.is_available() else "cpu"
        dtype = torch.float16 if device == "cuda" else torch.float32

        # 加载模型
        print(f"正在加载模型...", file=sys.stderr)
        pipe = StableDiffusionPipeline.from_single_file(
            BASE_MODEL_PATH,
            torch_dtype=dtype,
            safety_checker=None,
            load_safety_checker=False,  # 不加载safety_checker，避免下载CLIP
            requires_safety_checker=False,
            local_files_only=True,
        )
        pipe = pipe.to(device)

        # 使用更快的调度器
        pipe.scheduler = DPMSolverMultistepScheduler.from_config(pipe.scheduler.config)

        # 内存优化
        if device == "cuda":
            pipe.enable_vae_slicing()
            pipe.enable_attention_slicing()

        # 加载LoRA权重
        print(f"正在加载LoRA权重...", file=sys.stderr)
        pipe.load_lora_weights(
            os.path.dirname(LORA_MODEL_PATH),
            weight_name=os.path.basename(LORA_MODEL_PATH)
        )
        pipe.fuse_lora(lora_scale=config["lora_weight"])

        # 设置随机种子
        generator = None
        if config["seed"] is not None:
            generator = torch.Generator(device=device).manual_seed(config["seed"])

        # 生成图像
        print(f"正在生成图像...", file=sys.stderr)
        image = pipe(
            prompt=prompt,
            negative_prompt=config["negative_prompt"],
            num_inference_steps=config["num_inference_steps"],
            guidance_scale=config["guidance_scale"],
            width=config["width"],
            height=config["height"],
            generator=generator,
        ).images[0]

        # 保存图像
        image.save(output_path, format="PNG")

        generation_time = time.time() - start_time

        result["success"] = True
        result["path"] = output_path
        result["generation_time"] = round(generation_time, 2)

        print(f"✓ 图像已保存: {output_path}", file=sys.stderr)

    except Exception as e:
        result["error"] = str(e)
        print(f"✗ 生成失败: {e}", file=sys.stderr)

    return result

def main():
    """命令行入口"""
    parser = argparse.ArgumentParser(
        description="SD年画风格图像生成工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 基本使用
  python sd_tool.py --prompt "nianha, 传统年画，门神形象，威武雄壮，红色调"

  # 指定输出路径
  python sd_tool.py --prompt "nianha, 年画风格，福娃抱鱼" --output output.png

  # 使用配置文件
  python sd_tool.py --prompt "nianha, 年画艺术" --config config.json

  # 覆盖参数
  python sd_tool.py --prompt "nianha, 门神" --steps 50 --scale 8.0 --seed 42
        """
    )

    parser.add_argument(
        "--prompt", "-p",
        required=True,
        help="生成提示词（应包含触发词 'nianha'）"
    )
    parser.add_argument(
        "--output", "-o",
        help="输出文件路径（默认: generated_images/nianha_时间戳.png）"
    )
    parser.add_argument(
        "--config", "-c",
        help="JSON配置文件路径"
    )
    parser.add_argument(
        "--width",
        type=int,
        help=f"图像宽度（默认: {DEFAULT_CONFIG['width']}）"
    )
    parser.add_argument(
        "--height",
        type=int,
        help=f"图像高度（默认: {DEFAULT_CONFIG['height']}）"
    )
    parser.add_argument(
        "--steps",
        type=int,
        dest="num_inference_steps",
        help=f"推理步数（默认: {DEFAULT_CONFIG['num_inference_steps']}）"
    )
    parser.add_argument(
        "--scale",
        type=float,
        dest="guidance_scale",
        help=f"CFG Scale（默认: {DEFAULT_CONFIG['guidance_scale']}）"
    )
    parser.add_argument(
        "--lora-weight",
        type=float,
        dest="lora_weight",
        help=f"LoRA权重（默认: {DEFAULT_CONFIG['lora_weight']}）"
    )
    parser.add_argument(
        "--negative",
        dest="negative_prompt",
        help="负面提示词"
    )
    parser.add_argument(
        "--seed",
        type=int,
        help="随机种子（用于复现结果）"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="以JSON格式输出结果"
    )

    args = parser.parse_args()

    # 收集非None的参数
    kwargs = {
        k: v for k, v in vars(args).items()
        if v is not None and k not in ["prompt", "output", "config", "json"]
    }

    # 生成图像
    result = generate_image(
        prompt=args.prompt,
        output_path=args.output,
        config_file=args.config,
        **kwargs
    )

    # 输出结果
    if args.json:
        # JSON格式输出（用于程序调用）
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        # 人类可读格式
        if result["success"]:
            print(f"✓ 成功生成图像")
            print(f"  路径: {result['path']}")
            print(f"  用时: {result['generation_time']}秒")
        else:
            print(f"✗ 生成失败: {result['error']}")
            sys.exit(1)

if __name__ == "__main__":
    main()