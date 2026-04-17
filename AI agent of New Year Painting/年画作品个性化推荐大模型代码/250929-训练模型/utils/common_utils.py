import os
import json
import time
import random
import string
import logging
from datetime import datetime
import numpy as np
import pandas as pd
from PIL import Image
import matplotlib.pyplot as plt
import seaborn as sns
import re

class CommonUtils:
    @staticmethod
    def setup_logging(log_file=None):
        """设置日志配置"""
        # 创建日志目录
        if log_file:
            log_dir = os.path.dirname(log_file)
            if log_dir and not os.path.exists(log_dir):
                os.makedirs(log_dir, exist_ok=True)
                
        # 配置日志格式
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file) if log_file else logging.NullHandler(),
                logging.StreamHandler()
            ]
        )
        
        return logging.getLogger()
        
    @staticmethod
    def ensure_dir(dir_path):
        """确保目录存在，如果不存在则创建"""
        if not os.path.exists(dir_path):
            os.makedirs(dir_path, exist_ok=True)
        return dir_path
        
    @staticmethod
    def save_json(data, file_path, indent=2):
        """保存数据到JSON文件"""
        try:
            # 确保目录存在
            dir_path = os.path.dirname(file_path)
            if dir_path:
                CommonUtils.ensure_dir(dir_path)
                
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=indent)
            return True
        except Exception as e:
            print(f"保存JSON失败: {e}")
            return False
            
    @staticmethod
    def load_json(file_path):
        """从JSON文件加载数据"""
        try:
            if not os.path.exists(file_path):
                print(f"文件不存在: {file_path}")
                return None
                
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"加载JSON失败: {e}")
            return None
            
    @staticmethod
    def save_image(image, file_path, quality=95):
        """保存图像"""
        try:
            # 确保目录存在
            dir_path = os.path.dirname(file_path)
            if dir_path:
                CommonUtils.ensure_dir(dir_path)
                
            # 如果是numpy数组，转换为PIL Image
            if isinstance(image, np.ndarray):
                image = Image.fromarray(image)
                
            # 保存图像
            image.save(file_path, quality=quality)
            return True
        except Exception as e:
            print(f"保存图像失败: {e}")
            return False
            
    @staticmethod
    def load_image(file_path):
        """加载图像"""
        try:
            if not os.path.exists(file_path):
                print(f"图像文件不存在: {file_path}")
                return None
                
            return Image.open(file_path).convert('RGB')
        except Exception as e:
            print(f"加载图像失败: {e}")
            return None
            
    @staticmethod
    def generate_unique_id(prefix='', length=8):
        """生成唯一ID"""
        timestamp = str(int(time.time()))
        random_str = ''.join(random.choices(string.ascii_letters + string.digits, k=length))
        return f"{prefix}{timestamp}_{random_str}" if prefix else f"{timestamp}_{random_str}"
        
    @staticmethod
    def clean_text(text):
        """清理文本"""
        if not isinstance(text, str):
            return ''
            
        # 去除多余的空格和换行符
        text = re.sub(r'\s+', ' ', text)
        # 去除特殊字符（保留中文、英文、数字和常见标点）
        text = re.sub(r'[^一-龥a-zA-Z0-9，。！？,!.?]', '', text)
        # 去除首尾空格
        text = text.strip()
        
        return text
        
    @staticmethod
    def chinese_to_pinyin(text):
        """将中文转换为拼音（需要安装pypinyin库）"""
        try:
            from pypinyin import lazy_pinyin, Style
            return ''.join(lazy_pinyin(text, style=Style.NORMAL))
        except ImportError:
            print("未安装pypinyin库，无法将中文转换为拼音")
            return text
        except Exception as e:
            print(f"中文转拼音失败: {e}")
            return text
            
    @staticmethod
    def format_datetime(timestamp=None, format_str="%Y-%m-%d %H:%M:%S"):
        """格式化时间"""
        if timestamp is None:
            timestamp = datetime.now()
        elif isinstance(timestamp, (int, float)):
            timestamp = datetime.fromtimestamp(timestamp)
            
        return timestamp.strftime(format_str)
        
    @staticmethod
    def parse_datetime(datetime_str, format_str="%Y-%m-%d %H:%M:%S"):
        """解析时间字符串"""
        try:
            return datetime.strptime(datetime_str, format_str)
        except Exception as e:
            print(f"解析时间失败: {e}")
            return None
            
    @staticmethod
    def calculate_cosine_similarity(vec1, vec2):
        """计算余弦相似度"""
        try:
            # 转换为numpy数组
            vec1 = np.array(vec1)
            vec2 = np.array(vec2)
            
            # 计算点积
            dot_product = np.dot(vec1, vec2)
            
            # 计算模长
            norm_vec1 = np.linalg.norm(vec1)
            norm_vec2 = np.linalg.norm(vec2)
            
            # 计算余弦相似度
            if norm_vec1 == 0 or norm_vec2 == 0:
                return 0
            
            return dot_product / (norm_vec1 * norm_vec2)
        except Exception as e:
            print(f"计算余弦相似度失败: {e}")
            return 0
            
    @staticmethod
    def plot_dataframe(df, title=None, figsize=(10, 6), output_file=None):
        """可视化DataFrame数据"""
        try:
            plt.figure(figsize=figsize)
            
            # 根据数据类型选择可视化方式
            if len(df.columns) <= 2:
                # 简单的线图
                plt.plot(df)
            else:
                # 热图（相关性矩阵）
                corr = df.corr()
                sns.heatmap(corr, annot=True, cmap='coolwarm', linewidths=.5)
                
            if title:
                plt.title(title)
                
            plt.tight_layout()
            
            if output_file:
                # 确保目录存在
                dir_path = os.path.dirname(output_file)
                if dir_path:
                    CommonUtils.ensure_dir(dir_path)
                    
                plt.savefig(output_file, dpi=300)
                plt.close()
            else:
                plt.show()
                
            return True
        except Exception as e:
            print(f"可视化失败: {e}")
            return False
            
    @staticmethod
    def split_train_test(df, test_ratio=0.2, random_state=None):
        """分割训练集和测试集"""
        try:
            from sklearn.model_selection import train_test_split
            train_df, test_df = train_test_split(
                df, test_size=test_ratio, random_state=random_state
            )
            return train_df, test_df
        except ImportError:
            # 如果没有sklearn，使用简单的随机分割
            if random_state is not None:
                random.seed(random_state)
                
            # 打乱数据
            shuffled_indices = list(range(len(df)))
            random.shuffle(shuffled_indices)
            
            # 分割数据
            test_set_size = int(len(df) * test_ratio)
            test_indices = shuffled_indices[:test_set_size]
            train_indices = shuffled_indices[test_set_size:]
            
            return df.iloc[train_indices], df.iloc[test_indices]
        except Exception as e:
            print(f"分割数据集失败: {e}")
            return df, pd.DataFrame()
            
    @staticmethod
    def calculate_accuracy(y_true, y_pred):
        """计算准确率"""
        try:
            y_true = np.array(y_true)
            y_pred = np.array(y_pred)
            
            # 确保长度相同
            if len(y_true) != len(y_pred):
                print("预测值和真实值长度不匹配")
                return 0
                
            return np.mean(y_true == y_pred)
        except Exception as e:
            print(f"计算准确率失败: {e}")
            return 0
            
    @staticmethod
    def calculate_rmse(y_true, y_pred):
        """计算均方根误差"""
        try:
            y_true = np.array(y_true)
            y_pred = np.array(y_pred)
            
            # 确保长度相同
            if len(y_true) != len(y_pred):
                print("预测值和真实值长度不匹配")
                return float('inf')
                
            return np.sqrt(np.mean((y_true - y_pred) ** 2))
        except Exception as e:
            print(f"计算RMSE失败: {e}")
            return float('inf')
            
    @staticmethod
    def compress_image(image_path, output_path, quality=85, max_size=None):
        """压缩图像"""
        try:
            image = Image.open(image_path)
            
            # 如果设置了最大尺寸，调整图像大小
            if max_size:
                image.thumbnail(max_size, Image.Resampling.LANCZOS)
                
            # 保存压缩后的图像
            image.save(output_path, quality=quality, optimize=True)
            return True
        except Exception as e:
            print(f"压缩图像失败: {e}")
            return False
            
    @staticmethod
    def extract_text_from_image(image_path):
        """从图像中提取文本（需要安装pytesseract）"""
        try:
            import pytesseract
            from PIL import Image
            
            image = Image.open(image_path)
            text = pytesseract.image_to_string(image, lang='chi_sim+eng')
            return text
        except ImportError:
            print("未安装pytesseract库，无法从图像中提取文本")
            return """"
        except Exception as e:
            print(f"提取文本失败: {e}")
            return ""
            
    @staticmethod
    def translate_text(text, target_language='en'):
        """




        try:
            from deep_translator import GoogleTranslator
            
            translator = GoogleTranslator(source='auto', target=target_language)
            return translator.translate(text)
        except ImportError:
            print("未安装deep_translator库，无法翻译文本")
            return text
        except Exception as e:
            print(f"翻译失败: {e}")
            return text
            
    @staticmethod
    def get_file_size(file_path, unit='MB'):
        """获取文件大小"""
        try:
            if not os.path.exists(file_path):
                print(f"文件不存在: {file_path}")
                return 0
                
            size_in_bytes = os.path.getsize(file_path)
            
            # 转换单位
            if unit == 'KB':
                return size_in_bytes / 1024
            elif unit == 'MB':
                return size_in_bytes / (1024 * 1024)
            elif unit == 'GB':
                return size_in_bytes / (1024 * 1024 * 1024)
            else:
                return size_in_bytes
        except Exception as e:
            print(f"获取文件大小失败: {e}")
            return 0
            
    @staticmethod
    def get_file_extension(file_path):
        """获取文件扩展名"""
        return os.path.splitext(file_path)[1].lower()
        
    @staticmethod
    def remove_files_with_extension(directory, extensions):
        """删除目录下指定扩展名的文件"""
        try:
            if not os.path.exists(directory):
                print(f"目录不存在: {directory}")
                return 0
                
            if isinstance(extensions, str):
                extensions = [extensions]
                
            count = 0
            for root, _, files in os.walk(directory):
                for file in files:
                    if any(file.lower().endswith(ext.lower()) for ext in extensions):
                        file_path = os.path.join(root, file)
                        os.remove(file_path)
                        count += 1
                        
            return count
        except Exception as e:
            print(f"删除文件失败: {e}")
            return 0
            
    @staticmethod
    def backup_file(file_path, backup_dir=None):
        """备份文件"""
        try:
            if not os.path.exists(file_path):
                print(f"文件不存在: {file_path}")
                return None
                
            # 如果没有指定备份目录，使用原文件所在目录
            if not backup_dir:
                backup_dir = os.path.dirname(file_path)
                
            # 确保备份目录存在
            CommonUtils.ensure_dir(backup_dir)
            
            # 生成备份文件名
            file_name = os.path.basename(file_path)
            file_name_no_ext, file_ext = os.path.splitext(file_name)
            backup_file_name = f"{file_name_no_ext}_backup_{CommonUtils.format_datetime().replace(' ', '_').replace(':', '-')}{file_ext}"
            backup_file_path = os.path.join(backup_dir, backup_file_name)
            
            # 复制文件
            import shutil
            shutil.copy2(file_path, backup_file_path)
            
            return backup_file_path
        except Exception as e:
            print(f"备份文件失败: {e}")
            return None
            
    @staticmethod
    def retry_on_exception(func, max_retries=3, delay=1):
        """重试装饰器，在发生异常时重试"""
        def wrapper(*args, **kwargs):
            retries = 0
            while retries < max_retries:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    retries += 1
                    if retries >= max_retries:
                        raise
                    print(f"操作失败，{delay}秒后重试 ({retries}/{max_retries})...")
                    time.sleep(delay)
        return wrapper

