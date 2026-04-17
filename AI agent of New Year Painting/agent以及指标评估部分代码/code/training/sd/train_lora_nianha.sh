#!/bin/bash

# 中国传统年画 LoRA 训练脚本
# 数据集：162张传统年画图片，分辨率主要为 135x180

# 激活 conda 环境
source /home/ubuntu/miniconda3/bin/activate sd-lora

# 设置工作目录
cd /home/ubuntu/sd-scripts

# 训练参数
PRETRAINED_MODEL="/home/ubuntu/lora-training/models/sd-v1-5.safetensors"
TRAIN_DATA_DIR="/home/ubuntu/lora-training/dataset"
OUTPUT_DIR="/home/ubuntu/lora-training/output"
LOGGING_DIR="/home/ubuntu/lora-training/logs"
OUTPUT_NAME="nianha_lora"  # 年画 LoRA

# LoRA 参数 - 艺术风格训练
NETWORK_DIM=24            # LoRA rank (艺术风格推荐 16-32)
NETWORK_ALPHA=12          # LoRA alpha (rank 的一半)

# 训练参数 - 针对小分辨率图片优化
RESOLUTION=448            # 训练分辨率 (考虑到原图较小，用 448)
BATCH_SIZE=6              # 批次大小（L40S 46GB 显存充足）
MAX_TRAIN_STEPS=820       # 训练步数 (3 epochs ≈ 273×3=819)
LEARNING_RATE=1e-4        # 学习率
TEXT_ENCODER_LR=5e-5      # Text Encoder 学习率
LR_SCHEDULER="cosine_with_restarts"  # 学习率调度器
LR_WARMUP_STEPS=40        # 预热步数 (总步数的5%)
LR_SCHEDULER_NUM_CYCLES=1 # cosine_with_restarts 的重启次数

# 优化器
OPTIMIZER="AdamW8bit"     # 8bit AdamW 节省显存

# 其他设置
MIXED_PRECISION="fp16"    # fp16 混合精度
SAVE_PRECISION="fp16"     # 保存精度
SAVE_EVERY_N_STEPS=273    # 每个 epoch 保存一次

echo "=========================================="
echo "开始训练：中国传统年画 LoRA"
echo "=========================================="
echo "数据集：162 张图片"
echo "训练分辨率：${RESOLUTION}x${RESOLUTION}"
echo "LoRA Rank：${NETWORK_DIM}"
echo "训练步数：${MAX_TRAIN_STEPS}"
echo "批次大小：${BATCH_SIZE}"
echo "=========================================="

# 开始训练
accelerate launch --mixed_precision=$MIXED_PRECISION \
  train_network.py \
  --pretrained_model_name_or_path=$PRETRAINED_MODEL \
  --train_data_dir=$TRAIN_DATA_DIR \
  --output_dir=$OUTPUT_DIR \
  --output_name=$OUTPUT_NAME \
  --logging_dir=$LOGGING_DIR \
  --log_prefix="nianha" \
  --resolution=$RESOLUTION \
  --network_module=networks.lora \
  --network_dim=$NETWORK_DIM \
  --network_alpha=$NETWORK_ALPHA \
  --train_batch_size=$BATCH_SIZE \
  --max_train_steps=$MAX_TRAIN_STEPS \
  --learning_rate=$LEARNING_RATE \
  --text_encoder_lr=$TEXT_ENCODER_LR \
  --lr_scheduler=$LR_SCHEDULER \
  --lr_warmup_steps=$LR_WARMUP_STEPS \
  --lr_scheduler_num_cycles=$LR_SCHEDULER_NUM_CYCLES \
  --optimizer_type=$OPTIMIZER \
  --mixed_precision=$MIXED_PRECISION \
  --save_precision=$SAVE_PRECISION \
  --save_every_n_steps=$SAVE_EVERY_N_STEPS \
  --save_model_as=safetensors \
  --max_data_loader_n_workers=4 \
  --enable_bucket \
  --min_bucket_reso=256 \
  --max_bucket_reso=640 \
  --bucket_reso_steps=64 \
  --cache_latents \
  --gradient_checkpointing \
  --xformers \
  --noise_offset=0.05 \
  --caption_extension=".txt" \
  --keep_tokens=0 \
  --shuffle_caption \
  --seed=42

echo ""
echo "=========================================="
echo "训练完成！"
echo "模型保存在: $OUTPUT_DIR"
echo "=========================================="
echo ""
echo "使用方法："
echo "1. 将 ${OUTPUT_NAME}.safetensors 复制到 WebUI 或 ComfyUI 的 LoRA 目录"
echo "2. 在提示词中可以直接使用标签中的中文描述"
echo "3. 推荐 LoRA 权重：0.6-0.9"
echo "=========================================="
