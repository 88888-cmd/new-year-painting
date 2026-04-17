#!/usr/bin/env python3
"""
年画智能系统 - QA问答模型评估
指标: BLEU-1/BLEU-4, ROUGE-1/ROUGE-2/ROUGE-L, BERTScore
数据源: qa_val.jsonl (222条)
"""

import os
import sys
import json
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import (
    call_llm, load_jsonl, save_json, bleu_score,
    tokenize_chinese, format_results_table,
)

# 数据路径
VAL_DATA_PATH = "/root/autodl-tmp/LLaMA-Factory/data/qa_val.jsonl"
RESULTS_DIR = "/root/autodl-tmp/app/evaluation/results"


def compute_rouge(reference: str, hypothesis: str) -> dict:
    """计算 ROUGE-1, ROUGE-2, ROUGE-L (基于 jieba 分词)"""
    ref_tokens = tokenize_chinese(reference)
    hyp_tokens = tokenize_chinese(hypothesis)

    if not ref_tokens or not hyp_tokens:
        return {"rouge_1": 0.0, "rouge_2": 0.0, "rouge_l": 0.0}

    # ROUGE-1: unigram overlap
    ref_unigrams = set(ref_tokens)
    hyp_unigrams = set(hyp_tokens)
    overlap_1 = len(ref_unigrams & hyp_unigrams)
    rouge_1_p = overlap_1 / len(hyp_unigrams) if hyp_unigrams else 0.0
    rouge_1_r = overlap_1 / len(ref_unigrams) if ref_unigrams else 0.0
    rouge_1 = 2 * rouge_1_p * rouge_1_r / (rouge_1_p + rouge_1_r) if (rouge_1_p + rouge_1_r) > 0 else 0.0

    # ROUGE-2: bigram overlap
    def get_bigrams(tokens):
        return set(tuple(tokens[i:i+2]) for i in range(len(tokens) - 1))

    ref_bigrams = get_bigrams(ref_tokens)
    hyp_bigrams = get_bigrams(hyp_tokens)
    overlap_2 = len(ref_bigrams & hyp_bigrams)
    rouge_2_p = overlap_2 / len(hyp_bigrams) if hyp_bigrams else 0.0
    rouge_2_r = overlap_2 / len(ref_bigrams) if ref_bigrams else 0.0
    rouge_2 = 2 * rouge_2_p * rouge_2_r / (rouge_2_p + rouge_2_r) if (rouge_2_p + rouge_2_r) > 0 else 0.0

    # ROUGE-L: LCS
    def lcs_length(x, y):
        m, n = len(x), len(y)
        # 空间优化的 LCS
        prev = [0] * (n + 1)
        for i in range(1, m + 1):
            curr = [0] * (n + 1)
            for j in range(1, n + 1):
                if x[i-1] == y[j-1]:
                    curr[j] = prev[j-1] + 1
                else:
                    curr[j] = max(prev[j], curr[j-1])
            prev = curr
        return prev[n]

    lcs_len = lcs_length(ref_tokens, hyp_tokens)
    rouge_l_p = lcs_len / len(hyp_tokens) if hyp_tokens else 0.0
    rouge_l_r = lcs_len / len(ref_tokens) if ref_tokens else 0.0
    rouge_l = 2 * rouge_l_p * rouge_l_r / (rouge_l_p + rouge_l_r) if (rouge_l_p + rouge_l_r) > 0 else 0.0

    return {"rouge_1": rouge_1, "rouge_2": rouge_2, "rouge_l": rouge_l}


def compute_bertscore_batch(references: list, hypotheses: list) -> dict:
    """批量计算 BERTScore"""
    try:
        from bert_score import score as bert_score_fn
        print("  计算 BERTScore (bert-base-chinese)...")
        P, R, F1 = bert_score_fn(
            hypotheses, references,
            model_type="bert-base-chinese",
            num_layers=12,
            verbose=True,
            batch_size=32,
        )
        return {
            "bertscore_precision": P.mean().item(),
            "bertscore_recall": R.mean().item(),
            "bertscore_f1": F1.mean().item(),
        }
    except ImportError:
        print("  [WARN] bert-score 未安装，跳过 BERTScore")
        return {
            "bertscore_precision": -1.0,
            "bertscore_recall": -1.0,
            "bertscore_f1": -1.0,
        }
    except Exception as e:
        print(f"  [WARN] BERTScore 计算失败: {e}")
        return {
            "bertscore_precision": -1.0,
            "bertscore_recall": -1.0,
            "bertscore_f1": -1.0,
        }


