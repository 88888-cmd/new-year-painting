#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
数据处理脚本：将用户交互数据转换为Qwen3训练格式
用于用户标签分类大模型训练
"""

import pandas as pd
import json
import os
from collections import defaultdict


def load_all_data():
    """加载所有数据文件"""
    data_dir = './data'

    # 尝试不同的编码
    encodings = ['utf-8', 'gbk', 'gb18030', 'gb2312']

    def read_csv_with_encoding(filepath):
        for encoding in encodings:
            try:
                return pd.read_csv(filepath, encoding=encoding)
            except (UnicodeDecodeError, UnicodeError):
                continue
        raise ValueError(f"无法读取文件 {filepath}，尝试了所有编码")

    # 加载作品信息
    paintings = read_csv_with_encoding(f'{data_dir}/年画作品.csv')

    # 加载分类信息
    styles = read_csv_with_encoding(f'{data_dir}/年画风格.csv')
    themes = read_csv_with_encoding(f'{data_dir}/年画主体.csv')

    # 加载用户信息
    users = read_csv_with_encoding(f'{data_dir}/用户信息.csv')

    # 加载用户交互数据
    browsing = read_csv_with_encoding(f'{data_dir}/用户浏览年画物品记录.csv')
    ratings = read_csv_with_encoding(f'{data_dir}/用户作品打分.csv')
    comments = read_csv_with_encoding(f'{data_dir}/用户评价.csv')
    favorites = read_csv_with_encoding(f'{data_dir}/用户收藏记录.csv')

    return {
        'paintings': paintings,
        'styles': styles,
        'themes': themes,
        'users': users,
        'browsing': browsing,
        'ratings': ratings,
        'comments': comments,
        'favorites': favorites
    }


def create_style_theme_mapping(data):
    """创建风格和主体的映射字典"""
    style_map = dict(zip(data['styles']['id'], data['styles']['name']))
    theme_map = dict(zip(data['themes']['id'], data['themes']['name']))
    return style_map, theme_map


def aggregate_user_interactions(data, style_map, theme_map):
    """聚合每个用户的交互数据"""
    user_profiles = {}

    # 获取所有唯一用户ID
    all_user_ids = set()
    all_user_ids.update(data['browsing']['user_id'].unique())
    all_user_ids.update(data['ratings']['user_id'].unique())
    all_user_ids.update(data['comments']['user_id'].unique())
    all_user_ids.update(data['favorites']['user_id'].unique())

    for user_id in all_user_ids:
        profile = {
            'user_id': user_id,
            'browsed_paintings': [],
            'rated_paintings': [],
            'commented_paintings': [],
            'favorited_paintings': [],
            'style_preferences': defaultdict(float),
            'theme_preferences': defaultdict(float)
        }

        # 浏览记录
        user_browsing = data['browsing'][data['browsing']['user_id'] == user_id]
        profile['browsed_paintings'] = user_browsing['painting_id'].tolist()

        # 打分记录（高分表示喜欢）
        user_ratings = data['ratings'][data['ratings']['user_id'] == user_id]
        for _, row in user_ratings.iterrows():
            profile['rated_paintings'].append({
                'painting_id': row['painting_id'],
                'star_count': row['star_count']
            })

        # 评论记录
        user_comments = data['comments'][data['comments']['user_id'] == user_id]
        for _, row in user_comments.iterrows():
            profile['commented_paintings'].append({
                'painting_id': row['painting_id'],
                'content': row['content'] if pd.notna(row['content']) else ''
            })

        # 收藏记录
        user_favorites = data['favorites'][data['favorites']['user_id'] == user_id]
        profile['favorited_paintings'] = user_favorites['painting_id'].tolist()

        # 计算用户对不同风格和主体的偏好权重
        for painting_id in set(profile['browsed_paintings']):
            painting_info = data['paintings'][data['paintings']['id'] == painting_id]
            if not painting_info.empty:
                style_id = painting_info.iloc[0]['style_id']
                theme_id = painting_info.iloc[0]['theme_id']

                if pd.notna(style_id) and style_id in style_map:
                    profile['style_preferences'][style_map[style_id]] += 1
                if pd.notna(theme_id) and theme_id in theme_map:
                    profile['theme_preferences'][theme_map[theme_id]] += 1

        # 打分记录权重更高
        for rating in profile['rated_paintings']:
            painting_id = rating['painting_id']
            star_count = rating['star_count']
            painting_info = data['paintings'][data['paintings']['id'] == painting_id]

            if not painting_info.empty:
                style_id = painting_info.iloc[0]['style_id']
                theme_id = painting_info.iloc[0]['theme_id']

                # 星级越高，权重越大
                weight = star_count
                if pd.notna(style_id) and style_id in style_map:
                    profile['style_preferences'][style_map[style_id]] += weight
                if pd.notna(theme_id) and theme_id in theme_map:
                    profile['theme_preferences'][theme_map[theme_id]] += weight

        # 收藏记录权重最高
        for painting_id in profile['favorited_paintings']:
            painting_info = data['paintings'][data['paintings']['id'] == painting_id]
            if not painting_info.empty:
                style_id = painting_info.iloc[0]['style_id']
                theme_id = painting_info.iloc[0]['theme_id']

                weight = 5  # 收藏权重为5
                if pd.notna(style_id) and style_id in style_map:
                    profile['style_preferences'][style_map[style_id]] += weight
                if pd.notna(theme_id) and theme_id in theme_map:
                    profile['theme_preferences'][theme_map[theme_id]] += weight

        user_profiles[user_id] = profile

    return user_profiles


def get_painting_info(painting_id, data, style_map, theme_map):
    """获取作品的详细信息"""
    painting = data['paintings'][data['paintings']['id'] == painting_id]
    if painting.empty:
        return None

    painting = painting.iloc[0]
    return {
        'id': painting_id,
        'name': painting['name'] if pd.notna(painting['name']) else '未知作品',
        'style': style_map.get(painting['style_id'], '未知风格') if pd.notna(painting['style_id']) else '未知风格',
        'theme': theme_map.get(painting['theme_id'], '未知主体') if pd.notna(painting['theme_id']) else '未知主体'
    }


def generate_training_samples(user_profiles, data, style_map, theme_map):
    """生成训练样本 - 根据用户的具体交互行为生成标签"""
    training_samples = []

    for user_id, profile in user_profiles.items():
        # 收集用户的正向交互作品（高分、收藏）
        positive_interactions = []

        # 1. 收藏的作品（权重最高）
        for painting_id in profile['favorited_paintings']:
            painting_info = get_painting_info(painting_id, data, style_map, theme_map)
            if painting_info:
                positive_interactions.append({
                    'type': '收藏',
                    'painting': painting_info
                })

        # 2. 高分作品（4-5星）
        for rating in profile['rated_paintings']:
            if rating['star_count'] >= 4:
                painting_info = get_painting_info(rating['painting_id'], data, style_map, theme_map)
                if painting_info:
                    positive_interactions.append({
                        'type': f"打分{rating['star_count']}星",
                        'painting': painting_info
                    })

        # 3. 有评论的作品
        for comment in profile['commented_paintings']:
            if comment['content'] and len(comment['content']) > 10:
                painting_info = get_painting_info(comment['painting_id'], data, style_map, theme_map)
                if painting_info:
                    positive_interactions.append({
                        'type': '评论',
                        'painting': painting_info,
                        'comment': comment['content'][:100]  # 限制评论长度
                    })

        # 如果没有足够的正向交互，跳过
        if len(positive_interactions) < 2:
            continue

        # 限制每个用户最多取10个交互
        if len(positive_interactions) > 10:
            positive_interactions = positive_interactions[:10]

        # 构建用户交互描述
        interaction_details = []
        for idx, interaction in enumerate(positive_interactions, 1):
            painting = interaction['painting']
            if interaction['type'] == '评论' and 'comment' in interaction:
                interaction_details.append(
                    f"{idx}. {interaction['type']}了《{painting['name']}》({painting['style']}风格, {painting['theme']}主体): \"{interaction['comment']}\""
                )
            else:
                interaction_details.append(
                    f"{idx}. {interaction['type']}了《{painting['name']}》({painting['style']}风格, {painting['theme']}主体)"
                )

        interaction_text = "\n".join(interaction_details)

        # 统计用户偏好的风格和主体
        style_counter = defaultdict(int)
        theme_counter = defaultdict(int)

        for interaction in positive_interactions:
            painting = interaction['painting']
            # 收藏权重为3，打分根据星级，评论权重为2
            if interaction['type'] == '收藏':
                weight = 3
            elif '5星' in interaction['type']:
                weight = 2.5
            elif '4星' in interaction['type']:
                weight = 2
            elif interaction['type'] == '评论':
                weight = 2
            else:
                weight = 1

            style_counter[painting['style']] += weight
            theme_counter[painting['theme']] += weight

        # 获取前3个偏好
        top_styles = sorted(style_counter.items(), key=lambda x: x[1], reverse=True)[:3]
        top_themes = sorted(theme_counter.items(), key=lambda x: x[1], reverse=True)[:3]

        # 生成标签
        style_tags = [style for style, _ in top_styles if style != '未知风格']
        theme_tags = [theme for theme, _ in top_themes if theme != '未知主体']

        if not style_tags and not theme_tags:
            continue

        # 构建标签输出
        tag_parts = []
        if style_tags:
            tag_parts.append(f"风格标签: {', '.join(style_tags)}")
        if theme_tags:
            tag_parts.append(f"主体标签: {', '.join(theme_tags)}")

        tag_output = "; ".join(tag_parts)

        # 创建训练样本（Qwen格式）
        sample = {
            "messages": [
                {
                    "role": "system",
                    "content": "你是一个专业的用户标签分类助手。你的任务是根据用户对年画作品的交互行为（浏览、打分、评论、收藏等），分析用户的偏好特征，为用户打上合适的年画风格和主体标签。"
                },
                {
                    "role": "user",
                    "content": f"请根据以下用户的交互行为，为该用户分配合适的年画标签：\n\n{interaction_text}\n\n请分析该用户的偏好特征，并为其打上年画风格和主体标签。"
                },
                {
                    "role": "assistant",
                    "content": f"基于该用户的交互行为分析，该用户应被打上以下标签：\n{tag_output}\n\n分析理由：该用户对上述风格和主体的年画作品表现出明确的偏好，通过收藏、高分评价和评论等正向交互行为，反映出对这些类型作品的强烈兴趣。"
                }
            ]
        }

        training_samples.append(sample)

    return training_samples


def save_training_data(samples, output_path='./train_data.json'):
    """保存训练数据"""
    with open(output_path, 'w', encoding='utf-8') as f:
        for sample in samples:
            f.write(json.dumps(sample, ensure_ascii=False) + '\n')

    print(f"训练数据已保存到: {output_path}")
    print(f"总样本数: {len(samples)}")


def main():
    print("开始处理数据...")

    # 加载数据
    print("\n1. 加载数据文件...")
    data = load_all_data()
    print(f"   - 年画作品数: {len(data['paintings'])}")
    print(f"   - 用户数: {len(data['users'])}")
    print(f"   - 浏览记录数: {len(data['browsing'])}")
    print(f"   - 打分记录数: {len(data['ratings'])}")
    print(f"   - 评论记录数: {len(data['comments'])}")
    print(f"   - 收藏记录数: {len(data['favorites'])}")

    # 创建映射
    print("\n2. 创建风格和主体映射...")
    style_map, theme_map = create_style_theme_mapping(data)
    print(f"   - 风格类别数: {len(style_map)}")
    print(f"   - 主体类别数: {len(theme_map)}")

    # 聚合用户交互
    print("\n3. 聚合用户交互数据...")
    user_profiles = aggregate_user_interactions(data, style_map, theme_map)
    print(f"   - 活跃用户数: {len(user_profiles)}")

    # 生成训练样本
    print("\n4. 生成训练样本...")
    training_samples = generate_training_samples(user_profiles, data, style_map, theme_map)
    print(f"   - 训练样本数: {len(training_samples)}")

    # 保存数据
    print("\n5. 保存训练数据...")
    save_training_data(training_samples, './train_data.json')

    # 显示样本示例
    if training_samples:
        print("\n=== 样本示例 ===")
        print(json.dumps(training_samples[0], ensure_ascii=False, indent=2))

    print("\n数据处理完成！")


if __name__ == '__main__':
    main()
