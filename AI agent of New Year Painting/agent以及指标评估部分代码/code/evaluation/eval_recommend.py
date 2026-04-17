#!/usr/bin/env python3
"""
年画智能系统 - 推荐模型评估 v3
改进:
1. 从推荐理由中提取风格信息（不只从括号内提取）
2. 模糊名称匹配（子串包含关系）
3. 主题/风格用 Precision/Recall/F1 替代 Jaccard
4. 新增 Theme Hit Rate / Style Hit Rate
"""

import os, sys, json, time, re
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import (
    call_llm, load_jsonl, save_json,
    parse_recommend_items, precision_at_k, recall_at_k, f1_at_k,
    ndcg_at_k, mrr, hit_rate_at_k, format_results_table,
)

VAL_DATA_PATH = "/root/autodl-tmp/LLaMA-Factory/data/qwen3_val.jsonl"
RESULTS_DIR = "/root/autodl-tmp/app/evaluation/results"

KNOWN_STYLES = {"半印半绘", "堆金沥粉", "套印", "手绘", "扑灰", "线版", "门画"}
KNOWN_THEMES = {"仕途高升", "历史典故", "吉祥寓意", "女性主题", "安康长寿",
                "文化传承", "生活场景", "神话民俗", "自然意象", "驱邪纳吉"}


def extract_user_query(messages):
    for msg in messages:
        if msg["role"] == "user":
            return msg["content"]
    return ""


def extract_gt_items(messages):
    for msg in messages:
        if msg["role"] == "assistant":
            return parse_recommend_items(msg["content"])
    return []


def extract_style_theme(text):
    """从推荐文本中提取风格和主题 - 增强版：同时从括号和推荐理由中提取"""
    styles = set()
    themes = set()
    
    # 方法1: 从 风格:xxx 格式提取
    for m in re.finditer(r"风格[:：]\s*([^,，)）\n]+)", text):
        s = m.group(1).strip()
        if s and s != "未知风格" and s != "未知":
            styles.add(s)
    for m in re.finditer(r"主题[:：]\s*([^,，)）\n]+)", text):
        t = m.group(1).strip()
        if t and t != "未知主题" and t != "未知":
            themes.add(t)
    
    # 方法2: 从推荐理由中用已知标签匹配
    reason_text = ""
    if "推荐理由" in text:
        reason_text = text[text.index("推荐理由"):]
    # 也检查全文
    full_text = text
    
    for style in KNOWN_STYLES:
        if style in reason_text or style in full_text:
            styles.add(style)
    for theme in KNOWN_THEMES:
        if theme in reason_text or theme in full_text:
            themes.add(theme)
    
    return styles, themes


def fuzzy_match_items(pred_items, gt_items):
    """模糊名称匹配：子串包含关系"""
    matched = 0
    matched_gt = set()
    for pi in pred_items:
        for j, gi in enumerate(gt_items):
            if j in matched_gt:
                continue
            # 精确匹配
            if pi == gi:
                matched += 1
                matched_gt.add(j)
                break
            # 子串包含
            if len(pi) >= 2 and len(gi) >= 2:
                if pi in gi or gi in pi:
                    matched += 1
                    matched_gt.add(j)
                    break
    return matched


def compute_diversity(pred_text):
    """推荐列表内部多样性"""
    items_meta = []
    pattern = r"《([^》]+)》[^(（]*[(（]([^)）]+)[)）]"
    for match in re.finditer(pattern, pred_text):
        meta_str = match.group(2)
        style_m = re.search(r"风格[:：]\s*([^,，]+)", meta_str)
        theme_m = re.search(r"主题[:：]\s*([^,，)）]+)", meta_str)
        items_meta.append({
            "style": style_m.group(1).strip() if style_m else "",
            "theme": theme_m.group(1).strip() if theme_m else "",
        })
    if len(items_meta) < 2:
        return 0.0
    total_dist = 0.0
    count = 0
    for i in range(len(items_meta)):
        for j in range(i + 1, len(items_meta)):
            set_i = {items_meta[i]["style"], items_meta[i]["theme"]} - {"", "未知风格", "未知"}
            set_j = {items_meta[j]["style"], items_meta[j]["theme"]} - {"", "未知风格", "未知"}
            if not set_i and not set_j:
                continue
            intersection = len(set_i & set_j)
            union = len(set_i | set_j)
            total_dist += 1.0 - (intersection / union) if union > 0 else 0.0
            count += 1
    return total_dist / count if count > 0 else 0.0


