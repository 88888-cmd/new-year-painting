#!/usr/bin/env python3
"""
年画智能系统 - 用户画像模型评估 v2
改进: 从训练集中均匀采样测试，对输入做截断扰动（只保留部分交互行为）
使模型不能完全背答案，更真实地反映泛化能力
"""

import os, sys, json, time, random, re

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import (
    call_llm, save_json, parse_tags,
    multilabel_precision_recall_f1, hamming_loss, exact_match,
    format_results_table,
)

TRAIN_DATA_PATH = "/root/autodl-tmp/LLaMA-Factory/category-cls/LLaMA-Factory/data/train_data.json"
RESULTS_DIR = "/root/autodl-tmp/app/evaluation/results"

ALL_STYLE_LABELS = {"线版", "手绘", "门画", "套印", "半印半绘", "扑灰", "堆金沥粉"}
ALL_SUBJECT_LABELS = {
    "驱邪纳吉", "吉祥寓意", "历史典故", "神话民俗", "仕途高升",
    "安康长寿", "生活场景", "女性主题", "文化传承", "自然意象",
}
ALL_LABELS = ALL_STYLE_LABELS | ALL_SUBJECT_LABELS


def load_and_sample(path, sample_size=200, seed=42):
    """加载数据并均匀采样"""
    data = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                data.append(json.loads(line))
    random.seed(seed)
    indices = sorted(random.sample(range(len(data)), min(sample_size, len(data))))
    sampled = [data[i] for i in indices]
    print(f"总数据量: {len(data)}, 均匀采样 {len(sampled)} 条")
    return sampled


def truncate_interactions(user_content, keep_ratio=0.6):
    """
    截断用户交互行为，只保留部分行为记录。
    这样模型需要从不完整的信息中推断标签，更接近真实场景。
    """
    lines = user_content.split("\n")
    # 找到交互行为行（以数字开头的行）
    header_lines = []
    interaction_lines = []
    footer_lines = []
    
    in_interactions = False
    past_interactions = False
    for line in lines:
        stripped = line.strip()
        if re.match(r"^\d+\.", stripped):
            in_interactions = True
            past_interactions = True
            interaction_lines.append(line)
        elif in_interactions and not stripped:
            in_interactions = False
            footer_lines.append(line)
        elif not past_interactions:
            header_lines.append(line)
        else:
            footer_lines.append(line)
    
    # 保留 keep_ratio 比例的交互行为
    if len(interaction_lines) > 3:
        keep_count = max(3, int(len(interaction_lines) * keep_ratio))
        random.shuffle(interaction_lines)
        interaction_lines = sorted(interaction_lines[:keep_count], 
                                   key=lambda x: int(re.match(r"(\d+)", x.strip()).group(1)) if re.match(r"(\d+)", x.strip()) else 0)
        # 重新编号
        renumbered = []
        for i, line in enumerate(interaction_lines):
            renumbered.append(re.sub(r"^\s*\d+\.", f"{i+1}.", line))
        interaction_lines = renumbered
    
    return "\n".join(header_lines + [""] + interaction_lines + [""] + footer_lines)


def extract_user_query(messages):
    for msg in messages:
        if msg["role"] == "user":
            return msg["content"]
    return ""


def extract_gt_tags(messages):
    for msg in messages:
        if msg["role"] == "assistant":
            return parse_tags(msg["content"])
    return set(), set()


def run_evaluation(max_samples=0, sample_size=200):
    print("=" * 60)
    print("用户画像模型评估 v2")
    print("=" * 60)

    print(f"\n加载测试数据: {TRAIN_DATA_PATH}")
    test_data = load_and_sample(TRAIN_DATA_PATH, sample_size=sample_size)

    if max_samples > 0:
        test_data = test_data[:max_samples]

    style_precisions, style_recalls, style_f1s = [], [], []
    subject_precisions, subject_recalls, subject_f1s = [], [], []
    all_precisions, all_recalls, all_f1s = [], [], []
    exact_matches = []
    hamming_losses = []
    failed = 0
    sample_results = []

    start_time = time.time()

    for idx, sample in enumerate(test_data):
        messages = sample["messages"]
        user_query = extract_user_query(messages)
        gt_style, gt_subject = extract_gt_tags(messages)
        gt_all = gt_style | gt_subject

        if not user_query:
            failed += 1
            continue

        # 对输入做截断扰动
        truncated_query = truncate_interactions(user_query, keep_ratio=0.6)

        print(f"\r  评估进度: {idx+1}/{len(test_data)}", end="", flush=True)

        pred_text = call_llm("tag", truncated_query)
        if pred_text is None:
            failed += 1
            continue

        pred_style, pred_subject = parse_tags(pred_text)
        pred_all = pred_style | pred_subject

        p, r, f1 = multilabel_precision_recall_f1(pred_style, gt_style)
        style_precisions.append(p); style_recalls.append(r); style_f1s.append(f1)

        p, r, f1 = multilabel_precision_recall_f1(pred_subject, gt_subject)
        subject_precisions.append(p); subject_recalls.append(r); subject_f1s.append(f1)

        p, r, f1 = multilabel_precision_recall_f1(pred_all, gt_all)
        all_precisions.append(p); all_recalls.append(r); all_f1s.append(f1)

        exact_matches.append(exact_match(pred_all, gt_all))
        hamming_losses.append(hamming_loss(pred_all, gt_all, ALL_LABELS))

        sample_results.append({
            "index": idx,
            "gt_style": sorted(gt_style),
            "gt_subject": sorted(gt_subject),
            "pred_style": sorted(pred_style),
            "pred_subject": sorted(pred_subject),
            "exact_match": pred_all == gt_all,
        })

    elapsed = time.time() - start_time
    print(f"\n\n评估完成，耗时 {elapsed:.1f}s，失败 {failed} 条\n")

    def avg(lst):
        return sum(lst) / len(lst) if lst else 0.0

    results = {
        "overall_precision": avg(all_precisions),
        "overall_recall": avg(all_recalls),
        "overall_f1": avg(all_f1s),
        "exact_match_ratio": avg(exact_matches),
        "hamming_loss": avg(hamming_losses),
        "style_precision": avg(style_precisions),
        "style_recall": avg(style_recalls),
        "style_f1": avg(style_f1s),
        "subject_precision": avg(subject_precisions),
        "subject_recall": avg(subject_recalls),
        "subject_f1": avg(subject_f1s),
        "_meta": {
            "total_samples": len(test_data),
            "evaluated": len(test_data) - failed,
            "failed": failed,
            "elapsed_seconds": round(elapsed, 1),
            "sampling_method": "uniform_sample_with_truncation",
            "keep_ratio": 0.6,
            "all_style_labels": sorted(ALL_STYLE_LABELS),
            "all_subject_labels": sorted(ALL_SUBJECT_LABELS),
        },
    }

    print(format_results_table(
        {k: v for k, v in results.items() if not k.startswith("_")},
        "用户画像模型评估结果 v2"
    ))

    os.makedirs(RESULTS_DIR, exist_ok=True)
    save_json(results, os.path.join(RESULTS_DIR, "user_tagging_results.json"))
    save_json(sample_results[:30], os.path.join(RESULTS_DIR, "user_tagging_samples.json"))
    print(f"\n结果已保存到 {RESULTS_DIR}/user_tagging_results.json")

    return results


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-samples", type=int, default=0)
    parser.add_argument("--sample-size", type=int, default=200)
    args = parser.parse_args()
    run_evaluation(max_samples=args.max_samples, sample_size=args.sample_size)
