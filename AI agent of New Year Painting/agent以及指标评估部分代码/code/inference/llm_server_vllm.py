#!/usr/bin/env python3
"""
年画智能系统 - vLLM 加速版 LLM 统一服务器 v3
修复: tag/recommend 推理时加入 chat template + system prompt
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import torch
import uvicorn
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

TAG_MERGED = "/root/autodl-tmp/app/models/qwen3-tag-merged"
REC_MERGED = "/root/autodl-tmp/app/models/qwen3-recommend-merged"
QA_BASE = "/root/autodl-tmp/LLaMA-Factory/models/Qwen2.5-VL-3B-Instruct"
QA_LORA = "/root/autodl-tmp/LLaMA-Factory/saves/Qwen2.5-VL-3B-Instruct/lora/train_2025-11-19-22-17-38"

# System prompts (与训练数据一致)
TAG_SYSTEM_PROMPT = "你是一个专业的用户标签分类助手。你的任务是根据用户对年画作品的交互行为（浏览、打分、评论、收藏等），分析用户的偏好特征，为用户打上合适的年画风格和主体标签。"

REC_SYSTEM_PROMPT = """你是一位专业的年画推荐助手,精通中国传统年画艺术。你能够根据用户的历史喜好,为用户推荐合适的年画作品,并给出详细的推荐理由。

你需要考虑以下因素进行推荐:
1. 用户历史喜欢的作品风格(如手绘、木版、套印等)
2. 用户偏好的主题(如吉祥寓意、神话民俗、仕途高升等)
3. 作品的文化内涵和艺术价值
4. 用户的个人特征(职业、年龄等)