# 示例用法
if __name__ == "__main__":
    # 测试日志功能
    logger = CommonUtils.setup_logging("test.log")
    logger.info("测试日志")
    
    # 测试文件操作
    test_data = {"name": "测试", "value": 123}
    CommonUtils.save_json(test_data, "test.json")
    loaded_data = CommonUtils.load_json("test.json")
    print(f"加载的数据: {loaded_data}")
    
    # 测试唯一ID生成
    unique_id = CommonUtils.generate_unique_id("test_")
    print(f"生成的唯一ID: {unique_id}")
    
    # 测试文本清理
    dirty_text = "  这是   一段包含\n换行和多余空格的文本！@#￥  "
    clean_text = CommonUtils.clean_text(dirty_text)
    print(f"清理后的文本: {clean_text}")
    
    # 测试时间格式化
    current_time = CommonUtils.format_datetime()
    print(f"当前时间: {current_time}")
    
    # 测试余弦相似度计算
    vec1 = [1, 2, 3]
    vec2 = [2, 4, 6]
    similarity = CommonUtils.calculate_cosine_similarity(vec1, vec2)
    print(f"余弦相似度: {similarity}")
    
    # 清理测试文件
    if os.path.exists("test.log"):
        os.remove("test.log")
    if os.path.exists("test.json"):
        os.remove("test.json")