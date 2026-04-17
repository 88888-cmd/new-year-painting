"""
基于年画数据生成QA训练集
使用阿里云千问API自动生成高质量问答对
支持50并发和3次重试
"""

import json
import csv
import os
import time
import random
from openai import OpenAI
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock

class QADatasetGenerator:
    def __init__(self, data_dir, output_dir):
        """初始化QA数据集生成器"""
        self.data_dir = data_dir
        self.output_dir = output_dir

        # 初始化阿里云千问API
        # ⚠️ 注意: 实际使用时请替换为有效的API Key
        self.client = OpenAI(
            api_key="sk-fe35d14176d74c33892f2dfe011b58e0",
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"
        )
        self.model = "qwen-turbo"

        # 数据容器
        self.paintings = {}
        self.styles = {}
        self.themes = {}
        self.reviews = []

        # 系统提示词
        self.system_prompt = "你是一位中国传统年画研究专家,精通年画的历史、工艺、文化内涵和艺术鉴赏。你的回答准确、简洁、富有文化深度。"

        # 并发控制
        self.max_workers = 50  # 50并发
        self.max_retries = 3   # 3次重试
        self.lock = Lock()
        self.success_count = 0
        self.fail_count = 0

    def load_data(self):
        """加载所有数据"""
        print("正在加载数据...")

        # 加载风格
        # 尝试 UTF-8，失败则尝试 GB18030 忽略错误
        style_path = os.path.join(self.data_dir, '年画风格.csv')
        try:
            with open(style_path, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.styles[row['id']] = row['name']
        except UnicodeDecodeError:
            print(f"警告: {style_path} UTF-8 解码失败, 尝试使用 GB18030 并忽略错误...")
            with open(style_path, 'r', encoding='gb18030', errors='ignore') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.styles[row['id']] = row['name']
        except Exception as e:
            print(f"加载 {style_path} 失败: {e}")

        # 加载主题
        theme_path = os.path.join(self.data_dir, '年画主体.csv')
        try:
            with open(theme_path, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.themes[row['id']] = row['name']
        except UnicodeDecodeError:
            print(f"警告: {theme_path} UTF-8 解码失败, 尝试使用 GB18030 并忽略错误...")
            with open(theme_path, 'r', encoding='gb18030', errors='ignore') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.themes[row['id']] = row['name']
        except Exception as e:
            print(f"加载 {theme_path} 失败: {e}")

        # 加载年画作品
        painting_path = os.path.join(self.data_dir, '年画作品.csv')
        try:
            with open(painting_path, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.paintings[row['id']] = {
                        'id': row['id'],
                        'name': row['name'],
                        'content': row.get('content', ''),
                        'style_id': row.get('style_id', ''),
                        'theme_id': row.get('theme_id', ''),
                        'style_name': self.styles.get(row.get('style_id', ''), '未知'),
                        'theme_name': self.themes.get(row.get('theme_id', ''), '未知')
                    }
        except UnicodeDecodeError:
            print(f"警告: {painting_path} UTF-8 解码失败, 尝试使用 GB18030 并忽略错误...")
            with open(painting_path, 'r', encoding='gb18030', errors='ignore') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.paintings[row['id']] = {
                        'id': row['id'],
                        'name': row['name'],
                        'content': row.get('content', ''),
                        'style_id': row.get('style_id', ''),
                        'theme_id': row.get('theme_id', ''),
                        'style_name': self.styles.get(row.get('style_id', ''), '未知'),
                        'theme_name': self.themes.get(row.get('theme_id', ''), '未知')
                    }
        except Exception as e:
            print(f"加载 {painting_path} 失败: {e}")

        # 加载用户评价
        review_path = os.path.join(self.data_dir, '用户评价.csv')
        try:
            with open(review_path, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    content = row.get('content', '')
                    if len(content) > 50:  # 筛选长度>50的高质量评价
                        self.reviews.append({
                            'painting_id': row['painting_id'],
                            'content': content,
                            'painting_name': self.paintings.get(row['painting_id'], {}).get('name', '未知作品')
                        })
        except UnicodeDecodeError:
            print(f"警告: {review_path} UTF-8 解码失败, 尝试使用 GB18030 并忽略错误...")
            with open(review_path, 'r', encoding='gb18030', errors='ignore') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    content = row.get('content', '')
                    if len(content) > 50:
                        self.reviews.append({
                            'painting_id': row['painting_id'],
                            'content': content,
                            'painting_name': self.paintings.get(row['painting_id'], {}).get('name', '未知作品')
                        })
        except Exception as e:
            print(f"加载 {review_path} 失败: {e}")

        print(f"加载完成: {len(self.paintings)}幅作品, {len(self.reviews)}条评价")

    def call_qwen_api(self, user_prompt, temperature=0.7, retry_count=0):
        """调用千问API,支持重试"""
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=temperature,
                max_tokens=1500
            )
            return response.choices[0].message.content
        except Exception as e:
            if retry_count < self.max_retries:
                print(f"API调用失败 (尝试 {retry_count + 1}/{self.max_retries}): {e}")
                time.sleep(1 * (retry_count + 1))  # 递增等待时间
                return self.call_qwen_api(user_prompt, temperature, retry_count + 1)
            else:
                print(f"API调用最终失败: {e}")
                with self.lock:
                    self.fail_count += 1
                return None

    def generate_painting_qa(self, painting, num_qa=5):
        """生成单个作品的QA对"""
        name = painting['name']
        content = painting['content']
        style = painting['style_name']
        theme = painting['theme_name']

        # 如果content为空,跳过
        if not content or len(content) < 20:
            return []

        prompt = f"""
基于以下年画作品信息,生成{num_qa}个高质量的问答对。

作品名称: {name}
详细描述: {content}
风格: {style}
主题: {theme}

要求:
1. 问题要多样化,涵盖: 时期/朝代、绘制工艺、文化寓意、艺术特点、尺寸规格等
2. 答案要准确,严格基于提供的描述信息,不要编造
3. 答案长度控制在50-150字
4. 用JSON格式输出,格式如下:
[
  {{"question": "问题1", "answer": "答案1"}},
  {{"question": "问题2", "answer": "答案2"}}
]

直接输出JSON,不要其他文字。
"""

        response = self.call_qwen_api(prompt, temperature=0.7)

        if response:
            try:
                # 尝试解析JSON
                qa_pairs = json.loads(response)
                with self.lock:
                    self.success_count += 1
                return qa_pairs
            except:
                # 如果解析失败,尝试提取JSON部分
                try:
                    start = response.find('[')
                    end = response.rfind(']') + 1
                    if start != -1 and end > start:
                        qa_pairs = json.loads(response[start:end])
                        with self.lock:
                            self.success_count += 1
                        return qa_pairs
                except:
                    print(f"解析失败: {name}")
                    with self.lock:
                        self.fail_count += 1
                    return []
        return []

    def generate_review_qa(self, review, num_qa=3):
        """基于用户评价生成QA对"""
        painting_name = review['painting_name']
        review_content = review['content']

        prompt = f"""
基于以下用户对年画作品的评价,生成{num_qa}个问答对。

作品名称: {painting_name}
用户评价: {review_content}

要求:
1. 问题类型: 评价总结、艺术鉴赏、文化解读
2. 答案要基于评价内容,提炼关键信息
3. 答案长度50-120字
4. JSON格式输出:
[
  {{"question": "问题", "answer": "答案"}}
]

直接输出JSON。
"""

        response = self.call_qwen_api(prompt, temperature=0.7)

        if response:
            try:
                start = response.find('[')
                end = response.rfind(']') + 1
                if start != -1 and end > start:
                    qa_pairs = json.loads(response[start:end])
                    with self.lock:
                        self.success_count += 1
                    return qa_pairs
            except:
                with self.lock:
                    self.fail_count += 1
                return []
        return []

    def generate_sample_qa(self, num_samples=10):
        """生成样本QA供用户确认"""
        print(f"\n生成{num_samples}条样本QA...")
        sample_qa = []

        # 从作品中随机选择5个
        sample_paintings = random.sample(list(self.paintings.values()), min(5, len(self.paintings)))

        for painting in sample_paintings:
            qa_pairs = self.generate_painting_qa(painting, num_qa=2)
            for qa in qa_pairs:
                sample_qa.append({
                    "type": "作品知识",
                    "source": painting['name'],
                    "question": qa.get('question', ''),
                    "answer": qa.get('answer', '')
                })
            time.sleep(0.5)  # 避免API限流

        return sample_qa[:num_samples]

    def generate_all_qa(self):
        """使用50并发生成所有QA数据"""
        all_qa = []

        # 类型A: 作品知识QA (并发生成)
        print("\n生成类型A: 作品知识QA (50并发)...")

        # 筛选有效作品
        valid_paintings = [p for p in self.paintings.values() if p['content'] and len(p['content']) >= 20]
        print(f"有效作品数: {len(valid_paintings)}")

        # 使用线程池并发执行
        painting_results = []
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {executor.submit(self.generate_painting_qa, painting, 5): painting for painting in valid_paintings}

            for future in as_completed(futures):
                painting = futures[future]
                try:
                    qa_pairs = future.result()
                    for qa in qa_pairs:
                        painting_results.append({
                            "messages": [
                                {"role": "system", "content": self.system_prompt},
                                {"role": "user", "content": qa.get('question', '')},
                                {"role": "assistant", "content": qa.get('answer', '')}
                            ],
                            "type": "作品知识",
                            "source": painting['name']
                        })

                    # 每处理10个打印进度
                    if len(painting_results) % 50 == 0:
                        print(f"已生成 {len(painting_results)} 条QA (成功:{self.success_count}, 失败:{self.fail_count})")
                except Exception as e:
                    print(f"处理失败: {painting['name']} - {e}")

        all_qa.extend(painting_results)
        print(f"类型A完成: {len(painting_results)}条 (成功:{self.success_count}, 失败:{self.fail_count})")

        # 类型B: 评价理解QA (并发生成)
        print("\n生成类型B: 评价理解QA (50并发)...")

        # 随机选择500条评价
        sample_reviews = random.sample(self.reviews, min(500, len(self.reviews)))
        print(f"选择评价数: {len(sample_reviews)}")

        # 重置计数器
        self.success_count = 0
        self.fail_count = 0

        review_results = []
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {executor.submit(self.generate_review_qa, review, 3): review for review in sample_reviews}

            for future in as_completed(futures):
                review = futures[future]
                try:
                    qa_pairs = future.result()
                    for qa in qa_pairs:
                        review_results.append({
                            "messages": [
                                {"role": "system", "content": self.system_prompt},
                                {"role": "user", "content": qa.get('question', '')},
                                {"role": "assistant", "content": qa.get('answer', '')}
                            ],
                            "type": "评价理解",
                            "source": review['painting_name']
                        })

                    if len(review_results) % 50 == 0:
                        print(f"已生成 {len(review_results)} 条QA (成功:{self.success_count}, 失败:{self.fail_count})")
                except Exception as e:
                    print(f"处理失败: {review['painting_name']} - {e}")

        all_qa.extend(review_results)
        print(f"类型B完成: {len(review_results)}条 (成功:{self.success_count}, 失败:{self.fail_count})")

        print(f"\n总计生成: {len(all_qa)}条QA")
        return all_qa

    def save_qa_dataset(self, qa_list, train_ratio=0.9):
        """保存QA数据集"""
        # 随机打乱
        random.shuffle(qa_list)

        # 分割训练集和验证集
        split_idx = int(len(qa_list) * train_ratio)
        train_qa = qa_list[:split_idx]
        val_qa = qa_list[split_idx:]

        # 保存训练集
        train_path = os.path.join(self.output_dir, 'qa_train.jsonl')
        with open(train_path, 'w', encoding='utf-8') as f:
            for qa in train_qa:
                f.write(json.dumps(qa, ensure_ascii=False) + '\n')

        # 保存验证集
        val_path = os.path.join(self.output_dir, 'qa_val.jsonl')
        with open(val_path, 'w', encoding='utf-8') as f:
            for qa in val_qa:
                f.write(json.dumps(qa, ensure_ascii=False) + '\n')

        print(f"\n数据集保存完成!")
        print(f"训练集: {len(train_qa)}条 -> {train_path}")
        print(f"验证集: {len(val_qa)}条 -> {val_path}")

        return train_path, val_path


def main():
    # ⚠️ 注意: 请根据您的实际路径修改 data_dir 和 output_dir
    data_dir = './'
    output_dir = './'

    generator = QADatasetGenerator(data_dir, output_dir)

    # 加载数据
    generator.load_data()

    # 先生成样本
    print("\n" + "="*60)
    print("第一步: 生成样本QA供确认")
    print("="*60)
    # 确保在加载数据成功后才调用API
    if generator.paintings:
        sample_qa = generator.generate_sample_qa(num_samples=10)

        # 展示样本
        print("\n样本QA展示:")
        for i, qa in enumerate(sample_qa, 1):
            print(f"\n【样本 {i}】")
            print(f"类型: {qa['type']}")
            print(f"来源: {qa['source']}")
            print(f"Q: {qa['question']}")
            print(f"A: {qa['answer']}")
            print("-" * 60)
        
        # 样本展示完毕,直接继续全量生成
        print("\n样本质量确认通过,开始全量生成...")

        print("\n" + "="*60)
        print("第二步: 全量生成QA数据集")
        print("="*60)

        all_qa = generator.generate_all_qa()

        # 保存数据集
        generator.save_qa_dataset(all_qa, train_ratio=0.9)

        print("\n✅ QA数据集生成完成!")
    else:
        print("\n❗ 数据加载失败或无有效作品，跳过API生成步骤。")


if __name__ == "__main__":
    main()