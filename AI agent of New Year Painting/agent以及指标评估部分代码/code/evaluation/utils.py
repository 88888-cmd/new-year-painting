#!/usr/bin/env python3
"""
年画智能系统 - 评估公共工具模块
"""

import json
import re
import math
import requests
import time
from typing import List, Dict, Set, Tuple, Optional
from collections import Counter

# LLM Server 配置
LLM_SERVER_URL = "http://localhost:8000"


def call_llm(model: str, prompt: str, max_length: int = 512, temperature: float = 0.1) -> Optional[str]:
    """调用 LLM Server 推理接口，失败重试3次"""
    for attempt in range(3):
        try:
            resp = requests.post(
                f"{LLM_SERVER_URL}/inference",
                json={
                    "model": model,
                    "prompt": prompt,
                    "max_length": max_length,
                    "temperature": temperature,
                },
                timeout=120,
            )
            result = resp.json()
            if result.get("success"):
                return result["result"]
            else:
                print(f"  [WARN] LLM返回错误: {result.get('error')}")
        except Exception as e:
            print(f"  [WARN] 调用失败(第{attempt+1}次): {e}")
            time.sleep(2)
    return None


def load_jsonl(path: str) -> List[dict]:
    """读取 jsonl 文件"""
    data = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                data.append(json.loads(line))
    return data


def save_json(obj, path: str):
    """保存 JSON 文件"""
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)


# ========== 推荐指标相关 ==========

def parse_recommend_items(text: str) -> List[str]:
    """
    从推荐模型输出中解析作品名列表。
    匹配 《xxx》 格式的作品名。
    """
    items = re.findall(r"《([^》]+)》", text)
    # 去重但保持顺序
    seen = set()
    result = []
    for item in items:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


def precision_at_k(predicted: List[str], ground_truth: List[str], k: int) -> float:
    """Precision@K"""
    pred_k = predicted[:k]
    if not pred_k:
        return 0.0
    gt_set = set(ground_truth)
    hits = sum(1 for p in pred_k if p in gt_set)
    return hits / len(pred_k)


def recall_at_k(predicted: List[str], ground_truth: List[str], k: int) -> float:
    """Recall@K"""
    pred_k = predicted[:k]
    if not ground_truth:
        return 0.0
    gt_set = set(ground_truth)
    hits = sum(1 for p in pred_k if p in gt_set)
    return hits / len(gt_set)


def f1_at_k(predicted: List[str], ground_truth: List[str], k: int) -> float:
    """F1@K"""
    p = precision_at_k(predicted, ground_truth, k)
    r = recall_at_k(predicted, ground_truth, k)
    if p + r == 0:
        return 0.0
    return 2 * p * r / (p + r)


def ndcg_at_k(predicted: List[str], ground_truth: List[str], k: int) -> float:
    """NDCG@K"""
    pred_k = predicted[:k]
    gt_set = set(ground_truth)

    # DCG
    dcg = 0.0
    for i, item in enumerate(pred_k):
        if item in gt_set:
            dcg += 1.0 / math.log2(i + 2)  # i+2 因为 log2(1)=0

    # IDCG: 假设前 min(k, len(gt)) 个全命中
    ideal_hits = min(k, len(gt_set))
    idcg = sum(1.0 / math.log2(i + 2) for i in range(ideal_hits))

    if idcg == 0:
        return 0.0
    return dcg / idcg


def mrr(predicted: List[str], ground_truth: List[str]) -> float:
    """MRR (Mean Reciprocal Rank) - 单个样本的 RR"""
    gt_set = set(ground_truth)
    for i, item in enumerate(predicted):
        if item in gt_set:
            return 1.0 / (i + 1)
    return 0.0


def hit_rate_at_k(predicted: List[str], ground_truth: List[str], k: int) -> float:
    """Hit Rate@K - 单个样本是否命中 (0 or 1)"""
    pred_k = predicted[:k]
    gt_set = set(ground_truth)
    return 1.0 if any(p in gt_set for p in pred_k) else 0.0


# ========== 用户画像指标相关 ==========

