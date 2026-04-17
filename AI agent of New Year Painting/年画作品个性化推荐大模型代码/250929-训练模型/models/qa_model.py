import os
import torch
import numpy as np
from PIL import Image
import openai
from langchain.chat_models import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage, AIMessage
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.vectorstores import FAISS
from langchain.chains import RetrievalQA
from langchain.document_loaders import TextLoader, DirectoryLoader
from langchain.text_splitter import CharacterTextSplitter
import pandas as pd

class TianjinNewYearPaintingQAModel:
    def __init__(self, openai_api_key=None):
        """初始化问答模型"""
        # 设置OpenAI API密钥
        if openai_api_key:
            openai.api_key = openai_api_key
            os.environ["OPENAI_API_KEY"] = openai_api_key
        elif "OPENAI_API_KEY" not in os.environ:
            raise ValueError("请设置OpenAI API密钥")
            
        # 模型配置
        self.llm = ChatOpenAI(model_name="gpt-3.5-turbo", temperature=0.1)
        self.vector_store = None
        
        # 年画知识库（预先定义的信息）
        self.tianjin_new_year_painting_knowledge = """
        天津杨柳青木版年画是中国传统民间艺术的瑰宝，始于明朝崇祯年间，盛于清朝。
        杨柳青年画特点：
        - 色彩鲜艳，多用红、黄、绿等明快色彩
        - 线条流畅，注重细节刻画
        - 题材广泛，包括神话传说、历史故事、戏曲人物、世俗生活等
        - 构图饱满，布局合理
        - 有木版套印和手工彩绘两种制作方式
        
        主要题材分类：
        1. 门神类：如秦琼、尉迟恭等守护神灵
        2. 吉祥喜庆类：如《连年有余》、《五谷丰登》等
        3. 历史故事类：如《三国演义》、《水浒传》中的经典场景
        4. 戏曲人物类：如京剧、昆曲中的角色形象
        5. 世俗生活类：反映普通百姓的日常生活场景
        
        制作工艺：
        1. 勾描：用毛笔勾勒线条
        2. 刻版：将勾勒好的图案刻在木板上
        3. 印刷：用刻好的木版进行套色印刷
        4. 彩绘：在印刷基础上进行手工彩绘，增加细节和色彩层次
        
        文化意义：
        杨柳青年画不仅是一种艺术形式，更是中国传统文化的重要载体，承载着人们对美好生活的向往和祝福。
        它被列入第一批国家级非物质文化遗产名录，对于研究中国民间艺术、民俗文化具有重要价值。
        """
        
        # 初始化知识库
        self._init_knowledge_base()
        
    def _init_knowledge_base(self):
        """初始化知识库"""
        try:
            # 创建文档
            from langchain.docstore.document import Document
            docs = [Document(page_content=self.tianjin_new_year_painting_knowledge)]
            
            # 创建向量存储
            embeddings = OpenAIEmbeddings()
            self.vector_store = FAISS.from_documents(docs, embeddings)
            
            # 创建检索问答链
            self.retrieval_qa = RetrievalQA.from_chain_type(
                llm=self.llm,
                chain_type="stuff",
                retriever=self.vector_store.as_retriever()
            )
            
            print("知识库初始化完成")
        except Exception as e:
            print(f"知识库初始化失败: {e}")
            
    def add_knowledge_from_csv(self, csv_path, content_column):
        """从CSV文件添加知识"""
        try:
            if not os.path.exists(csv_path):
                print(f"文件不存在: {csv_path}")
                return False
                
            # 读取CSV文件
            df = pd.read_csv(csv_path)
            
            # 检查内容列是否存在
            if content_column not in df.columns:
                print(f"内容列不存在: {content_column}")
                return False
                
            # 提取内容
            contents = df[content_column].dropna().tolist()
            
            # 添加到知识库
            from langchain.docstore.document import Document
            new_docs = [Document(page_content=content) for content in contents]
            
            if self.vector_store:
                self.vector_store.add_documents(new_docs)
            else:
                embeddings = OpenAIEmbeddings()
                self.vector_store = FAISS.from_documents(new_docs, embeddings)
                self.retrieval_qa = RetrievalQA.from_chain_type(
                    llm=self.llm,
                    chain_type="stuff",
                    retriever=self.vector_store.as_retriever()
                )
                
            print(f"成功从{csv_path}添加了{len(new_docs)}条知识")
            return True
        except Exception as e:
            print(f"从CSV添加知识失败: {e}")
            return False
            
    def answer_text_question(self, question):
        """回答文本问题"""
        try:
            # 构建提示词
            system_prompt = SystemMessage(content="你是一位天津杨柳青年画的专家，需要准确回答用户关于杨柳青年画的问题。")
            user_prompt = HumanMessage(content=question)
            
            # 如果有知识库，先从知识库检索
            if self.retrieval_qa:
                # 先进行检索增强
                retrieved_info = self.retrieval_qa.run(question)
                # 结合检索结果和原始问题进行回答
                combined_prompt = HumanMessage(content=f"基于以下信息回答问题:\n{retrieved_info}\n\n问题: {question}")
                response = self.llm([system_prompt, combined_prompt])
            else:
                # 直接使用LLM回答
                response = self.llm([system_prompt, user_prompt])
                
            return response.content
        except Exception as e:
            print(f"回答文本问题失败: {e}")
            return "抱歉，我暂时无法回答这个问题。"
            
    def answer_image_question(self, image_path, question):
        """回答关于图像的问题"""
        try:
            # 检查图像文件是否存在
            if not os.path.exists(image_path):
                return "图像文件不存在，请检查路径是否正确。"
                
            # 使用OpenAI的多模态API
            with open(image_path, "rb") as image_file:
                response = openai.ChatCompletion.create(
                    model="gpt-4-vision-preview",
                    messages=[
                        {
                            "role": "system",
                            "content": "你是一位天津杨柳青年画的专家，需要分析图像并回答用户关于这幅年画的问题。"
                        },
                        {
                            "role": "user",
                            "content": [
                                {"type": "text", "text": question},
                                {
                                    "type": "image_url",
                                    "image_url": {
                                        "url": f"data:image/jpeg;base64,{self._encode_image(image_path)}"
                                    }
                                }
                            ]
                        }
                    ],
                    max_tokens=300
                )
                
            return response["choices"][0]["message"]["content"]
        except Exception as e:
            print(f"回答图像问题失败: {e}")
            return "抱歉，分析图像时出现错误，无法回答这个问题。"
            
    def _encode_image(self, image_path):
        """将图像编码为base64"""
        import base64
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode('utf-8')
            
    def answer_multimodal_question(self, input_data, question):
        """回答多模态问题
        input_data: 可以是文本、图像路径或PIL Image对象
        """
        try:
            # 判断输入类型
            if isinstance(input_data, str):
                # 检查是否是图像路径
                image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp']
                if any(input_data.lower().endswith(ext) for ext in image_extensions):
                    return self.answer_image_question(input_data, question)
                else:
                    # 文本输入
                    combined_question = f"基于以下信息回答问题:\n{input_data}\n\n问题: {question}"
                    return self.answer_text_question(combined_question)
            elif isinstance(input_data, Image.Image):
                # PIL Image对象
                # 保存临时文件
                import tempfile
                with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as temp_file:
                    input_data.save(temp_file.name)
                    result = self.answer_image_question(temp_file.name, question)
                # 删除临时文件
                os.unlink(temp_file.name)
                return result
            else:
                return "不支持的输入类型，请提供文本或图像。"
        except Exception as e:
            print(f"回答多模态问题失败: {e}")
            return "抱歉，处理多模态输入时出现错误，无法回答这个问题。"
            
    def get_painting_interpretation(self, image_path):
        """获取年画的解释和分析"""
        question = "请分析这幅年画的风格、主题、寓意和艺术特点，并给出详细解释。"
        return self.answer_image_question(image_path, question)
        
    def get_painting_history(self, painting_name):
        """获取特定年画的历史背景"""
        question = f"请介绍'{painting_name}'这幅天津杨柳青年画的历史背景、创作年代、文化意义和艺术特色。"
        return self.answer_text_question(question)
        
    def chat_with_history(self, user_message, chat_history=None):
        """带历史记录的对话功能"""
        try:
            # 初始化对话历史
            if chat_history is None:
                chat_history = []
                
            # 构建消息列表
            messages = [
                SystemMessage(content="你是一位天津杨柳青年画的专家，需要准确回答用户关于杨柳青年画的问题。")
            ]
            
            # 添加历史记录
            for role, content in chat_history:
                if role == "user":
                    messages.append(HumanMessage(content=content))
                elif role == "assistant":
                    messages.append(AIMessage(content=content))
                    
            # 添加当前用户消息
            messages.append(HumanMessage(content=user_message))
            
            # 生成回答
            response = self.llm(messages)
            
            # 更新对话历史
            new_chat_history = chat_history + [
                ("user", user_message),
                ("assistant", response.content)
            ]
            
            return response.content, new_chat_history
        except Exception as e:
            print(f"对话失败: {e}")
            return "抱歉，对话过程中出现错误。", chat_history

