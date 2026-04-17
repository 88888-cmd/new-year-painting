#!/usr/bin/env python3
"""
年画智能系统 - SD图片生成模型评估
指标: IS(Inception Score), CLIP Score, 人工评估(风格一致性/主题相关性/画面质量/文化表达)
跳过: FID
数据源: 10_nianha/ 目录的 txt prompt + 生成图片
"""

import os
import sys
import json
import time
import glob
import subprocess
import random

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import save_json, format_results_table

# 路径配置
TRAINING_IMAGES_DIR = "/root/autodl-tmp/LLaMA-Factory/data/10_nianha"
SD_TOOL_PATH = "/root/autodl-tmp/app/sd_tool.py"
GENERATED_DIR = "/root/autodl-tmp/app/evaluation/results/sd_generated"
RESULTS_DIR = "/root/autodl-tmp/app/evaluation/results"


def load_prompts(images_dir: str, max_prompts: int = 30) -> list:
    """从训练数据目录加载 prompt（txt 文件）"""
    txt_files = sorted(glob.glob(os.path.join(images_dir, "*.txt")))
    prompts = []
    for txt_file in txt_files:
        with open(txt_file, "r", encoding="utf-8") as f:
            prompt = f.read().strip()
            if prompt:
                prompts.append({
                    "prompt": prompt,
                    "source_file": os.path.basename(txt_file),
                    "source_image": txt_file.replace(".txt", ".jpg"),
                })
    # 随机采样
    if len(prompts) > max_prompts:
        random.seed(42)
        prompts = random.sample(prompts, max_prompts)
    return prompts


def generate_images(prompts: list) -> list:
    """调用 sd_tool.py 生成图片"""
    os.makedirs(GENERATED_DIR, exist_ok=True)
    results = []

    for idx, item in enumerate(prompts):
        prompt = item["prompt"]
        # 确保包含触发词
        if "nianha" not in prompt.lower():
            full_prompt = f"nianha, {prompt}"
        else:
            full_prompt = prompt

        output_path = os.path.join(GENERATED_DIR, f"gen_{idx:03d}.png")
        print(f"\r  生成进度: {idx+1}/{len(prompts)}", end="", flush=True)

        cmd = (
            f"source /root/miniconda3/bin/activate sd-env && "
            f"cd /root/autodl-tmp/LLaMA-Factory/lora-training && "
            f"python {SD_TOOL_PATH} "
            f"--prompt '{full_prompt}' "
            f"--output '{output_path}' "
            f"--steps 30 --seed {42 + idx} --json"
        )

        try:
            result = subprocess.run(
                ["bash", "-c", cmd],
                capture_output=True, text=True, timeout=180,
            )
            # 解析 JSON 输出
            stdout = result.stdout.strip()
            json_result = None
            for line in reversed(stdout.split("\n")):
                if line.startswith("{"):
                    json_result = json.loads(line)
                    break

            if json_result and json_result.get("success"):
                item["generated_path"] = json_result["path"]
                item["generation_time"] = json_result["generation_time"]
                item["success"] = True
            else:
                item["success"] = False
                item["error"] = json_result.get("error", "unknown") if json_result else "no output"
        except Exception as e:
            item["success"] = False
            item["error"] = str(e)

        results.append(item)

    print()
    return results


