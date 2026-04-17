#!/usr/bin/env python3
"""
年画智能系统 - 统一评估入口
汇总运行所有评估模块，生成综合报告
"""

import os
import sys
import json
import time
import argparse
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

RESULTS_DIR = "/root/autodl-tmp/app/evaluation/results"


def run_all(args):
    """运行所有评估"""
    print("=" * 70)
    print("  年画智能系统 - 综合性能评估")
    print(f"  时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)

    all_results = {}
    total_start = time.time()

    # 1. 推荐模型
    if not args.skip_recommend:
        print("\n\n" + "=" * 70)
        print("  [1/5] 推荐模型评估")
        print("=" * 70)
        try:
            from eval_recommend import run_evaluation as eval_recommend
            all_results["recommend"] = eval_recommend(max_samples=args.max_samples)
        except Exception as e:
            print(f"[ERROR] 推荐模型评估失败: {e}")
            import traceback; traceback.print_exc()
            all_results["recommend"] = {"error": str(e)}
    else:
        print("\n[SKIP] 推荐模型评估")

    # 2. 用户画像
    if not args.skip_tagging:
        print("\n\n" + "=" * 70)
        print("  [2/5] 用户画像模型评估")
        print("=" * 70)
        try:
            from eval_user_tagging import run_evaluation as eval_tagging
            all_results["user_tagging"] = eval_tagging(
                max_samples=args.max_samples,
                test_size=args.tagging_test_size,
            )
        except Exception as e:
            print(f"[ERROR] 用户画像评估失败: {e}")
            import traceback; traceback.print_exc()
            all_results["user_tagging"] = {"error": str(e)}
    else:
        print("\n[SKIP] 用户画像模型评估")

    # 3. QA 问答
    if not args.skip_qa:
        print("\n\n" + "=" * 70)
        print("  [3/5] QA 问答模型评估")
        print("=" * 70)
        try:
            from eval_qa import run_evaluation as eval_qa
            all_results["qa"] = eval_qa(max_samples=args.max_samples)
        except Exception as e:
            print(f"[ERROR] QA评估失败: {e}")
            import traceback; traceback.print_exc()
            all_results["qa"] = {"error": str(e)}
    else:
        print("\n[SKIP] QA 问答模型评估")

    # 4. SD 图片生成
    if not args.skip_sd:
        print("\n\n" + "=" * 70)
        print("  [4/5] SD 图片生成模型评估")
        print("=" * 70)
        try:
            from eval_sd import run_evaluation as eval_sd
            all_results["sd"] = eval_sd(
                max_prompts=args.sd_prompts,
                skip_generation=args.sd_skip_gen,
            )
        except Exception as e:
            print(f"[ERROR] SD评估失败: {e}")
            import traceback; traceback.print_exc()
            all_results["sd"] = {"error": str(e)}
    else:
        print("\n[SKIP] SD 图片生成模型评估")

    # 5. Agent 端到端
    if not args.skip_agent:
        print("\n\n" + "=" * 70)
        print("  [5/5] Agent 端到端评估")
        print("=" * 70)
        try:
            from eval_agent import run_evaluation as eval_agent
            all_results["agent"] = eval_agent()
        except Exception as e:
            print(f"[ERROR] Agent评估失败: {e}")
            import traceback; traceback.print_exc()
            all_results["agent"] = {"error": str(e)}
    else:
        print("\n[SKIP] Agent 端到端评估")

    total_elapsed = time.time() - total_start

    # 生成综合报告
    print("\n\n" + "=" * 70)
    print("  生成综合报告")
    print("=" * 70)

    report = generate_report(all_results, total_elapsed)

    # 保存
    os.makedirs(RESULTS_DIR, exist_ok=True)

    save_path = os.path.join(RESULTS_DIR, "full_evaluation.json")
    with open(save_path, "w", encoding="utf-8") as f:
        json.dump(all_results, f, ensure_ascii=False, indent=2)
    print(f"\n综合结果 JSON: {save_path}")

    report_path = os.path.join(RESULTS_DIR, "evaluation_report.md")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(report)
    print(f"评估报告 MD:   {report_path}")

    print(f"\n总耗时: {total_elapsed:.1f}s ({total_elapsed/60:.1f}min)")
    print("=" * 70)


def generate_report(all_results: dict, elapsed: float) -> str:
    """生成 Markdown 格式的评估报告"""
    lines = []
    lines.append("# 年画智能系统 - 综合性能评估报告\n")
    lines.append(f"评估时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"总耗时: {elapsed:.1f}s\n")

    # 推荐模型
    if "recommend" in all_results and "error" not in all_results["recommend"]:
        r = all_results["recommend"]
        lines.append("## 1. 推荐模型评估\n")
        lines.append("| 指标 | 值 |")
        lines.append("|------|-----|")
        for k in ["precision@3", "precision@5", "recall@3", "recall@5",
                   "f1@3", "f1@5", "ndcg@3", "ndcg@5", "mrr",
                   "hit_rate@3", "hit_rate@5", "coverage", "diversity"]:
            if k in r:
                lines.append(f"| {k} | {r[k]:.4f} |")
        meta = r.get("_meta", {})
        lines.append(f"\n评估样本: {meta.get('evaluated', '?')}/{meta.get('total_samples', '?')}\n")

    # 用户画像
    if "user_tagging" in all_results and "error" not in all_results["user_tagging"]:
        r = all_results["user_tagging"]
        lines.append("## 2. 用户画像模型评估\n")
        lines.append("| 指标 | 值 |")
        lines.append("|------|-----|")
        for k in ["overall_precision", "overall_recall", "overall_f1",
                   "exact_match_ratio", "hamming_loss",
                   "style_precision", "style_recall", "style_f1",
                   "subject_precision", "subject_recall", "subject_f1"]:
            if k in r:
                lines.append(f"| {k} | {r[k]:.4f} |")
        meta = r.get("_meta", {})
        lines.append(f"\n评估样本: {meta.get('evaluated', '?')}/{meta.get('total_samples', '?')}\n")

    # QA 问答
    if "qa" in all_results and "error" not in all_results["qa"]:
        r = all_results["qa"]
        lines.append("## 3. QA 问答模型评估\n")
        lines.append("| 指标 | 值 |")
        lines.append("|------|-----|")
        for k in ["bleu_1", "bleu_4", "rouge_1", "rouge_2", "rouge_l",
                   "bertscore_precision", "bertscore_recall", "bertscore_f1"]:
            if k in r:
                lines.append(f"| {k} | {r[k]:.4f} |")
        meta = r.get("_meta", {})
        lines.append(f"\n评估样本: {meta.get('evaluated', '?')}/{meta.get('total_samples', '?')}\n")

    # SD 图片生成
    if "sd" in all_results and "error" not in all_results["sd"]:
        r = all_results["sd"]
        lines.append("## 4. SD 图片生成模型评估\n")
        lines.append("| 指标 | 值 |")
        lines.append("|------|-----|")
        for k in ["generation_success_rate", "inception_score", "clip_score",
                   "style_consistency_avg", "theme_relevance_avg",
                   "image_quality_avg", "cultural_expression_avg",
                   "human_overall_avg", "avg_generation_time"]:
            if k in r:
                v = r[k]
                lines.append(f"| {k} | {v:.4f} |" if isinstance(v, float) else f"| {k} | {v} |")
        lines.append(f"\n注: FID 已跳过\n")

    # Agent 端到端
    if "agent" in all_results and "error" not in all_results["agent"]:
        r = all_results["agent"]
        lines.append("## 5. Agent 端到端评估\n")
        lines.append("| 指标 | 值 |")
        lines.append("|------|-----|")
        for k in ["task_completion_rate", "tool_call_precision",
                   "tool_call_recall", "tool_call_f1",
                   "avg_response_time", "max_response_time", "min_response_time"]:
            if k in r:
                v = r[k]
                lines.append(f"| {k} | {v:.4f} |" if isinstance(v, float) else f"| {k} | {v} |")

        # 分类别统计
        lines.append("\n### 分类别统计\n")
        lines.append("| 类别 | 完成率 | 平均响应时间 |")
        lines.append("|------|--------|-------------|")
        for k, v in r.items():
            if k.endswith("_完成率"):
                cat = k.replace("_完成率", "")
                time_key = f"{cat}_平均响应时间"
                time_val = r.get(time_key, 0)
                lines.append(f"| {cat} | {v:.2%} | {time_val:.2f}s |")

        lines.append(f"\n注: 消融实验已跳过\n")

    # 跳过的指标汇总
    lines.append("## 跳过的指标\n")
    lines.append("| 指标 | 原因 |")
    lines.append("|------|------|")
    lines.append("| FID | 客户要求可跳过 |")
    lines.append("| 消融实验 | 客户要求可跳过 |")
    lines.append("| 显著性检验 | 客户要求可跳过 |")
    lines.append("| 幻觉率 | 客户要求可跳过 |")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="年画智能系统 - 综合性能评估",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 运行全部评估
  python eval_runner.py

  # 快速测试（每模块最多10条）
  python eval_runner.py --max-samples 10

  # 只跑推荐和QA
  python eval_runner.py --skip-tagging --skip-sd --skip-agent

  # 跳过SD图片生成（耗时最长）
  python eval_runner.py --skip-sd
        """,
    )
    parser.add_argument("--max-samples", type=int, default=0,
                        help="每个模块最大评估样本数(0=全部)")
    parser.add_argument("--tagging-test-size", type=int, default=500,
                        help="用户画像测试集大小")
    parser.add_argument("--sd-prompts", type=int, default=30,
                        help="SD生成图片数量")
    parser.add_argument("--sd-skip-gen", action="store_true",
                        help="跳过SD图片生成，使用已有图片")
    parser.add_argument("--skip-recommend", action="store_true")
    parser.add_argument("--skip-tagging", action="store_true")
    parser.add_argument("--skip-qa", action="store_true")
    parser.add_argument("--skip-sd", action="store_true")
    parser.add_argument("--skip-agent", action="store_true")

    args = parser.parse_args()
    run_all(args)


if __name__ == "__main__":
    main()