if __name__ == "__main__":
    # 测试问答模型
    import sys
    
    # 检查是否提供了API密钥
    if len(sys.argv) > 1:
        api_key = sys.argv[1]
    else:
        api_key = os.environ.get("OPENAI_API_KEY")
        
    if not api_key:
        print("错误: 请提供OpenAI API密钥")
        sys.exit(1)
        
    # 创建问答模型实例
    qa_model = TianjinNewYearPaintingQAModel(openai_api_key=api_key)
    
    # 测试文本问答
    print("\n测试文本问答:")
    question1 = "天津杨柳青年画有哪些特点？"
    answer1 = qa_model.answer_text_question(question1)
    print(f"问题: {question1}")
    print(f"回答: {answer1}")
    
    question2 = "杨柳青年画的制作工艺包括哪些步骤？"
    answer2 = qa_model.answer_text_question(question2)
    print(f"\n问题: {question2}")
    print(f"回答: {answer2}")
    
    # 测试对话功能
    print("\n测试对话功能:")
    chat_history = []
    user_question = "天津杨柳青年画的主要题材有哪些？"
    response, chat_history = qa_model.chat_with_history(user_question, chat_history)
    print(f"用户: {user_question}")
    print(f"助手: {response}")
    
    follow_up = "能详细介绍一下吉祥喜庆类的年画吗？"
    response, chat_history = qa_model.chat_with_history(follow_up, chat_history)
    print(f"\n用户: {follow_up}")
    print(f"助手: {response}")
    
    # 注意：图像问答需要实际的图像文件，可以在实际使用时测试
    print("\n提示: 图像问答功能需要实际的图像文件，在实际使用时可以通过answer_image_question方法测试")