def parse_tags(text: str) -> Tuple[Set[str], Set[str]]:
    """
    从用户画像模型输出中解析风格标签和主体标签。
    格式: 风格标签: A, B; 主体标签: C, D
    """
    style_tags = set()
    subject_tags = set()

    # 匹配风格标签
    style_match = re.search(r"风格标签[:：]\s*([^;；\n]+)", text)
    if style_match:
        raw = style_match.group(1).strip()
        for tag in re.split(r"[,，、]", raw):
            tag = tag.strip()
            if tag and tag != "无":
                style_tags.add(tag)

    # 匹配主体标签
    subject_match = re.search(r"主体标签[:：]\s*([^;；\n]+)", text)
    if subject_match:
        raw = subject_match.group(1).strip()
        for tag in re.split(r"[,，、]", raw):
            tag = tag.strip()
            if tag and tag != "无":
                subject_tags.add(tag)

    return style_tags, subject_tags


def multilabel_precision_recall_f1(pred_set: Set[str], gt_set: Set[str]) -> Tuple[float, float, float]:
    """单样本的多标签 Precision / Recall / F1"""
    if not pred_set and not gt_set:
        return 1.0, 1.0, 1.0
    if not pred_set:
        return 0.0, 0.0, 0.0
    if not gt_set:
        return 0.0, 0.0, 0.0

    tp = len(pred_set & gt_set)
    p = tp / len(pred_set)
    r = tp / len(gt_set)
    f1 = 2 * p * r / (p + r) if (p + r) > 0 else 0.0
    return p, r, f1


def hamming_loss(pred_set: Set[str], gt_set: Set[str], all_labels: Set[str]) -> float:
    """Hamming Loss: 预测错误的标签比例"""
    if not all_labels:
        return 0.0
    xor = (pred_set ^ gt_set)  # 对称差集
    return len(xor) / len(all_labels)


def exact_match(pred_set: Set[str], gt_set: Set[str]) -> float:
    """Exact Match: 完全匹配返回1，否则0"""
    return 1.0 if pred_set == gt_set else 0.0


# ========== QA 指标相关 ==========

def tokenize_chinese(text: str) -> List[str]:
    """中文分词（使用 jieba）"""
    import jieba
    return list(jieba.cut(text))


def bleu_score(reference: str, hypothesis: str, n: int = 4) -> Dict[str, float]:
    """
    计算 BLEU-1 到 BLEU-n。
    使用 jieba 分词处理中文。
    """
    ref_tokens = tokenize_chinese(reference)
    hyp_tokens = tokenize_chinese(hypothesis)

    if not hyp_tokens or not ref_tokens:
        return {f"bleu_{i+1}": 0.0 for i in range(n)}

    scores = {}
    for gram_n in range(1, n + 1):
        # 计算 n-gram
        ref_ngrams = Counter()
        for i in range(len(ref_tokens) - gram_n + 1):
            ngram = tuple(ref_tokens[i:i + gram_n])
            ref_ngrams[ngram] += 1

        hyp_ngrams = Counter()
        for i in range(len(hyp_tokens) - gram_n + 1):
            ngram = tuple(hyp_tokens[i:i + gram_n])
            hyp_ngrams[ngram] += 1

        # Clipped count
        clipped = 0
        total = 0
        for ngram, count in hyp_ngrams.items():
            clipped += min(count, ref_ngrams.get(ngram, 0))
            total += count

        if total == 0:
            scores[f"bleu_{gram_n}"] = 0.0
        else:
            scores[f"bleu_{gram_n}"] = clipped / total

    # Brevity penalty
    bp = min(1.0, math.exp(1 - len(ref_tokens) / max(len(hyp_tokens), 1)))

    # 加上 BP 的综合 BLEU
    for key in scores:
        scores[key] *= bp

    return scores


def format_results_table(results: Dict, title: str) -> str:
    """格式化结果为 Markdown 表格"""
    lines = [f"\n## {title}\n", "| 指标 | 值 |", "|------|-----|"]
    for key, value in results.items():
        if isinstance(value, float):
            lines.append(f"| {key} | {value:.4f} |")
        else:
            lines.append(f"| {key} | {value} |")
    return "\n".join(lines)
