#!/bin/bash
# 用户标签分类大模型训练脚本

set -e

echo "========================================"
echo "开始训练用户标签分类大模型"
echo "========================================"

# 激活conda环境
source /home/ubuntu/miniconda3/etc/profile.d/conda.sh
conda activate llamafactory

# 复制数据集配置到LLaMA-Factory
cp ../dataset_info.json data/
cp ../train_data.json data/

# 开始训练
echo "训练参数:"
echo "  模型: Qwen2.5-1.5B-Instruct"
echo "  方法: LoRA"
echo "  Epochs: 3"
echo "  数据集: user_tagging (4951个样本)"
echo "========================================"

llamafactory-cli train ../train_config.yaml

echo "========================================"
echo "训练完成！"
echo "模型保存在: ./output/qwen3_user_tagging_lora"
echo "========================================"
