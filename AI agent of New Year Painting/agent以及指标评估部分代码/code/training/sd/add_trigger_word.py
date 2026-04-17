#!/usr/bin/env python3
"""
为所有标签文件添加英文触发词
这样可以在保留中文描述的同时，添加英文触发词以提高 SD 1.5 的兼容性
"""

import os
from pathlib import Path

# 设置
DATASET_DIR = "/home/ubuntu/lora-training/dataset/train"
TRIGGER_WORD = "nianha"  # 触发词：年画
# 或者使用: "traditional chinese art" "chinese new year painting"

def add_trigger_word(dataset_dir, trigger_word):
    """为所有 txt 文件添加触发词"""
    txt_files = list(Path(dataset_dir).glob("*.txt"))

    modified_count = 0
    for txt_file in txt_files:
        try:
            # 读取原始内容
            with open(txt_file, 'r', encoding='utf-8') as f:
                content = f.read().strip()

            # 检查是否已经有触发词
            if not content.startswith(trigger_word):
                # 添加触发词
                new_content = f"{trigger_word}, {content}"

                # 写回文件
                with open(txt_file, 'w', encoding='utf-8') as f:
                    f.write(new_content)

                modified_count += 1
                print(f"✓ {txt_file.name}: {content[:50]}...")

        except Exception as e:
            print(f"✗ 处理 {txt_file.name} 时出错: {e}")

    print(f"\n处理完成！")
    print(f"总文件数: {len(txt_files)}")
    print(f"修改文件数: {modified_count}")
    print(f"触发词: {trigger_word}")

if __name__ == "__main__":
    print("=" * 60)
    print("为标签添加英文触发词")
    print("=" * 60)
    print(f"数据集目录: {DATASET_DIR}")
    print(f"触发词: {TRIGGER_WORD}")
    print("=" * 60)
    print()

    add_trigger_word(DATASET_DIR, TRIGGER_WORD)

    print("\n" + "=" * 60)
    print("示例：")
    print("原标签: 传统年画，长者手持供品的形象")
    print(f"新标签: {TRIGGER_WORD}, 传统年画，长者手持供品的形象")
    print("=" * 60)
