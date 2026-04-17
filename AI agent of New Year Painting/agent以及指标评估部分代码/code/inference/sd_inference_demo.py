#!/usr/bin/env python3
"""
中国传统年画 LoRA 推理示例脚本
使用 Stable Diffusion 1.5 + 训练好的 LoRA 模型生成年画风格图片
"""

import torch
from diffusers import StableDiffusionPipeline
from safetensors.torch import load_file
import os

# 配置参数
BASE_MODEL_PATH = "/root/autodl-tmp/LLaMA-Factory/lora-training/models/sd-v1-5.safetensors"
LORA_MODEL_PATH = "/root/autodl-tmp/LLaMA-Factory/lora-training/output/nianha_lora.safetensors"
OUTPUT_DIR = "/root/autodl-tmp/LLaMA-Factory/lora-training/generated_images"
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# 推理参数
LORA_WEIGHT = 0.8  # LoRA 权重 (推荐 0.6-0.9)
NUM_INFERENCE_STEPS = 30  # 推理步数
GUIDANCE_SCALE = 7.5  # CFG scale
IMAGE_WIDTH = 512
IMAGE_HEIGHT = 512
SEED = 42  # 随机种子（设为None则每次不同）

# 示例提示词（必须包含触发词 "nianha"）
PROMPTS = [
    "nianha, 传统年画，门神形象，威武雄壮，红色调",
    "nianha, 年画风格，仕女图，古典美女，细腻笔触",
    "nianha, 中国传统年画，福娃抱鱼，喜庆祥和",
    "nianha, 年画艺术，戏曲人物，京剧脸谱，色彩鲜艳",
]

NEGATIVE_PROMPT = "low quality, blurry, distorted, modern, photograph, realistic, 3d render"


def load_lora_weights(pipeline, lora_path, lora_weight=1.0):
    """加载 LoRA 权重到 pipeline"""
    print(f"正在加载 LoRA 权重: {lora_path}")
    print(f"LoRA 权重系数: {lora_weight}")

    # 加载 LoRA 权重
    lora_state_dict = load_file(lora_path)

    # 应用 LoRA 权重到 UNet 和 Text Encoder
    # 注意：这是简化版本，完整实现需要使用 kohya-ss 的加载方法
    # 或者使用支持 LoRA 的 pipeline

    # 使用 diffusers 的内置方法加载 LoRA
    pipeline.load_lora_weights(os.path.dirname(lora_path),
                               weight_name=os.path.basename(lora_path))

    # 设置 LoRA 权重
    pipeline.fuse_lora(lora_scale=lora_weight)

    print("LoRA 权重加载完成！")
    return pipeline


def generate_images(prompts, output_dir, num_images_per_prompt=1):
    """生成图片"""

    # 创建输出目录
    os.makedirs(output_dir, exist_ok=True)

    print("=" * 60)
    print("正在初始化 Stable Diffusion Pipeline...")
    print("=" * 60)

    # 加载 SD 1.5 模型
    pipe = StableDiffusionPipeline.from_single_file(
        BASE_MODEL_PATH,
        torch_dtype=torch.float16 if DEVICE == "cuda" else torch.float32,
        safety_checker=None,
        load_safety_checker=False,
        local_files_only=True,
    )

    pipe = pipe.to(DEVICE)

    # 启用内存优化
    if DEVICE == "cuda":
        # 禁用 xformers - RTX 5090 不支持
        # pipe.enable_xformers_memory_efficient_attention()
        pipe.enable_vae_slicing()
        pipe.enable_attention_slicing()

    # 加载 LoRA 权重
    pipe = load_lora_weights(pipe, LORA_MODEL_PATH, LORA_WEIGHT)

    # 设置随机种子
    if SEED is not None:
        generator = torch.Generator(device=DEVICE).manual_seed(SEED)
    else:
        generator = None

    print("\n" + "=" * 60)
    print("开始生成图片...")
    print("=" * 60)

    # 生成图片
    for idx, prompt in enumerate(prompts):
        print(f"\n[{idx + 1}/{len(prompts)}] 提示词: {prompt}")

        for img_num in range(num_images_per_prompt):
            # 如果要每张图不同，更新种子
            if SEED is not None and num_images_per_prompt > 1:
                current_generator = torch.Generator(device=DEVICE).manual_seed(SEED + idx * 100 + img_num)
            else:
                current_generator = generator

            # 生成图片
            image = pipe(
                prompt=prompt,
                negative_prompt=NEGATIVE_PROMPT,
                num_inference_steps=NUM_INFERENCE_STEPS,
                guidance_scale=GUIDANCE_SCALE,
                width=IMAGE_WIDTH,
                height=IMAGE_HEIGHT,
                generator=current_generator,
            ).images[0]

            # 保存图片
            output_filename = f"nianha_{idx + 1:02d}_{img_num + 1}.png"
            output_path = os.path.join(output_dir, output_filename)
            image.save(output_path)
            print(f"  ✓ 已保存: {output_path}")

    print("\n" + "=" * 60)
    print(f"生成完成！共生成 {len(prompts) * num_images_per_prompt} 张图片")
    print(f"保存位置: {output_dir}")
    print("=" * 60)


def main():
    """主函数"""
    print("\n" + "=" * 60)
    print("中国传统年画 LoRA 推理脚本")
    print("=" * 60)
    print(f"设备: {DEVICE}")
    print(f"基础模型: {BASE_MODEL_PATH}")
    print(f"LoRA 模型: {LORA_MODEL_PATH}")
    print(f"LoRA 权重: {LORA_WEIGHT}")
    print(f"输出目录: {OUTPUT_DIR}")
    print(f"图片尺寸: {IMAGE_WIDTH}x{IMAGE_HEIGHT}")
    print(f"推理步数: {NUM_INFERENCE_STEPS}")
    print(f"CFG Scale: {GUIDANCE_SCALE}")
    print("=" * 60)

    # 检查文件是否存在
    if not os.path.exists(BASE_MODEL_PATH):
        print(f"错误: 找不到基础模型 {BASE_MODEL_PATH}")
        return

    if not os.path.exists(LORA_MODEL_PATH):
        print(f"错误: 找不到 LoRA 模型 {LORA_MODEL_PATH}")
        print("可用的 LoRA 模型:")
        output_dir = os.path.dirname(LORA_MODEL_PATH)
        if os.path.exists(output_dir):
            for f in os.listdir(output_dir):
                if f.endswith(".safetensors"):
                    print(f"  - {os.path.join(output_dir, f)}")
        return

    # 生成图片
    try:
        generate_images(
            prompts=PROMPTS,
            output_dir=OUTPUT_DIR,
            num_images_per_prompt=1  # 每个提示词生成1张图
        )
    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