def run_evaluation(max_samples=0):
    print("=" * 60)
    print("推荐模型评估 v3")
    print("=" * 60)

    print(f"\n加载验证数据: {VAL_DATA_PATH}")
    val_data = load_jsonl(VAL_DATA_PATH)
    print(f"共 {len(val_data)} 条样本")

    if max_samples > 0:
        val_data = val_data[:max_samples]
        print(f"限制评估前 {max_samples} 条")

    k_values = [3, 5]
    
    # 精确匹配指标
    exact_metrics = {f"precision@{k}": [] for k in k_values}
    exact_metrics.update({f"recall@{k}": [] for k in k_values})
    exact_metrics.update({f"f1@{k}": [] for k in k_values})
    exact_metrics.update({f"ndcg@{k}": [] for k in k_values})
    exact_metrics.update({f"hit_rate@{k}": [] for k in k_values})
    exact_metrics["mrr"] = []
    
    # 模糊匹配指标
    fuzzy_metrics = {f"fuzzy_precision@{k}": [] for k in k_values}
    fuzzy_metrics.update({f"fuzzy_recall@{k}": [] for k in k_values})
    fuzzy_metrics.update({f"fuzzy_hit_rate@{k}": [] for k in k_values})

    # 风格/主题匹配
    style_precisions = []
    style_recalls = []
    theme_precisions = []
    theme_recalls = []
    style_hit_rates = []  # at least 1 style overlap
    theme_hit_rates = []  # at least 1 theme overlap

    all_recommended_items = set()
    all_gt_items = set()
    diversity_scores = []
    failed = 0
    sample_results = []

    start_time = time.time()

    for idx, sample in enumerate(val_data):
        messages = sample["messages"]
        user_query = extract_user_query(messages)
        gt_items = extract_gt_items(messages)

        if not user_query or not gt_items:
            failed += 1
            continue

        all_gt_items.update(gt_items)

        # GT 风格/主题
        gt_text = ""
        for msg in messages:
            if msg["role"] == "assistant":
                gt_text = msg["content"]
                break
        gt_styles, gt_themes = extract_style_theme(gt_text)

        print(f"\r  评估进度: {idx+1}/{len(val_data)}", end="", flush=True)
        pred_text = call_llm("recommend", user_query)

        if pred_text is None:
            failed += 1
            continue

        pred_items = parse_recommend_items(pred_text)
        all_recommended_items.update(pred_items)

        # === 精确匹配指标 ===
        for k in k_values:
            exact_metrics[f"precision@{k}"].append(precision_at_k(pred_items, gt_items, k))
            exact_metrics[f"recall@{k}"].append(recall_at_k(pred_items, gt_items, k))
            exact_metrics[f"f1@{k}"].append(f1_at_k(pred_items, gt_items, k))
            exact_metrics[f"ndcg@{k}"].append(ndcg_at_k(pred_items, gt_items, k))
            exact_metrics[f"hit_rate@{k}"].append(hit_rate_at_k(pred_items, gt_items, k))
        exact_metrics["mrr"].append(mrr(pred_items, gt_items))
        
        # === 模糊名称匹配指标 ===
        fuzzy_matched = fuzzy_match_items(pred_items, gt_items)
        for k in k_values:
            top_k_pred = pred_items[:k]
            fuzz_k = fuzzy_match_items(top_k_pred, gt_items)
            fp = fuzz_k / len(top_k_pred) if top_k_pred else 0.0
            fr = fuzz_k / len(gt_items) if gt_items else 0.0
            fuzzy_metrics[f"fuzzy_precision@{k}"].append(fp)
            fuzzy_metrics[f"fuzzy_recall@{k}"].append(fr)
            fuzzy_metrics[f"fuzzy_hit_rate@{k}"].append(1.0 if fuzz_k > 0 else 0.0)

        # === 风格/主题匹配 ===
        pred_styles, pred_themes = extract_style_theme(pred_text)
        
        # Style precision/recall
        if pred_styles and gt_styles:
            sp = len(pred_styles & gt_styles) / len(pred_styles)
            sr = len(pred_styles & gt_styles) / len(gt_styles)
            style_precisions.append(sp)
            style_recalls.append(sr)
        elif not pred_styles and not gt_styles:
            style_precisions.append(1.0)
            style_recalls.append(1.0)
        else:
            style_precisions.append(0.0)
            style_recalls.append(0.0)
        
        style_hit_rates.append(1.0 if (pred_styles & gt_styles) else 0.0)
        
        # Theme precision/recall
        if pred_themes and gt_themes:
            tp = len(pred_themes & gt_themes) / len(pred_themes)
            tr = len(pred_themes & gt_themes) / len(gt_themes)
            theme_precisions.append(tp)
            theme_recalls.append(tr)
        elif not pred_themes and not gt_themes:
            theme_precisions.append(1.0)
            theme_recalls.append(1.0)
        else:
            theme_precisions.append(0.0)
            theme_recalls.append(0.0)
        
        theme_hit_rates.append(1.0 if (pred_themes & gt_themes) else 0.0)

        # 多样性
        div = compute_diversity(pred_text)
        if div > 0:
            diversity_scores.append(div)

        sample_results.append({
            "index": idx,
            "gt_items": gt_items,
            "pred_items": pred_items,
            "fuzzy_matched": fuzzy_matched,
            "gt_styles": sorted(gt_styles),
            "gt_themes": sorted(gt_themes),
            "pred_styles": sorted(pred_styles),
            "pred_themes": sorted(pred_themes),
            "style_overlap": sorted(pred_styles & gt_styles) if pred_styles and gt_styles else [],
            "theme_overlap": sorted(pred_themes & gt_themes) if pred_themes and gt_themes else [],
            "pred_text_snippet": pred_text[:400],
        })

    elapsed = time.time() - start_time
    print(f"\n\n评估完成，耗时 {elapsed:.1f}s，失败 {failed} 条\n")

    def avg(lst):
        return sum(lst) / len(lst) if lst else 0.0
    
    def f1(p, r):
        return 2 * p * r / (p + r) if (p + r) > 0 else 0.0

    results = {}
    
    # 精确匹配
    for key, values in exact_metrics.items():
        results[key] = avg(values)
    
    # 模糊匹配
    for key, values in fuzzy_metrics.items():
        results[key] = avg(values)
    
    # 风格匹配
    results["style_precision"] = avg(style_precisions)
    results["style_recall"] = avg(style_recalls)
    results["style_f1"] = f1(avg(style_precisions), avg(style_recalls))
    results["style_hit_rate"] = avg(style_hit_rates)
    
    # 主题匹配
    results["theme_precision"] = avg(theme_precisions)
    results["theme_recall"] = avg(theme_recalls)
    results["theme_f1"] = f1(avg(theme_precisions), avg(theme_recalls))
    results["theme_hit_rate"] = avg(theme_hit_rates)
    
    # Coverage & Diversity
    results["coverage"] = len(all_recommended_items) / len(all_gt_items) if all_gt_items else 0.0
    results["coverage_unique_items"] = len(all_recommended_items)
    results["gt_unique_items"] = len(all_gt_items)
    results["diversity"] = avg(diversity_scores)

    results["_meta"] = {
        "total_samples": len(val_data),
        "evaluated": len(val_data) - failed,
        "failed": failed,
        "elapsed_seconds": round(elapsed, 1),
    }

    # 打印结果
    print("=" * 50)
    print("精确匹配指标 (作品名严格匹配)")
    print("=" * 50)
    for k in k_values:
        pk = "precision@%d" % k
        rk = "recall@%d" % k
        fk = "f1@%d" % k
        print("  Precision@%d: %.4f" % (k, results[pk]))
        print("  Recall@%d:    %.4f" % (k, results[rk]))
        print("  F1@%d:        %.4f" % (k, results[fk]))
    print("  MRR:           %.4f" % results["mrr"])
    print()
    print("=" * 50)
    print("模糊匹配指标 (作品名子串匹配)")
    print("=" * 50)
    for k in k_values:
        fpk = "fuzzy_precision@%d" % k
        frk = "fuzzy_recall@%d" % k
        fhk = "fuzzy_hit_rate@%d" % k
        print("  Fuzzy Precision@%d: %.4f" % (k, results[fpk]))
        print("  Fuzzy Recall@%d:    %.4f" % (k, results[frk]))
        print("  Fuzzy Hit Rate@%d:  %.4f" % (k, results[fhk]))
    print()
    print("=" * 50)
    print("语义匹配指标 (风格/主题属性)")
    print("=" * 50)
    print("  Style Precision:  %.4f" % results["style_precision"])
    print("  Style Recall:     %.4f" % results["style_recall"])
    print("  Style F1:         %.4f" % results["style_f1"])
    print("  Style Hit Rate:   %.4f" % results["style_hit_rate"])
    print("  Theme Precision:  %.4f" % results["theme_precision"])
    print("  Theme Recall:     %.4f" % results["theme_recall"])
    print("  Theme F1:         %.4f" % results["theme_f1"])
    print("  Theme Hit Rate:   %.4f" % results["theme_hit_rate"])
    print()
    print("=" * 50)
    print("其他指标")
    print("=" * 50)
    print("  Coverage:   %.2f%%" % (results["coverage"] * 100))
    print("  Diversity:  %.4f" % results["diversity"])

    os.makedirs(RESULTS_DIR, exist_ok=True)
    save_json(results, os.path.join(RESULTS_DIR, "recommend_results.json"))
    save_json(sample_results[:50], os.path.join(RESULTS_DIR, "recommend_samples.json"))
    print(f"\n结果已保存到 {RESULTS_DIR}/recommend_results.json")

    return results


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-samples", type=int, default=0)
    args = parser.parse_args()
    run_evaluation(max_samples=args.max_samples)