推荐时请给出3-5个作品,并说明推荐理由。"""

QA_SYSTEM_PROMPT = "你是一位中国传统年画研究专家,精通年画的历史、工艺、文化内涵和艺术鉴赏。你的回答准确、简洁、富有文化深度。"

app = FastAPI(title="年画智能系统LLM服务(vLLM v3)", version="3.0.0")

vllm_tag = None
vllm_rec = None
tag_tokenizer = None
rec_tokenizer = None
qa_model = None
qa_processor = None


class InferenceRequest(BaseModel):
    model: str
    prompt: str
    max_length: Optional[int] = 512
    temperature: Optional[float] = 0.7


class InferenceResponse(BaseModel):
    success: bool
    model: str
    result: str
    error: Optional[str] = None


@app.on_event("startup")
async def load_models():
    global vllm_tag, vllm_rec, tag_tokenizer, rec_tokenizer, qa_model, qa_processor

    from vllm import LLM
    from transformers import AutoTokenizer

    # 1. tag
    logger.info("加载 vLLM: Qwen3-4B tag (merged)...")
    try:
        vllm_tag = LLM(
            model=TAG_MERGED, max_model_len=2048,
            gpu_memory_utilization=0.25, dtype="float16",
            trust_remote_code=True, enforce_eager=True,
        )
        tag_tokenizer = AutoTokenizer.from_pretrained(TAG_MERGED, trust_remote_code=True)
        logger.info("tag loaded")
    except Exception as e:
        logger.error(f"tag failed: {e}")

    # 2. recommend
    logger.info("加载 vLLM: Qwen3-4B recommend (merged)...")
    try:
        vllm_rec = LLM(
            model=REC_MERGED, max_model_len=2048,
            gpu_memory_utilization=0.25, dtype="float16",
            trust_remote_code=True, enforce_eager=True,
        )
        rec_tokenizer = AutoTokenizer.from_pretrained(REC_MERGED, trust_remote_code=True)
        logger.info("recommend loaded")
    except Exception as e:
        logger.error(f"recommend failed: {e}")

    # 3. QA (transformers)
    logger.info("加载 QA: Qwen2.5-VL-3B + LoRA...")
    try:
        from transformers import Qwen2_5_VLForConditionalGeneration, AutoProcessor, BitsAndBytesConfig
        qa_processor = AutoProcessor.from_pretrained(QA_BASE, trust_remote_code=True)
        quant_config = BitsAndBytesConfig(
            load_in_4bit=True, bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16, bnb_4bit_use_double_quant=True,
        )
        qa_model = Qwen2_5_VLForConditionalGeneration.from_pretrained(
            QA_BASE, quantization_config=quant_config,
            device_map="auto", trust_remote_code=True, torch_dtype=torch.float16,
        )
        if os.path.exists(QA_LORA):
            qa_model.load_adapter(QA_LORA, adapter_name="qa")
            qa_model.set_adapter("qa")
        logger.info("QA loaded")
    except Exception as e:
        logger.error(f"QA failed: {e}")

    logger.info("所有模型加载完成")


def build_chat_prompt(tokenizer, system_prompt: str, user_prompt: str) -> str:
    """用 tokenizer 的 chat template 构建完整 prompt"""
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt},
    ]
    return tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)


def infer_vllm(engine, full_prompt: str, max_tokens: int = 512, temperature: float = 0.7) -> str:
    from vllm import SamplingParams
    sampling = SamplingParams(max_tokens=max_tokens, temperature=max(temperature, 0.01), top_p=0.9)
    outputs = engine.generate([full_prompt], sampling)
    return outputs[0].outputs[0].text.strip()


def infer_qa(prompt: str, max_tokens: int = 512, temperature: float = 0.7) -> str:
    messages = [
        {"role": "system", "content": [{"type": "text", "text": QA_SYSTEM_PROMPT}]},
        {"role": "user", "content": [{"type": "text", "text": prompt}]},
    ]
    text = qa_processor.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    inputs = qa_processor(text=[text], return_tensors="pt", padding=True).to(qa_model.device)
    with torch.no_grad():
        outputs = qa_model.generate(
            **inputs, max_new_tokens=max_tokens, temperature=max(temperature, 0.01),
            do_sample=True, pad_token_id=qa_processor.tokenizer.pad_token_id,
        )
    output_ids = outputs[0][inputs.input_ids.shape[1]:]
    return qa_processor.batch_decode([output_ids], skip_special_tokens=True, clean_up_tokenization_spaces=False)[0]


@app.get("/")
async def root():
    return {"service": "年画智能系统LLM服务(vLLM v3)", "status": "running",
            "tag_loaded": vllm_tag is not None, "recommend_loaded": vllm_rec is not None,
            "qa_loaded": qa_model is not None}


@app.get("/models")
async def list_models():
    return {"models": {
        "tag": {"loaded": vllm_tag is not None, "engine": "vllm+chat_template"},
        "recommend": {"loaded": vllm_rec is not None, "engine": "vllm+chat_template"},
        "qa": {"loaded": qa_model is not None, "engine": "transformers"},
    }}


@app.post("/inference", response_model=InferenceResponse)
async def inference(request: InferenceRequest):
    try:
        if request.model == "tag":
            if not vllm_tag: raise HTTPException(503, "tag not loaded")
            full_prompt = build_chat_prompt(tag_tokenizer, TAG_SYSTEM_PROMPT, request.prompt)
            result = infer_vllm(vllm_tag, full_prompt, request.max_length, request.temperature)
        elif request.model == "recommend":
            if not vllm_rec: raise HTTPException(503, "recommend not loaded")
            full_prompt = build_chat_prompt(rec_tokenizer, REC_SYSTEM_PROMPT, request.prompt)
            result = infer_vllm(vllm_rec, full_prompt, request.max_length, request.temperature)
        elif request.model == "qa":
            if not qa_model: raise HTTPException(503, "qa not loaded")
            result = infer_qa(request.prompt, request.max_length, request.temperature)
        else:
            raise HTTPException(400, f"unknown model: {request.model}")
        return InferenceResponse(success=True, model=request.model, result=result)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"inference error: {e}")
        return InferenceResponse(success=False, model=request.model, result="", error=str(e))


@app.get("/health")
async def health_check():
    loaded = sum(1 for x in [vllm_tag, vllm_rec, qa_model] if x is not None)
    return {"status": "healthy", "models_loaded": loaded, "cuda_available": torch.cuda.is_available()}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