def extract_qa_pair(messages: list):
    """从 messages 中提取问题和答案"""
    question = ""
    answer = ""
    for msg in messages:
        if msg["role"] == "user":
            question = msg["content"]
        elif msg["role"] == "assistant":
            answer = msg["content"]
    return question, answer


def run_evaluation(max_samples: int = 0):
    """运行 QA 问答模型评估"""
    print("=" * 60)
    print("QA 问答模型评估")
    print("=" * 60)

    # 加载数据
    print(f"\n加载验证数据: {VAL_DATA_PATH}")
    val_data = load_jsonl(VAL_DATA_PATH)
    print(f"共 {len(val_data)} 条样本")

    if max_samples > 0:
        val_data = val_data[:max_samples]
        print(f"限制评估前 {max_samples} 条")

    # 指标累加器
    bleu_1_scores = []
    bleu_4_scores = []
    rouge_1_scores = []
    rouge_2_scores = []
    rouge_l_scores = []
    all_references = []
    all_hypotheses = []
    failed = 0
    sample_results = []

    start_time = time.time()

    for idx, sample in enumerate(val_data):
        messages = sample["messages"]
        question, gt_answer = extract_qa_pair(messages)

        if not question or not gt_answer:
            failed += 1
            continue

        print(f"\r  评估进度: {idx+1}/{len(val_data)}", end="", flush=True)

        # 调用模型
        pred_answer = call_llm("qa", question)
        if pred_answer is None:
            failed += 1
            continue

        # BLEU
        bleu = bleu_score(gt_answer, pred_answer, n=4)
        bleu_1_scores.append(bleu["bleu_1"])
        bleu_4_scores.append(bleu["bleu_4"])

        # ROUGE
        rouge = compute_rouge(gt_answer, pred_answer)
        rouge_1_scores.append(rouge["rouge_1"])
        rouge_2_scores.append(rouge["rouge_2"])
        rouge_l_scores.append(rouge["rouge_l"])

        # 收集用于 BERTScore 的批量计算
        all_references.append(gt_answer)
        all_hypotheses.append(pred_answer)

        # 保存单条结果
        sample_results.append({
            "index": idx,
            "question": question,
            "gt_answer": gt_answer[:100],
            "pred_answer": pred_answer[:100],
            "bleu_1": bleu["bleu_1"],
            "bleu_4": bleu["bleu_4"],
            "rouge_l": rouge["rouge_l"],
        })

    elapsed_inference = time.time() - start_time
    print(f"\n\n推理完成，耗时 {elapsed_inference:.1f}s，失败 {failed} 条")

    def avg(lst):
        return sum(lst) / len(lst) if lst else 0.0

    # 汇总 BLEU 和 ROUGE
    results = {
        "bleu_1": avg(bleu_1_scores),
        "bleu_4": avg(bleu_4_scores),
        "rouge_1": avg(rouge_1_scores),
        "rouge_2": avg(rouge_2_scores),
        "rouge_l": avg(rouge_l_scores),
    }

    # BERTScore (批量计算)
    if all_references and all_hypotheses:
        bert_results = compute_bertscore_batch(all_references, all_hypotheses)
        results.update(bert_results)

    elapsed_total = time.time() - start_time

    results["_meta"] = {
        "total_samples": len(val_data),
        "evaluated": len(val_data) - failed,
        "failed": failed,
        "elapsed_seconds": round(elapsed_total, 1),
    }

    # 打印结果
    print(format_results_table(
        {k: v for k, v in results.items() if not k.startswith("_")},
        "QA 问答模型评估结果"
    ))

    # 保存
    os.makedirs(RESULTS_DIR, exist_ok=True)
    save_json(results, os.path.join(RESULTS_DIR, "qa_results.json"))
    save_json(sample_results[:30], os.path.join(RESULTS_DIR, "qa_samples.json"))
    print(f"\n结果已保存到 {RESULTS_DIR}/qa_results.json")

    return results


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="QA问答模型评估")
    parser.add_argument("--max-samples", type=int, default=0, help="最大评估样本数(0=全部)")
    args = parser.parse_args()
    run_evaluation(max_samples=args.max_samples)
