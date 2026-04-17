import os
import json
from datetime import datetime

# 导入各个模型
try:
    from data_processing.data_loader import TianjinNewYearPaintingDataLoader
    from data_processing.data_preprocessor import TianjinNewYearPaintingPreprocessor
    from models.recommendation_model import TianjinNewYearPaintingRecommender
    from models.generation_model import TianjinNewYearPaintingGenerator
    from models.qa_model import TianjinNewYearPaintingQAModel
except ImportError:
    # 如果是直接运行此文件，添加父目录到路径
    import sys
    sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from data_processing.data_loader import TianjinNewYearPaintingDataLoader
    from data_processing.data_preprocessor import TianjinNewYearPaintingPreprocessor
    from models.recommendation_model import TianjinNewYearPaintingRecommender
    from models.generation_model import TianjinNewYearPaintingGenerator
    from models.qa_model import TianjinNewYearPaintingQAModel

class TianjinNewYearPaintingAgent:
    def __init__(self, data_dir="../../", openai_api_key=None):
        """初始化天津杨柳青年画智能助手
        data_dir: 数据文件所在目录
        openai_api_key: OpenAI API密钥
        """
        self.data_dir = data_dir
        self.openai_api_key = openai_api_key
        
        # 初始化各个组件
        self.data_loader = None
        self.data_preprocessor = None
        self.recommender = None
        self.generator = None
        self.qa_model = None
        
        # 记录用户历史
        self.user_history = {}
        
        # 初始化各个模块
        self._initialize_components()
        
    def _initialize_components(self):
        """初始化各个组件"""
        print("正在初始化天津杨柳青年画智能助手...")
        
        # 初始化数据加载器
        try:
            self.data_loader = TianjinNewYearPaintingDataLoader(self.data_dir)
            print("数据加载器初始化成功")
        except Exception as e:
            print(f"数据加载器初始化失败: {e}")
            
        # 初始化数据预处理器
        try:
            if self.data_loader:
                self.data_preprocessor = TianjinNewYearPaintingPreprocessor(self.data_loader)
                print("数据预处理器初始化成功")
        except Exception as e:
            print(f"数据预处理器初始化失败: {e}")
            
        # 初始化推荐模型
        try:
            if self.data_preprocessor:
                self.recommender = TianjinNewYearPaintingRecommender(self.data_preprocessor)
                print("推荐模型初始化成功")
        except Exception as e:
            print(f"推荐模型初始化失败: {e}")
            
        # 初始化生成模型
        try:
            self.generator = TianjinNewYearPaintingGenerator()
            print("生成模型初始化成功")
        except Exception as e:
            print(f"生成模型初始化失败: {e}")
            
        # 初始化问答模型
        try:
            self.qa_model = TianjinNewYearPaintingQAModel(self.openai_api_key)
            print("问答模型初始化成功")
            # 从CSV文件添加知识
            if self.data_loader and hasattr(self.data_loader, 'paintings_df'):
                # 假设paintings_df中的content列包含年画描述
                if 'content' in self.data_loader.paintings_df.columns:
                    # 创建临时CSV文件
                    temp_csv = "temp_painting_knowledge.csv"
                    self.data_loader.paintings_df[['name', 'content']].to_csv(temp_csv, index=False)
                    self.qa_model.add_knowledge_from_csv(temp_csv, 'content')
                    os.remove(temp_csv)
        except Exception as e:
            print(f"问答模型初始化失败: {e}")
            
        print("天津杨柳青年画智能助手初始化完成")
        
    def process_user_input(self, user_id, input_text, input_type="text"):
        """处理用户输入
        user_id: 用户ID
        input_text: 用户输入的文本或图像路径
        input_type: 输入类型，可选'text'、'image'、'command'
        """
        # 确保用户历史存在
        if user_id not in self.user_history:
            self.user_history[user_id] = {
                "chat_history": [],
                "recent_activities": [],
                "preferences": {}
            }
            
        # 根据输入类型处理
        if input_type == "command":
            return self._process_command(user_id, input_text)
        elif input_type == "image":
            return self._process_image_input(user_id, input_text)
        else:
            return self._process_text_input(user_id, input_text)
            
    def _process_command(self, user_id, command):
        """处理命令输入"""
        command = command.lower().strip()
        
        # 处理推荐命令
        if command in ["推荐年画", "给我推荐", "推荐新作品", "推荐"]:
            return self.recommend_paintings(user_id)
            
        # 处理生成命令
        elif command.startswith("生成年画") or command.startswith("创建年画"):
            # 提取生成参数
            keywords = command.replace("生成年画", "").replace("创建年画", "").strip()
            return self.generate_painting(user_id, keywords)
            
        # 处理帮助命令
        elif command in ["帮助", "功能介绍", "使用说明"]:
            return self._show_help()
            
        # 处理其他命令
        else:
            return f"未知命令: {command}。输入'帮助'查看可用命令。"
            
    def _process_text_input(self, user_id, text):
        """处理文本输入"""
        # 检查是否是命令
        if text.startswith("/"):
            return self._process_command(user_id, text[1:])
            
        # 否则作为问答处理
        if self.qa_model:
            response, self.user_history[user_id]["chat_history"] = \
                self.qa_model.chat_with_history(
                    text,
                    self.user_history[user_id]["chat_history"]
                )
            
            # 记录用户活动
            self._record_user_activity(user_id, "qa", {"question": text, "answer": response})
            
            return response
        else:
            return "问答模型尚未初始化，无法回答问题。"
            
    def _process_image_input(self, user_id, image_path):
        """处理图像输入"""
        if not os.path.exists(image_path):
            return "图像文件不存在，请检查路径是否正确。"
            
        # 默认询问关于图像的分析
        question = "请分析这幅年画的风格、主题、寓意和艺术特点，并给出详细解释。"
        
        if self.qa_model:
            response = self.qa_model.answer_image_question(image_path, question)
            
            # 记录用户活动
            self._record_user_activity(user_id, "image_analysis", {"image_path": image_path})
            
            return response
        else:
            return "问答模型尚未初始化，无法分析图像。"
            
    def recommend_paintings(self, user_id, n=5):
        """为用户推荐年画
        user_id: 用户ID
        n: 推荐数量
        """
        if not self.recommender:
            return "推荐模型尚未初始化，无法推荐年画。"
            
        try:
            # 获取推荐结果
            recommendations = self.recommender.recommend_based_on_user_activity(user_id, n)
            
            # 如果没有基于活动的推荐，使用基于相似用户的推荐
            if not recommendations.empty:
                # 格式化推荐结果
                result = "为您推荐以下年画作品：\n\n"
                for idx, row in recommendations.iterrows():
                    result += f"{idx+1}. {row['name']}\n"
                    if 'content' in row and pd.notna(row['content']):
                        # 提取部分描述
                        content = str(row['content']).split('\n')[0]  # 只取第一行
                        if len(content) > 50:
                            content = content[:50] + "..."
                        result += f"   描述：{content}\n"
                    result += "\n"
                
                # 记录用户活动
                self._record_user_activity(user_id, "recommendation", {"count": len(recommendations)})
                
                return result
            else:
                return "抱歉，暂时无法为您推荐相关年画作品。"
        except Exception as e:
            print(f"推荐失败: {e}")
            return "推荐过程中出现错误，请稍后再试。"
            
    def generate_painting(self, user_id, keywords="", style="杨柳青", theme="吉祥喜庆"):
        """生成天津杨柳青年画风格的图像
        user_id: 用户ID
        keywords: 关键词
        style: 风格
        theme: 主题
        """
        if not self.generator:
            return "生成模型尚未初始化，无法生成年画。"
            
        try:
            # 生成图像
            image_path = self.generator.generate_image(
                prompt=f"{style}年画，{theme}主题，{keywords}",
                user_id=user_id
            )
            
            # 记录用户活动
            self._record_user_activity(user_id, "generation", {"keywords": keywords, "image_path": image_path})
            
            return f"年画生成成功！图像已保存至：{image_path}"
        except Exception as e:
            print(f"生成失败: {e}")
            return "生成过程中出现错误，请稍后再试。"
            
    def _record_user_activity(self, user_id, activity_type, details=None):
        """记录用户活动
        user_id: 用户ID
        activity_type: 活动类型
        details: 活动详情
        """
        activity = {
            "timestamp": datetime.now().isoformat(),
            "type": activity_type,
            "details": details or {}
        }
        
        # 添加到用户历史
        self.user_history[user_id]["recent_activities"].append(activity)
        
        # 保留最近的100条活动记录
        if len(self.user_history[user_id]["recent_activities"]) > 100:
            self.user_history[user_id]["recent_activities"] = self.user_history[user_id]["recent_activities"][-100:]
            
        # 保存用户历史
        self._save_user_history(user_id)
        
    def _save_user_history(self, user_id):
        """保存用户历史"""
        try:
            # 创建历史记录目录
            history_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "user_history")
            os.makedirs(history_dir, exist_ok=True)
            
            # 保存历史记录
            history_file = os.path.join(history_dir, f"user_{user_id}_history.json")
            with open(history_file, 'w', encoding='utf-8') as f:
                json.dump(self.user_history[user_id], f, ensure_ascii=False, indent=2)
        except Exception as e:
            print(f"保存用户历史失败: {e}")
            
    def _load_user_history(self, user_id):
        """加载用户历史"""
        try:
            history_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "user_history")
            history_file = os.path.join(history_dir, f"user_{user_id}_history.json")
            
            if os.path.exists(history_file):
                with open(history_file, 'r', encoding='utf-8') as f:
                    self.user_history[user_id] = json.load(f)
        except Exception as e:
            print(f"加载用户历史失败: {e}")
            
    def _show_help(self):
        """显示帮助信息"""
        help_text = "天津杨柳青年画智能助手功能说明：\n\n"
        help_text += "1. 问答功能：直接输入您关于杨柳青年画的问题，我会为您解答。\n"
        help_text += "2. 推荐功能：输入'推荐'或'推荐年画'，我会为您推荐适合的年画作品。\n"
        help_text += "3. 生成功能：输入'生成年画 关键词'，我会为您生成杨柳青年画风格的图像。\n"
        help_text += "4. 图像分析：提供年画图像，我会为您分析其风格、主题和艺术特点。\n"
        help_text += "\n示例：\n"
        help_text += "- '杨柳青年画的历史渊源是什么？'\n"
        help_text += "- '推荐'\n"
        help_text += "- '生成年画 连年有余 鲤鱼 莲花'\n"
        
        return help_text
        
    def update_user_preferences(self, user_id, preferences):
        """更新用户偏好
        user_id: 用户ID
        preferences: 用户偏好字典
        """
        if user_id not in self.user_history:
            self.user_history[user_id] = {
                "chat_history": [],
                "recent_activities": [],
                "preferences": {}
            }
            
        # 更新偏好
        self.user_history[user_id]["preferences"].update(preferences)
        
        # 保存用户历史
        self._save_user_history(user_id)
        
        return "用户偏好已更新"

if __name__ == "__main__":
    # 测试agent
    import sys
    
    # 检查是否提供了API密钥
    api_key = None
    if len(sys.argv) > 1:
        api_key = sys.argv[1]
    else:
        api_key = os.environ.get("OPENAI_API_KEY")
        
    # 创建agent实例
    agent = TianjinNewYearPaintingAgent(
        data_dir="../../",  # 假设数据文件在上上层目录
        openai_api_key=api_key
    )
    
    print("\n天津杨柳青年画智能助手已启动！")
    print("输入'帮助'查看可用功能，输入'退出'结束对话。\n")
    
    # 模拟用户ID
    test_user_id = "user_123"
    
    while True:
        try:
            user_input = input("用户: ")
            
            if user_input.lower() in ["退出", "quit", "exit"]:
                print("助手: 感谢使用天津杨柳青年画智能助手，再见！")
                break
                
            # 处理用户输入
            response = agent.process_user_input(test_user_id, user_input)
            
            print(f"助手: {response}")
            
        except KeyboardInterrupt:
            print("\n助手: 感谢使用天津杨柳青年画智能助手，再见！")
            break
        except Exception as e:
            print(f"助手: 发生错误: {e}")