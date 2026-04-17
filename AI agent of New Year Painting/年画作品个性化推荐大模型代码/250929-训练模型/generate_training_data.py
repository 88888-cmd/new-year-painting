"""
生成Qwen3格式的推荐系统训练数据
采用标准模式:用户至少5个Like(3个作为历史,2个作为推荐目标)
"""

import json
import random
import csv
from collections import defaultdict
from itertools import combinations
import os


class RecommendationTrainingDataGenerator:
    def __init__(self, data_dir):
        """初始化训练数据生成器"""
        self.data_dir = data_dir
        self.users = {}
        self.paintings = {}
        self.styles = {}
        self.themes = {}
        self.user_likes = defaultdict(list)
        self.user_ratings = defaultdict(list)
        self.user_collections = defaultdict(set)

        # Qwen3系统提示词
        self.system_prompt = """你是一位专业的年画推荐助手,精通中国传统年画艺术。你能够根据用户的历史喜好,为用户推荐合适的年画作品,并给出详细的推荐理由。

你需要考虑以下因素进行推荐:
1. 用户历史喜欢的作品风格(如手绘、木版、套印等)
2. 用户偏好的主题(如吉祥寓意、神话民俗、仕途高升等)
3. 作品的文化内涵和艺术价值
4. 用户的个人特征(职业、年龄等)

推荐时请给出3-5个作品,并说明推荐理由。"""

    def load_data(self):
        """加载所有必要的数据"""
        print("正在加载数据...")

        # 加载用户信息
        try:
            with open(os.path.join(self.data_dir, '用户信息.csv'), 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.users[row['id']] = {
                        'id': row['id'],
                        'nickname': row.get('nickname', '用户'),
                        'gender': '男' if row.get('gender') == '1' else '女',
                        'profession': row.get('profession', '未知'),
                        'birthday': row.get('birthday', '')
                    }
        except UnicodeDecodeError:
            # 尝试GB18030编码
            with open(os.path.join(self.data_dir, '用户信息.csv'), 'r', encoding='gb18030') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.users[row['id']] = {
                        'id': row['id'],
                        'nickname': row.get('nickname', '用户'),
                        'gender': '男' if row.get('gender') == '1' else '女',
                        'profession': row.get('profession', '未知'),
                        'birthday': row.get('birthday', '')
                    }

        # 加载年画作品
        with open(os.path.join(self.data_dir, '年画作品.csv'), 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                self.paintings[row['id']] = {
                    'id': row['id'],
                    'name': row['name'],
                    'style_id': row.get('style_id', ''),
                    'theme_id': row.get('theme_id', ''),
                    'content': row.get('content', '')
                }

        # 加载风格
        with open(os.path.join(self.data_dir, '年画风格.csv'), 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                self.styles[row['id']] = row['name']

        # 加载主题
        with open(os.path.join(self.data_dir, '年画主体.csv'), 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                self.themes[row['id']] = row['name']

        # 加载Like记录
        with open(os.path.join(self.data_dir, '用户物品喜好矩阵表.csv'), 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                user_id = row['user_id']
                painting_id = row['painting_id']
                attitude = row['attitude']
                if attitude == 'like':
                    self.user_likes[user_id].append(painting_id)

        # 加载打分记录
        with open(os.path.join(self.data_dir, '用户作品打分.csv'), 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                user_id = row['user_id']
                painting_id = row['painting_id']
                star = int(row['star_count'])
                self.user_ratings[user_id].append((painting_id, star))

        # 加载收藏记录
        with open(os.path.join(self.data_dir, '用户收藏记录.csv'), 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                user_id = row['user_id']
                painting_id = row['painting_id']
                self.user_collections[user_id].add(painting_id)

        print(f"加载完成: {len(self.users)}个用户, {len(self.paintings)}个作品")
        print(f"Like记录: {sum(len(v) for v in self.user_likes.values())}条")

    def get_painting_description(self, painting_id):
        """获取作品描述"""
        if painting_id not in self.paintings:
            return "未知作品"

        painting = self.paintings[painting_id]
        name = painting['name']
        style = self.styles.get(painting['style_id'], '未知风格')
        theme = self.themes.get(painting['theme_id'], '未知主题')

        return f"《{name}》(风格:{style},主题:{theme})"

    def get_user_description(self, user_id):
        """获取用户描述"""
        if user_id not in self.users:
            return "用户信息未知"

        user = self.users[user_id]
        profession = user['profession']
        gender = user['gender']

        return f"职业{profession},性别{gender}"

    def analyze_user_preferences(self, liked_painting_ids):
        """分析用户偏好"""
        style_count = defaultdict(int)
        theme_count = defaultdict(int)

        for pid in liked_painting_ids:
            if pid in self.paintings:
                painting = self.paintings[pid]
                style_id = painting['style_id']
                theme_id = painting['theme_id']

                if style_id in self.styles:
                    style_count[self.styles[style_id]] += 1
                if theme_id in self.themes:
                    theme_count[self.themes[theme_id]] += 1

        # 找出最喜欢的风格和主题
        preferred_styles = sorted(style_count.items(), key=lambda x: x[1], reverse=True)[:2]
        preferred_themes = sorted(theme_count.items(), key=lambda x: x[1], reverse=True)[:2]

        return preferred_styles, preferred_themes

    def generate_recommendation_reason(self, user_id, history_paintings, recommended_paintings):
        """生成推荐理由"""
        preferred_styles, preferred_themes = self.analyze_user_preferences(history_paintings)

        reasons = []
        reasons.append("根据您的历史喜好,为您推荐以下年画作品:\n")

        for i, pid in enumerate(recommended_paintings, 1):
            painting_desc = self.get_painting_description(pid)
            painting = self.paintings.get(pid, {})
            style = self.styles.get(painting.get('style_id', ''), '精美')
            theme = self.themes.get(painting.get('theme_id', ''), '传统')

            reason_parts = [f"{i}. {painting_desc}"]

            # 根据用户偏好生成理由
            if preferred_styles and style in [s[0] for s in preferred_styles]:
                reason_parts.append(f"延续您喜爱的{style}风格")
            if preferred_themes and theme in [t[0] for t in preferred_themes]:
                reason_parts.append(f"符合您对{theme}主题的偏好")

            reasons.append(" - ".join(reason_parts))

        # 添加总结性推荐理由
        if preferred_styles:
            style_summary = "、".join([s[0] for s in preferred_styles])
            reasons.append(f"\n推荐理由:这些作品的风格和主题与您喜欢的作品相似,都具有{style_summary}的特点")

        if preferred_themes:
            theme_summary = "、".join([t[0] for t in preferred_themes])
            reasons.append(f",并且注重{theme_summary}的文化内涵,相信您会喜欢。")

        return "\n".join(reasons)

    def generate_training_sample(self, user_id, history_paintings, target_paintings):
        """生成单个训练样本(Qwen3格式)"""
        # 构造用户输入
        user_desc = self.get_user_description(user_id)
        history_desc = [self.get_painting_description(pid) for pid in history_paintings]

        user_input = f"用户信息:{user_desc}\n"
        user_input += f"历史喜好:用户喜欢过以下作品 - {', '.join(history_desc)}\n"
        user_input += "请为该用户推荐3-5个年画作品。"

        # 构造助手回复
        assistant_reply = self.generate_recommendation_reason(user_id, history_paintings, target_paintings)

        # Qwen3格式
        sample = {
            "messages": [
                {
                    "role": "system",
                    "content": self.system_prompt
                },
                {
                    "role": "user",
                    "content": user_input
                },
                {
                    "role": "assistant",
                    "content": assistant_reply
                }
            ]
        }

        return sample

    def generate_all_samples(self, min_likes=5, samples_per_user=8, train_ratio=0.9):
        """生成所有训练样本并分割为训练集和验证集"""
        print("\n开始生成训练样本...")

        all_samples = []
        valid_users = 0

        for user_id, liked_paintings in self.user_likes.items():
            # 过滤:至少有min_likes个like的用户
            if len(liked_paintings) < min_likes:
                continue

            valid_users += 1

            # 为每个用户生成多个样本
            user_samples = 0

            # 策略:随机选择不同的历史和目标组合
            for _ in range(samples_per_user):
                if len(liked_paintings) < min_likes:
                    break

                # 随机打乱
                shuffled = liked_paintings.copy()
                random.shuffle(shuffled)

                # 选择历史(3个)和推荐目标(2-3个)
                history_size = 3
                target_size = min(3, len(shuffled) - history_size)

                if target_size < 1:
                    continue

                history = shuffled[:history_size]
                targets = shuffled[history_size:history_size + target_size]

                # 生成样本
                sample = self.generate_training_sample(user_id, history, targets)
                all_samples.append(sample)
                user_samples += 1

            if valid_users % 100 == 0:
                print(f"已处理 {valid_users} 个用户, 生成 {len(all_samples)} 个样本")

        # 打乱所有样本
        random.shuffle(all_samples)

        # 分割训练集和验证集
        split_index = int(len(all_samples) * train_ratio)
        train_samples = all_samples[:split_index]
        val_samples = all_samples[split_index:]

        # 保存训练集
        train_path = os.path.join(self.data_dir, 'qwen3_train.jsonl')
        with open(train_path, 'w', encoding='utf-8') as f:
            for sample in train_samples:
                f.write(json.dumps(sample, ensure_ascii=False) + '\n')

        # 保存验证集
        val_path = os.path.join(self.data_dir, 'qwen3_val.jsonl')
        with open(val_path, 'w', encoding='utf-8') as f:
            for sample in val_samples:
                f.write(json.dumps(sample, ensure_ascii=False) + '\n')

        print(f"\n训练数据生成完成!")
        print(f"符合条件的用户数: {valid_users}")
        print(f"生成总样本数: {len(all_samples)}")
        print(f"训练集样本数: {len(train_samples)} (保存至: {train_path})")
        print(f"验证集样本数: {len(val_samples)} (保存至: {val_path})")

        return train_samples, val_samples, train_path, val_path

    def generate_statistics(self, train_samples, val_samples):
        """生成数据统计"""
        print("\n" + "="*60)
        print("数据集统计信息")
        print("="*60)

        total_samples = len(train_samples) + len(val_samples)
        print(f"总样本数: {total_samples}")
        print(f"训练集样本数: {len(train_samples)} ({len(train_samples)/total_samples*100:.1f}%)")
        print(f"验证集样本数: {len(val_samples)} ({len(val_samples)/total_samples*100:.1f}%)")

        # 统计每个样本的token长度(粗略估计)
        total_tokens = 0
        for sample in train_samples + val_samples:
            for msg in sample['messages']:
                total_tokens += len(msg['content'])

        avg_chars = total_tokens / total_samples if total_samples > 0 else 0
        print(f"\n平均每样本字符数: {avg_chars:.2f}")
        print(f"预估总token数: {total_tokens // 2}")  # 粗略估计: 2个字符≈1个token

        # 推荐用于训练的配置
        print("\n推荐训练配置:")
        print(f"- 建议epoch: 3-5")
        print(f"- 建议batch size: 4-8")
        print(f"- 建议learning rate: 1e-5 ~ 5e-5")


def main():
    # 设置数据目录
    data_dir = '/Users/huanghao/Desktop/projects/250929-训练模型'

    # 创建生成器
    generator = RecommendationTrainingDataGenerator(data_dir)

    # 加载数据
    generator.load_data()

    # 生成训练样本(标准模式:至少5个Like,分割为90%训练+10%验证)
    train_samples, val_samples, train_path, val_path = generator.generate_all_samples(
        min_likes=5,           # 至少5个Like
        samples_per_user=8,    # 每用户生成8个样本
        train_ratio=0.9        # 90%训练,10%验证
    )

    # 生成统计信息
    generator.generate_statistics(train_samples, val_samples)

    # 显示训练集前2个样本示例
    print("\n" + "="*60)
    print("训练集样本示例(前2个):")
    print("="*60)
    for i, sample in enumerate(train_samples[:2], 1):
        print(f"\n【训练样本 {i}】")
        print(json.dumps(sample, ensure_ascii=False, indent=2))
        if i < 2:
            print("\n" + "-"*60)

    # 显示验证集前1个样本示例
    print("\n" + "="*60)
    print("验证集样本示例(第1个):")
    print("="*60)
    if val_samples:
        print(json.dumps(val_samples[0], ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()