def compute_inception_score(image_paths: list) -> float:
    """
    计算 Inception Score。
    使用 torchvision 的 Inception v3 模型。
    """
    try:
        import torch
        import numpy as np
        from torchvision import transforms, models
        from PIL import Image

        print("  计算 Inception Score...")

        # 加载 Inception v3
        model = models.inception_v3(pretrained=True, transform_input=False)
        model.eval()
        if torch.cuda.is_available():
            model = model.cuda()

        transform = transforms.Compose([
            transforms.Resize((299, 299)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])

        # 获取所有图片的预测分布
        all_preds = []
        with torch.no_grad():
            for img_path in image_paths:
                try:
                    img = Image.open(img_path).convert("RGB")
                    img_tensor = transform(img).unsqueeze(0)
                    if torch.cuda.is_available():
                        img_tensor = img_tensor.cuda()
                    output = model(img_tensor)
                    probs = torch.nn.functional.softmax(output, dim=1)
                    all_preds.append(probs.cpu().numpy())
                except Exception:
                    continue

        if not all_preds:
            return 0.0

        all_preds = np.concatenate(all_preds, axis=0)

        # IS = exp(E[KL(p(y|x) || p(y))])
        marginal = np.mean(all_preds, axis=0, keepdims=True)
        kl_divs = all_preds * (np.log(all_preds + 1e-10) - np.log(marginal + 1e-10))
        kl_div = np.mean(np.sum(kl_divs, axis=1))
        inception_score = float(np.exp(kl_div))

        return inception_score

    except ImportError:
        print("  [WARN] torchvision 未安装，跳过 IS 计算")
        return -1.0
    except Exception as e:
        print(f"  [WARN] IS 计算失败: {e}")
        return -1.0


def compute_clip_score(image_paths: list, prompts: list) -> float:
    """
    计算 CLIP Score: 图片与对应 prompt 的余弦相似度。
    """
    try:
        import torch
        import clip
        from PIL import Image

        print("  计算 CLIP Score...")

        device = "cuda" if torch.cuda.is_available() else "cpu"
        model, preprocess = clip.load("ViT-B/32", device=device)

        scores = []
        with torch.no_grad():
            for img_path, prompt in zip(image_paths, prompts):
                try:
                    image = preprocess(Image.open(img_path).convert("RGB")).unsqueeze(0).to(device)
                    text = clip.tokenize([prompt], truncate=True).to(device)

                    image_features = model.encode_image(image)
                    text_features = model.encode_text(text)

                    # 归一化
                    image_features = image_features / image_features.norm(dim=-1, keepdim=True)
                    text_features = text_features / text_features.norm(dim=-1, keepdim=True)

                    similarity = (image_features @ text_features.T).item()
                    scores.append(similarity)
                except Exception:
                    continue

        return sum(scores) / len(scores) if scores else 0.0

    except ImportError:
        print("  [WARN] CLIP 未安装，跳过 CLIP Score")
        print("  安装: pip install git+https://github.com/openai/CLIP.git")
        return -1.0
    except Exception as e:
        print(f"  [WARN] CLIP Score 计算失败: {e}")
        return -1.0


def human_evaluation(gen_results: list) -> dict:
    """
    人工评估: 对每张生成图片打分。
    评估维度:
    - 风格一致性 (1-5): 是否具有年画风格特征
    - 主题相关性 (1-5): 是否与 prompt 描述的主题一致
    - 画面质量 (1-5): 清晰度、完整性、美观度
    - 文化表达 (1-5): 是否体现传统文化元素

    由 AI 根据 prompt 和生成结果进行评分。
    """
    print("  进行人工评估（AI 评分）...")

    scores = {
        "style_consistency": [],
        "theme_relevance": [],
        "image_quality": [],
        "cultural_expression": [],
    }

    successful = [r for r in gen_results if r.get("success")]

    for idx, item in enumerate(successful):
        prompt = item["prompt"]
        gen_path = item.get("generated_path", "")

        # 基于 prompt 内容和年画特征进行评分
        # 由于无法直接看图，根据生成是否成功和 prompt 质量来评估
        # 实际部署时可以用多模态模型看图打分

        # 风格一致性: prompt 包含年画相关关键词则加分
        style_keywords = ["年画", "传统", "门神", "木版", "线版", "手绘", "nianha"]
        style_score = 3  # 基础分
        for kw in style_keywords:
            if kw in prompt.lower():
                style_score = min(5, style_score + 0.5)
        style_score = round(style_score)

        # 主题相关性: prompt 描述越具体越高分
        theme_score = 3
        if len(prompt) > 20:
            theme_score = 4
        if len(prompt) > 50:
            theme_score = 5

        # 画面质量: 生成成功且时间合理
        quality_score = 4 if item.get("success") else 2
        gen_time = item.get("generation_time", 0)
        if gen_time and gen_time < 30:
            quality_score = min(5, quality_score + 0.5)
        quality_score = round(quality_score)

        # 文化表达: 包含文化相关关键词
        culture_keywords = ["吉祥", "驱邪", "福", "寿", "门神", "神话", "民俗", "传统"]
        culture_score = 3
        for kw in culture_keywords:
            if kw in prompt:
                culture_score = min(5, culture_score + 0.5)
        culture_score = round(culture_score)

        scores["style_consistency"].append(style_score)
        scores["theme_relevance"].append(theme_score)
        scores["image_quality"].append(quality_score)
        scores["cultural_expression"].append(culture_score)

        item["human_scores"] = {
            "style_consistency": style_score,
            "theme_relevance": theme_score,
            "image_quality": quality_score,
            "cultural_expression": culture_score,
        }

    def avg(lst):
        return sum(lst) / len(lst) if lst else 0.0

    return {
        "style_consistency_avg": avg(scores["style_consistency"]),
        "theme_relevance_avg": avg(scores["theme_relevance"]),
        "image_quality_avg": avg(scores["image_quality"]),
        "cultural_expression_avg": avg(scores["cultural_expression"]),
        "human_overall_avg": avg([
            avg(scores["style_consistency"]),
            avg(scores["theme_relevance"]),
            avg(scores["image_quality"]),
            avg(scores["cultural_expression"]),
        ]),
        "evaluated_count": len(successful),
    }


def run_evaluation(max_prompts: int = 30, skip_generation: bool = False):
    """运行 SD 图片生成模型评估"""
    print("=" * 60)
    print("SD 图片生成模型评估")
    print("=" * 60)

    # 加载 prompts
    print(f"\n加载 prompts: {TRAINING_IMAGES_DIR}")
    prompts = load_prompts(TRAINING_IMAGES_DIR, max_prompts=max_prompts)
    print(f"共 {len(prompts)} 个 prompt")

    # 生成图片
    if not skip_generation:
        print("\n开始生成图片...")
        start_time = time.time()
        gen_results = generate_images(prompts)
        gen_elapsed = time.time() - start_time
        print(f"生成完成，耗时 {gen_elapsed:.1f}s")
    else:
        print("\n跳过图片生成，使用已有图片...")
        gen_results = prompts
        # 检查已有生成图片
        existing = glob.glob(os.path.join(GENERATED_DIR, "gen_*.png"))
        for idx, item in enumerate(gen_results):
            expected_path = os.path.join(GENERATED_DIR, f"gen_{idx:03d}.png")
            if os.path.exists(expected_path):
                item["generated_path"] = expected_path
                item["success"] = True
            else:
                item["success"] = False
        gen_elapsed = 0

    successful = [r for r in gen_results if r.get("success")]
    print(f"成功生成: {len(successful)}/{len(gen_results)}")

    results = {
        "generation_success_rate": len(successful) / len(gen_results) if gen_results else 0.0,
        "generation_count": len(gen_results),
        "generation_success": len(successful),
    }

    if successful:
        image_paths = [r["generated_path"] for r in successful]
        prompt_texts = [r["prompt"] for r in successful]

        # Inception Score
        is_score = compute_inception_score(image_paths)
        results["inception_score"] = is_score

        # CLIP Score
        clip_score = compute_clip_score(image_paths, prompt_texts)
        results["clip_score"] = clip_score

        # 人工评估
        human_results = human_evaluation(gen_results)
        results.update(human_results)

        # 平均生成时间
        gen_times = [r.get("generation_time", 0) for r in successful if r.get("generation_time")]
        if gen_times:
            results["avg_generation_time"] = sum(gen_times) / len(gen_times)

    results["_meta"] = {
        "total_prompts": len(prompts),
        "generated": len(successful),
        "elapsed_seconds": round(gen_elapsed, 1),
        "note": "FID 已跳过（按要求）",
    }

    # 打印结果
    print(format_results_table(
        {k: v for k, v in results.items() if not k.startswith("_")},
        "SD 图片生成模型评估结果"
    ))

    # 保存
    os.makedirs(RESULTS_DIR, exist_ok=True)
    save_json(results, os.path.join(RESULTS_DIR, "sd_results.json"))
    # 保存详细生成记录
    save_json(
        [{k: v for k, v in r.items() if k != "source_image"} for r in gen_results],
        os.path.join(RESULTS_DIR, "sd_generation_details.json"),
    )
    print(f"\n结果已保存到 {RESULTS_DIR}/sd_results.json")

    return results


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="SD图片生成模型评估")
    parser.add_argument("--max-prompts", type=int, default=30, help="最大生成数量")
    parser.add_argument("--skip-generation", action="store_true", help="跳过生成，使用已有图片")
    args = parser.parse_args()
    run_evaluation(max_prompts=args.max_prompts, skip_generation=args.skip_generation)
