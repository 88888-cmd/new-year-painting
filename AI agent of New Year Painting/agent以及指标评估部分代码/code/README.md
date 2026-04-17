# 年画智能系统 - 代码仓库

基于大语言模型和生成式 AI 的中国传统年画智能服务平台，包含训练、推理、Agent 和评估四个部分的完整代码。

## 系统架构

| 模块 | 基座模型 | 微调方式 | 功能 |
|------|---------|---------|------|
| 用户画像 | Qwen3-4B-Instruct | LoRA | 分析用户交互行为，生成风格/主体偏好标签 |
| 推荐模型 | Qwen3-4B-Instruct | LoRA | 根据用户历史喜好推荐年画作品 |
| QA 问答 | Qwen2.5-VL-3B-Instruct | LoRA | 回答年画相关的知识问答 |
| 图片生成 | Stable Diffusion v1.5 | LoRA | 生成年画风格的图片 |
| Agent | Gemini 2.5 Flash | — | 编排调用上述四个工具，完成端到端用户任务 |

## 目录结构

```
code/
├── training/                        # 训练相关
│   ├── data_preparation/
│   │   └── prepare_training_data.py # 训练数据预处理（用户画像 + 推荐）
│   ├── llm/
│   │   ├── train_config_user_tagging.yaml  # 用户画像模型训练配置
│   │   ├── train_config_recommend.yaml     # 推荐模型训练配置
│   │   ├── dataset_info_tagging.json       # LLaMA-Factory 数据集注册
│   │   └── start_training.sh               # 训练启动脚本
│   └── sd/
│       ├── train_lora_nianha.sh     # SD LoRA 训练脚本（kohya-ss）
│       ├── train_config.toml        # SD 训练参数配置
│       └── add_trigger_word.py      # 为训练图片添加触发词
├── inference/                       # 推理服务
│   ├── llm_server_vllm.py          # LLM 统一推理服务（vLLM 加速）
│   ├── sd_tool.py                  # SD 图片生成工具
│   ├── sd_inference_demo.py        # SD 推理示例
│   └── start_services.sh           # 服务启动脚本
├── agent/                           # Agent 智能体
│   ├── nianha_agent.py             # Strands Agent 主程序
│   └── nianha_tools.py             # Agent 工具定义（QA/推荐/画像/生成）
└── evaluation/                      # 评估框架
    ├── utils.py                    # 公共工具（LLM 调用、指标计算、解析函数）
    ├── eval_recommend.py           # 推荐模型评估（语义匹配）
    ├── eval_user_tagging.py        # 用户画像评估（截断扰动策略）
    ├── eval_qa.py                  # QA 问答评估（BLEU/ROUGE）
    ├── eval_sd.py                  # SD 图片生成评估（IS + 人工评分）
    ├── eval_agent.py               # Agent 端到端评估
    └── eval_runner.py              # 统一评估入口
```

## 环境要求

- Python 3.10+
- CUDA 12.x + GPU（建议 16GB 显存以上）
- Conda 环境：`sd-lora`

主要依赖：

```
vllm>=0.18.0
transformers
peft
torch
torchvision
diffusers
accelerate
jieba
rouge-score
```

## 使用说明

### 1. 训练

#### LLM 训练（用户画像 / 推荐）

基于 LLaMA-Factory 框架，使用 LoRA 微调 Qwen3-4B-Instruct：

```bash
# 数据预处理
python training/data_preparation/prepare_training_data.py

# 启动训练（以用户画像为例）
cd training/llm
bash start_training.sh
```

训练配置文件说明：
- `train_config_user_tagging.yaml`：用户画像模型，输入用户交互行为，输出风格/主体标签
- `train_config_recommend.yaml`：推荐模型，输入用户历史喜好，输出推荐作品列表

#### SD LoRA 训练

基于 kohya-ss sd-scripts，训练年画风格 LoRA：

```bash
# 为训练图片添加触发词
python training/sd/add_trigger_word.py

# 启动 LoRA 训练
cd training/sd
bash train_lora_nianha.sh
```

### 2. 推理

#### 启动 LLM 推理服务

```bash
# 激活环境
source /root/miniconda3/bin/activate sd-lora

# 启动服务（端口 8000）
python inference/llm_server_vllm.py
```

服务接口：

| 接口 | 方法 | 说明 |
|------|------|------|
| `/health` | GET | 健康检查 |
| `/inference` | POST | 统一推理接口 |

请求示例：

```json
{
  "model": "tag",
  "prompt": "用户交互行为描述...",
  "max_length": 2048,
  "temperature": 0.7
}
```

`model` 可选值：`tag`（用户画像）、`recommend`（推荐）、`qa`（问答）

#### SD 图片生成

```bash
python inference/sd_tool.py
```

### 3. Agent

基于 Strands 框架，使用 Gemini 2.5 Flash 作为推理引擎，串联调用四个工具模块：

```bash
python agent/nianha_agent.py
```

Agent 可调用的工具（定义在 `nianha_tools.py`）：
- `nianha_qa`：年画知识问答
- `analyze_user_preferences`：用户偏好分析
- `recommend_nianha`：年画推荐
- `generate_nianha_image`：年画图片生成

### 4. 评估

#### 运行全部评估

```bash
# 确保 LLM 推理服务已启动
python evaluation/eval_runner.py

# 快速测试（每模块最多 10 条）
python evaluation/eval_runner.py --max-samples 10

# 跳过指定模块
python evaluation/eval_runner.py --skip-sd --skip-agent
```

#### 单独运行各模块

```bash
# 推荐模型（493 条，约 20 分钟）
python evaluation/eval_recommend.py

# 用户画像（200 条，约 19 分钟）
python evaluation/eval_user_tagging.py

# QA 问答（222 条，约 9 分钟）
python evaluation/eval_qa.py

# SD 图片生成（30 条，约 29 分钟）
python evaluation/eval_sd.py

# Agent 端到端（20 个场景，约 2 分钟）
python evaluation/eval_agent.py
```

评估结果输出到 `evaluation/results/` 目录。

## 评估指标概览

| 模块 | 核心指标 | 值 |
|------|---------|-----|
| 推荐模型 | Style F1 / Theme Hit Rate | 0.74 / 100% |
| 用户画像 | Overall F1 / Exact Match | 0.9945 / 98.5% |
| QA 问答 | BLEU-1 / ROUGE-L | 0.34 / 0.34 |
| 图片生成 | 人工评估综合 | 3.84 / 5 |
| Agent | 任务完成率 / 工具调用 F1 | 85% / 1.0 |
