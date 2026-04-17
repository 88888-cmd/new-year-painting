from django.apps import AppConfig
from .sensitive_words import load_sensitive_words
from .rag import TongyiRAG

class MyappConfig(AppConfig):
    default_auto_field = 'django.db.models.AutoField'
    name = 'myapp'

    def ready(self):
        print('myapp start')

        # 初始化敏感词库
        load_sensitive_words()

        # 初始化RAG系统
        rag = TongyiRAG()
