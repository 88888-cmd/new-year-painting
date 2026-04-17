import os
from pathlib import Path
from typing import List, Union
import threading

from django.conf import settings

from langchain_core.documents import Document
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
from langchain_community.embeddings import DashScopeEmbeddings
from langchain_community.chat_models import ChatTongyi
from langchain_community.document_loaders import DirectoryLoader, TextLoader

from chromadb.config import Settings as chromadbSettings
from langchain_chroma import Chroma


class TongyiRAG:
    _instance = None
    _lock = threading.Lock()

    # 单例
    def __new__(cls):
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
                    cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if self._initialized:
            return
        # 是否已经初始化过
        self._initialized = True

        self.dashscope_api_key = settings.DASHSCOPE_API_KEY
        self.knowledge_base_path = settings.RAG_KNOWLEDGE_BASE_PATH
        self.persist_directory = settings.RAG_PERSIST_DIRECTORY
        self.collection_name = 'rag-chroma'

        self.embeddings = DashScopeEmbeddings(
            dashscope_api_key=self.dashscope_api_key,
            model="text-embedding-v1"
        )

        self.text_llm = ChatTongyi(
            api_key=self.dashscope_api_key,
            model="qwen-turbo"
        )

        self.multimodal_llm = ChatTongyi(
            api_key=self.dashscope_api_key,
            model="qwen-vl-plus"
        )

        self._initialize_vectorstore()


    def _initialize_vectorstore(self):
        print("正在初始化RAG系统")
        if os.path.exists(self.persist_directory):
            # 加载现有向量数据库
            self.vectorstore = Chroma(
                persist_directory=self.persist_directory,
                embedding_function=self.embeddings,
                collection_name=self.collection_name,
                client_settings=chromadbSettings(
                    is_persistent=True,
                    persist_directory=self.persist_directory,
                    anonymized_telemetry=False
                )
            )
        else:
            # 创建新的向量数据库
            self._build_knowledge_base()

        self.retriever = self.vectorstore.as_retriever(
            search_type="similarity",
            search_kwargs={"k": 3}
        )
        print("RAG系统初始化完成")

    def _build_knowledge_base(self):
        print("正在加载知识库")

        loader = DirectoryLoader(
            path=str(self.knowledge_base_path),
            glob="*.txt",
            loader_cls=TextLoader,
            loader_kwargs={"encoding": "utf-8"},
            show_progress=True
        )

        documents = loader.load()

        if not documents:
            print("加载的知识库文档为空")
            return

        for doc in documents:
            file_path = doc.metadata.get('source', '')
            painting_name = Path(file_path).stem
            doc.metadata.update({
                'painting_name': painting_name,
                'filename': Path(file_path).name
            })

        # 创建向量数据库，年画信息不涉及长文本所以不进行文档分割
        self.vectorstore = Chroma.from_documents(
            documents=documents,
            embedding=self.embeddings,
            persist_directory=self.persist_directory,
            collection_name=self.collection_name
        )
        print("知识库加载完成")

    def _format_docs(self, docs: List[Document]) -> str:
        if not docs:
            return ""

        formatted_docs = []
        for doc in docs:
            painting_name = doc.metadata.get('painting_name', '未知年画')
            content = doc.page_content.strip()
            formatted_docs.append(f"年画名称: {painting_name}\n内容:\n{content}")

        return "\n\n".join(formatted_docs)


    def _text_query_with_knowledge_base(self, question: str, message_history: List[Union[SystemMessage, HumanMessage, AIMessage]]) -> str:
        try:
            relevant_docs = self.retriever.invoke(question)
            context = self._format_docs(relevant_docs) if relevant_docs else "知识库中没有找到相关信息"

            system_prompt = f"""你是一个专业的年画信息查询助手。请根据以下知识库信息和历史对话回答用户问题。

重要规则：
1. 严格基于提供的知识库信息回答问题
2. 可以结合历史对话上下文理解用户意图
3. 如果知识库中没有相关信息，请明确说明"知识库中没有找到相关信息"
4. 回答要准确、简洁、有帮助
5. 可以提及相关的年画名称以便用户参考
6. 不要生成任何图片链接或URL
7. 专注于基于文本信息的准确回答

重要限制：
- 不要回答关于对话历史的问题（如"我第一次问了什么"、"之前聊了什么"、"我刚刚问了什么"等）
- 如果用户询问历史对话内容，请回复："抱歉，我无法查询之前的对话记录，请重新描述您的问题"

知识库信息：
{context}"""

            messages = [SystemMessage(content=system_prompt)]

            # 最近5轮对话
            recent_history = message_history[-10:] if len(message_history) > 10 else message_history

            for msg in recent_history:
                if isinstance(msg, HumanMessage):
                    if isinstance(msg.content, list):
                        text_parts = []
                        has_image = False
                        for content_item in msg.content:
                            if isinstance(content_item, dict):
                                if "text" in content_item:
                                    text_parts.append(content_item["text"])
                                elif "image" in content_item:
                                    has_image = True

                        if text_parts:
                            text_content = " ".join(text_parts)
                            if has_image:
                                text_content = f"[用户之前上传了图片并询问: {text_content}]"
                            messages.append(HumanMessage(content=text_content))
                    else:
                        messages.append(msg)
                else:
                    messages.append(msg)

            current_message = HumanMessage(content=question)
            messages.append(current_message)

            response = self.text_llm.invoke(messages)
            response_text = str(response.content).strip()

            # response.response_metadata.get('token_usage')

            return response_text

        except Exception as e:
            print(str(e))
            return 'Error'

    def _multimodal_query(self, question: str, image: str, message_history: List[Union[SystemMessage, HumanMessage, AIMessage]]) -> str:

        try:
            system_prompt = """你是一个专业的年画信息查询助手。请基于图片内容和历史对话回答用户问题。

重要规则：
1. 专注于图片内容的理解和分析
2. 结合历史对话上下文提供准确回答
3. 回答要准确、详细、有帮助
4. 不要生成任何图片链接或URL
5. 基于实际看到的图片内容进行描述和分析
6. 如果无法从图片中获取某些信息，请如实说明

重要限制：
- 不要回答关于对话历史的问题（如"我第一次问了什么"、"之前聊了什么"、"我刚刚问了什么"等）
- 如果用户询问历史对话内容，请回复："抱歉，我无法查询之前的对话记录，请重新描述您的问题"
"""

            messages = [SystemMessage(content=system_prompt)]

            # 最近5轮对话
            recent_history = message_history[-10:] if len(message_history) > 10 else message_history
            for msg in recent_history:
                if isinstance(msg, HumanMessage):
                    if isinstance(msg.content, list):
                        messages.append(msg)
                    else:
                        converted_message = HumanMessage(content=[
                            {"text": str(msg.content)}
                        ])
                        messages.append(converted_message)
                else:
                    messages.append(msg)

            current_message = HumanMessage(content=[
                {"text": question},
                {"image": image}
            ])

            messages.append(current_message)
            response = self.multimodal_llm.invoke(messages)

            return response.content[0].get('text').strip()

        except Exception as e:
            print(str(e))
            return 'Error'

    def query_with_history(self, question: str, image: str = None,
                           message_history: List[Union[SystemMessage, HumanMessage, AIMessage]] = None) -> str:

        if message_history is None:
            message_history = []

        try:
            # 用户是否上传图片
            current_has_image = image is not None
            # if current_has_image:
            #     current_message = HumanMessage(content=[
            #         {"text": question},
            #         {"image": image_url}
            #     ])
            # else:
            #     current_message = HumanMessage(content=question)

            if current_has_image:
                response = self._multimodal_query(question, image, message_history)
            else:
                response = self._text_query_with_knowledge_base(question, message_history)

            return response

        except Exception:
            return '查询过程中出现错误'

    # def process_query(self, user_input: str, message_history: List[Union[SystemMessage, HumanMessage, AIMessage]] = None) -> str:
    #
    #     if message_history is None:
    #         message_history = []
    #
    #     try:
    #         if user_input.strip().startswith('{') and user_input.strip().endswith('}'):
    #             try:
    #                 parsed_input = json.loads(user_input)
    #                 text = parsed_input.get('text', '')
    #                 img = parsed_input.get('img', '')
    #
    #                 return self.query_with_history(text, img, message_history)
    #
    #             except json.JSONDecodeError:
    #                 pass
    #
    #         return self.query_with_history(user_input, None, message_history)
    #
    #     except Exception:
    #         return '处理查询时出现错误'
